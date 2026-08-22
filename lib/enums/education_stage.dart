import '../l10n/app_strings.dart';

enum EducationStage { elementarySchool, highSchool }

enum CurriculumSource { bncc, editorial }

extension EducationStageLabel on EducationStage {
  String get shortLabel => switch (this) {
    EducationStage.elementarySchool => AppStrings.stageElementarySchoolShort,
    EducationStage.highSchool => AppStrings.stageHighSchoolShort,
  };

  String yearLabel(int year) => switch (this) {
    EducationStage.elementarySchool =>
      AppStrings.stageElementarySchoolYear(year),
    EducationStage.highSchool => AppStrings.stageHighSchoolYear(year),
  };
}
