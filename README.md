# Salesforce DX Project: Next Steps

Now that you’ve created a Salesforce DX project, what’s next? Here are some documentation resources to get you started.

## How Do You Plan to Deploy Your Changes?
Deploy using VS Code
xml--->
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Package xmlns="http://soap.sforce.com/2006/04/metadata">
	<types>
		<members>CoverageClass</members>
		<members>CoverageClass2</members>
		<members>Quiz_AdminAssessmentCtrl</members>
		<members>Quiz_AdminSessionViewCtrl</members>
		<members>Quiz_DashboardController</members>
		<members>Quiz_Login</members>
		<members>Quiz_SessionJoinPageCtrl</members>
		<members>Quiz_SessionResultCtrl</members>
		<members>TestCoverageClass</members>
		<name>ApexClass</name>
	</types>
	<types>
		<members>Quiz</members>
		<name>CustomApplication</name>
	</types>
	<types>
		<members>Quiz_Admin_User__c</members>
		<members>Quiz_Answer__c</members>
		<members>Quiz_Assessment_Name__c</members>
		<members>Quiz_Question__c</members>
		<members>Quiz_Result__c</members>
		<members>Quiz_Session__c</members>
		<members>Quiz_User__c</members>
		<name>CustomObject</name>
	</types>
	<types>
		<members>Quiz_Admin_User__c</members>
		<members>Quiz_Answer__c</members>
		<members>Quiz_Application</members>
		<members>Quiz_Assessment_Name__c</members>
		<members>Quiz_Question__c</members>
		<members>Quiz_Result__c</members>
		<members>Quiz_Session__c</members>
		<members>Quiz_User__c</members>
		<name>CustomTab</name>
	</types>
	<types>
		<members>Quiz_Application</members>
		<name>FlexiPage</name>
		<members>Quiz_UtilityBar</members>
	</types>
	<types>
		<members>quiz_AdminAssessmentView</members>
		<members>quiz_AdminDashboard</members>
		<members>quiz_AdminSessionResultView</members>
		<members>quiz_AdminSessionView</members>
		<members>quiz_LandingPage</members>
		<members>quiz_LoginPage</members>
		<members>quiz_SessionJoinPage</members>
		<members>quiz_SessionQuizPage</members>
		<members>quiz_Spinner</members>
		<members>quiz_NavBar</members>
		<members>quiz_StudentResultView</members>
		<members>quiz_AdminResultDetails</members>
		<members>quiz_AdminQuestionWiseReport</members>
		<name>LightningComponentBundle</name>
	</types>
	<types>
		<members>companyLogo</members>
		<name>StaticResource</name>
	</types>
	<version>62.0</version>
</Package>

## Configure Your Salesforce DX Project
After Deploy via **VS Code**:
1. Go to System Admin profile and give access for "Quiz (Quiz)" under 'Assigned Apps' section.
2. Go to System Admin profile and give all access to all the custom objects related to the Quiz app. And Tab Visibility should be default on.
3. Go to System Admin profile and give all related apex class access
4. Enable Digital Experiences if not enabled.
5. create a guest site 
	a. Go to "All Sites" and click on new.
	b. select "Build Your Own(LWR)"
	c. click on "Get Started"
	d. put site name(Quiz Application) and click on create
	e. Now go to Builder and add Quiz_Landing_Page only
	f. Enable public access from the setting
	g. click Publish
6. Give all apex class access for guest user profile.

After installation via **installation URL**:
1. Enable Digital Experiences if not enabled.
2. create a guest site 
	a. Go to "All Sites" and click on new.
	b. select "Build Your Own(LWR)"
	c. click on "Get Started"
	d. put site name(Quiz Application) and click on create
	e. Now go to Builder and add Quiz_Landing_Page only
	f. Enable public access from the setting
	g. click Publish
3. Give all apex class access for guest user profile.
	

Published Site: https://personalcom22-dev-ed.develop.my.site.com/quiz
DEMO Link: https://youtu.be/-9-r8u40H0A
