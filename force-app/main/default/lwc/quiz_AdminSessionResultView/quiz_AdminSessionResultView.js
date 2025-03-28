import { api, LightningElement, track } from 'lwc';
import fetchSessionResultPayload from '@salesforce/apex/Quiz_SessionResultCtrl.getSessionResultPayload';
import fetchStudentResultPayload from '@salesforce/apex/Quiz_SessionResultCtrl.getStudentResultPayload';
import publishResultDB from '@salesforce/apex/Quiz_SessionResultCtrl.publishResultDB';

export default class Quiz_AdminSessionResultView extends LightningElement {
    @track error;
    adminResultViewFlag = true;
    // selectStudentResultFlag = false;
    @api studenthideflag = false;
    @api createdsessionid = '';
    @api userpayload = {};
    @api assessmentpayload = {};
    @api sessionresultpayload = {};
    // selectStudentPayload = {};
    // selectStudentRecId = '';
    isPublished = true;
    isLoading = false;
    anonymousUserFlag = true;

    connectedCallback(){
        this.isLoading = true;

        const username = localStorage.getItem('quizusername') || '';
        const password = localStorage.getItem('quizpassword') || '';
        if(username=='' && password==''){
            this.anonymousUserFlag = true;
        }
        else{
            this.anonymousUserFlag = false;
        }

        fetchSessionResultPayload({ 
            sessionId: this.createdsessionid
        })
        .then(result => {
            this.sessionresultpayload = result;
            this.isPublished = result.isPublished;
            this.isLoading = false;
        })
        .catch(error => {
            this.error = JSON.stringify(error);
            this.isLoading = false;
        })
    }

    // clickPublishResult(){
    //     this.isLoading = true;
    //     this.isPublished = true;
    //     publishResultDB({ 
    //         sessionId: this.createdsessionid
    //     })
    //     .then(result => {
    //         this.isLoading = false;
    //     })
    //     .catch(error => {
    //         this.error = JSON.stringify(error);
    //         this.isLoading = false;
    //     })
    // }

    // studentNameClick(event){
    //     this.isLoading = true;
    //     this.selectStudentRecId = event.target.dataset.studentid;
    //     fetchStudentResultPayload({ 
    //         studentId: this.selectStudentRecId,
    //         assessmentId : this.assessmentpayload.assessmentId
    //     })
    //     .then(result => {
    //         this.selectStudentPayload = result;
    //         this.isLoading = false;
    //         this.selectStudentResultFlag = true;
    //     })
    //     .catch(error => {
    //         this.error = JSON.stringify(error);
    //         this.isLoading = false;
    //     })
    // }

    // hideModalBoxSelectResultDetails(){
    //     this.selectStudentResultFlag = false;
    //     this.selectStudentPayload = {};
    // }
}