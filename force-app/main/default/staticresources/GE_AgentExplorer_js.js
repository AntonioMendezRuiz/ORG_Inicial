
function togglePostponedFields(idprefix, campaignStatusLabel){
    const postponePersonElem = document.getElementById(idprefix + "postponePersonField");
    const postponeDatetimeElem = document.getElementById(idprefix +"postponeDatetimeField");
    for(let elem of document.getElementsByClassName("postpone-row")) {
        if(campaignStatusLabel.includes("APLAZADO")) {
            elem.style.display = "inline";
            //
            if(postponePersonElem.value == "")
            	postponePersonElem.value = user.Name;
            
            postponePersonElem.required = false;
            postponeDatetimeElem.required = true;
        } else {
            elem.style.display = "none";
            //postponePersonElem.value = "";
            postponeDatetimeElem.value = "";
            postponePersonElem.required = false;
            postponeDatetimeElem.required = false;
        }
    }
}

function toggleNonEngagedFields(idprefix, campaignStatusLabel) {
    const nonEngagedReasonElem = document.getElementById(idprefix + "nonEngagedReasonField");
    
    for(let elem of document.getElementsByClassName("nonengaged-row")) {
        if(campaignStatusLabel.includes("NO CONTRATA")) {
            elem.style.display = "inline";
        } else {
            elem.style.display = "none";
            nonEngagedReasonElem.value = "";
        }
    }
}

function toggleInvalidReasonFields(idprefix, campaignStatusLabel) {
    console.log("toggleInvalidReasonFields");
    const invalidReasonElem = document.getElementById(idprefix + "invalidReasonField");
    
    for(let elem of document.getElementsByClassName("invalidreasonfield-row")) {
        if(campaignStatusLabel.includes("NO V\u00C1LIDO")) {
            elem.style.display = "inline";
        } else {
            elem.style.display = "none";
            invalidReasonElem.value = "";
        }
    }
}

function validateHolderEmail(idprefix,campaignStatusLabel) {
    const holderEmailElem = document.getElementById(idprefix + "holderEmail");
	const SI_CONTRATA = 'S'+String.fromCharCode(205)+' CONTRATA';
    
    if((campaignStatusLabel.includes(SI_CONTRATA)) || (campaignStatusLabel.includes("SI CONTRATA"))) {
        console.log("REQUIRED");
        holderEmailElem.required = "true";
    } else {
        console.log("NON REQUIRED");
        holderEmailElem.removeAttribute('required');
    }
}

function onChangeStatusField(idprefix) {
    const campaignStatus = document.getElementById(idprefix+"statusField");
    const campaignStatusLabel = campaignStatus.options[campaignStatus.selectedIndex].label.toUpperCase();
    
    togglePostponedFields(idprefix, campaignStatusLabel);
    toggleNonEngagedFields(idprefix, campaignStatusLabel);
    toggleInvalidReasonFields(idprefix, campaignStatusLabel);
    validateHolderEmail(idprefix, campaignStatusLabel);
    
}

function toggleOtherElectricalCompanyField(elementId) {
    const currentCompany = document.getElementById(elementId).value;
    
    for(let elem of document.getElementsByClassName("otherElectrical-row")) {
        if(currentCompany.toUpperCase() === 'OTRO') {
            elem.style.display = "inline";
        } else {
            elem.value = '';
            elem.style.display = "none";
        }
    }    
}

function toggleOtherGasCompanyField(elementId) {
    const currentCompany = document.getElementById(elementId).value;
    
    for(let elem of document.getElementsByClassName("otherGas-row")) {
        if(currentCompany.toUpperCase() === 'OTRO') {
            elem.style.display = "inline";
        } else {
            elem.value = '';
            elem.style.display = "none";
        }
    } 
}

function toggleHistoricalTabs(tabIndex) {
    const unsignedTabIndex = Math.abs(tabIndex);
    
    for(let i = 2; i >= 0; i--) {
        let tabHeadElement = document.getElementById("tab-header-default-"+i);
        let tabContentElement = document.getElementById("tab-default-"+i);
        if(i == unsignedTabIndex) {
            tabHeadElement.classList.add("slds-is-active");
            tabContentElement.classList.add("slds-show");
            tabContentElement.classList.remove("slds-hide");
        } else {
            tabHeadElement.classList.remove("slds-is-active");
            tabContentElement.classList.remove("slds-show");
            tabContentElement.classList.add("slds-hide");
            
        }
    }
}

window.onload = function () {
    // Hide Subscription status fields
    this.onChangeStatusField('AgentExplorer:subscriberForm:campaignSubscriptionInfo:CampaignSubscriptionInfoCmp:');
    
    
    // Hide/Display other company fields:
    this.toggleOtherElectricalCompanyField('AgentExplorer:subscriberForm:campaignSubscriptionInfo:CampaignSubscriptionInfoCmp:electricalCompanySelect');
    this.toggleOtherGasCompanyField('AgentExplorer:subscriberForm:campaignSubscriptionInfo:CampaignSubscriptionInfoCmp:gasCompanySelect');
}
