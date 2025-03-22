import { api, LightningElement, track } from 'lwc';
import addQuestion from '@salesforce/apex/Quiz_AdminAssessmentCtrl.createQuestion';
import fetchAssessmentDetails from '@salesforce/apex/Quiz_AdminAssessmentCtrl.fetchAssessmentDetails';
import createSession from '@salesforce/apex/Quiz_AdminAssessmentCtrl.createSession';
import fetchSessionDetails from '@salesforce/apex/Quiz_AdminAssessmentCtrl.fetchSessionDetails';
import deleteQuestion from '@salesforce/apex/Quiz_AdminAssessmentCtrl.deleteQuestion';
import fetchQuesToEdit from '@salesforce/apex/Quiz_AdminAssessmentCtrl.fetchQuesToEdit';

export default class Quiz_AdminAssessmentView extends LightningElement {
    @track adminAssessmentViewFlag = true;
    isShowModal = false;
    isShowModalSessionCreate = false;
    adminSessionViewFlag = false;
    fetchSessionDetailsFlag = false;
    adminSessionResultFlag = false;
    @track error = '';
    studenthideflag = true;
    @api userpayload = {};
    @api assessmentpayload = {};
    @api assessmentid = '';
    @api createdsessionid = '';
    sessionName = '';
    sessionTimeValue = null;
    @track allsessiondata = {};
    isLoading = false;
    questionPayload = {};

    connectedCallback(){
        this.isLoading = true;
        console.log('AAV assessmentId--->'+this.assessmentid);
        fetchAssessmentDetails({ 
            assessmentId: this.assessmentid
        })
        .then(result => {
            this.assessmentpayload = result;
            console.log('AAV assessmentpayload Name--->'+this.assessmentpayload.assessmentName);
            this.isLoading = false;
        })
        .catch(error => {
            this.error = JSON.stringify(error);
            this.isLoading = false;
        })
    }

    handleEdit(event) {
        this.isLoading = true;
        fetchQuesToEdit({ 
            questionId: event.target.dataset.quesid
        })
        .then(result => {
            this.isShowModal = true;
            this.questionPayload = result;
            console.log('ques Id->'+this.questionPayload.quesId);
            this.isLoading = false;
        })
        .catch(error => {
            this.error = JSON.stringify(error);
            this.isLoading = false;
        })
    }
    handleDelete(event) {
        this.isLoading = true;
        deleteQuestion({ 
            questionId: event.target.dataset.quesid
        })
        .then(result => {
            this.connectedCallback();
        })
        .catch(error => {
            this.error = JSON.stringify(error);
            this.isLoading = false;
        })
    }

    clickViewResult(){
        this.isLoading = true;
        fetchSessionDetails({ 
            assessmentId: this.assessmentid
        })
        .then(result => {
            this.allsessiondata = result;
            this.fetchSessionDetailsFlag = true;
            this.isLoading = false;
        })
        .catch(error => {
            this.error = JSON.stringify(error);
            this.isLoading = false;
        })
    }
    hideModalBoxSessionDetails(){
        this.fetchSessionDetailsFlag = false;
    }

    sessionNameClick(event){
        console.log('createdsessionid'+this.createdsessionid);
        this.createdsessionid = event.target.dataset.sessionid;
        const selectedSessionStatus = event.target.dataset.sessionstatus;
        if(selectedSessionStatus == 'Completed'){
            this.adminSessionResultFlag = true;
            this.fetchSessionDetailsFlag = false;
            this.adminAssessmentViewFlag = false;
            this.isShowModalSessionCreate = false;
        }
        else{
            this.adminSessionViewFlag = true;
            this.fetchSessionDetailsFlag = false;
            this.adminAssessmentViewFlag = false;
            this.isShowModalSessionCreate = false;
        }
    }

    sessionNameChange(event){
        this.sessionName = event.target.value;
    }
    sessionTimeChange(event){
        this.sessionTimeValue = event.target.value;
    }

    createSession(){
        this.isLoading = true;
        createSession({ 
            sessionName: this.sessionName,
            sessionTime: this.sessionTimeValue,
            assessmentId: this.assessmentid
        })
        .then(result => {
            this.createdsessionid = result;
            this.adminAssessmentViewFlag = false;
            this.isShowModalSessionCreate = false;
            this.adminSessionViewFlag = true;
            this.isLoading = false;
        })
        .catch(error => {
            this.error = JSON.stringify(error);
            this.isLoading = false;
        })
    }

    clickStartSession(){
        this.isShowModalSessionCreate = true;
    }

    clickAddQuestion(){
        this.isShowModal = true;
        this.questionPayload = {};
    }

    createQuestion(){
        this.isLoading = true;
        console.log('questionPayload->'+JSON.stringify(this.questionPayload));
        addQuestion({ 
            assessmentId: this.assessmentid,
            questionPayloadParam : JSON.stringify(this.questionPayload)
        }).then(result => { 
            this.isShowModal = false;
            this.connectedCallback();
            document.documentElement.scrollTop = document.documentElement.scrollHeight;
            this.questionPayload = {};
        })
        .catch(error => {
			this.error = JSON.stringify(error);
            this.isLoading = false;
		});
    }

    questionChange(event){
        this.questionPayload.questionName = event.target.value;
    }
    answer1Change(event){
        this.questionPayload.answerName1 = event.target.value;
    }
    answer2Change(event){
        this.questionPayload.answerName2 = event.target.value;
    }
    answer3Change(event){
        this.questionPayload.answerName3 = event.target.value;
    }
    answer4Change(event){
        this.questionPayload.answerName4 = event.target.value;
    }
    answer5Change(event){
        this.questionPayload.answerName5 = event.target.value;
    }
    answer6Change(event){
        this.questionPayload.answerName6 = event.target.value;
    }
    check1Change(event) {
        this.questionPayload.isTrue1 = event.target.checked;
    }
    check2Change(event) {
        this.questionPayload.isTrue2 = event.target.checked;
    }
    check3Change(event) {
        this.questionPayload.isTrue3 = event.target.checked;
    }
    check4Change(event) {
        this.questionPayload.isTrue4 = event.target.checked;
    }
    check5Change(event) {
        this.questionPayload.isTrue5 = event.target.checked;
    }
    check6Change(event) {
        this.questionPayload.isTrue6 = event.target.checked;
    }


    hideModalBox(){
        this.isShowModal = false;
    }
    hideModalBoxSessionCreate(){
        this.isShowModalSessionCreate = false;
    }


}