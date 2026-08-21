class ContentPage {
  const ContentPage({
    required this.page,
    required this.type,
    required this.title,
    required this.text,
    this.visualDescription = '',
    this.keyConcept = '',
  });

  final int page;
  final String type;
  final String title;
  final String text;
  final String visualDescription;
  final String keyConcept;
}
