import { LightningElement, track } from 'lwc';
import joinQuiz from '@salesforce/apex/Quiz_SessionJoinPageCtrl.joinQuiz';
import checkQuizResult from '@salesforce/apex/Quiz_SessionJoinPageCtrl.checkQuizResult';

export default class Quiz_SessionJoinPage extends LightningElement {
    @track sessionJoinFlag = true;
    @track sessionQuizFlag = false;
    joinButtonDisabled = false;
    checkResultFlag = false;
    SessionResultFlag = false;
    @track joinCode = '';
    @track studentName = '';
    @track studentEmail = '';
    @track error = '';
    @track sessionpayload = {};
    resultCode = '';
    resultEmail = '';
    // createdsessionid='';
    // userpayload={};
    // assessmentpayload={};
    // studenthideflag = false;
    backbuttonFlag = false;
    homebuttonFlag = false;
    logoutbuttonFlag = false;
    isLoading = false;

    joinClick(){
        this.isLoading = true;
        if(this.joinCode == '' || this.studentName == '' || this.studentEmail == ''){
            this.error = 'Please fill all the fields';
            this.isLoading = false;
        }
        else{
            this.joinButtonDisabled = true;
            joinQuiz({ 
                joinCode: this.joinCode,
                studentName: this.studentName,
                studentEmail: this.studentEmail
            })
            .then(result => {
                if(result.error){
                    console.log('error part');
                    this.error=result.error;
                    this.joinButtonDisabled = false;
                }
                else{
                    console.log('joined');
                    this.sessionpayload = result;
                    this.sessionJoinFlag = false;
                    this.sessionQuizFlag = true;
                }
                this.isLoading = false;
            })
            .catch(error => {
                this.joinButtonDisabled = false;
                if(JSON.stringify(error).includes("INVALID_EMAIL_ADDRESS")){
                    this.error = 'INVALID_EMAIL_ADDRESS';
                }
                else{
                    this.error = JSON.stringify(error);
                    console.log('error->'+this.error);
                }
                this.isLoading = false;
            })
        }
    }

    hideModalBoxCheckResult(){
        this.checkResultFlag = false;
    }

    checkResult(){
        this.checkResultFlag = true;
    }

    /*resultView(){
        this.isLoading = true;
        if(this.resultCode == ''){
            this.error = 'Please fill all the fields';
        }
        else{
            checkQuizResult({ 
                quizCode: this.resultCode
            })
            .then(result => {
                if(result.error){
                    console.log('error');
                    this.error=result.error;
                }
                else{
                    console.log('fetched');
                    //console.log(JSON.stringify(result));
                    this.checkResultFlag = false;
                    this.sessionJoinFlag = false;
                    this.SessionResultFlag = true;
                    this.createdsessionid = result.sessionId;
                    this.userpayload = result.userpayload;
                    this.assessmentpayload = result.assessmentpayload;
                }
                this.isLoading = false;
            })
            .catch(error => {
                this.error = JSON.stringify(error);
                console.log('checkQuizResult error->'+this.error);
                this.isLoading = false;
            })
        }
    }*/

    resultView(){
        this.checkResultFlag = false;
        this.sessionJoinFlag = false;
        this.SessionResultFlag = true;
    }

    codeChange(event){
        this.joinCode = event.target.value;
        this.error = '';
    }
    nameChange(event){
        this.studentName = event.target.value;
        this.error = '';
    }
    emailChange(event){
        this.studentEmail = event.target.value;
        this.error = '';
    }
    resultCodeChange(event){
        this.resultCode = event.target.value;
        this.error = '';
    }
    resultEmailChange(event){
        this.resultEmail = event.target.value;
        this.error = '';
    }

}