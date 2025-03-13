import { api, LightningElement, track } from 'lwc';
import fetchQuestion from '@salesforce/apex/Quiz_SessionJoinPageCtrl.fetchQuestion';
import checkExamStatus from '@salesforce/apex/Quiz_SessionJoinPageCtrl.checkExamStart';
import submitAnswerDB from '@salesforce/apex/Quiz_SessionJoinPageCtrl.submitAnswerDB';
import checkSessionStart from '@salesforce/apex/Quiz_SessionJoinPageCtrl.checkSessionStart';
import fetchSessionResultPayload from '@salesforce/apex/Quiz_SessionResultCtrl.getSessionResultPayload';
import updateUserActivity from '@salesforce/apex/Quiz_SessionJoinPageCtrl.updateUserActivity';

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
    sessionresultpayload = {};
    studentResulPercentage = '0%';
    isPaused = false;

    @track allQuestions = [
        { quesId: 1, questionIndex: 1, attempted: false, pillClass: 'question-circle unattempted-pill' },
        { quesId: 2, questionIndex: 2, attempted: false, pillClass: 'question-circle attempted-pill' },
        { quesId: 3, questionIndex: 3, attempted: false, pillClass: 'question-circle review-pill' },
        { quesId: 4, questionIndex: 4, attempted: false, pillClass: 'question-circle unattempted-pill' },
        { quesId: 5, questionIndex: 5, attempted: false, pillClass: 'question-circle attempted-pill' },
        { quesId: 6, questionIndex: 6, attempted: false, pillClass: 'question-circle review-pill' },
        { quesId: 7, questionIndex: 7, attempted: false, pillClass: 'question-circle unattempted-pill' },
        { quesId: 8, questionIndex: 8, attempted: false, pillClass: 'question-circle attempted-pill' },
        { quesId: 9, questionIndex: 9, attempted: false, pillClass: 'question-circle review-pill' },
        { quesId: 10, questionIndex: 10, attempted: false, pillClass: 'question-circle unattempted-pill' },
        { quesId: 11, questionIndex: 11, attempted: false, pillClass: 'question-circle attempted-pill' },
        { quesId: 12, questionIndex: 12, attempted: false, pillClass: 'question-circle review-pill' },
        { quesId: 13, questionIndex: 13, attempted: false, pillClass: 'question-circle unattempted-pill' },
        { quesId: 14, questionIndex: 14, attempted: false, pillClass: 'question-circle attempted-pill' },
        { quesId: 15, questionIndex: 15, attempted: false, pillClass: 'question-circle review-pill' },
        { quesId: 16, questionIndex: 16, attempted: false, pillClass: 'question-circle unattempted-pill' },
        { quesId: 17, questionIndex: 17, attempted: false, pillClass: 'question-circle attempted-pill' },
        { quesId: 18, questionIndex: 18, attempted: false, pillClass: 'question-circle review-pill' },
        { quesId: 19, questionIndex: 19, attempted: false, pillClass: 'question-circle unattempted-pill' },
        { quesId: 20, questionIndex: 20, attempted: false, pillClass: 'question-circle attempted-pill' },
        // Add more questions dynamically
    ];

    get formattedTime() {
        const minutes = Math.floor(this.timeLeft / 60);
        const seconds = this.timeLeft % 60;
        return `${minutes}:${seconds < 10 ? '0' : ''}${seconds}`;
    }

    navigateToQuestion(){
        
    }

    constructor() {
        super();
        this.handleVisibilityChange = this.handleVisibilityChange.bind(this);
    }

    connectedCallback(){
        this.isLoading = true;
        window.addEventListener('beforeunload', this.beforeUnloadHandler.bind(this));
        this.checkExamPolling();
        this.isLoading = false;

        //document.addEventListener('visibilitychange', this.handleVisibilityChange.bind(this));
        // window.addEventListener('blur', this.handleBlur.bind(this));
        // window.addEventListener('focus', this.handleFocus.bind(this));
    }

    disconnectedCallback() {
        window.removeEventListener("beforeunload", this.beforeUnloadHandler.bind(this));
        //document.removeEventListener('visibilitychange', this.handleVisibilityChange.bind(this));
        document.removeEventListener('visibilitychange', this.handleVisibilityChange);
        // window.removeEventListener('blur', this.handleBlur.bind(this));
        // window.removeEventListener('focus', this.handleFocus.bind(this));
    }

    // handleBlur() {
    //     console.log('blur start');
    // }

    // handleFocus() {
    //     console.log('User returned to the browser');
    // }

    handleVisibilityChange() {
        if (document.visibilityState === 'hidden') {
            console.log('hidden');
            updateUserActivity({ 
                userId: this.sessionpayload.userRecId,
                inAnotherTab: true
            })
            .then(result => {
                console.log('result->'+result);
            })
            .catch(error => {
                console.log('error->'+JSON.stringify(error));
                this.error = JSON.stringify(error);
            })
            //alert('You switched tabs!\nThis may suspend your exam\nPlease do not switch your tab');
        } else {
            console.log('show');
            updateUserActivity({ 
                userId: this.sessionpayload.userRecId,
                inAnotherTab: false
            })
            .then(result => {
                console.log('result->'+result);
            })
            .catch(error => {
                console.log('error->'+JSON.stringify(error));
                this.error = JSON.stringify(error);
            })
            console.log('===================');
        }
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
        checkExamStatus({ 
            sessionId: this.sessionpayload.sessionId
        })
        .then(result => {
            if(result == 'started'){
                //document.addEventListener('visibilitychange', this.handleVisibilityChange.bind(this));
                document.addEventListener('visibilitychange', this.handleVisibilityChange);
                console.log('visibilitychange & blur event added');
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
            if (!this.isPaused && this.timeLeft > 0) {
                this.timeLeft--;
            } else if (this.timeLeft === 0) {
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
        this.handleManualSubmit();
    }

    handleManualSubmit(){
        //document.removeEventListener('visibilitychange', this.handleVisibilityChange.bind(this));
        document.removeEventListener('visibilitychange', this.handleVisibilityChange);
        this.isLoading = true;
        clearInterval(this.timerId);
        this.examCompletedFlag = true;
        this.sessionQuizPageFlag = false;
        fetchSessionResultPayload({ 
            sessionId: this.sessionpayload.sessionId
        })
        .then(result => {
            for(let i=0; i<result.studentList.length; i++){
                if(result.studentList[i].studentId == this.sessionpayload.userRecId){
                    this.studentResulPercentage = result.studentList[i].studentResulPercentage;
                    break;
                }
            }
            this.sessionresultpayload = result;
            //document.removeEventListener('visibilitychange', this.handleVisibilityChange.bind(this));
            this.isLoading = false;
        })
        .catch(error => {
            //document.removeEventListener('visibilitychange', this.handleVisibilityChange.bind(this));
            this.error = JSON.stringify(error);
            console.log('error->'+this.error);
            this.isLoading = false;
        })
    }

    getQuestion(){
        this.isLoading = true;
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
            this.isPaused = false;
        })
        .catch(error => {
            this.error = error;
            this.isLoading = false;
            this.getQuestion();
        })
    }

    ansChange(event) {
        const selectedAnsId = event.target.dataset.id;
        const isChecked = event.target.checked;
        const questionId = event.target.name; // Identifies the question
        
        // Check if the question allows multiple answers
        if (this.currentquestionpayload.isMultiAnswer) {
            // Multi-Answer: Allow multiple checkboxes to be selected
            this.currentquestionpayload.answerList = this.currentquestionpayload.answerList.map(ans => 
                ans.answerId === selectedAnsId ? { ...ans, isSelected: isChecked } : ans
            );
        } else {
            // Single-Answer: Ensure only one radio button is selected
            this.currentquestionpayload.answerList = this.currentquestionpayload.answerList.map(ans => 
                ({ ...ans, isSelected: ans.answerId === selectedAnsId }) // Mark only the selected one as true
            );
        }    
    }
    

    nextClick(){
        this.isPaused = true;
        this.submitAnswerJSON.push(this.currentquestionpayload);
        this.submitAnswer();
    }

    submitAnswer(){
        this.isLoading = true;
        submitAnswerDB({ 
            quizUserId: this.sessionpayload.userRecId,
            sessionId: this.sessionpayload.sessionId,
            result: JSON.stringify(this.submitAnswerJSON),
            resultRecId: this.resultRecId
        })
        .then(result => {
            this.resultRecId = result;
            this.getQuestion();
        })
        .catch(error => {
            console.log('submitAnswerDB error->'+error);
            this.error = JSON.stringify(error);
            this.submitAnswer();
        })
    }

    disconnectedCallback(){
        clearTimeout(this.timerId);
        clearTimeout(this.startCheckId);
    }

}