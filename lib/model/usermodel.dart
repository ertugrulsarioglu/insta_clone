class Usermodel {
  String email;
  String username;
  String bio;
  String profile;
  List following;
  List followers;
  List posts;

  Usermodel(this.bio, this.email, this.followers, this.following, this.profile,
      this.username,
      {this.posts = const []} // Yeni eklenen alan, varsayılan olarak boş liste
      );

  // Firestore'dan gelen verileri Usermodel'e dönüştürmek için factory constructor
  factory Usermodel.fromFirestore(Map<String, dynamic> data) {
    return Usermodel(
      data['bio'] ?? '',
      data['email'] ?? '',
      List.from(data['followers'] ?? []),
      List.from(data['following'] ?? []),
      data['profile'] ?? '',
      data['username'] ?? '',
      posts: List.from(data['posts'] ?? []),
    );
  }
}
