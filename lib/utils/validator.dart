class Validators{
  static String? checkTaskName(String? value) {
    if (value!.isEmpty) {
      return "Task Name is required";
    } else if (value.trim().length<3) {
      return 'Task Name should have at least 3 characters';
    }
    return null;
  }
  static String? checkRemark(String? value) {
    if (value!.isEmpty) {
      return "Remark is required";
    } else if (value.trim().length<3) {
      return 'Remark should have at least 3 characters';
    }
    return null;
  }
  static String? checkQuestion(String? value) {
    if (value!.isEmpty) {
      return "Question is required";
    } else if (value.trim().length<3) {
      return 'Question should have at least 3 characters';
    }
    return null;
  }
  static String? checkOfficeNumber(String? value) {
    if (value!.trim().isEmpty) {
      return "Office Number is required";
    }
    return null;
  }
}