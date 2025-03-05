import { LightningElement, track } from 'lwc';

export default class Quiz_LandingPage extends LightningElement {
    @track landingPageFlag = false;
    @track adminFlag = false;
    @track learnerFlag = false;
    username = '';
    password = '';
    backbuttonFlag = false;
    homebuttonFlag = false;
    logoutbuttonFlag = false;

    connectedCallback(){
        //get the credentials---
        this.username = localStorage.getItem('quizusername') || '';
        this.password = localStorage.getItem('quizpassword') || '';
        if(this.username!='' && this.password!=''){
            this.adminClick();
        }
        else{
            this.landingPageFlag = true;
        }

    }
    
    adminClick(){
        this.landingPageFlag = false;
        this.adminFlag = true;
        this.learnerFlag = false;
    }

    learnerClick(){
        this.landingPageFlag = false;
        this.adminFlag = false;
        this.learnerFlag = true;
    }
}