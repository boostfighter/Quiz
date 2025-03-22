import { LightningElement, track, api } from 'lwc';
import loginValidate from '@salesforce/apex/Quiz_Login.loginValidate';

export default class Quiz_LoginPage extends LightningElement {
    @track loginPageFlag = false;
    @track adminDashboardFlag = false;
    @api userpayload = {};
    @api userId = '';
    @track entEmail = '';
    @track entPassword = '';
    @track error = '';
    backbuttonFlag = false;
    homebuttonFlag = false;
    logoutbuttonFlag = false;
    isLoading = false;

    connectedCallback(){
        const username = localStorage.getItem('quizusername') || '';
        const password = localStorage.getItem('quizpassword') || '';
        if(username!='' && password!=''){
            this.entEmail = username;
            this.entPassword = password;
            this.loginClick();
        }
        else{
            this.loginPageFlag = true;
        }
    }

    loginClick(){
        this.isLoading = true;
        loginValidate({ 
            email: this.entEmail,
            password: this.entPassword
            })
		.then(result => {
			console.log('userId--->'+result.userId+'   error--->'+result.error);
            if(result.error){
                console.log('error part');
                this.error=result.error;
            }
            else{
                console.log('else part');
                this.userpayload = result;
                this.userId = result.userId;
                this.adminDashboardFlag = true;
                this.loginPageFlag = false;
                localStorage.setItem('quizusername', this.entEmail);
                localStorage.setItem('quizpassword', this.entPassword);
            }
            this.isLoading = false;
		})
		.catch(error => {
			this.error = error;
            this.isLoading = false;
		})
    }

    registerClick(){

    }

    emailChange(event){
        this.entEmail= event.target.value;
        this.error = '';
    }
    passwordChange(event){
        this.entPassword= event.target.value;
        this.error = '';
    }

}