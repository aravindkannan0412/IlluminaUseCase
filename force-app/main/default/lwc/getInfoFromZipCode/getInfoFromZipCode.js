import { LightningElement ,wire} from 'lwc';
import getZipCodeData from '@salesforce/apex/GetInfoFromZipCode_LT.getZipCodeData';
import upsertPlaces from '@salesforce/apex/GetInfoFromZipCode_LT.upsertPlaces';
import PLACESPOSTALCODE_OBJECT from "@salesforce/schema/PlacesFromPostalCode__c";
import COUNTRYCODE_FIELD from "@salesforce/schema/PlacesFromPostalCode__c.CountryCode__c"
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import LightningAlert from 'lightning/alert';

const BATCHSIZE=150;
const MAX_CALLS=5;

export default class GetInfoFromZipCode extends LightningElement {
    //child properties
    childprops= {
     sobjectApiName:PLACESPOSTALCODE_OBJECT.objectApiName,
     sobjfieldApiName:COUNTRYCODE_FIELD,
     inputLabel:'Select Country',
     placeHolderLabel:'Search Countries',    
     targetComp:'AppPage',
     selectedpicklistvalue:'',
     isrequired:true
    };

    countryCodeOptions=[];
    countryCodeValue;
    zipCodeValue;
    timer;
    btnDisabled=true;
    zipCodeUsFlattenedLst=[];
    isUsOnly=false;
    showSpinner=false;
    btnLabel='Get Info'

    //hold the selected country code value
    handleComboBoxChange(event){
        this.countryCodeValue=event.detail;
    }

    //handles the zip code input change

    handleInputChange(event){
        let value = event.target.value;
        // Clear existing timeout if any
        if (this.timer) {
            window.clearTimeout(this.timer);
        }
        // Set new debounce timer
        this.timer = setTimeout(() => {
            this.zipCodeValue = value;
            this.btnDisabled = false;
        }, 3000);
    }

    hanldeClick(){
        if(!this.countryCodeValue || !this.zipCodeValue){
            this.showToastEvent('Error','Please select a country and enter the zip code','error','sticky');
        }
        else if(this.isUsOnly && this.btnLabel=='Close'){
            this.showSpinner=true;
            this.resetPage();
        }
        else{
            this.showSpinner=true;
            this.loadZipCodeData();
        }
       
    }



    async loadZipCodeData(){
        try{
            const zipCodeData=await getZipCodeData({countryCode:this.countryCodeValue,zipCode:this.zipCodeValue});
            const zipCodeFlattenedLst=this.getFlattenZipCodeData(zipCodeData);
            if(this.countryCodeValue==='US'){
                this.handleUsZipCodeData(zipCodeFlattenedLst);
               
            }else{
                this.handleNonUsZipCodeData(zipCodeFlattenedLst);
                this.resetPage();
            }

        }catch(error){
            this.handleError(error,'sticky');
        }
    }

    getFlattenZipCodeData(zipCodeData) {
        return zipCodeData.places.map(place => ({
            'sobjectType':PLACESPOSTALCODE_OBJECT.objectApiName,
            'PostalCode__c': zipCodeData['post code'],
            'Country__c': zipCodeData['country'],
            'CountryCode__c': zipCodeData['country abbreviation'],
            'PlaceName__c': place['place name'],
            'State__c': place['state'],
            'StateAbbreviation__c': place['state abbreviation'],
            'PlaceLocation__Latitude__s': parseFloat(place['latitude']),
            'PlaceLocation__Longitude__s': parseFloat(place['longitude']),
            'External_Id__c':place['place name'].replace(/[^a-zA-Z0-9]/g, "")+'-'+zipCodeData['country abbreviation']+'-'+zipCodeData['post code']+'-'+place['state'],

        }));
    }

    //show the US Data in UI using child component (treadted as another component)
    handleUsZipCodeData(zipCodeFlattenedLst){
        this.zipCodeUsFlattenedLst=[...zipCodeFlattenedLst];
        this.isUsOnly=true;
        this.showSpinner=false;
        this.btnLabel='Close';
    }

    //implementing a UI level batching for upserting the data
    async handleNonUsZipCodeData(zipCodeFlattenedLst){
       try{
            const recordsForUpsert=this.chunkArrUsingLoop(zipCodeFlattenedLst,BATCHSIZE);
            let noOfItems=1;
            let batches=[];
            for(const batch of recordsForUpsert){
                if(noOfItems>MAX_CALLS){
                    await Promise.all(batches);
                    batches=[];
                    noOfItems=1;
                }
                batches.push(this.upsertPlacesData(batch));
                noOfItems++;
            }
            //handle remaining calls
            if(batches.length){
                await Promise.all(batches);
            }

            await LightningAlert.open({message: 'Postal Places Records Created/Updated Successfully!!!',theme: 'success', label: 'Success!'});
        
       }catch(error){
            this.handleError(error,'sticky');
        }
    }

    chunkArrUsingLoop(array, batchSize) {
        let result = [];
        for (let i = 0; i < array.length; i += batchSize) {
            result.push(array.slice(i, i + batchSize));
        }
        return result;
    }

    upsertPlacesData(batch){
        upsertPlaces({placeRecords:batch})
        .then((result)=>{
            console.log(result);
        })
        .catch((error)=>{
            this.handleError(error,'dismissable');
        })
    }

    showToastEvent(title,message,variant,mode){
         const evt = new ShowToastEvent({title, message,variant,mode});
         this.dispatchEvent(evt);
    }

    resetPage(){

        this.btnLabel='Get Info';
        this.countryCodeValue='';
        this.zipCodeValue='';
        this.btnDisabled=true;
        this.showSpinner=false;
        this.zipCodeUsFlattenedLst=[];
        this.isUsOnly=false;
        
    }

    handleError(error,notifymode) {
        let errorMessage = "An unknown error occurred";
    
        if (error) {
            if (error.body && error.body.message) {
                errorMessage = error.body.message; 
            } else if (error.message) {
                errorMessage = error.message; 
            } else if (Array.isArray(error.body) && error.body.length > 0 && error.body[0].message) {
                errorMessage = error.body[0].message; 
            }
        }
    
        this.showToastEvent('Error',errorMessage,'error',notifymode);
        this.resetPage();
    }
    
    async handleAlertClick() {
        await LightningAlert.open({
            message: 'this is the alert message',
            theme: 'error', // a red theme intended for error states
            label: 'Error!', // this is the header text
        });
        //Alert has been closed
    }
}