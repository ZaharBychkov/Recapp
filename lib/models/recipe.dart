class Recipe {
  int id;
  String title;
  String description;
  int prepTimeSeconds;
  List<String> ingredients;
  String imagePath;

  Recipe(this.id, this.title, this.description, this.ingredients, this.prepTimeSeconds, this.imagePath);
}

