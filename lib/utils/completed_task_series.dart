class CompletedTaskQuestionSeries{
String QuestionId;
String QuestionStr;
String AnswerStr;
String ImageUrl;
String VoiceUrl;
String VideoUrl;
String eSignUrl;
List<CompletedTaskSubQuestionSeries> subQuestionlist;
CompletedTaskQuestionSeries(this.QuestionId, this.QuestionStr, this.AnswerStr,
      this.ImageUrl, this.VoiceUrl,this.VideoUrl,this.eSignUrl,this.subQuestionlist);
}
class CompletedTaskSubQuestionSeries{
  String SubQuestionId;
  String QuestionId;
  String AnswerStr;
  String subQuestionStr;
  CompletedTaskSubQuestionSeries(
      this.SubQuestionId,this.subQuestionStr, this.QuestionId, this.AnswerStr);
}