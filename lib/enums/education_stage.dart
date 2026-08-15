enum EducationStage { elementarySchool, highSchool }

enum CurriculumSource { bncc, editorial }

extension EducationStageLabel on EducationStage {
  String get shortLabel => switch (this) {
    EducationStage.elementarySchool => 'EF',
    EducationStage.highSchool => 'EM',
  };

  String yearLabel(int year) => switch (this) {
    EducationStage.elementarySchool => '$yearº ano EF',
    EducationStage.highSchool => '$yearª série EM',
  };
}
