class TaskQuestionListSeries{
  String questionId;
  String areaId;
  String subAreaId;
  String taskId;
  String question;
  String afterBeforeImage;
  String voiceNote;
  int imageRequired;
  int audioRequired;
  String uploadedImageUrl;
  String uploadedAudioUrl;
  int isImageUploaded;
  int isAudioUploaded;
  String answerId;
  String imageUrl;
  String voiceUrl;
  int videoRequired;
  int eSignRequired;
  String questionType;
  int isVideoUploaded;
  int isEsignUploaded;
  String videoUrl;
  String eSignUrl;
  List<TaskSubQuestionListSeries> subQuestionList;
  TaskQuestionListSeries(
      this.questionId,
      this.areaId,
      this.subAreaId,
      this.taskId,
      this.question,
      this.afterBeforeImage,
      this.voiceNote,
      this.imageRequired,
      this.audioRequired,
      this.uploadedImageUrl,
      this.uploadedAudioUrl,
      this.isImageUploaded,
      this.isAudioUploaded,
      this.answerId,
      this.imageUrl,
      this.voiceUrl,
      this.videoRequired,
      this.eSignRequired,
      this.questionType,
      this.isVideoUploaded,
      this.isEsignUploaded,
      this.videoUrl,this.eSignUrl,this.subQuestionList
      );
}

class TaskSubQuestionListSeries{
  String subQuestionId;
  String taskId;
  String questionId;
  String subQuestionType;
  String subQuestionText;
  String subAnswer;

  TaskSubQuestionListSeries(this.subQuestionId, this.taskId, this.questionId,
      this.subQuestionType, this.subQuestionText, this.subAnswer);
}