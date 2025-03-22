import { api, LightningElement } from 'lwc';
import fetchStudentResultPayload from '@salesforce/apex/Quiz_SessionResultCtrl.studentResultPayload';

export default class Quiz_StudentResultView extends LightningElement {
    @api resultEmail = '';
    @api resultCode = '';
    selectStudentPayload = {};
    isLoading = false;

    connectedCallback(){
        this.fetchResultDetails();
    }

    clickDownloadResult(){

    }

    fetchResultDetails(){
        this.isLoading = true;
        fetchStudentResultPayload({ 
            studentEmail: this.resultEmail,
            sessionCode : this.resultCode
        })
        .then(result => {
            this.selectStudentPayload = result;
            this.isLoading = false;
        })
        .catch(error => {
            this.error = JSON.stringify(error);
            this.isLoading = false;
        })
    }
}