class User {
  final String login;           //Логин
  final String password;        //Пароль
  final DateTime createdAt;     //Когда создан

  User(this.login, this.password) : createdAt = DateTime.now();
}