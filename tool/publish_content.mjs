import { execFileSync } from 'node:child_process';
import { readFileSync, statSync } from 'node:fs';

const projectId = process.argv[2] ?? 'eureka-9675a';
const base = `https://firestore.googleapis.com/v1/projects/${projectId}/databases/(default)/documents`;
const token = execFileSync('gcloud', ['auth', 'print-access-token'], { encoding: 'utf8' }).trim();

function value(input) {
  if (input === null) return { nullValue: null };
  if (typeof input === 'string') return { stringValue: input };
  if (typeof input === 'boolean') return { booleanValue: input };
  if (Number.isInteger(input)) return { integerValue: String(input) };
  if (typeof input === 'number') return { doubleValue: input };
  if (Array.isArray(input)) return { arrayValue: { values: input.map(value) } };
  return { mapValue: { fields: fields(input) } };
}

function fields(input) {
  return Object.fromEntries(Object.entries(input).map(([key, item]) => [key, value(item)]));
}

async function publish(collection, id, path) {
  if (statSync(path).size > 900_000) throw new Error(`${path} excede o limite seguro de 900 KB.`);
  const json = JSON.parse(readFileSync(path, 'utf8'));
  const response = await fetch(`${base}/${collection}/${id}`, {
    method: 'PATCH',
    headers: { Authorization: `Bearer ${token}`, 'Content-Type': 'application/json' },
    body: JSON.stringify({ fields: fields(json) }),
  });
  if (!response.ok) throw new Error(`${collection}/${id}: ${response.status} ${await response.text()}`);
  process.stdout.write(`Publicado: ${collection}/${id}\n`);
}

// As atividades são publicadas antes; o manifesto vira a troca atômica final.
await publish('content_activities', 'fractions_intro_v1', 'firebase/content/fractions_intro_v1.json');
await publish('content_activities', 'text_genres_v1', 'firebase/content/text_genres_v1.json');
await publish('content_activities', 'water_cycle_v1', 'firebase/content/water_cycle_v1.json');
await publish('content_manifests', 'current', 'firebase/content/content_manifest.json');
