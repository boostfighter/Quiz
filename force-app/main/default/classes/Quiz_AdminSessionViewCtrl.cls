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
}