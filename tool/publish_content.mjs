import { execFileSync } from 'node:child_process';
import { resolve } from 'node:path';
import { compileContent, validateRelease } from './content_pipeline.mjs';

function parseArguments(argv) {
  const result = { validateOnly: false };
  for (let index = 0; index < argv.length; index += 1) {
    const argument = argv[index];
    if (argument === '--validate-only') result.validateOnly = true;
    else if (argument === '--project') result.projectId = argv[++index];
    else if (argument === '--release') result.releaseDirectory = argv[++index];
    else if (argument === '--source') result.sourceDirectory = argv[++index];
    else if (argument === '--output') result.outputDirectory = argv[++index];
    else if (!argument.startsWith('--') && !result.projectId) result.projectId = argument;
    else throw new Error(`Argumento desconhecido: ${argument}`);
  }
  return result;
}

function firestoreValue(input) {
  if (input === null) return { nullValue: null };
  if (typeof input === 'string') return { stringValue: input };
  if (typeof input === 'boolean') return { booleanValue: input };
  if (Number.isInteger(input)) return { integerValue: String(input) };
  if (typeof input === 'number') return { doubleValue: input };
  if (Array.isArray(input)) return { arrayValue: { values: input.map(firestoreValue) } };
  return { mapValue: { fields: firestoreFields(input) } };
}

function firestoreFields(input) {
  return Object.fromEntries(Object.entries(input).map(([key, item]) => [key, firestoreValue(item)]));
}

function field(document, name) {
  const value = document?.fields?.[name];
  if (!value) return undefined;
  if ('integerValue' in value) return Number(value.integerValue);
  if ('stringValue' in value) return value.stringValue;
  if ('booleanValue' in value) return value.booleanValue;
  return undefined;
}

async function request(url, options = {}, expected = [200]) {
  const response = await fetch(url, options);
  if (!expected.includes(response.status)) {
    throw new Error(`${options.method ?? 'GET'} ${url}: ${response.status} ${await response.text()}`);
  }
  return response.status === 204 ? null : response.json();
}

function encodedBody(document) {
  const body = JSON.stringify({ fields: firestoreFields(document) });
  if (Buffer.byteLength(body) > 900_000) throw new Error(`${document.id}: excede o limite seguro de 900 KB.`);
  return body;
}

async function getDocument(base, token, collection, id) {
  const response = await fetch(`${base}/${collection}/${encodeURIComponent(id)}`, {
    headers: { Authorization: `Bearer ${token}` },
  });
  if (response.status === 404) return null;
  if (!response.ok) throw new Error(`GET ${collection}/${id}: ${response.status} ${await response.text()}`);
  return response.json();
}

async function createImmutable(base, token, collection, document) {
  const existing = await getDocument(base, token, collection, document.id);
  if (existing) {
    if (field(existing, 'checksum') !== document.checksum) {
      throw new Error(`${collection}/${document.id} já existe com conteúdo diferente; IDs de release são imutáveis.`);
    }
    process.stdout.write(`Verificado: ${collection}/${document.id}\n`);
    return;
  }
  const url = `${base}/${collection}?documentId=${encodeURIComponent(document.id)}`;
  await request(url, {
    method: 'POST',
    headers: { Authorization: `Bearer ${token}`, 'Content-Type': 'application/json' },
    body: encodedBody(document),
  });
  process.stdout.write(`Publicado: ${collection}/${document.id}\n`);
}

async function promoteCurrent(base, token, manifest, current) {
  const currentUrl = `${base}/content_manifests/current`;
  const precondition = current
    ? `currentDocument.updateTime=${encodeURIComponent(current.updateTime)}`
    : 'currentDocument.exists=false';
  const promoted = { ...manifest, releaseId: manifest.id };
  await request(`${currentUrl}?${precondition}`, {
    method: 'PATCH',
    headers: { Authorization: `Bearer ${token}`, 'Content-Type': 'application/json' },
    body: encodedBody(promoted),
  });
  process.stdout.write(`Promovido: content_manifests/current -> ${manifest.id}\n`);
}

async function main() {
  const args = parseArguments(process.argv.slice(2));
  let releaseDirectory = args.releaseDirectory ? resolve(args.releaseDirectory) : null;
  if (!releaseDirectory) {
    const compiled = compileContent({
      sourceDirectory: resolve(args.sourceDirectory ?? 'firebase/content/source/grade05'),
      outputDirectory: resolve(args.outputDirectory ?? 'firebase/content/releases'),
    });
    releaseDirectory = compiled.releaseDirectory;
  }
  const { release, manifest, activities } = validateRelease(releaseDirectory);
  process.stdout.write(`Release v${release.contentVersion} válida: ${activities.length} atividade(s).\n`);
  if (args.validateOnly) return;
  if (!args.projectId) throw new Error('Informe o projeto explicitamente com --project <project-id>.');

  const token = execFileSync('gcloud', ['auth', 'print-access-token'], { encoding: 'utf8' }).trim();
  if (!token) throw new Error('gcloud não retornou um token de acesso.');
  const base = `https://firestore.googleapis.com/v1/projects/${args.projectId}/databases/(default)/documents`;
  const current = await getDocument(base, token, 'content_manifests', 'current');
  const currentVersion = field(current, 'contentVersion');
  const currentChecksum = field(current, 'checksum');
  if (currentVersion === release.contentVersion && currentChecksum === manifest.checksum) {
    process.stdout.write(`Release v${release.contentVersion} já está promovida.\n`);
    return;
  }
  if (Number.isInteger(currentVersion) && release.contentVersion <= currentVersion) {
    throw new Error(`contentVersion ${release.contentVersion} deve ser maior que a versão publicada ${currentVersion}.`);
  }

  // Nada é promovido antes de todos os blobs imutáveis estarem disponíveis.
  for (const activity of activities) await createImmutable(base, token, 'content_activities', activity);
  await createImmutable(base, token, 'content_manifests', manifest);
  await promoteCurrent(base, token, manifest, current);
}

main().catch((error) => {
  process.stderr.write(`${error.message}\n`);
  process.exitCode = 1;
});
