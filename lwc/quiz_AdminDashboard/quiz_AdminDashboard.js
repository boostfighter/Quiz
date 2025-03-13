import { LightningElement, api, track } from 'lwc';
import fetchAdminAssessment from '@salesforce/apex/Quiz_DashboardController.fetchAdminAssessment';
import createAssessment from '@salesforce/apex/Quiz_DashboardController.createAssessment';
import COMPANY_LOGO from '@salesforce/resourceUrl/companyLogo'; 

export default class Quiz_AdminDashboard extends LightningElement {
    companyLogo = COMPANY_LOGO;
    @track adminDashboardFlag = true;
    @api userpayload = {};
    @api assessmentpayload = {};
    isShowModal = false;
    assessmentName = '';
    adminAssessmentViewFlag = false;
    @api selectedAssessmentId = '';
    backbuttonFlag = false;
    homebuttonFlag = true;
    logoutbuttonFlag = true;
    isLoading = false;

    connectedCallback(){
        this.isLoading = true;
        console.log('admin dashboard connected call back fire'+this.userpayload.userId);
        fetchAdminAssessment({ 
            userId: this.userpayload.userId
            })
		.then(result => {
            if(result.error){
                console.log('error part');
                this.error=result.error;
            }
            else{
                console.log('else part');
                this.assessmentpayload = result;
            }
            this.isLoading = false;
		})
		.catch(error => {
			this.error = error;
            this.isLoading = false;
		})
    }

    navEvent(event) {
        //this.receivedValue = event.detail; // Get boolean from child
        if(event.detail === "homeClick"){
        this.adminAssessmentViewFlag = false;
        this.adminDashboardFlag = true;
        }
    }

    createQuizClick(){
        this.isShowModal = true;
    }

    hideModalBox(){
        this.isShowModal = false;
    }

    createAssessmentClick(){
        this.isLoading = true;
        createAssessment({ 
            userId: this.userpayload.userId,
            assessmentName: this.assessmentName
            })
		.then(result => {
            if(result.error){
                console.log('error part');
                this.error=result.error;
            }
            else{
                console.log('else part');
                this.connectedCallback();
                this.isShowModal = false;
            }
            this.isLoading = false;
		})
		.catch(error => {
			this.error = error;
            this.isLoading = false;
		})
    }

    clickAssessment(event){
        this.adminAssessmentViewFlag = true;
        this.adminDashboardFlag = false;
        this.selectedAssessmentId = event.target.dataset.assessId;//event.target.dataset.id
        console.log('assId->'+event.target.dataset.assessId);
    }

    assessmentChange(event){
        this.assessmentName = event.target.value;
    }

}