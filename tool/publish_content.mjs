import { execFileSync } from 'node:child_process';
import { readFileSync } from 'node:fs';

const validateOnly = process.argv.includes('--validate-only');
const projectId = process.argv.slice(2).find((argument) => !argument.startsWith('--')) ?? 'eureka-9675a';
const base = `https://firestore.googleapis.com/v1/projects/${projectId}/databases/(default)/documents`;
let token;

function readJson(path) {
  return JSON.parse(readFileSync(path, 'utf8'));
}

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
  return Object.fromEntries(
    Object.entries(input).map(([key, item]) => [key, value(item)]),
  );
}

async function publish(collection, id, document) {
  const body = JSON.stringify({ fields: fields(document) });
  if (Buffer.byteLength(body) > 900_000) {
    throw new Error(`${collection}/${id} excede o limite seguro de 900 KB.`);
  }
  const response = await fetch(`${base}/${collection}/${id}`, {
    method: 'PATCH',
    headers: {
      Authorization: `Bearer ${token}`,
      'Content-Type': 'application/json',
    },
    body,
  });
  if (!response.ok) {
    throw new Error(
      `${collection}/${id}: ${response.status} ${await response.text()}`,
    );
  }
  process.stdout.write(`Publicado: ${collection}/${id}\n`);
}

const manifestDocument = readJson('firebase/content/content_manifest.json');
const manifest = manifestDocument.payload;
const enabledSubjects = [];
const enabledLessons = [];

for (const subject of manifest.subjects) {
  const schoolYears = subject.schoolYears.filter((year) => year.enabled);
  if (schoolYears.length === 0) continue;
  const subjectDocument = {
    id: subject.id,
    published: true,
    enabled: true,
    schemaVersion: manifest.schemaVersion,
    contentVersion: manifest.contentVersion,
    updatedAt: manifest.updatedAt,
    payload: {
      id: subject.id,
      title: subject.title,
      type: subject.type,
      order: subject.order,
      schoolYears: schoolYears.map((year) => year.id),
    },
  };
  enabledSubjects.push(subjectDocument);

  for (const schoolYear of schoolYears) {
    for (const lesson of schoolYear.lessons) {
      enabledLessons.push({
        id: lesson.id,
        published: true,
        enabled: true,
        schemaVersion: manifest.schemaVersion,
        contentVersion: manifest.contentVersion,
        updatedAt: manifest.updatedAt,
        payload: {
          ...lesson,
          id: lesson.id,
          subjectId: subject.id,
          schoolYearId: schoolYear.id,
          schoolYear: schoolYear.year,
          educationStage: schoolYear.educationStage,
          order: schoolYear.lessons.indexOf(lesson),
        },
      });
    }
  }
}

const subjectIds = new Set(enabledSubjects.map((subject) => subject.id));
const lessonIds = new Set(enabledLessons.map((lesson) => lesson.id));
if (subjectIds.size !== enabledSubjects.length) throw new Error('IDs de matéria duplicados.');
if (lessonIds.size !== enabledLessons.length) throw new Error('IDs de conteúdo duplicados.');

const activityIds = new Set();
const activityDocuments = [];
for (const lesson of enabledLessons) {
  for (const reference of lesson.payload.activities) {
    if (activityIds.has(reference.id)) throw new Error(`Atividade duplicada: ${reference.id}`);
    const document = readJson(`firebase/content/${reference.id}.json`);
    if (document.id !== reference.id || document.payload.id !== reference.id) {
      throw new Error(`ID divergente na atividade ${reference.id}.`);
    }
    if (document.payload.lessonId !== lesson.id) {
      throw new Error(`lessonId divergente na atividade ${reference.id}.`);
    }
    if (document.payload.subjectId !== lesson.payload.subjectId) {
      throw new Error(`subjectId divergente na atividade ${reference.id}.`);
    }
    if (document.payload.activityVersion !== reference.version) {
      throw new Error(`Versão divergente na atividade ${reference.id}.`);
    }
    const questions = document.payload.questions.filter(
      (question) => question.enabled,
    );
    if (questions.length !== 10) {
      throw new Error(`Atividade ${reference.id} deve ter 10 questões habilitadas.`);
    }
    if (new Set(questions.map((question) => question.id)).size !== 10) {
      throw new Error(`Atividade ${reference.id} possui IDs de questão duplicados.`);
    }
    activityIds.add(reference.id);
    activityDocuments.push(document);
  }
}

if (validateOnly) {
  process.stdout.write(
    `Catálogo válido: ${enabledSubjects.length} matérias, ${enabledLessons.length} conteúdos e ${activityDocuments.length} atividades.\n`,
  );
  process.exit(0);
}

token = execFileSync('gcloud', ['auth', 'print-access-token'], {
  encoding: 'utf8',
}).trim();

for (const subject of enabledSubjects) await publish('subjects', subject.id, subject);
for (const lesson of enabledLessons) await publish('lessons', lesson.id, lesson);
for (const activity of activityDocuments) {
  await publish('content_activities', activity.id, activity);
}
await publish('content_manifests', 'current', manifestDocument);
