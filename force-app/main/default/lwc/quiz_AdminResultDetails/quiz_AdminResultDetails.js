import { LightningElement, api } from 'lwc';
import fetchStudentResultPayload from '@salesforce/apex/Quiz_SessionResultCtrl.getStudentResultPayload';

export default class Quiz_AdminResultDetails extends LightningElement {
    @api sessionresultpayload = {};
    @api assessmentpayload = {};
    isLoading = false;
    selectStudentRecId = '';
    selectStudentPayload = {};
    selectStudentResultFlag = false;
    error;

    studentNameClick(event){
        this.isLoading = true;
        this.selectStudentRecId = event.target.dataset.studentid;
        fetchStudentResultPayload({ 
            studentId: this.selectStudentRecId,
            assessmentId : this.assessmentpayload.assessmentId
        })
        .then(result => {
            this.selectStudentPayload = result;
            this.isLoading = false;
            this.selectStudentResultFlag = true;
        })
        .catch(error => {
            this.error = JSON.stringify(error);
            this.isLoading = false;
        })
    }

    hideModalBoxSelectResultDetails(){
        this.selectStudentResultFlag = false;
        this.selectStudentPayload = {};
    }
}