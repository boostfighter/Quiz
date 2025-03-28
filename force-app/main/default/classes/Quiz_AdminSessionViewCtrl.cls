/**
* @File Name : Quiz_AdminSessionViewCtrl.cls
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

public without sharing class Quiz_AdminSessionViewCtrl {
    @AuraEnabled
	public static wrapperSessionDetails fetchSessionDetails(String sessionId){
        wrapperSessionDetails wsd = new wrapperSessionDetails();
        Quiz_Session__c newSession = new Quiz_Session__c();
        newSession = [SELECT Id,Quiz_Assessment_Name__c,Session_Name__c,Session_Time_Minutes__c,Session_Status__c,Session_Join_Code__c FROM Quiz_Session__c WHERE Id=:sessionId];
        wsd.Id = newSession.Id;
        wsd.Quiz_Assessment_Name = newSession.Quiz_Assessment_Name__c;
        wsd.Session_Name = newSession.Session_Name__c;
        wsd.Session_Time_Minutes = String.valueof(newSession.Session_Time_Minutes__c);
        wsd.Session_Status = newSession.Session_Status__c;
        wsd.Session_Join_Code = String.valueof(newSession.Session_Join_Code__c);

        return wsd;
    }
    public class wrapperSessionDetails{
        @AuraEnabled public String Id='';
        @AuraEnabled public String Quiz_Assessment_Name='';
		@AuraEnabled public String Session_Name='';
		@AuraEnabled public String Session_Time_Minutes='';
        @AuraEnabled public String Session_Status='';
        @AuraEnabled public String Session_Join_Code='';
	}

    @AuraEnabled
	public static void startSession(String sessionId){
        Quiz_Session__c newSession = new Quiz_Session__c();
        newSession.Id= sessionId;
        newSession.Session_Status__c = 'Running';
        update newSession;
    }

    @AuraEnabled
	public static void endSession(String sessionId){
        Quiz_Session__c newSession = new Quiz_Session__c();
        newSession.Id= sessionId;
        newSession.Session_Status__c = 'Completed';
        update newSession;
    }

    @AuraEnabled
	public static List<wrapperJoinee> fetchJoinee(String sessionId){
        Integer indexCount = 1;
        List<wrapperJoinee> joineeList = new List<wrapperJoinee>();
        List<Quiz_User__c> userList = new List<Quiz_User__c>();
        userList = [SELECT Id,Full_Name__c,Email__c,Total_Tab_Switched__c,Another_Tab_Open__c FROM Quiz_User__c WHERE Quiz_Session__c=:sessionId ORDER BY CreatedDate ASC];
        for(Quiz_User__c userRec:userList){
            wrapperJoinee joinee = new wrapperJoinee();
            joinee.userId = userRec.Id;
            joinee.userFullName = userRec.Full_Name__c;
            joinee.userEmail = userRec.Email__c;
            joinee.index = String.valueof(indexCount);
            joinee.userTabChange = String.valueof(userRec.Total_Tab_Switched__c);
            joinee.anotherTabOpen = userRec.Another_Tab_Open__c == true ? 'true' : 'false';
            joinee.tabStyleCss = userRec.Another_Tab_Open__c == true ? 'highlighted-row':'';
            joineeList.add(joinee);
            indexCount = indexCount+1;
        }
        return joineeList;
    }
    public class wrapperJoinee{
        @AuraEnabled public String userId='';
        @AuraEnabled public String index='0';
		@AuraEnabled public String userFullName='';
		@AuraEnabled public String userEmail='';
        @AuraEnabled public String userTabChange='0';
        @AuraEnabled public String anotherTabOpen='false';
        @AuraEnabled public String tabStyleCss='';
	}

    @AuraEnabled
    public static List<wrapperResultReportQuestionWise> resultReportQuestionWise(String sessionId){
        List<wrapperResultReportQuestionWise> resultReportList = new List<wrapperResultReportQuestionWise>();
        Quiz_Session__c session = [SELECT Id,Quiz_Assessment_Name__c, Quiz_Assessment_Name__r.Name, Session_Join_Code__c, Session_Name__c,Session_Status__c, Session_Time_Minutes__c FROM Quiz_Session__c WHERE ID=:sessionId];
        String assessmentID = session.Quiz_Assessment_Name__c;
        Map<ID,Quiz_Question__c> qustionMap = new Map<ID, Quiz_Question__c>( [SELECT ID, Name, Question__c,Quiz_Assessment_Name__c, isMultiAnswer__c,Quiz_Assessment_Name__r.Quiz_Admin_User__r.Name, Quiz_Assessment_Name__r.Name FROM Quiz_Question__c WHERE Quiz_Assessment_Name__c = :assessmentID]);
        Map<ID,Quiz_Answer__c> relatedAnswerListMap = new Map<ID, Quiz_Answer__c>([SELECT ID, Name, Answer__c, Index__c, isTrue__c, Quiz_Question__c FROM Quiz_Answer__c WHERE Quiz_Question__c IN :qustionMap.keySet()]);
        //Map<ID, List<Quiz_Answer__c>> quizIdAnswerListMap = new Map<ID, List<Quiz_Answer__c>>();
        Map<ID, String> quizIdCorrectAnswerMap = new Map<ID, String>();
        //Map<ID, String> userIdQuizIdAndSelectAnswerMap = new Map<ID, String>();
        Map<String,wrapCandidateDetails> UserAndQuizIdAndCandidateResultMap = new Map<String, wrapCandidateDetails>();
        List<Quiz_Result__c> resultList = [SELECT Id,Name, Quiz_User__c, Quiz_User__r.Name,JSON_Result__c, Quiz_User__r.Full_Name__c, Quiz_User__r.Email__c, Quiz_Session__c FROM Quiz_Result__c WHERE Quiz_Session__c = :sessionId];
        List<Quiz_User__c> quizUserList = [Select Id, Full_Name__c From Quiz_User__c Where Quiz_Session__c = :sessionId];
        Integer questionIndexCount = 1;


        // for(Quiz_Answer__c answer : relatedAnswerListMap.values()){
        //     if (!quizIdAnswerListMap.containsKey(answer.Quiz_Question__c))
        //     quizIdAnswerListMap.put(answer.Quiz_Question__c, new List<Quiz_Answer__c>());
        //     quizIdAnswerListMap.get(answer.Quiz_Question__c).add(answer);
        // }

        for(Quiz_Answer__c answer : relatedAnswerListMap.values()){
            if(answer.isTrue__c){
                if (!quizIdCorrectAnswerMap.containsKey(answer.Quiz_Question__c)){
                    quizIdCorrectAnswerMap.put(answer.Quiz_Question__c, answer.Answer__c);
                }
                else{
                    quizIdCorrectAnswerMap.put(answer.Quiz_Question__c, quizIdCorrectAnswerMap.get(answer.Quiz_Question__c) + ';' + answer.Answer__c);
                }
            }
        }

        for(Quiz_Result__c qr : resultList){
            List<Quiz_SessionResultCtrl.WrapperQuestion> objResultList = (List<Quiz_SessionResultCtrl.WrapperQuestion>) JSON.deserialize(qr.JSON_Result__c, List<Quiz_SessionResultCtrl.WrapperQuestion>.class);
            for(Quiz_SessionResultCtrl.WrapperQuestion wrapObj : objResultList){
                wrapCandidateDetails wrapCandidate = new wrapCandidateDetails();
                String userAndQuesId = qr.Quiz_User__c + wrapObj.quesId;
                String selectedAnswerNameCombine = '';
                Boolean trueFlag  = false;
                for(Quiz_SessionResultCtrl.WrapperAnswer wAns : wrapObj.answerList){
                    if(wAns.isSelected){
                        selectedAnswerNameCombine = selectedAnswerNameCombine + relatedAnswerListMap.get(wAns.answerId).Answer__c + ';'; 
                    }
                    if(wAns.isTrue == true){
                        if(wAns.isSelected == false){
                            trueFlag = false;
                            break;
                        }
                        else{
                            trueFlag = true;
                        }
                    }
                    else{
                        if(wAns.isSelected == true){
                            trueFlag = false;
                            break;
                        }
                        else{
                            trueFlag = true;
                        }
                    }
                }
                wrapCandidate.userId = qr.Quiz_User__c;
                wrapCandidate.userFullName = qr.Quiz_User__r.Full_Name__c;
                wrapCandidate.selectedAnswerNameCombine = selectedAnswerNameCombine;
                wrapCandidate.isCorrect = trueFlag == true ? 'true' : 'false';
                UserAndQuizIdAndCandidateResultMap.put(userAndQuesId, wrapCandidate);
            }
        }

        for(Quiz_Question__c quizQues : qustionMap.values()){
            wrapperResultReportQuestionWise wrapResultReport = new wrapperResultReportQuestionWise();
            List<wrapCandidateDetails> candidateDetailsList = new List<wrapCandidateDetails>();
            wrapResultReport.questionIndex = String.valueof(questionIndexCount);
            wrapResultReport.questionId = quizQues.Id;
            wrapResultReport.questionName = quizQues.Question__c;
            wrapResultReport.correctAnswerNameCombine = quizIdCorrectAnswerMap.get(quizQues.Id);
            for(Quiz_User__c qUser : quizUserList){
                wrapCandidateDetails wrapCandidate = new wrapCandidateDetails();
                if(UserAndQuizIdAndCandidateResultMap.containsKey(String.valueof(qUser.Id) + String.valueof(quizQues.Id))){
                    wrapCandidate = UserAndQuizIdAndCandidateResultMap.get(String.valueof(qUser.Id) + String.valueof(quizQues.Id));
                }else{
                    wrapCandidate = new wrapCandidateDetails();
                }
                candidateDetailsList.add(wrapCandidate);
            }
            wrapResultReport.candidateDetails = candidateDetailsList;
            questionIndexCount = questionIndexCount + 1;
            resultReportList.add(wrapResultReport);
        }
        system.debug('resultReportList ====>'+resultReportList);
        return resultReportList;
    }
    public class wrapperResultReportQuestionWise{
        @AuraEnabled public String questionIndex='0';
        @AuraEnabled public String questionId='';
        @AuraEnabled public String questionName='';
		@AuraEnabled public String correctAnswerNameCombine='';
        @AuraEnabled public List<wrapCandidateDetails> candidateDetails = new List<wrapCandidateDetails>();
	}
    public class wrapCandidateDetails{
        @AuraEnabled public String userId='';
        @AuraEnabled public String userFullName='';
        @AuraEnabled public String selectedAnswerNameCombine='';
        @AuraEnabled public String isCorrect='';
    }



    //Start-----written by Sayantan----------
    @AuraEnabled
    public static List<SessionAnswerDetailsView> getAnswerWiseUserList(String sessionId){
        List<SessionAnswerDetailsView> returnList = new List<SessionAnswerDetailsView>();
        try {
            // List<AnswerSessionView> ansSessionViewList = new List<AnswerSessionView>();
            Quiz_Session__c session = [SELECT Id,isResultPublished__c,Quiz_Assessment_Name__c, Quiz_Assessment_Name__r.Name, Session_Join_Code__c,
                    Session_Name__c,Session_Status__c, Session_Time_Minutes__c 
                    FROM Quiz_Session__c WHERE ID=:sessionId];
            String assessmentID = session.Quiz_Assessment_Name__c;
            Map<ID,Quiz_Question__c> qustionMap = new Map<ID, Quiz_Question__c>( [SELECT ID, Name, Question__c,Quiz_Assessment_Name__c, 
                    isMultiAnswer__c,Quiz_Assessment_Name__r.Quiz_Admin_User__r.Name, Quiz_Assessment_Name__r.Name
                    /*(SELECT Id, Name, Answer__c, Index__c, isTrue__c, Quiz_Question__c FROM Quiz_Answers__r) ---- not takeing this line */
                    FROM Quiz_Question__c WHERE Quiz_Assessment_Name__c = :assessmentID]);
            List<Quiz_Result__c> answerList = [SELECT Id,Name, Quiz_User__c, Quiz_User__r.Name,JSON_Result__c, Quiz_User__r.Full_Name__c,
                    Quiz_User__r.Email__c, Quiz_Session__c 
                    FROM Quiz_Result__c WHERE Quiz_Session__c = :sessionId];
            Map<ID, List<Quiz_Answer__c>> answerMap = new Map<ID, List<Quiz_Answer__c>>();
            List<Quiz_Answer__c> relatedAnswerList = [SELECT ID, Name, Answer__c, Index__c, isTrue__c, Quiz_Question__c FROM Quiz_Answer__c WHERE Quiz_Question__c IN :qustionMap.keySet()];
            // for(String qid : qustionMap.keySet()){
            //     List<Quiz_Answer__c> answerList1 = new List<Quiz_Answer__c>();
            //     answerList1.addAll(qustionMap.get(qid).Quiz_Answers__r);
            //     answerMap.put(qid, answerList1);
            // }
            for(Quiz_Answer__c answer : relatedAnswerList){
                if (!answerMap.containsKey(answer.Quiz_Question__c))
                    answerMap.put(answer.Quiz_Question__c, new List<Quiz_Answer__c>());
                answerMap.get(answer.Quiz_Question__c).add(answer);
            }
            Map<ID, List<AnsUser>> quesIDvsListCorrectUser = new Map<ID, List<AnsUser>>();
            Map<ID, List<AnsUser>> quesIDvsListWrongUser = new Map<ID, List<AnsUser>>();
            Map<ID, List<Question>> quesIDvsListQuesAns = new Map<ID, List<Question>>();
            if(answerList != NULL && answerList.size()>0){
                Set<String> questionIDSet = new Set<String>();
                for(Quiz_Result__c qr : answerList){
                    // List<Map<String, Object>> answerMap = (List<Map<String,Object>>)JSON.deserializeUntyped(qr.JSON_Result__c);
                    // List<AnsUser> correctAnsUserList = new List<AnsUser>();
                    // List<AnsUser> wrongAnsUserList = new List<AnsUser>();
                    List<Question> questions = (List<Question>) JSON.deserialize(qr.JSON_Result__c, List<Question>.class);
                    // SessionAnswerDetailsView retObj = new SessionAnswerDetailsView();
                    System.debug('quiz result ----->'+qr);
                    for(Question qustion: questions){
                        System.debug('quiz result answer ----->'+qustion);
                        AnsUser ansUser = new AnsUser();
                        ansUser.userId = qr.Quiz_User__c;
                        ansUser.userName = qr.Quiz_User__r.Full_Name__c;
                        // retObj.quesId = qustion.quesId;
                        // retObj.question = qustion.questionName;// take this from question map.
                        // retObj.sessionId = sessionId;
                        // retObj.Quiz_Assessment_Name = qustionMap.get(qustion.quesId).Quiz_Assessment_Name__r.Name;
                        // System.debug('return object ---->'+retObj);
                        if(qustion.isAnswered){
                            System.debug('quiz result is answered ----->');
                            System.debug('answermap ----->'+answerMap.get(qustion.quesId));
                            if(qustion.isMultiAnswer){
                                System.debug('quiz result multi answer ----->');
                                Boolean correct=true;
                                // List<String> answerList1 = new List<String>();
                                for(Answer ans :  qustion.answerList){
                                    if((ans.isSelected && !ans.isTrue) ||(!ans.isSelected && ans.isTrue)){
                                        correct = false;
                                        System.debug('quiz result wrong answer selected ----->'+ans);
                                        break;
                                    //     if(!wrongAnsUserList.contains(ansUser))
                                    //         wrongAnsUserList.add(ansUser);
                                    //     correct = false;
                                    //     break;
                                    // }else if(!ans.isSelected && ans.isTrue){
                                    //     if(!wrongAnsUserList.contains(ansUser))
                                    //         wrongAnsUserList.add(ansUser);
                                    //     correct = false;
                                    //     break;
                                    }
                                }
                                if(correct){
                                    if(!quesIDvsListCorrectUser.containsKey(qustion.quesId))
                                        quesIDvsListCorrectUser.put(qustion.quesId, new List<AnsUser>());
                                    quesIDvsListCorrectUser.get(qustion.quesId).add(ansUser);
                                    System.debug('quiz result is answered and multi answer quesIDvsListCorrectUser ----->'+quesIDvsListCorrectUser);
                                }
                                else{
                                    if(!quesIDvsListWrongUser.containsKey(qustion.quesId))
                                        quesIDvsListWrongUser.put(qustion.quesId, new List<AnsUser>());
                                    quesIDvsListWrongUser.get(qustion.quesId).add(ansUser);
                                    System.debug('quiz result is answered and multi answer quesIDvsListCorrectUser ----->'+quesIDvsListCorrectUser);
                                }
                            }
                            //if(!retObj.isMultiAnswer){
                            else{
                                Boolean correct=false;
                                for(Answer ans : qustion.answerList){
                                    if(ans.isTrue && ans.isSelected){
                                        // correctAnsUserList.add(ansUser);
                                        System.debug('quiz result single answer right ----->'+ans);
                                        correct = true;
                                        break;
                                    }
                                    else{
                                        System.debug('quiz result single answer wrong ----->'+ans);
                                        correct = false;
                                    }
                                }
                                if(!correct){
                                    if(!quesIDvsListWrongUser.containsKey(qustion.quesId))
                                        quesIDvsListWrongUser.put(qustion.quesId, new List<AnsUser>());
                                    quesIDvsListWrongUser.get(qustion.quesId).add(ansUser);
                                    System.debug('quiz result single answer quesIDvsListWrongUser ----->'+quesIDvsListWrongUser);
                                }else{
                                    if(!quesIDvsListCorrectUser.containsKey(qustion.quesId))
                                        quesIDvsListCorrectUser.put(qustion.quesId, new List<AnsUser>());
                                    quesIDvsListCorrectUser.get(qustion.quesId).add(ansUser);
                                    System.debug('quiz result single answer quesIDvsListCorrectUser ---->'+quesIDvsListCorrectUser);
                                }
                                    // wrongAnsUserList.add(ansUser);

                            }
                        }
                        else{
                            // wrongAnsUserList.add(ansUser);
                            if(!quesIDvsListWrongUser.containsKey(qustion.quesId))
                                quesIDvsListWrongUser.put(qustion.quesId, new List<AnsUser>());
                            quesIDvsListWrongUser.get(qustion.quesId).add(ansUser);
                            System.debug('quiz result not answered quesIDvsListCorrectUser ----->'+quesIDvsListCorrectUser);
                            System.debug('quiz result not answered quesIDvsListWrongUser ------>'+quesIDvsListWrongUser);
                        }
                        // if(!quesIDvsListCorrectUser.containsKey(qustion.quesId))
                        //     quesIDvsListCorrectUser.put(qustion.quesId, new List<ansUser>());
                        // quesIDvsListCorrectUser.get(qustion.quesId).addAll(correctAnsUserList);
                        // if(!quesIDvsListWrongUser.containsKey(qustion.quesId))
                        //     quesIDvsListWrongUser.put(qustion.quesId, new List<ansUser>());
                        // quesIDvsListWrongUser.get(qustion.quesId).addAll(wrongAnsUserList);
                        // retObj.correctuserList = correctAnsUserList;
                        // retObj.wronguserList = wrongAnsUserList;
                        // returnList.add(retObj);
                        // System.debug('retObj final ---->'+retObj);
                        System.debug('final before return quesIDvsListCorrectUser --->'+quesIDvsListCorrectUser);
                        System.debug('final before return quesIDvsListWrongUser --->'+quesIDvsListWrongUser);
                        System.debug('final before return qustionMap --->'+qustionMap.get(qustion.quesId));
                    }
                }
            }
            // now create the return wraper based on question query. 
            for(String qid : qustionMap.keySet()){
                SessionAnswerDetailsView retObj = new SessionAnswerDetailsView();
                retObj.quesId = qid;
                retObj.correctuserList = quesIDvsListCorrectUser.get(qid);
                retObj.wronguserList = quesIDvsListWrongUser.get(qid);
                retObj.question = qustionMap.get(qid).Question__c;
                retObj.Quiz_Assessment_Name = qustionMap.get(qid).Quiz_Assessment_Name__r.Name;
                retObj.answerList = answerMap.get(qid);
                returnList.add(retObj);
            }
            System.debug('before return in try block returnList ====>'+returnList);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return returnList;
    }
    // public class ansJSONDeserialize
    public class Question {
        public String questionName; // need to remove later
        public Integer questionIndex;
        public String quesId;
        public Boolean markForReview;
        public Boolean isMultiAnswer;
        public Boolean isAnswered;
        public String error;
        public List<Answer> answerList;
    }

    public class Answer {
        public Boolean isTrue;
        public Boolean isSelected;
        public String answerName;
        public String answerIndex;
        public String answerId;
    }

    public class SessionAnswerDetailsView{
        @AuraEnabled public String quesId='';
        @AuraEnabled public String sessionId='';
        @AuraEnabled public String Quiz_Assessment_Name='';
        @AuraEnabled public String question='';
        @AuraEnabled public List<ansUser> correctuserList = new List<AnsUser>();
        @AuraEnabled public List<ansUser> wronguserList = new List<AnsUser>();
        @AuraEnabled public List<Quiz_Answer__c> answerList = new List<Quiz_Answer__c>();
        // @auraEnabled public List<Quiz_Answer__c> answerList = new List<Quiz_Answer__c>();

    }
    public class AnsUser{
        @AuraEnabled public String userName='';
        // @AuraEnabled public String userEmail='';
        @AuraEnabled public String userId='';
    }
    // Public class correctAnswer{
    //     @AuraEnabled public String answer='';
    //     @AuraEnabled public Boolean correctAnswer=false;
    //     @AuraEnabled public Boolean multiANser=false;
    //     @AuraEnabled public Boolean correctAnswer=false;
        
    // }
    //End-----written by Sayantan----------
}