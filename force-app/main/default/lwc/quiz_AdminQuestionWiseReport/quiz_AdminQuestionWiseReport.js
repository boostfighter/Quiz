import { api, LightningElement, track } from 'lwc';
import fetchResultReportQuestionWise from '@salesforce/apex/Quiz_AdminSessionViewCtrl.resultReportQuestionWise';

export default class Quiz_AdminQuestionWiseReport extends LightningElement {
    @api sessionid='';
    @track questionWiseReportData = [];
    error;
    isLoading = true;
    @track userNameList = [];

    connectedCallback() {
        this.isLoading = true;
        fetchResultReportQuestionWise({ 
            sessionId: this.sessionid
        })
        .then(result => {
            this.questionWiseReportData = result;
            if (this.questionWiseReportData.length > 0) {
                this.userNameList = this.questionWiseReportData[0].candidateDetails.map(candidate => ({
                    userId: candidate.userId,
                    userFullName: candidate.userFullName
                }));
            }
            console.log('User Full Names:', JSON.stringify(this.userNameList));
            //console.log('Result:', JSON.stringify(this.questionWiseReportData));
            this.isLoading = false;
        })
        .catch(error => {
            this.error = JSON.stringify(error);
            this.isLoading = false;
        })
    }
}