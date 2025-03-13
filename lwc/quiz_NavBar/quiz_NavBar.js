import { api, LightningElement } from 'lwc';
import COMPANY_LOGO from '@salesforce/resourceUrl/companyLogo'; 

export default class Quiz_NavBar extends LightningElement {
    companyLogo = COMPANY_LOGO;
    @api backbutton = false;
    @api homebutton = false;
    @api logoutbutton = false;
    allSetIntervalIds = [];

    connectedCallback(){
        window.addEventListener('myevent', (event) => {
            this.allSetIntervalIds.push(event.detail.intervalId);
        });
    }

    handleBack() {
        //this.dispatchEvent(new CustomEvent('navigate', { detail: 'back' }));
    }

    handleHome() {
        this.clearAllIntervals();
        this.dispatchEvent(new CustomEvent('navigate', { detail: 'homeClick' }));
    }

    handleLogout() {
        //this.dispatchEvent(new CustomEvent('logout'));
        localStorage.removeItem('quizusername');
        localStorage.removeItem('quizpassword');
        window.location.reload();
    }

    clearAllIntervals() {
        // Clear all tracked intervals
        this.allSetIntervalIds.forEach(clearInterval);
        this.allSetIntervalIds = [];
    }
}