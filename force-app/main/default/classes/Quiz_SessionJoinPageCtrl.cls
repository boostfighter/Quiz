/**
* @File Name : Quiz_SessionJoinPageCtrl.cls
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
public without sharing class Quiz_SessionJoinPageCtrl {
    @AuraEnabled
    public static string checkExamStart(String sessionId){
        String retMessage = '';
        List<Quiz_Session__c> sessionRec = new List<Quiz_Session__c>();
        sessionRec = [SELECT Id,Session_Status__c FROM Quiz_Session__c WHERE Id=:sessionId Limit 1];
        if(sessionRec.size()>0){
            if(sessionRec[0].Session_Status__c == 'Running'){
                retMessage = 'started';
            }
            else{
                retMessage = 'Not started';
            }
        }else{
            retMessage = 'Exam Not Found';
        }
        return retMessage;
    }

    @AuraEnabled
	public static WrapperResult checkQuizResult(String quizCode){
        WrapperResult wResult = new WrapperResult();
        String errorMessage = '';
        List<Quiz_Session__c> sessionRec = new List<Quiz_Session__c>();
        Integer intJoinCode = Integer.valueof(quizCode);

        sessionRec = [SELECT Id,Quiz_Assessment_Name__c,Session_Join_Code__c,isResultPublished__c FROM Quiz_Session__c WHERE Session_Join_Code__c=:intJoinCode Limit 1];

        if(sessionRec.size()>0){
            if(sessionRec[0].isResultPublished__c == false){
                errorMessage = 'Result Not Yet Published by Host';
            }
            else{
                wResult.sessionId = sessionRec[0].Id;
                wResult.userpayload.greetUser = 'Hi,';
                wResult.assessmentpayload = Quiz_AdminAssessmentCtrl.fetchAssessmentDetails(sessionRec[0].Quiz_Assessment_Name__c);
            }
        }
        else{
            errorMessage = 'Invalid Quiz Code';
        }

        wResult.error = errorMessage;
        return wResult;
    }
    public class WrapperResult{
        @AuraEnabled public String sessionId = '';
        @AuraEnabled public Quiz_Login.WrapperObject userpayload = new Quiz_Login.WrapperObject();
        @AuraEnabled public Quiz_AdminAssessmentCtrl.WrapperAssessmentDetails assessmentpayload = new Quiz_AdminAssessmentCtrl.WrapperAssessmentDetails();
        @AuraEnabled public String error = '';
    }
    
    @AuraEnabled
	public static WrapperSession joinQuiz(String joinCode, String studentName, String studentEmail){
        WrapperSession payload = new WrapperSession();
        List<Quiz_User__c> userRecList = new List<Quiz_User__c>();
        List<Quiz_Session__c> sessionRec = new List<Quiz_Session__c>();
        Quiz_User__c userRec = new Quiz_User__c();
        Integer intJoinCode = Integer.valueof(joinCode);

        if(joinCode!=null){
            sessionRec = [SELECT Id,Quiz_Assessment_Name__c,Quiz_Assessment_Name__r.Name,Session_Name__c,Session_Status__c,Session_Time_Minutes__c FROM Quiz_Session__c WHERE Session_Join_Code__c=:intJoinCode AND Session_Status__c='Initialize' Limit 1];
        }
        if(sessionRec.size()>0){
            userRecList = [Select Id From Quiz_User__c Where Email__c=:studentEmail AND Quiz_Session__c=:sessionRec[0].Id Limit 1];
            if(userRecList.size()>0){
                payload.error='Someone already joined with this email!!!';
            }
            else{
                userRec.Full_Name__c = studentName;
                userRec.Email__c = studentEmail;
                userRec.Quiz_Session__c = sessionRec[0].Id;
                insert userRec;
                payload.greetStudent = 'Hello '+studentName+'('+studentEmail+')';
                payload.userRecId = userRec.Id;
                payload.studentEmail = studentEmail;
                payload.studentNme = studentName;
                payload.sessionId = sessionRec[0].Id;
                payload.totalTime = String.valueof(sessionRec[0].Session_Time_Minutes__c);
                payload.sessionName = sessionRec[0].Session_Name__c;
                payload.totalQuestion = String.valueof([SELECT Id FROM Quiz_Question__c WHERE Quiz_Assessment_Name__c=:sessionRec[0].Quiz_Assessment_Name__c].size());
                payload.assessmentName = sessionRec[0].Quiz_Assessment_Name__r.Name;
                payload.assessmentId = sessionRec[0].Quiz_Assessment_Name__c;
            }
        }
        else{
            payload.error='No Active Quiz Found!!!';
        }
        return payload;
    }
    public class WrapperSession{
        @AuraEnabled public String greetStudent = '';
        @AuraEnabled public String userRecId = '';
        @AuraEnabled public String studentEmail = '';
        @AuraEnabled public String studentNme = '';
        @AuraEnabled public String sessionId = '';
        @AuraEnabled public String totalTime = '';
		@AuraEnabled public String sessionName = '';
        @AuraEnabled public String totalQuestion = '';
        @AuraEnabled public String assessmentName = '';
        @AuraEnabled public String assessmentId = '';
		@AuraEnabled public String error;
	}

    @AuraEnabled
    public static void checkSessionStart(String userId, String sessionId){
        List<Quiz_Session__c> sessionRec = new List<Quiz_Session__c>();
        sessionRec = [SELECT Id,Session_Status__c FROM Quiz_Session__c WHERE Id=:sessionId AND Session_Status__c='Initialize' Limit 1];
        if(sessionRec.size()>0){
            Quiz_User__c userRec = new Quiz_User__c();
            userRec.Id = userId;
            Delete userRec;
        }
    }

    @AuraEnabled
	public static WrapperQuestion fetchQuestion(String assessmentId, Integer offset){
        WrapperQuestion payload = new WrapperQuestion();
        List<WrapperAnswer> answerList=new List<WrapperAnswer>();
        List<Quiz_Question__c> questionRec = new List<Quiz_Question__c>();
        List<Quiz_Answer__c> answerRecList = new List<Quiz_Answer__c>();

        try{
            questionRec = [SELECT Id,Question__c,isMultiAnswer__c,Quiz_Assessment_Name__c FROM Quiz_Question__c WHERE Quiz_Assessment_Name__c=:assessmentId ORDER BY CreatedDate ASC Limit 2 OFFSET :offset];
            if(questionRec.size()>0){
                payload.quesId = questionRec[0].Id;
                payload.questionIndex = String.valueof(offset+1);
                payload.questionName = questionRec[0].Question__c;
                payload.isMultiAnswer = questionRec[0].isMultiAnswer__c;
                answerRecList = [SELECT Id,Answer__c,Quiz_Question__c,isTrue__c,Index__c FROM Quiz_Answer__c WHERE Quiz_Question__c =:questionRec[0].Id];
                for(Quiz_Answer__c qa : answerRecList){
                    WrapperAnswer tempWrpAns = new WrapperAnswer();
                    tempWrpAns.answerId = qa.Id;
                    tempWrpAns.answerName = qa.Answer__c;
                    tempWrpAns.answerIndex = qa.Index__c;
                    tempWrpAns.isTrue = qa.isTrue__c;
                    answerList.add(tempWrpAns);
                }
                payload.answerList = answerList;
                payload.finalQuestion = questionRec.size()==1 ? 'true' : 'false';
            }
            else{
                payload.filterMesage = 'completed';
                return payload;
            }
            return payload;
        }
        catch(exception e){
            payload.error=e.getMessage()+' at line number-'+e.getLineNumber();
            return payload;
        }
        
    }
    public class WrapperQuestion{
        @AuraEnabled public String questionIndex='0';
        @AuraEnabled public String quesId='';
        @AuraEnabled public String error;
		@AuraEnabled public String questionName='';
		@AuraEnabled public Boolean isMultiAnswer=false;
        @AuraEnabled public String finalQuestion='';
        @AuraEnabled public String filterMesage='';
        @AuraEnabled public List<WrapperAnswer> answerList=new List<WrapperAnswer>();
	}
    public class WrapperAnswer{
        @AuraEnabled public String answerId='';
		@AuraEnabled public String answerName='';
        @AuraEnabled public String answerIndex='';
		@AuraEnabled public Boolean isTrue=false;
        @AuraEnabled public Boolean isSelected=false;
	}

    @AuraEnabled
	public static String submitAnswerDB(String quizUserId, String sessionId, String result, String resultRecId){
        system.debug('resultRecId->'+resultRecId);
        String retVal = resultRecId;
        Quiz_Result__c resultRec = new Quiz_Result__c();
        if(resultRecId != '' && resultRecId != null && resultRecId != 'undefined'){
            resultRec = [Select Id,JSON_Result__c From Quiz_Result__c Where Id=:resultRecId];
            resultRec.JSON_Result__c = result;
            update resultRec;
        }
        else{
            resultRec.Quiz_User__c = quizUserId;
            resultRec.Quiz_Session__c = sessionId;
            resultRec.JSON_Result__c = result;
            insert resultRec;
            retVal = resultRec.Id;
        }
        system.debug('retVal->'+retVal);
        return retVal;
    }

}