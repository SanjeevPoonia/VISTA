class ViTaskQuestionSeries{
  String groupId;
  String groupType;
  String groupName;
  List<ViTaskSubGroupList> subGroupList;
  ViTaskQuestionSeries(
      this.groupId, this.groupType, this.groupName, this.subGroupList);
}
class ViTaskSubGroupList{
  String subGroupId;
  String groupId;
  String subGroupName;
  List<viQuestionsList> questionList;
  ViTaskSubGroupList(
      this.subGroupId, this.groupId, this.subGroupName, this.questionList);
}
class viQuestionsList{
  String questionId;
  String groupId;
  String subGroupId;
  String taskId;
  String type;
  String question;
  String score;
  int imageRequired;
  int audioRequired;
  int videoRequired;
  int eSignRequired;
  String afterBeforeImage;
  String voiceNote;
  String createdBy;
  String areaId;
  String subAreaId;
  String norms;
  String referenceImage;
  int minPhoto;
  int maxPhoto;
  String uploadedImageUrl;
  String uploadedAudioUrl;
  int isImageUploaded;
  int isAudioUploaded;
  String answerId;
  String imageUrl;
  String voiceUrl;
  int isVideoUploaded;
  int isEsignUploaded;
  String videoUrl;
  String eSignUrl;
  List<viSubQuestionListSeries> subQuestionList;
  String readOnlyAnswer;
  viQuestionsList(
      this.questionId,
      this.groupId,
      this.subGroupId,
      this.taskId,
      this.type,
      this.question,
      this.score,
      this.imageRequired,
      this.audioRequired,
      this.videoRequired,
      this.eSignRequired,
      this.afterBeforeImage,
      this.voiceNote,
      this.createdBy,
      this.areaId,
      this.subAreaId,
      this.norms,
      this.referenceImage,
      this.minPhoto,
      this.maxPhoto,
      this.uploadedImageUrl,
      this.uploadedAudioUrl,
      this.isImageUploaded,
      this.isAudioUploaded,
      this.answerId,
      this.imageUrl,
      this.voiceUrl,
      this.isVideoUploaded,
      this.isEsignUploaded,
      this.videoUrl,
      this.eSignUrl,
      this.subQuestionList,
      this.readOnlyAnswer);
}
class viSubQuestionListSeries{
  String subQuestionId;
  String taskId;
  String questionId;
  String subQuestionType;
  String subQuestionText;
  String subAnswer;

  viSubQuestionListSeries(this.subQuestionId, this.taskId, this.questionId,
      this.subQuestionType, this.subQuestionText, this.subAnswer);
}