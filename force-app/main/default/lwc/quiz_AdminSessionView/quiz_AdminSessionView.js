import { LightningElement, api, track } from 'lwc';
import fetchSessionDetails from '@salesforce/apex/Quiz_AdminSessionViewCtrl.fetchSessionDetails';
import startSession from '@salesforce/apex/Quiz_AdminSessionViewCtrl.startSession';
import endSession from '@salesforce/apex/Quiz_AdminSessionViewCtrl.endSession';
import fetchJoinee from '@salesforce/apex/Quiz_AdminSessionViewCtrl.fetchJoinee';

export default class Quiz_AdminSessionView extends LightningElement {
    @api userpayload = {};
    @api assessmentpayload = {};
    @api assessmentid = '';
    @api createdsessionid = '';
    adminSessionViewFlag = true;
    @track sessionrecdetails = {};
    @track isSessionRunning = false;
    @track endSessionFlag = true;
    @track error;
    @track sessionStartFlag = false;
    timerId;
    timeLeft = 0;
    joineeDetailsIntervalId;
    @track joineedata = [{userId: '', index: '', userFullName: '', userEmail: '', userTabChange: ''}];
    isLoading = false;

    get formattedTime() {
        const minutes = Math.floor(this.timeLeft / 60);
        const seconds = this.timeLeft % 60;
        return `${minutes}:${seconds < 10 ? '0' : ''}${seconds}`;
    }

    connectedCallback(){
        this.isLoading = true;
        fetchSessionDetails({ 
            sessionId: this.createdsessionid
        })
        .then(result => {
            this.sessionrecdetails = result;
            if(this.sessionrecdetails.Session_Status == 'Initialize'){
                this.isSessionRunning = false;
                this.endSessionFlag = true;
            }
            else if(this.sessionrecdetails.Session_Status == 'Running'){
                this.isSessionRunning = true;
                this.endSessionFlag = false;
            }
            else if(this.sessionrecdetails.Session_Status == 'Completed'){
                this.isSessionRunning = true;
                this.endSessionFlag = true;
            }
            else if(this.sessionrecdetails.Session_Status == 'Scheduled'){
                this.isSessionRunning = true;
                this.endSessionFlag = true;
            }
            this.fetchJoineePolling();
            this.isLoading = false;
        })
        .catch(error => {
            this.error = JSON.stringify(error);
            console.log('error1->'+error);
            console.log('error2->'+this.error);
            this.isLoading = false;
        })
    }

    fetchJoineePolling() {
        this.joineeDetailsIntervalId = setInterval(() => {
            this.fetchJoineeDetails();
        }, 3000);
        const event = new CustomEvent('myevent', {
             detail: {
                intervalId: this.joineeDetailsIntervalId
            } 
        });
        window.dispatchEvent(event);
    }

    fetchJoineeDetails(){
        console.log('fetchJoineeDetails');
        fetchJoinee({ 
            sessionId: this.createdsessionid
        })
        .then(result => {
            this.joineedata = result;
        })
        .catch(error => {
            this.error = JSON.stringify(error);
        })
    }

    clickToStartSession(){
        this.isLoading = true;
        this.sessionStartFlag = true;
        this.isSessionRunning = true;
        startSession({ 
            sessionId: this.createdsessionid
        })
        .then(result => {
            this.endSessionFlag = false;
            this.startTimer();
            this.isLoading = false;
        })
        .catch(error => {
            this.error = JSON.stringify(error);
            this.isLoading = false;
        })
    }

    startTimer() {
        this.timeLeft = parseInt(this.sessionrecdetails.Session_Time_Minutes)*60;
        this.timerId = setInterval(() => {
            if (this.timeLeft > 0) {
                this.timeLeft--;
            } else {
                clearInterval(this.timerId);
            }
        }, 1000);
        const event = new CustomEvent('myevent', {
            detail: {
               intervalId: this.timerId
           } 
       });
        window.dispatchEvent(event);
    }

    clickToEndSession(){
        this.isLoading = true;
        this.endSessionFlag = true;
        endSession({ 
            sessionId: this.createdsessionid
        })
        .then(result => {
            this.isSessionRunning = true;
            clearInterval(this.timerId);
            this.sessionStartFlag = false;
            this.isLoading = false;
        })
        .catch(error => {
            this.error = JSON.stringify(error);
            this.isLoading = false;
        })
    }
}