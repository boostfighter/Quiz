public without sharing class Quiz_SessionResultCtrl {
    @AuraEnabled
    public static WrapperStudentDetails getStudentResultPayload(String studentId, String assessmentId) {
        WrapperStudentDetails wrpObj = new WrapperStudentDetails();
        Quiz_User__c qUser = new Quiz_User__c();
        List<WrapperQuestion> wrpQuesList = new List<WrapperQuestion>();
        List<Quiz_Result__c> qResult = new List<Quiz_Result__c>();
        Quiz_Assessment_Name__c assName = [SELECT Id, Name, Quiz_Admin_User__c FROM Quiz_Assessment_Name__c WHERE Id=:assessmentId Limit 1];
        List<Quiz_Question__c> questionList = new List<Quiz_Question__c>();
        List<Quiz_Answer__c> answerList = new List<Quiz_Answer__c>();
        Map<String, List<WrapperAnswer>> questionAnswerMap = new Map<String, List<WrapperAnswer>>();
        Integer questionIndex = 1;
        Map<String,Boolean> answerIdAndIsCorrectMap = new Map<String,Boolean>();
        Integer corrAns = 0;
        Integer sessionTotalQuestion = 0;

        qUser = [SELECT Id, Full_Name__c, Email__c FROM Quiz_User__c WHERE Id=:studentId Limit 1];
        qResult = [SELECT Id,JSON_Result__c,Quiz_User__c FROM Quiz_Result__c WHERE Quiz_User__c =: studentId];
        questionList = [SELECT Id, Question__c, Quiz_Assessment_Name__c, isMultiAnswer__c FROM Quiz_Question__c WHERE Quiz_Assessment_Name__c=:assessmentId ORDER BY CreatedDate ASC];
        answerList = [SELECT Id, Index__c, Answer__c, isTrue__c, Quiz_Question__c FROM Quiz_Answer__c WHERE Quiz_Question__c in:questionList ORDER BY CreatedDate ASC];
        sessionTotalQuestion = questionList.size();
        
        system.debug('qResult.size--->'+qResult.size());
        if(qResult.size()>0){
            List<WrapperQuestion> objResultList = (List<WrapperQuestion>) JSON.deserialize(qResult[0].JSON_Result__c, List<WrapperQuestion>.class);
            corrAns = getCorrectAnsCount(objResultList);
            for(WrapperQuestion wQues : objResultList){
                for(WrapperAnswer wAns : wQues.answerList){
                    If(wAns.isSelected == true){
                        if(wAns.isTrue){
                            answerIdAndIsCorrectMap.put(wAns.answerId, true);
                        }
                        else{
                             answerIdAndIsCorrectMap.put(wAns.answerId, false);
                        }
                    }
                }
            }
        }
        
        for(Quiz_Answer__c ans : answerList){
            if(!questionAnswerMap.containsKey(ans.Quiz_Question__c)){
                questionAnswerMap.put(ans.Quiz_Question__c, new List<WrapperAnswer>());
            }
            List<WrapperAnswer> answerList1 = questionAnswerMap.get(ans.Quiz_Question__c);
            WrapperAnswer wrpAns = new WrapperAnswer();
            wrpAns.answerIndex = ans.Index__c;
            wrpAns.answerId = ans.Id;
            wrpAns.answerName = ans.Answer__c;
            wrpAns.isTrue = ans.isTrue__c;
            if(answerIdAndIsCorrectMap.containsKey(ans.Id)){
                //wrpAns.style = answerIdAndIsCorrectMap.get(ans.Id) == true ? 'background-color: rgb(132, 222, 132);' : 'background-color: rgb(240, 140, 140);';
                wrpAns.className = answerIdAndIsCorrectMap.get(ans.Id) == true ? 'right-answer' : 'wrong-answer';
            }
            answerList1.add(wrpAns);
            questionAnswerMap.put(ans.Quiz_Question__c, answerList1);
        }

        wrpObj.assessmentName = assName.Name;
        wrpObj.studentName = qUser.Full_Name__c;
        wrpObj.studentEmail = qUser.Email__c;
        wrpObj.correctAnswer = String.valueof(corrAns)+'/'+String.valueof(sessionTotalQuestion);
        Decimal resPer = (Decimal.valueof(corrAns)*100)/Decimal.valueof(sessionTotalQuestion);
        wrpObj.percentage = String.valueof(resPer.setScale(2))+'%';
        wrpObj.greetUser = 'Hello '+qUser.Full_Name__c+',';
        for(Quiz_Question__c ques : questionList){
            WrapperQuestion wrpQues = new WrapperQuestion();
            wrpQues.questionIndex = String.valueof(questionIndex);
            wrpQues.questionName = ques.Question__c;
            wrpQues.isMultiAnswer = ques.isMultiAnswer__c;
            wrpQues.quesId = ques.Id;
            wrpQues.answerList = questionAnswerMap.get(ques.Id);
            wrpQuesList.add(wrpQues);
            questionIndex ++;
        }
        wrpObj.totalQuestion = String.valueof(wrpQuesList.size());
        wrpObj.questionList = wrpQuesList;

        return wrpObj;
    }
    public class WrapperStudentDetails{
		@AuraEnabled public String assessmentName='';
        @AuraEnabled public String totalQuestion='';
        @AuraEnabled public String studentName='';
        @AuraEnabled public String studentEmail='';
        @AuraEnabled public String greetUser='';
        @AuraEnabled public String correctAnswer='';
        @AuraEnabled public String percentage='';
        @AuraEnabled public String sessionName='';
        @AuraEnabled public String sessionTime='';
        @AuraEnabled public List<WrapperQuestion> questionList=new List<WrapperQuestion>();
	}

    @AuraEnabled
    public static void publishResultDB(String sessionId) {
        Quiz_Session__c sessionRec = [SELECT Id,isResultPublished__c,Quiz_Assessment_Name__c,Session_Name__c,Session_Status__c,Session_Time_Minutes__c FROM Quiz_Session__c WHERE Id =: sessionId];

        sessionRec.isResultPublished__c = true;
        update sessionRec;
    }

    @AuraEnabled
    public static WrapperStudentDetails studentResultPayload(String sessionCode, String studentEmail) {
        WrapperStudentDetails wrd = new WrapperStudentDetails();
        String studentId = '';
        List<Quiz_Session__c> sessionRec = new List<Quiz_Session__c>();
        List<Quiz_User__c> studentRec = new List<Quiz_User__c>();
        Integer intJoinCode = Integer.valueof(sessionCode);

        sessionRec = [SELECT Id,Session_Name__c,Session_Time_Minutes__c,Quiz_Assessment_Name__c,Session_Join_Code__c,isResultPublished__c FROM Quiz_Session__c WHERE Session_Join_Code__c=:intJoinCode Limit 1];

        if(sessionRec.size()>0){
            studentRec = [Select Id,Email__c From Quiz_User__c Where Email__c =:studentEmail AND Quiz_Session__c =:sessionRec[0].Id];
            if(studentRec.size()>0){
                wrd = getStudentResultPayload(studentRec[0].Id, sessionRec[0].Quiz_Assessment_Name__c);
                wrd.sessionName = sessionRec[0].Session_Name__c;
                wrd.sessionTime = String.valueof(sessionRec[0].Session_Time_Minutes__c)+' Minutes';
            }
        }

        return wrd;
    }
    

    @AuraEnabled
    public static WrapperResult getSessionResultPayload(String sessionId) {
        WrapperResult wResult = new WrapperResult();
        List<WrapperStudent> studentList=new List<WrapperStudent>();
        List<Quiz_User__c> sessionUserList = new List<Quiz_User__c>();
        List<Quiz_Result__c> sessionResultList = new List<Quiz_Result__c>();
        Map<Id,Quiz_Result__c> userIdResultMap = new Map<Id,Quiz_Result__c>();
        List<Quiz_Question__c> sessionQuestionList = new List<Quiz_Question__c>();
        Integer sessionTotalQuestion = 0;
        Integer indexCount = 1;
        Quiz_Session__c sessionRec = [SELECT Id,Session_Join_Code__c,isResultPublished__c,Quiz_Assessment_Name__c,Session_Name__c,Session_Status__c,Session_Time_Minutes__c FROM Quiz_Session__c WHERE Id =: sessionId];
        wResult.sessionId = sessionId;
        wResult.quizCode = String.valueof(sessionRec.Session_Join_Code__c);
        wResult.sessionName = sessionRec.Session_Name__c;
        wResult.sessionStatus = sessionRec.Session_Status__c;
        wResult.sessionTime = String.valueof(sessionRec.Session_Time_Minutes__c);
        wResult.isPublished = sessionRec.isResultPublished__c;

        sessionUserList = [SELECT Id,Full_Name__c,Email__c,Total_Tab_Switched__c FROM Quiz_User__c WHERE Quiz_Session__c =: sessionId];
        sessionResultList = [SELECT Id,JSON_Result__c,Quiz_User__c FROM Quiz_Result__c WHERE Quiz_Session__c =: sessionId];
        sessionQuestionList = [SELECT Id FROM Quiz_Question__c WHERE Quiz_Assessment_Name__c =: sessionRec.Quiz_Assessment_Name__c];
        sessionTotalQuestion = sessionQuestionList.size();

        for(Quiz_Result__c qr : sessionResultList){
            userIdResultMap.put(qr.Quiz_User__c, qr);
        }
        for(Quiz_User__c qUser : sessionUserList){
            WrapperStudent ws = new WrapperStudent();
            ws.studentId = qUser.Id;
            ws.position = String.valueof(indexCount);
            ws.studentName = qUser.Full_Name__c;
            ws.totalTabSwitch = String.valueof(qUser.Total_Tab_Switched__c);
            ws.studentEmail = qUser.Email__c;
            ws.studentCorrectAnswer = '0';
            ws.studentResulPercentage = '0%';
            if(userIdResultMap.containsKey(qUser.Id)){
                Integer corrAns = 0;
                Quiz_Result__c qr = userIdResultMap.get(qUser.Id); 
                List<WrapperQuestion> objResultList = (List<WrapperQuestion>) JSON.deserialize(qr.JSON_Result__c, List<WrapperQuestion>.class);
                corrAns = getCorrectAnsCount(objResultList);
                /*for(WrapperQuestion wQues : objResultList){
                    Boolean trueFlag  = false;
                    for(WrapperAnswer wAns : wQues.answerList){
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
                    if(trueFlag){
                        corrAns = corrAns + 1;
                    }
                }*/
                ws.studentCorrectAnswer = String.valueof(corrAns)+'/'+String.valueof(sessionTotalQuestion);
                Decimal resPer = (Decimal.valueof(corrAns)*100)/Decimal.valueof(sessionTotalQuestion);
                ws.studentResulPercentage = String.valueof(resPer.setScale(2))+'%';
            }
            studentList.add(ws);
            indexCount = indexCount+1;
        }
        wResult.studentList = studentList;
        return wResult;
    }

    public static Integer getCorrectAnsCount(List<WrapperQuestion> objResultList){
        Integer corrAns = 0;
        for(WrapperQuestion wQues : objResultList){
            Boolean trueFlag  = false;
            for(WrapperAnswer wAns : wQues.answerList){
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
            if(trueFlag){
                corrAns = corrAns + 1;
            }
        }
        return corrAns;
    }

    public class WrapperResult{
        @AuraEnabled public String sessionId='';
        @AuraEnabled public String quizCode='';
		@AuraEnabled public String sessionName='';
        @AuraEnabled public String sessionStatus='';
        @AuraEnabled public String sessionTime='';
        @AuraEnabled public Boolean isPublished=true;
        @AuraEnabled public List<WrapperStudent> studentList=new List<WrapperStudent>();
	}
    public class WrapperStudent{
        @AuraEnabled public String studentId='';
        @AuraEnabled public String position='';
		@AuraEnabled public String studentName='';
        @AuraEnabled public String totalTabSwitch='';
        @AuraEnabled public String studentEmail='';
        @AuraEnabled public String studentCorrectAnswer='';
        @AuraEnabled public String studentResulPercentage='';
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
        //@AuraEnabled public String style='';
        @AuraEnabled public String className='';
	}
}