/**
* @File Name : Quiz_DashboardController.cls
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

public without sharing class Quiz_DashboardController {
	@AuraEnabled
	public static WrapperAssessment fetchAdminAssessment(String userId){
		WrapperAssessment payload = new WrapperAssessment();
		List<WrapperAssessmentDetails> waDetailList = new List<WrapperAssessmentDetails>();
		List<Quiz_Assessment_Name__c> assementList = new List<Quiz_Assessment_Name__c>();

		assementList = [Select Id,Name,Quiz_Admin_User__r.Id,CreatedDate From Quiz_Assessment_Name__c Where Quiz_Admin_User__c=:userId ORDER BY CreatedDate DESC Limit 100];
		for(Quiz_Assessment_Name__c qan : assementList){
			WrapperAssessmentDetails wad = new WrapperAssessmentDetails();
			wad.assessmentName = qan.Name;
			wad.assessmentDate = string.valueof(qan.CreatedDate);
			wad.assessmentId = qan.Id;
			waDetailList.add(wad);
		}
		payload.wadList = waDetailList;
		return payload;
	}

	@AuraEnabled
	public static WrapperAssessmentCreate createAssessment(String userId, String assessmentName){
		WrapperAssessmentCreate payload = new WrapperAssessmentCreate();
		Quiz_Assessment_Name__c asmt = new Quiz_Assessment_Name__c();
		if(String.isBlank(assessmentName)){
			payload.error = 'Assessment name is mandatory';
			return payload;
		}
		asmt.Name = assessmentName;
		asmt.Quiz_Admin_User__c = userId;

		insert asmt;
		payload.assessmentId = asmt.Id;
		return payload;
	}

	public class WrapperAssessment{
		@AuraEnabled public List<WrapperAssessmentDetails> wadList = new List<WrapperAssessmentDetails>();
		@AuraEnabled public String error;
	}
	public class WrapperAssessmentDetails{
		@AuraEnabled public String assessmentName='';
		@AuraEnabled public String assessmentDate='';
		@AuraEnabled public String assessmentId='';
	}
	public class WrapperAssessmentCreate{
		@AuraEnabled public String assessmentId='';
		@AuraEnabled public String error;
	}
}