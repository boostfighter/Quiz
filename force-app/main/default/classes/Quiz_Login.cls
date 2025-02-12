/**
* @File Name : Quiz_Login.cls
* @Description :
* @Author : Debabrata Ghosh
* @Last Modified By :
* @Last Modified On : January 30, 2025
* @Modification Log :
*==============================================================================
* Ver | Date | Author | Modification
*==============================================================================
* 1.0 | January 30, 2025 |   | Initial Version
**/

public without sharing class Quiz_Login {
	@AuraEnabled
	public static WrapperObject loginValidate(String email, String password){
		System.debug('email->'+email+'  pass->'+password);
		WrapperObject retVal = new WrapperObject();
		List<Quiz_Admin_User__c> adminUserList = new List<Quiz_Admin_User__c>();

		adminUserList = [Select Id,Name From Quiz_Admin_User__c Where Email__c=:email AND Password__c=:password AND isActive__c=true Limit 1];

		if(adminUserList.size()>0){
			retVal.userId = adminUserList[0].Id;
			retVal.userName = adminUserList[0].Name;
			retVal.greetUser = 'Hello '+adminUserList[0].Name+',';
		}
		else{
			retVal.error = 'user not found';
		}

		return retVal;
	}

	public class WrapperObject{
		@AuraEnabled public String userId='';
		@AuraEnabled public String userName='';
		@AuraEnabled public String greetUser='';
		@AuraEnabled public String error;
	}
}