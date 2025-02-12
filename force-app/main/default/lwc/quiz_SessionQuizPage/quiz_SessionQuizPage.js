import { api, LightningElement, track } from 'lwc';
import fetchQuestion from '@salesforce/apex/Quiz_SessionJoinPageCtrl.fetchQuestion';
import checkExamStatus from '@salesforce/apex/Quiz_SessionJoinPageCtrl.checkExamStart';
import submitAnswerDB from '@salesforce/apex/Quiz_SessionJoinPageCtrl.submitAnswerDB';
import checkSessionStart from '@salesforce/apex/Quiz_SessionJoinPageCtrl.checkSessionStart';

export default class Quiz_SessionQuizPage extends LightningElement {
    timerId;
    startCheckId;
    @track sessionQuizPageFlag = true;
    @track examCompletedFlag = false;
    @track quizStartFlag = false;
    @track waitingSpinnerFlag = true;
    @track timeLeft = 0;//parseInt()
    @api sessionpayload = {};
    @api currentquestionpayload = {};
    offsetNumber = 0;
    @track error;
    submitAnswerJSON = [];//JSON.parse(JSONString);
    resultRecId = '';
    nextButtonLabel = 'Submit & Next';
    isLoading = false;

    get formattedTime() {
        const minutes = Math.floor(this.timeLeft / 60);
        const seconds = this.timeLeft % 60;
        return `${minutes}:${seconds < 10 ? '0' : ''}${seconds}`;
    }

    connectedCallback(){
        this.isLoading = true;
        console.log('sessionpayload---->');
        console.log(JSON.stringify(this.sessionpayload));
        window.addEventListener('beforeunload', this.beforeUnloadHandler.bind(this));
        this.checkExamPolling();
        this.isLoading = false;
    }

    beforeUnloadHandler(event){
        clearInterval(this.timerId);
        clearInterval(this.startCheckId);
        checkSessionStart({ 
            userId: this.sessionpayload.userRecId,
            sessionId: this.sessionpayload.sessionId
        })
        .then(result => {
        })
        .catch(error => {
            console.log('error->'+error);
            this.error = error;
        })
    }

    disconnectedCallback() {
        window.removeEventListener("beforeunload", this.beforeUnloadHandler);
        console.log("disconnectedCallback executed");
      }

    checkExamPolling(){
        this.startCheckId = setInterval(() => {
            this.checkStart();
        }, 3000);
        const event = new CustomEvent('myevent', {
            detail: {
               intervalId: this.startCheckId
           } 
       });
        window.dispatchEvent(event);
    }

    checkStart(){
        console.log('checkStart');
        checkExamStatus({ 
            sessionId: this.sessionpayload.sessionId
        })
        .then(result => {
            if(result == 'started'){
                clearInterval(this.startCheckId);
                this.quizStartFlag = true;
                this.waitingSpinnerFlag = false;
                this.getQuestion();
                this.startTimer();
            }
        })
        .catch(error => {
            this.error = error;
        })
    }

    startTimer() {
        this.timeLeft = parseInt(this.sessionpayload.totalTime)*60;
        this.timerId = setInterval(() => {
            if (this.timeLeft > 0) {
                this.timeLeft--;
            } else {
                clearInterval(this.timerId);
                this.handleAutoSubmit();
            }
        }, 1000);
        const event = new CustomEvent('myevent', {
            detail: {
               intervalId: this.timerId
           } 
       });
        window.dispatchEvent(event);
    }

    handleAutoSubmit(){
        console.log('handleAutoSubmit');
        this.handleManualSubmit();
    }

    handleManualSubmit(){
        console.log('handleAutoSubmit');
        clearInterval(this.timerId);
        this.examCompletedFlag = true;
        this.sessionQuizPageFlag = false;
    }

    getQuestion(){
        this.isLoading = true;
        console.log('getQuestion');
        fetchQuestion({ 
            assessmentId: this.sessionpayload.assessmentId,
            offset: this.offsetNumber
        })
        .then(result => {
            if(result.error){
                console.log('error part');
                this.error=result.error;
            }
            else{
                this.nextButtonLabel = result.finalQuestion == 'true' ? 'Submit' : 'Submit & Next';
                if(result.filterMesage!='completed'){
                    this.currentquestionpayload = result;
                    this.offsetNumber = this.offsetNumber+1;
                }
                else{
                    this.handleManualSubmit();
                }
            }
            this.isLoading = false;
        })
        .catch(error => {
            this.error = error;
            this.isLoading = false;
        })
    }

    /*ansChange(event){
        const isChecked = event.target.checked;
        const selectedAnsId = event.target.dataset.id;
        console.log('selectedAnsId->'+selectedAnsId);
        this.currentquestionpayload.answerList = this.currentquestionpayload.answerList.map(q => 
            q.answerId === selectedAnsId ? { ...q, isSelected: isChecked } : q
        );
        console.log('currentquestionpayload'+JSON.stringify(this.currentquestionpayload));
    }*/
    ansChange(event) {
        const selectedAnsId = event.target.dataset.id;
        const isChecked = event.target.checked;
        const questionId = event.target.name; // Identifies the question
        
        console.log('Selected Answer ID -> ' + selectedAnsId);
        console.log('Question ID -> ' + questionId);
        
        // Check if the question allows multiple answers
        if (this.currentquestionpayload.isMultiAnswer) {
            // ✅ Multi-Answer: Allow multiple checkboxes to be selected
            this.currentquestionpayload.answerList = this.currentquestionpayload.answerList.map(ans => 
                ans.answerId === selectedAnsId ? { ...ans, isSelected: isChecked } : ans
            );
        } else {
            // ✅ Single-Answer: Ensure only one radio button is selected
            this.currentquestionpayload.answerList = this.currentquestionpayload.answerList.map(ans => 
                ({ ...ans, isSelected: ans.answerId === selectedAnsId }) // Mark only the selected one as true
            );
        }
    
        console.log('Updated Payload:', JSON.stringify(this.currentquestionpayload));
    }
    

    nextClick(){
        console.log('nextClick');
        this.submitAnswer();
        this.getQuestion();
    }

    submitAnswer(){
        this.submitAnswerJSON.push(this.currentquestionpayload);
        submitAnswerDB({ 
            quizUserId: this.sessionpayload.userRecId,
            sessionId: this.sessionpayload.sessionId,
            result: JSON.stringify(this.submitAnswerJSON),
            resultRecId: this.resultRecId
        })
        .then(result => {
            console.log('resultRecId->'+this.resultRecId);
            this.resultRecId = result;
        })
        .catch(error => {
            console.log('submitAnswerDB error->'+error);
            this.error = JSON.stringify(error);
        })
    }

    disconnectedCallback(){
        console.log('disconnectedCallback');
        clearTimeout(this.timerId);
        clearTimeout(this.startCheckId);
    }

}