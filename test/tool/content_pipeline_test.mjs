import assert from 'node:assert/strict';
import { mkdtempSync, readFileSync, writeFileSync, mkdirSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import test from 'node:test';
import { compileContent, ContentValidationError, loadAndValidateSource, validateRelease } from '../../tool/content_pipeline.mjs';

const subjects = ['portuguese', 'mathematics', 'science', 'geography', 'history'];

function exercise(id, usage, type = 'true_false', difficulty = 'easy') {
  const variants = {
    true_false: { parameters: {}, correct_answer: { value: true } },
    essay: { parameters: {}, correct_answer: { model_answer: 'Uma resposta-modelo completa.' } },
    text_input: {
      parameters: { accepted_answers: ['conceito'], case_sensitive: false, ignore_accents: false },
      correct_answer: { value: 'conceito' },
    },
  };
  return {
    id, usage, type, difficulty,
    statement: 'O enunciado é verdadeiro.', instruction: 'Marque verdadeiro ou falso.',
    ...variants[type],
    correct_answer_explanation: 'A afirmação apresenta corretamente o conceito avaliado.',
  };
}

function fixture() {
  const source = mkdtempSync(join(tmpdir(), 'eureka-content-source-'));
  const catalog = {
    schema_version: 1, content_version: 9, locale: 'pt-BR', grade: 5,
    updated_at: '2026-08-21T00:00:00.000Z',
    subjects: subjects.map((subject, index) => ({
      id: subject, subject, title: `Matéria ${index + 1}`,
      units: [{ id: `unit_${subject}`, title: 'Unidade', topics: [{
        id: `topic_${subject}`, title: 'Tópico', lessons: [`grade05_${subject}_unit_topic_lesson`],
      }] }],
    })),
  };
  writeFileSync(join(source, 'catalog.json'), JSON.stringify(catalog));
  mkdirSync(join(source, 'lessons'));
  for (const subject of subjects) {
    const id = `grade05_${subject}_unit_topic_lesson`;
    const lesson = {
      id, grade: 5, subject, unit: `unit_${subject}`, topic: `topic_${subject}`,
      title: 'Uma aula válida', short_description: 'Descrição curta da aula.',
      bncc_codes: [], skills: ['identify_concept'],
      learning_objectives: ['Identificar o conceito estudado.'], estimated_minutes: 12,
      content_pages: Array.from({ length: 4 }, (_, index) => ({
        page: index + 1, type: ['hook', 'discovery', 'explanation', 'recap'][index],
        title: `Página ${index + 1}`, text: 'Texto pedagógico claro e objetivo.',
        visual_description: '', key_concept: 'Conceito principal.',
      })),
      practice_exercises: [
        exercise(`${id}_practice_1`, 'practice', 'true_false', 'easy'),
        exercise(`${id}_practice_2`, 'practice', 'text_input', 'easy'),
        exercise(`${id}_practice_3`, 'practice', 'essay', 'medium'),
        exercise(`${id}_practice_4`, 'practice', 'true_false', 'medium'),
        exercise(`${id}_practice_5`, 'practice', 'essay', 'hard'),
      ],
      extra_exercises: Array.from({ length: 3 }, (_, index) => exercise(`${id}_extra_${index + 1}`, 'simulator_explore')),
      keywords: ['conceito'], prerequisites: [], difficulty: 'easy', version: 1, status: 'reviewed',
    };
    writeFileSync(join(source, 'lessons', `${id}.json`), JSON.stringify(lesson));
  }
  return source;
}

test('compila fonte mestre em release compatível e reproduzível', () => {
  const sourceDirectory = fixture();
  const outputDirectory = mkdtempSync(join(tmpdir(), 'eureka-content-release-'));
  const result = compileContent({ sourceDirectory, outputDirectory });
  assert.equal(result.lessonCount, 5);
  const release = validateRelease(result.releaseDirectory);
  assert.equal(release.activities.length, 5);
  assert.equal(release.manifest.payload.subjects.length, 5);
  assert.deepEqual(release.activities[0].payload.questions.map((item) => item.usage), [
    'practice', 'practice', 'practice', 'practice', 'practice',
    'simulator_explore', 'simulator_explore', 'simulator_explore',
  ]);
  const first = readFileSync(join(result.releaseDirectory, 'content_manifest.json'), 'utf8');
  compileContent({ sourceDirectory, outputDirectory });
  assert.equal(readFileSync(join(result.releaseDirectory, 'content_manifest.json'), 'utf8'), first);
});

test('rejeita aula que não possui exatamente cinco exercícios de prática', () => {
  const sourceDirectory = fixture();
  const path = join(sourceDirectory, 'lessons', 'grade05_portuguese_unit_topic_lesson.json');
  const lesson = JSON.parse(readFileSync(path, 'utf8'));
  lesson.practice_exercises.pop();
  writeFileSync(path, JSON.stringify(lesson));
  assert.throws(() => loadAndValidateSource(sourceDirectory), (error) => {
    assert.ok(error instanceof ContentValidationError);
    assert.match(error.message, /exatamente 5 exercícios/);
    return true;
  });
});

test('rejeita distribuição editorial inválida nas práticas', () => {
  const sourceDirectory = fixture();
  const path = join(sourceDirectory, 'lessons', 'grade05_portuguese_unit_topic_lesson.json');
  const lesson = JSON.parse(readFileSync(path, 'utf8'));
  lesson.practice_exercises[2].type = 'true_false';
  lesson.practice_exercises[2].parameters = {};
  lesson.practice_exercises[2].correct_answer = { value: true };
  lesson.practice_exercises[4].difficulty = 'medium';
  writeFileSync(path, JSON.stringify(lesson));
  assert.throws(() => loadAndValidateSource(sourceDirectory), (error) => {
    assert.match(error.message, /no máximo 2 exercícios do mesmo tipo/);
    assert.match(error.message, /exatamente 2 easy, 2 medium e 1 hard/);
    return true;
  });
});

test('rejeita extra dependente da aula e explicação tautológica', () => {
  const sourceDirectory = fixture();
  const path = join(sourceDirectory, 'lessons', 'grade05_portuguese_unit_topic_lesson.json');
  const lesson = JSON.parse(readFileSync(path, 'utf8'));
  lesson.extra_exercises[0].statement = 'Como vimos na aula anterior, o enunciado é verdadeiro.';
  lesson.extra_exercises[0].correct_answer_explanation = 'Essa é a resposta correta.';
  writeFileSync(path, JSON.stringify(lesson));
  assert.throws(() => loadAndValidateSource(sourceDirectory), (error) => {
    assert.match(error.message, /deve ser autossuficiente/);
    assert.match(error.message, /deve explicar o raciocínio/);
    return true;
  });
});

test('rejeita IDs de exercício repetidos entre aulas', () => {
  const sourceDirectory = fixture();
  const portuguesePath = join(sourceDirectory, 'lessons', 'grade05_portuguese_unit_topic_lesson.json');
  const mathPath = join(sourceDirectory, 'lessons', 'grade05_mathematics_unit_topic_lesson.json');
  const portuguese = JSON.parse(readFileSync(portuguesePath, 'utf8'));
  const mathematics = JSON.parse(readFileSync(mathPath, 'utf8'));
  mathematics.extra_exercises[0].id = portuguese.practice_exercises[0].id;
  writeFileSync(mathPath, JSON.stringify(mathematics));
  assert.throws(() => loadAndValidateSource(sourceDirectory), /globalmente únicos/);
});

test('rejeita páginas sem abertura pedagógica, recap final ou metadados de busca', () => {
  const sourceDirectory = fixture();
  const path = join(sourceDirectory, 'lessons', 'grade05_portuguese_unit_topic_lesson.json');
  const lesson = JSON.parse(readFileSync(path, 'utf8'));
  lesson.content_pages[0].type = 'rule';
  lesson.content_pages.at(-1).type = 'example';
  lesson.skills = [];
  lesson.keywords = [];
  writeFileSync(path, JSON.stringify(lesson));
  assert.throws(() => loadAndValidateSource(sourceDirectory), (error) => {
    assert.match(error.message, /primeira content_page/);
    assert.match(error.message, /última content_page/);
    assert.match(error.message, /skills não pode ser vazio/);
    assert.match(error.message, /keywords não pode ser vazio/);
    return true;
  });
});
