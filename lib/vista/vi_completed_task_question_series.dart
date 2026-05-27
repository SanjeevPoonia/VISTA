class ViCompltedTaskQuestionSeries{
  String groupId;
  String groupType;
  String groupName;
  List<ViCompletedTaskSubGroupList> subGroupList;
  ViCompltedTaskQuestionSeries(
      this.groupId, this.groupType, this.groupName, this.subGroupList);
}
class ViCompletedTaskSubGroupList{
  String subGroupId;
  String groupId;
  String subGroupName;
  List<viCompletedQuestionsList> questionList;
  ViCompletedTaskSubGroupList(
      this.subGroupId, this.groupId, this.subGroupName, this.questionList);
}
class viCompletedQuestionsList{
  String questionId;
  String groupId;
  String subGroupId;
  String taskId;
  String type;
  String question;
  String answerStr;
  String imageUrl;
  String voiceUrl;
  String videoUrl;
  String eSignUrl;
  String selfScore;
  String readOnlyAnswer;
  List<viCompletedSubQuestionListSeries> subQuestionList;

  viCompletedQuestionsList(
      this.questionId,
      this.groupId,
      this.subGroupId,
      this.taskId,
      this.type,
      this.question,
      this.answerStr,
      this.imageUrl,
      this.voiceUrl,
      this.videoUrl,
      this.eSignUrl,
      this.selfScore,
      this.readOnlyAnswer,
      this.subQuestionList,
     );
}
class viCompletedSubQuestionListSeries{
  String subQuestionId;
  String taskId;
  String questionId;
  String subQuestionType;
  String subQuestionText;
  String subAnswer;

  viCompletedSubQuestionListSeries(this.subQuestionId, this.taskId, this.questionId,
      this.subQuestionType, this.subQuestionText, this.subAnswer);
}