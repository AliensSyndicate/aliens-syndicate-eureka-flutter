import { createHash } from 'node:crypto';
import { existsSync, mkdirSync, readFileSync, readdirSync, writeFileSync } from 'node:fs';
import { basename, dirname, join, relative, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';

const SUBJECTS = ['portuguese', 'mathematics', 'science', 'geography', 'history'];
const PAGE_TYPES = new Set([
  'hook', 'story', 'discovery', 'explanation', 'example', 'visual_example',
  'rule', 'curiosity', 'recap',
]);
const EXERCISE_TYPES = new Set([
  'multiple_choice', 'text_input', 'essay', 'fill_blank', 'ordering',
  'sequencing', 'matching', 'memory', 'true_false', 'image_choice',
  'word_completion',
]);
const TYPE_TO_RUNTIME = {
  multiple_choice: 'multipleChoice', text_input: 'textInput', essay: 'essay',
  fill_blank: 'fillBlank', ordering: 'ordering', sequencing: 'sequencing',
  matching: 'matching', memory: 'memory', true_false: 'trueFalse',
  image_choice: 'imageChoice', word_completion: 'wordCompletion',
};
const DIFFICULTY_TO_RUNTIME = { easy: 1, medium: 2, hard: 3 };
const RUNTIME_SCHEMA_VERSION = 1;

function contentVersion(catalog) {
  return catalog.content_version ?? catalog.catalog_version;
}

export class ContentValidationError extends Error {
  constructor(errors) {
    super(`Conteúdo inválido (${errors.length} erro(s)):\n- ${errors.join('\n- ')}`);
    this.name = 'ContentValidationError';
    this.errors = errors;
  }
}

function json(path) {
  try {
    return JSON.parse(readFileSync(path, 'utf8'));
  } catch (error) {
    throw new Error(`${path}: JSON inválido: ${error.message}`);
  }
}

function jsonFiles(directory) {
  if (!existsSync(directory)) return [];
  return readdirSync(directory, { withFileTypes: true }).flatMap((entry) => {
    const path = join(directory, entry.name);
    return entry.isDirectory() ? jsonFiles(path) : entry.name.endsWith('.json') ? [path] : [];
  });
}

function text(value) {
  return typeof value === 'string' && value.trim().length > 0;
}

function normalized(value) {
  return String(value ?? '').normalize('NFD').replace(/[\u0300-\u036f]/g, '').toLowerCase();
}

function array(value) {
  return Array.isArray(value) ? value : [];
}

function assert(errors, condition, location, message) {
  if (!condition) errors.push(`${location}: ${message}`);
}

function uniqueIds(errors, values, location) {
  const ids = values.map((value) => value?.id);
  assert(errors, ids.every(text), location, 'todos os itens devem possuir id.');
  assert(errors, new Set(ids).size === ids.length, location, 'IDs duplicados.');
}

function validateCatalog(catalog, errors) {
  assert(errors, [1, 2].includes(catalog.schema_version), 'catalog.json', 'schema_version deve ser 1 ou 2.');
  assert(errors, Number.isInteger(contentVersion(catalog)) && contentVersion(catalog) > 0,
    'catalog.json', 'content_version (ou catalog_version) deve ser inteiro positivo.');
  assert(errors, catalog.locale === 'pt-BR', 'catalog.json', 'locale deve ser pt-BR.');
  assert(errors, text(catalog.updated_at) && !Number.isNaN(Date.parse(catalog.updated_at)),
    'catalog.json', 'updated_at deve ser uma data ISO válida para builds reproduzíveis.');
  assert(errors, catalog.grade === 5, 'catalog.json', 'grade deve ser 5.');
  const subjects = array(catalog.subjects);
  uniqueIds(errors, subjects, 'catalog.json/subjects');
  const received = subjects.map((item) => item.subject ?? item.id).sort();
  assert(errors, received.length === SUBJECTS.length && SUBJECTS.every((id) => received.includes(id)),
    'catalog.json/subjects', `deve conter exatamente: ${SUBJECTS.join(', ')}.`);
  const lessonIds = [];
  for (const subject of subjects) {
    const subjectId = subject.subject ?? subject.id;
    assert(errors, SUBJECTS.includes(subjectId), `subject/${subjectId}`, 'matéria não permitida.');
    assert(errors, text(subject.title), `subject/${subjectId}`, 'title obrigatório.');
    const units = array(subject.units);
    assert(errors, units.length > 0, `subject/${subjectId}`, 'units não pode ser vazio.');
    uniqueIds(errors, units, `subject/${subjectId}/units`);
    for (const unit of units) {
      assert(errors, text(unit.title), `unit/${unit.id}`, 'title obrigatório.');
      const topics = array(unit.topics);
      assert(errors, topics.length > 0, `unit/${unit.id}`, 'topics não pode ser vazio.');
      uniqueIds(errors, topics, `unit/${unit.id}/topics`);
      for (const topic of topics) {
        assert(errors, text(topic.title), `topic/${topic.id}`, 'title obrigatório.');
        const refs = array(topic.lessons ?? topic.lesson_ids).map((item) => typeof item === 'string' ? item : item?.id);
        assert(errors, refs.length > 0 && refs.every(text), `topic/${topic.id}`, 'lessons deve listar IDs.');
        lessonIds.push(...refs.map((id) => ({ id, subjectId, unitId: unit.id, topicId: topic.id })));
      }
    }
  }
  assert(errors, new Set(lessonIds.map((item) => item.id)).size === lessonIds.length,
    'catalog.json', 'uma aula não pode aparecer mais de uma vez no catálogo.');
  return lessonIds;
}

function optionItems(parameters) {
  return array(parameters?.options);
}

function validateExercise(exercise, location, expectedUsage, errors) {
  assert(errors, text(exercise.id), location, 'id obrigatório.');
  assert(errors, exercise.usage === expectedUsage, location, `usage deve ser ${expectedUsage}.`);
  assert(errors, EXERCISE_TYPES.has(exercise.type), location, 'type inválido.');
  assert(errors, ['easy', 'medium', 'hard'].includes(exercise.difficulty), location, 'difficulty inválida.');
  assert(errors, text(exercise.statement), location, 'statement obrigatório.');
  assert(errors, text(exercise.instruction), location, 'instruction obrigatório.');
  assert(errors, exercise.parameters && typeof exercise.parameters === 'object' && !Array.isArray(exercise.parameters),
    location, 'parameters deve ser objeto.');
  assert(errors, exercise.correct_answer && typeof exercise.correct_answer === 'object' && !Array.isArray(exercise.correct_answer),
    location, 'correct_answer deve ser objeto.');
  assert(errors, text(exercise.correct_answer_explanation), location,
    'correct_answer_explanation obrigatório.');
  const explanation = normalized(exercise.correct_answer_explanation).replace(/[^a-z0-9 ]/g, ' ').replace(/\s+/g, ' ').trim();
  const tautologies = new Set([
    'porque essa e a resposta correta', 'essa e a resposta correta',
    'porque esta correta', 'a resposta esta correta', 'esta e a resposta correta',
  ]);
  assert(errors, explanation.length >= 30 && !tautologies.has(explanation), location,
    'correct_answer_explanation deve explicar o raciocínio, não apenas afirmar que a resposta está correta.');
  if (expectedUsage === 'simulator_explore') {
    const standaloneText = normalized(JSON.stringify({
      statement: exercise.statement, instruction: exercise.instruction, parameters: exercise.parameters,
    }));
    const forbidden = [
      /\bcomo vimos\b/, /\bna aula\b/, /\bacima\b/, /\banterior\b/, /\blembra\b/,
    ];
    assert(errors, !forbidden.some((pattern) => pattern.test(standaloneText)), location,
      'exercício simulator_explore deve ser autossuficiente e não referenciar aula ou conteúdo anterior.');
  }

  const parameters = exercise.parameters ?? {};
  const answer = exercise.correct_answer ?? {};
  const options = optionItems(parameters);
  if (exercise.type === 'multiple_choice' || exercise.type === 'image_choice') {
    assert(errors, options.length === 4, location, 'deve possuir exatamente 4 opções.');
    uniqueIds(errors, options, `${location}/parameters/options`);
    assert(errors, options.every((item) => text(item.text) || text(item.image)), location,
      'cada opção deve possuir text ou image.');
    assert(errors, text(answer.option_id) && options.some((item) => item.id === answer.option_id),
      location, 'correct_answer.option_id deve apontar para uma opção.');
  } else if (exercise.type === 'true_false') {
    assert(errors, typeof answer.value === 'boolean', location, 'correct_answer.value deve ser boolean.');
  } else if (exercise.type === 'text_input' || exercise.type === 'fill_blank' || exercise.type === 'word_completion') {
    const accepted = array(parameters.accepted_answers);
    assert(errors, accepted.length > 0 && accepted.every(text), location, 'accepted_answers não pode ser vazio.');
    assert(errors, text(answer.value) && accepted.includes(answer.value), location,
      'correct_answer.value deve estar em accepted_answers.');
    if (exercise.type !== 'text_input') {
      assert(errors, text(parameters.sentence) && parameters.sentence.includes('_'), location,
        'parameters.sentence deve possuir uma lacuna "_".');
    }
  } else if (exercise.type === 'ordering' || exercise.type === 'sequencing') {
    const items = array(parameters.items);
    uniqueIds(errors, items, `${location}/parameters/items`);
    assert(errors, items.length >= 2 && items.every((item) => text(item.text)), location,
      'items deve possuir ao menos 2 textos.');
    const ordered = array(answer.ordered_ids);
    assert(errors, ordered.length === items.length && new Set(ordered).size === ordered.length &&
      ordered.every((id) => items.some((item) => item.id === id)), location,
    'ordered_ids deve ser uma permutação completa de items.');
  } else if (exercise.type === 'matching' || exercise.type === 'memory') {
    const left = array(parameters.left_items);
    const right = array(parameters.right_items);
    uniqueIds(errors, left, `${location}/parameters/left_items`);
    uniqueIds(errors, right, `${location}/parameters/right_items`);
    assert(errors, left.length >= 2 && left.length === right.length, location,
      'left_items e right_items devem ter o mesmo tamanho (mínimo 2).');
    if (exercise.type === 'matching') assert(errors, left.length === 5, location, 'matching deve possuir 5 pares.');
    assert(errors, left.every((item) => text(item.text)) && right.every((item) => text(item.text)), location,
      'itens de associação devem possuir text.');
    const pairs = array(answer.pairs);
    assert(errors, pairs.length === left.length &&
      pairs.every((pair) => left.some((item) => item.id === pair.left_id) && right.some((item) => item.id === pair.right_id)) &&
      new Set(pairs.map((pair) => pair.left_id)).size === pairs.length &&
      new Set(pairs.map((pair) => pair.right_id)).size === pairs.length,
    location, 'pairs deve associar todos os itens uma única vez.');
  } else if (exercise.type === 'essay') {
    assert(errors, text(answer.value) || text(answer.model_answer), location,
      'essay exige correct_answer.value ou model_answer.');
  }
}

function validateLesson(lesson, catalogRef, errors) {
  const location = `lesson/${lesson.id ?? '?'}`;
  assert(errors, /^grade05_[a-z0-9]+(?:_[a-z0-9]+)+$/.test(lesson.id ?? ''), location,
    'id deve seguir grade05_subject_unit_topic_lesson, sem acentos ou espaços.');
  assert(errors, lesson.grade === 5, location, 'grade deve ser 5.');
  assert(errors, lesson.subject === catalogRef?.subjectId, location, 'subject diverge do catálogo.');
  assert(errors, lesson.unit === catalogRef?.unitId, location, 'unit diverge do catálogo.');
  assert(errors, lesson.topic === catalogRef?.topicId, location, 'topic diverge do catálogo.');
  for (const field of ['title', 'short_description']) assert(errors, text(lesson[field]), location, `${field} obrigatório.`);
  for (const field of ['bncc_codes', 'skills', 'learning_objectives', 'keywords', 'prerequisites']) {
    assert(errors, Array.isArray(lesson[field]) && lesson[field].every(text), location, `${field} deve ser lista de strings.`);
  }
  assert(errors, lesson.learning_objectives?.length >= 1 && lesson.learning_objectives?.length <= 4,
    location, 'learning_objectives deve ter de 1 a 4 itens.');
  assert(errors, Number.isInteger(lesson.estimated_minutes) && lesson.estimated_minutes > 0,
    location, 'estimated_minutes deve ser inteiro positivo.');
  assert(errors, ['easy', 'medium', 'hard'].includes(lesson.difficulty), location, 'difficulty inválida.');
  assert(errors, Number.isInteger(lesson.version) && lesson.version > 0, location, 'version deve ser inteiro positivo.');
  assert(errors, lesson.status === 'generated' || lesson.status === 'reviewed', location,
    'status deve ser generated ou reviewed.');
  const pages = array(lesson.content_pages);
  assert(errors, pages.length >= 4 && pages.length <= 7, location, 'content_pages deve ter de 4 a 7 páginas.');
  pages.forEach((page, index) => {
    const pageLocation = `${location}/content_pages/${index}`;
    assert(errors, page.page === index + 1, pageLocation, 'page deve ser sequencial, iniciando em 1.');
    assert(errors, PAGE_TYPES.has(page.type), pageLocation, 'type inválido.');
    assert(errors, text(page.title) && text(page.text) && text(page.key_concept), pageLocation,
      'title, text e key_concept são obrigatórios.');
    assert(errors, typeof page.visual_description === 'string', pageLocation,
      'visual_description deve ser string, podendo ser vazia.');
  });
  const practice = array(lesson.practice_exercises);
  const extra = array(lesson.extra_exercises);
  assert(errors, practice.length === 5, location, 'practice_exercises deve conter exatamente 5 exercícios.');
  assert(errors, extra.length === 3, location, 'extra_exercises deve conter exatamente 3 exercícios.');
  const practiceTypes = new Map();
  for (const exercise of practice) practiceTypes.set(exercise.type, (practiceTypes.get(exercise.type) ?? 0) + 1);
  assert(errors, [...practiceTypes.values()].every((count) => count <= 2), location,
    'practice_exercises pode ter no máximo 2 exercícios do mesmo tipo.');
  const difficultyCounts = Object.fromEntries(['easy', 'medium', 'hard'].map((value) => [value, practice.filter((item) => item.difficulty === value).length]));
  assert(errors, difficultyCounts.easy === 2 && difficultyCounts.medium === 2 && difficultyCounts.hard === 1,
    location, 'practice_exercises deve ter exatamente 2 easy, 2 medium e 1 hard.');
  practice.forEach((item, index) => validateExercise(item, `${location}/practice/${index}`, 'practice', errors));
  extra.forEach((item, index) => validateExercise(item, `${location}/extra/${index}`, 'simulator_explore', errors));
  uniqueIds(errors, [...practice, ...extra], `${location}/exercises`);
  assert(errors, lesson.skills.length > 0, location, 'skills não pode ser vazio.');
  assert(errors, lesson.keywords.length > 0, location, 'keywords não pode ser vazio.');
  if (pages.length > 0) {
    assert(errors, ['hook', 'story', 'discovery', 'curiosity'].includes(pages[0].type), location,
      'a primeira content_page deve ser hook, story, discovery ou curiosity.');
    assert(errors, pages.at(-1).type === 'recap', location, 'a última content_page deve ser recap.');
  }
}

function runtimeQuestion(exercise, lesson) {
  const parameters = exercise.parameters;
  const answer = exercise.correct_answer;
  const option = optionItems(parameters).find((item) => item.id === answer.option_id);
  const itemById = new Map(array(parameters.items).map((item) => [item.id, item.text]));
  const leftById = new Map(array(parameters.left_items).map((item) => [item.id, item.text]));
  const rightById = new Map(array(parameters.right_items).map((item) => [item.id, item.text]));
  const pairs = array(answer.pairs).map((pair) => ({
    left: leftById.get(pair.left_id), right: rightById.get(pair.right_id),
  }));
  let correctAnswer = answer.value ?? answer.model_answer ?? option?.text ?? '';
  if (exercise.type === 'true_false') correctAnswer = answer.value ? 'Verdadeiro' : 'Falso';
  if (exercise.type === 'ordering' || exercise.type === 'sequencing') {
    correctAnswer = answer.ordered_ids.map((id) => itemById.get(id)).join(' | ');
  } else if (exercise.type === 'matching' || exercise.type === 'memory') {
    correctAnswer = exercise.type === 'memory' ? '__memory_done__' : pairs.map((pair) => `${pair.left} — ${pair.right}`).join(' | ');
  }
  const result = {
    id: exercise.id, enabled: true, version: exercise.version ?? 1,
    usage: exercise.usage, type: TYPE_TO_RUNTIME[exercise.type],
    prompt: exercise.statement, instruction: exercise.instruction,
    options: exercise.type === 'true_false'
      ? ['Verdadeiro', 'Falso']
      : (exercise.type === 'ordering' || exercise.type === 'sequencing')
        ? array(parameters.items).map((item) => item.text)
        : optionItems(parameters).map((item) => item.text ?? item.image),
    correctAnswer, explanation: exercise.correct_answer_explanation,
    subjectId: lesson.subject, topicId: lesson.topic,
    difficulty: DIFFICULTY_TO_RUNTIME[exercise.difficulty],
    tags: array(exercise.tags), parameters, correct_answer: answer,
  };
  if (pairs.length) result.pairs = pairs;
  if (parameters.sentence) result.template = parameters.sentence;
  if (parameters.accepted_answers) result.acceptedAnswers = parameters.accepted_answers;
  return result;
}

function stableJson(value) {
  if (Array.isArray(value)) return `[${value.map(stableJson).join(',')}]`;
  if (value && typeof value === 'object') return `{${Object.keys(value).sort().map((key) => `${JSON.stringify(key)}:${stableJson(value[key])}`).join(',')}}`;
  return JSON.stringify(value);
}

export function checksum(value) {
  return createHash('sha256').update(stableJson(value)).digest('hex');
}

export function loadAndValidateSource(sourceDirectory) {
  const catalogPath = join(sourceDirectory, 'catalog.json');
  if (!existsSync(catalogPath)) throw new Error(`${catalogPath}: arquivo obrigatório ausente.`);
  const catalog = json(catalogPath);
  const errors = [];
  const refs = validateCatalog(catalog, errors);
  const files = jsonFiles(sourceDirectory).filter((path) => resolve(path) !== resolve(catalogPath));
  const lessons = files.flatMap((path) => {
    const document = json(path);
    const values = Array.isArray(document.lessons) ? document.lessons : [document];
    return values.map((lesson) => ({ lesson, path: relative(sourceDirectory, path) }));
  });
  const lessonIds = lessons.map(({ lesson }) => lesson.id);
  assert(errors, new Set(lessonIds).size === lessonIds.length, sourceDirectory, 'IDs de aula duplicados.');
  const refById = new Map(refs.map((ref) => [ref.id, ref]));
  for (const { lesson, path } of lessons) {
    assert(errors, refById.has(lesson.id), path, 'aula não referenciada no catálogo.');
    validateLesson(lesson, refById.get(lesson.id), errors);
  }
  for (const ref of refs) assert(errors, lessonIds.includes(ref.id), 'catalog.json', `aula ausente: ${ref.id}.`);
  const allExercises = lessons.flatMap(({ lesson }) => [
    ...array(lesson.practice_exercises), ...array(lesson.extra_exercises),
  ]);
  const exerciseIds = allExercises.map((exercise) => exercise.id).filter(text);
  assert(errors, new Set(exerciseIds).size === exerciseIds.length, sourceDirectory,
    'IDs de exercício devem ser globalmente únicos em toda a release.');
  const known = new Set(lessonIds);
  for (const { lesson } of lessons) {
    for (const prerequisite of array(lesson.prerequisites)) {
      assert(errors, known.has(prerequisite), `lesson/${lesson.id}`, `pré-requisito inexistente: ${prerequisite}.`);
      assert(errors, prerequisite !== lesson.id, `lesson/${lesson.id}`, 'aula não pode depender de si própria.');
    }
  }
  const prerequisites = new Map(lessons.map(({ lesson }) => [lesson.id, array(lesson.prerequisites)]));
  const visiting = new Set();
  const visited = new Set();
  function visit(id, path = []) {
    if (visiting.has(id)) {
      errors.push(`lesson/${id}: ciclo de pré-requisitos: ${[...path, id].join(' -> ')}.`);
      return;
    }
    if (visited.has(id)) return;
    visiting.add(id);
    for (const dependency of prerequisites.get(id) ?? []) {
      if (known.has(dependency)) visit(dependency, [...path, id]);
    }
    visiting.delete(id);
    visited.add(id);
  }
  for (const id of known) visit(id);
  if (errors.length) throw new ContentValidationError(errors);
  return { catalog, lessons: lessons.map(({ lesson }) => lesson), refs };
}

function buildArtifacts(source) {
  const { catalog, lessons, refs } = source;
  const lessonById = new Map(lessons.map((lesson) => [lesson.id, lesson]));
  const activityDocuments = [];
  const activityByLesson = new Map();
  for (const lesson of lessons) {
    const activityId = `${lesson.id}_v${lesson.version}`;
    const payload = {
      id: activityId, schemaVersion: RUNTIME_SCHEMA_VERSION,
      contentVersion: contentVersion(catalog), activityVersion: lesson.version,
      lessonId: lesson.id, subjectId: lesson.subject, topicId: lesson.topic,
      schoolYear: 5, summary: lesson.short_description,
      contentPages: lesson.content_pages, learningObjectives: lesson.learning_objectives,
      skills: lesson.skills, keywords: lesson.keywords,
      questions: [...lesson.practice_exercises, ...lesson.extra_exercises].map((item) => runtimeQuestion(item, lesson)),
    };
    const digest = checksum(payload);
    const document = {
      id: activityId, published: true, enabled: true,
      schemaVersion: RUNTIME_SCHEMA_VERSION, contentVersion: contentVersion(catalog),
      activityVersion: lesson.version, checksum: digest, payload,
    };
    activityDocuments.push(document);
    activityByLesson.set(lesson.id, { id: activityId, version: lesson.version, checksum: digest, order: 0 });
  }
  const subjects = catalog.subjects.map((subject, subjectOrder) => ({
    id: subject.subject ?? subject.id, title: subject.title,
    type: subject.subject ?? subject.id, order: subject.order ?? subjectOrder,
    schoolYears: [{
      id: `${subject.subject ?? subject.id}_ef_5`, year: 5,
      educationStage: 'elementarySchool', curriculumSource: 'bncc',
      title: '5º ano', order: 0, enabled: true,
      lessons: subject.units.flatMap((unit) => unit.topics.flatMap((topic) => (topic.lessons ?? topic.lesson_ids).map((rawId) => {
        const id = typeof rawId === 'string' ? rawId : rawId.id;
        const lesson = lessonById.get(id);
        return {
          id, title: lesson.title, summary: lesson.short_description,
          unitId: unit.id, unitTitle: unit.title, topicId: topic.id, topicTitle: topic.title,
          skillId: lesson.skills[0] ?? null, prerequisiteLessonIds: lesson.prerequisites,
          activities: [activityByLesson.get(id)],
        };
      }))),
    }],
  }));
  const payload = {
    schemaVersion: RUNTIME_SCHEMA_VERSION, contentVersion: contentVersion(catalog),
    locale: catalog.locale, updatedAt: catalog.updated_at, subjects,
  };
  const manifestDocument = {
    id: `v${contentVersion(catalog)}`, published: true, enabled: true,
    schemaVersion: RUNTIME_SCHEMA_VERSION, contentVersion: contentVersion(catalog),
    checksum: checksum(payload), payload,
  };
  return { manifestDocument, activityDocuments };
}

function writeJson(path, value) {
  mkdirSync(dirname(path), { recursive: true });
  writeFileSync(path, `${JSON.stringify(value, null, 2)}\n`);
}

export function compileContent({ sourceDirectory, outputDirectory }) {
  const source = loadAndValidateSource(sourceDirectory);
  const artifacts = buildArtifacts(source);
  const releaseDirectory = join(outputDirectory, `v${contentVersion(source.catalog)}`);
  writeJson(join(releaseDirectory, 'content_manifest.json'), artifacts.manifestDocument);
  for (const document of artifacts.activityDocuments) {
    writeJson(join(releaseDirectory, 'activities', `${document.id}.json`), document);
  }
  writeJson(join(releaseDirectory, 'release.json'), {
    schemaVersion: RUNTIME_SCHEMA_VERSION,
    sourceSchemaVersion: source.catalog.schema_version,
    contentVersion: contentVersion(source.catalog),
    manifest: 'content_manifest.json',
    activities: artifacts.activityDocuments.map((item) => `activities/${item.id}.json`),
  });
  return { releaseDirectory, lessonCount: source.lessons.length, activityCount: artifacts.activityDocuments.length };
}

export function validateRelease(releaseDirectory) {
  const release = json(join(releaseDirectory, 'release.json'));
  const manifest = json(join(releaseDirectory, release.manifest));
  const errors = [];
  assert(errors, manifest.published === true && manifest.enabled === true, 'manifest', 'deve estar publicado e habilitado.');
  assert(errors, manifest.id === `v${release.contentVersion}`, 'manifest', 'id divergente da release.');
  assert(errors, manifest.contentVersion === release.contentVersion, 'manifest', 'contentVersion divergente.');
  assert(errors, checksum(manifest.payload) === manifest.checksum, 'manifest', 'checksum inválido.');
  const references = manifest.payload.subjects.flatMap((subject) => subject.schoolYears.flatMap((year) => year.lessons.flatMap((lesson) => lesson.activities)));
  const activities = array(release.activities).map((path) => json(join(releaseDirectory, path)));
  uniqueIds(errors, activities, 'release/activities');
  assert(errors, references.length === activities.length, 'release', 'quantidade de referências e atividades diverge.');
  const byId = new Map(activities.map((item) => [item.id, item]));
  for (const reference of references) {
    const document = byId.get(reference.id);
    assert(errors, Boolean(document), `activity/${reference.id}`, 'arquivo ausente.');
    if (!document) continue;
    assert(errors, document.published === true && document.enabled === true, `activity/${reference.id}`, 'deve estar publicada e habilitada.');
    assert(errors, document.activityVersion === reference.version, `activity/${reference.id}`, 'versão divergente.');
    assert(errors, checksum(document.payload) === reference.checksum && reference.checksum === document.checksum,
      `activity/${reference.id}`, 'checksum divergente.');
    const questions = document.payload.questions;
    assert(errors, questions.length === 8, `activity/${reference.id}`, 'deve possuir 8 questões.');
    assert(errors, questions.filter((item) => item.usage === 'practice').length === 5,
      `activity/${reference.id}`, 'deve possuir 5 questões practice.');
    assert(errors, questions.filter((item) => item.usage === 'simulator_explore').length === 3,
      `activity/${reference.id}`, 'deve possuir 3 questões simulator_explore.');
  }
  if (errors.length) throw new ContentValidationError(errors);
  return { release, manifest, activities };
}

function argumentsMap(argv) {
  const result = {};
  for (let index = 0; index < argv.length; index += 1) {
    if (!argv[index].startsWith('--')) continue;
    result[argv[index].slice(2)] = argv[index + 1]?.startsWith('--') ? true : argv[++index] ?? true;
  }
  return result;
}

export function runContentPipelineCli(argv = process.argv.slice(2)) {
  try {
    const args = argumentsMap(argv);
    const sourceDirectory = resolve(String(args.source ?? 'firebase/content/source/grade05'));
    const outputDirectory = resolve(String(args.output ?? 'firebase/content/releases'));
    if (args['validate-release']) {
      const result = validateRelease(resolve(String(args['validate-release'])));
      process.stdout.write(`Release v${result.release.contentVersion} válida: ${result.activities.length} atividade(s).\n`);
    } else {
      const result = compileContent({ sourceDirectory, outputDirectory });
      process.stdout.write(`Release gerada em ${result.releaseDirectory}: ${result.lessonCount} aula(s), ${result.activityCount} atividade(s).\n`);
    }
  } catch (error) {
    process.stderr.write(`${error.message}\n`);
    process.exitCode = 1;
  }
}

const invokedPath = process.argv[1] ? resolve(process.argv[1]) : '';
if (invokedPath === fileURLToPath(import.meta.url)) runContentPipelineCli();
