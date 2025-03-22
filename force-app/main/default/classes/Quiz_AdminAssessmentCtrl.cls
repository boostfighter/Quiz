/**
* @File Name : Quiz_DashboardController.cls
* @Description :
* @Author : Debabrata Ghosh
* @Last Modified By :
* @Last Modified On : January 31, 2025
* @Modification Log :
*==============================================================================
* Ver | Date | Author | Modification
*==============================================================================
* 1.0 | January 31, 2025 |   | Initial Version
**/

public without sharing class Quiz_AdminAssessmentCtrl {
    @AuraEnabled
	public static String createSession(String sessionName, Integer sessionTime, String assessmentId){
        String recId = '';
        Quiz_Session__c newSession = new Quiz_Session__c();
        newSession.Quiz_Assessment_Name__c = assessmentId;
        newSession.Session_Name__c = sessionName;
        newSession.Session_Time_Minutes__c = sessionTime;
        newSession.Session_Status__c = 'Initialize';
        newSession.Session_Join_Code__c = Integer.valueof((Math.random() * 1000000));
        insert newSession;
        recId = newSession.Id;
        return recId;
    }

    @AuraEnabled
	public static List<WrapperAllSessionDetails> fetchSessionDetails(String assessmentId){
        List<WrapperAllSessionDetails> wrpObjList = new List<WrapperAllSessionDetails>();
        List<Quiz_Session__c> sessionList = new List<Quiz_Session__c>();
        Integer indCount = 1;
        sessionList = [Select Id,Session_Name__c, Session_Status__c, Session_Time_Minutes__c, CreatedDate From Quiz_Session__c Where Quiz_Assessment_Name__c=:assessmentId ORDER BY CreatedDate DESC];
        for(Quiz_Session__c qs : sessionList){
            WrapperAllSessionDetails wrpObj = new WrapperAllSessionDetails();
            wrpObj.sessionId = qs.Id;
            wrpObj.sessionName = qs.Session_Name__c;
            wrpObj.sessionTotalStudent = String.valueof([SELECT Id FROM Quiz_User__c WHERE Quiz_Session__c=:qs.Id].size());
            wrpObj.indexNo = String.valueof(indCount);
            wrpObj.sessionCreatedDate = (qs.CreatedDate.format('dd/MM/yyyy'));
            wrpObj.sessionStatus = qs.Session_Status__c;
            wrpObj.sessionMinute = String.valueOf(qs.Session_Time_Minutes__c);
            wrpObjList.add(wrpObj);
            indCount=indCount+1;
        }
        return wrpObjList;
    }
    public class WrapperAllSessionDetails{
        @AuraEnabled public String sessionId='';
        @AuraEnabled public String indexNo='';
		@AuraEnabled public String sessionName='';
        @AuraEnabled public String sessionCreatedDate='';
        @AuraEnabled public String sessionTotalStudent='';
        @AuraEnabled public String sessionStatus='';
        @AuraEnabled public String sessionMinute='';
	}

    @AuraEnabled
	public static WrapperAssessmentDetails fetchAssessmentDetails(String assessmentId){
        WrapperAssessmentDetails wrpObj = new WrapperAssessmentDetails();
        List<WrapperQuestion> wrpQuesList = new List<WrapperQuestion>();
        Quiz_Assessment_Name__c assName = [SELECT Id, Name, Quiz_Admin_User__c FROM Quiz_Assessment_Name__c WHERE Id=:assessmentId Limit 1];
        List<Quiz_Question__c> questionList = new List<Quiz_Question__c>();
        List<Quiz_Answer__c> answerList = new List<Quiz_Answer__c>();
        Map<String, List<WrapperAnswer>> questionAnswerMap = new Map<String, List<WrapperAnswer>>();
        Integer questionIndex = 1;

        questionList = [SELECT Id, Question__c, Quiz_Assessment_Name__c, isMultiAnswer__c FROM Quiz_Question__c WHERE Quiz_Assessment_Name__c=:assessmentId ORDER BY CreatedDate ASC];
        answerList = [SELECT Id, Answer__c, isTrue__c, Quiz_Question__c, Index__c FROM Quiz_Answer__c WHERE Quiz_Question__c in:questionList ORDER BY Index__c];
        for(Quiz_Answer__c ans : answerList){
            if(!questionAnswerMap.containsKey(ans.Quiz_Question__c)){
                questionAnswerMap.put(ans.Quiz_Question__c, new List<WrapperAnswer>());
            }
            List<WrapperAnswer> answerList1 = questionAnswerMap.get(ans.Quiz_Question__c);
            WrapperAnswer wrpAns = new WrapperAnswer();
            wrpAns.answerId = ans.Id;
            wrpAns.answerName = ans.Answer__c;
            wrpAns.isTrue = ans.isTrue__c;
            wrpAns.answerIndex = ans.Index__c+')';
            answerList1.add(wrpAns);
            questionAnswerMap.put(ans.Quiz_Question__c, answerList1);
        }

        wrpObj.assessmentName = assName.Name;
        wrpObj.assessmentId = assessmentId;
        for(Quiz_Question__c ques : questionList){
            WrapperQuestion wrpQues = new WrapperQuestion();
            wrpQues.questionName = ques.Question__c;
            wrpQues.isMultiAnswer = ques.isMultiAnswer__c;
            wrpQues.quesId = ques.Id;
            wrpQues.answerList = questionAnswerMap.get(ques.Id);
            wrpQues.quesIndex = String.valueOf(questionIndex);
            wrpQuesList.add(wrpQues);
            questionIndex = questionIndex+1;
        }
        wrpObj.totalQuestion = String.valueof(wrpQuesList.size());
        wrpObj.questionList = wrpQuesList;

        return wrpObj;
    }

    public class WrapperAssessmentDetails{
        @AuraEnabled public String assessmentId='';
		@AuraEnabled public String assessmentName='';
        @AuraEnabled public String totalQuestion='';
        @AuraEnabled public List<WrapperQuestion> questionList=new List<WrapperQuestion>();
	}
    public class WrapperQuestion{
        @AuraEnabled public String quesIndex='0';
        @AuraEnabled public String quesId='';
		@AuraEnabled public String questionName='';
		@AuraEnabled public Boolean isMultiAnswer=false;
        @AuraEnabled public List<WrapperAnswer> answerList=new List<WrapperAnswer>();
	}
    public class WrapperAnswer{
        @AuraEnabled public String answerIndex='';
        @AuraEnabled public String answerId='';
		@AuraEnabled public String answerName='';
		@AuraEnabled public Boolean isTrue=false;
	}

    @AuraEnabled
	public static void createQuestion(String assessmentId, String questionPayloadParam){
        system.debug('questionPayloadParam->'+questionPayloadParam);
        WrapperQuestionDetails questionPayload = (WrapperQuestionDetails)JSON.deserialize(questionPayloadParam, WrapperQuestionDetails.class);
        system.debug('questionPayload->'+questionPayload);

        Quiz_Question__c ques = new Quiz_Question__c();
        if(questionPayload.quesId != null && questionPayload.quesId != ''){
            ques.Id = questionPayload.quesId;
        }
        List<Quiz_Answer__c> ansList = new List<Quiz_Answer__c>();
        Integer trueCount = 0;

        if(questionPayload.isTrue1 != null && questionPayload.isTrue1){
            trueCount = trueCount + 1;
        }
        if(questionPayload.isTrue2 != null && questionPayload.isTrue2){
            trueCount = trueCount + 1;
        }
        if(questionPayload.isTrue3 != null && questionPayload.isTrue3){
            trueCount = trueCount + 1;
        }
        if(questionPayload.isTrue4 != null && questionPayload.isTrue4){
            trueCount = trueCount + 1;
        }
        if(questionPayload.isTrue5 != null && questionPayload.isTrue5){
            trueCount = trueCount + 1;
        }
        if(questionPayload.isTrue6 != null && questionPayload.isTrue6){
            trueCount = trueCount + 1;
        }

        ques.Question__c = questionPayload.questionName;
        ques.Quiz_Assessment_Name__c = assessmentId;
        ques.isMultiAnswer__c = trueCount > 1 ? true : false;

        upsert ques;

        if(questionPayload.answerName1 != null && !String.isBlank(questionPayload.answerName1)){
            Quiz_Answer__c ans = new Quiz_Answer__c();
            if(questionPayload.answerId1 != null && questionPayload.answerId1 != ''){
                ans.Id = questionPayload.answerId1;
            }
            ans.Index__c = 'a';
            ans.Answer__c = questionPayload.answerName1;
            ans.isTrue__c = questionPayload.isTrue1 == null ? false : questionPayload.isTrue1;
            ans.Quiz_Question__c = ques.Id;
            ansList.add(ans);
        }
        else{
            Quiz_Answer__c ans = new Quiz_Answer__c();
            if(questionPayload.answerId1 != null && questionPayload.answerId1 != ''){
                ans.Id = questionPayload.answerId1;
                delete ans;
            }
        }
        if(questionPayload.answerName2 != null && !String.isBlank(questionPayload.answerName2)){
            Quiz_Answer__c ans = new Quiz_Answer__c();
            if(questionPayload.answerId2 != null && questionPayload.answerId2 != ''){
                ans.Id = questionPayload.answerId2;
            }
            ans.Index__c = 'b';
            ans.Answer__c = questionPayload.answerName2;
            ans.isTrue__c = questionPayload.isTrue2 == null ? false : questionPayload.isTrue2;
            ans.Quiz_Question__c = ques.Id;
            ansList.add(ans);
        }
        else{
            Quiz_Answer__c ans = new Quiz_Answer__c();
            if(questionPayload.answerId2 != null && questionPayload.answerId2 != ''){
                ans.Id = questionPayload.answerId2;
                delete ans;
            }
        }
        if(questionPayload.answerName3 != null && !String.isBlank(questionPayload.answerName3)){
            Quiz_Answer__c ans = new Quiz_Answer__c();
            if(questionPayload.answerId3 != null && questionPayload.answerId3 != ''){
                ans.Id = questionPayload.answerId3;
            }
            ans.Index__c = 'c';
            ans.Answer__c = questionPayload.answerName3;
            ans.isTrue__c = questionPayload.isTrue3 == null ? false : questionPayload.isTrue3;
            ans.Quiz_Question__c = ques.Id;
            ansList.add(ans);
        }
        else{
            Quiz_Answer__c ans = new Quiz_Answer__c();
            if(questionPayload.answerId3 != null && questionPayload.answerId3 != ''){
                ans.Id = questionPayload.answerId3;
                delete ans;
            }
        }
        if(questionPayload.answerName4 != null && !String.isBlank(questionPayload.answerName4)){
            Quiz_Answer__c ans = new Quiz_Answer__c();
            if(questionPayload.answerId4 != null && questionPayload.answerId4 != ''){
                ans.Id = questionPayload.answerId4;
            }
            ans.Index__c = 'd';
            ans.Answer__c = questionPayload.answerName4;
            ans.isTrue__c = questionPayload.isTrue4 == null ? false : questionPayload.isTrue4;
            ans.Quiz_Question__c = ques.Id;
            ansList.add(ans);
        }
        else{
            Quiz_Answer__c ans = new Quiz_Answer__c();
            if(questionPayload.answerId4 != null && questionPayload.answerId4 != ''){
                ans.Id = questionPayload.answerId4;
                delete ans;
            }
        }
        if(questionPayload.answerName5 != null && !String.isBlank(questionPayload.answerName5)){
            Quiz_Answer__c ans = new Quiz_Answer__c();
            if(questionPayload.answerId5 != null && questionPayload.answerId5 != ''){
                ans.Id = questionPayload.answerId5;
            }
            ans.Index__c = 'e';
            ans.Answer__c = questionPayload.answerName5;
            ans.isTrue__c = questionPayload.isTrue5 == null ? false : questionPayload.isTrue5;
            ans.Quiz_Question__c = ques.Id;
            ansList.add(ans);
        }
        else{
            Quiz_Answer__c ans = new Quiz_Answer__c();
            if(questionPayload.answerId5 != null && questionPayload.answerId5 != ''){
                ans.Id = questionPayload.answerId5;
                delete ans;
            }
        }
        if(questionPayload.answerName6 != null && !String.isBlank(questionPayload.answerName6)){
            Quiz_Answer__c ans = new Quiz_Answer__c();
            if(questionPayload.answerId6 != null && questionPayload.answerId6 != ''){
                ans.Id = questionPayload.answerId6;
            }
            ans.Index__c = 'f';
            ans.Answer__c = questionPayload.answerName6;
            ans.isTrue__c = questionPayload.isTrue6 == null ? false : questionPayload.isTrue6;
            ans.Quiz_Question__c = ques.Id;
            ansList.add(ans);
        }
        else{
            Quiz_Answer__c ans = new Quiz_Answer__c();
            if(questionPayload.answerId6 != null && questionPayload.answerId6 != ''){
                ans.Id = questionPayload.answerId6;
                delete ans;
            }
        }

        upsert ansList;
    }

    @AuraEnabled
	public static WrapperQuestionDetails fetchQuesToEdit(String questionId){
        WrapperQuestionDetails wqd = new WrapperQuestionDetails();
        Quiz_Question__c ques = [SELECT Id, Question__c FROM Quiz_Question__c WHERE Id =: questionId];
        wqd.quesId = ques.Id;
        wqd.questionName = ques.Question__c;

        List<Quiz_Answer__c> ansList = [SELECT Id, Answer__c, Quiz_Question__c, isTrue__c,Index__c FROM Quiz_Answer__c WHERE Quiz_Question__c =:questionId];
        for(Quiz_Answer__c qa : ansList){
            if(qa.Index__c == 'a'){
                wqd.answerId1 = qa.Id;
                wqd.answerName1 = qa.Answer__c;
                wqd.isTrue1 = qa.isTrue__c;
                continue;
            }
            if(qa.Index__c == 'b'){
                wqd.answerId2 = qa.Id;
                wqd.answerName2 = qa.Answer__c;
                wqd.isTrue2 = qa.isTrue__c;
                continue;
            }
            if(qa.Index__c == 'c'){
                wqd.answerId3 = qa.Id;
                wqd.answerName3 = qa.Answer__c;
                wqd.isTrue3 = qa.isTrue__c;
                continue;
            }
            if(qa.Index__c == 'd'){
                wqd.answerId4 = qa.Id;
                wqd.answerName4 = qa.Answer__c;
                wqd.isTrue4 = qa.isTrue__c;
                continue;
            }
            if(qa.Index__c == 'e'){
                wqd.answerId5 = qa.Id;
                wqd.answerName5 = qa.Answer__c;
                wqd.isTrue5 = qa.isTrue__c;
                continue;
            }
            if(qa.Index__c == 'f'){
                wqd.answerId6 = qa.Id;
                wqd.answerName6 = qa.Answer__c;
                wqd.isTrue6 = qa.isTrue__c;
                continue;
            }
        }

        return wqd;
    }   
    public class WrapperQuestionDetails{
        @AuraEnabled public String quesId='';
		@AuraEnabled public String questionName='';
        @AuraEnabled public String answerId1='';
		@AuraEnabled public String answerName1='';
		@AuraEnabled public Boolean isTrue1=false;
        @AuraEnabled public String answerId2='';
		@AuraEnabled public String answerName2='';
		@AuraEnabled public Boolean isTrue2=false;
        @AuraEnabled public String answerId3='';
		@AuraEnabled public String answerName3='';
		@AuraEnabled public Boolean isTrue3=false;
        @AuraEnabled public String answerId4='';
		@AuraEnabled public String answerName4='';
		@AuraEnabled public Boolean isTrue4=false;
        @AuraEnabled public String answerId5='';
		@AuraEnabled public String answerName5='';
		@AuraEnabled public Boolean isTrue5=false;
        @AuraEnabled public String answerId6='';
		@AuraEnabled public String answerName6='';
		@AuraEnabled public Boolean isTrue6=false;
	}

    @AuraEnabled
	public static void deleteQuestion(String questionId){
        Quiz_Question__c ques = new Quiz_Question__c();
        List<Quiz_Answer__c> ansList = new List<Quiz_Answer__c>();

        ansList = [Select Id From Quiz_Answer__c Where Quiz_Question__c =: questionId];
        if(ansList.size()>0){
            delete ansList;
        }
        
        ques.Id = questionId;
        delete ques;
    }

}