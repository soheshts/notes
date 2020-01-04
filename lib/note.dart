class Note{
   int id;
   String title;
   String note;

  Note({this.id, this.title, this.note});

  Map<String, dynamic> toMap(){
    return {
      'id': id,
      'title': title,
      'note': note,
    };
  }


}