import { LightningElement, wire, api } from 'lwc';
import { getObjectInfo,getPicklistValues } from "lightning/uiObjectInfoApi";
import { FlowAttributeChangeEvent} from 'lightning/flowSupport';


export default class SearchablePicklistComboBox extends LightningElement {

    @api sobjectApiName='';
    @api sobjfieldApiName='';
    @api inputLabel='';
    @api placeHolderLabel='';
    @api targetComp='';
    @api selectedpicklistvalue='';
    @api isrequired=false;

    pickListOptions = [];
    searchResults=[];
    showSearchResults=false;
    selectedSearchResult;

    get selectedValue() {
        return this.selectedSearchResult
                    ? this.selectedSearchResult.label
                    : '';
    }

    //gets object info as a property
    @wire(getObjectInfo, { objectApiName:"$sobjectApiName"})
    sobjectInfo;

    //gets picklist values from the object
    @wire(getPicklistValues, { recordTypeId:"$sobjectInfo.data.defaultRecordTypeId",fieldApiName:"$sobjfieldApiName"})
    getCountryCodes({ error, data }) {
        if (data) {
        this.pickListOptions = data.values.map(item=>({ "label": item.label,"value": item.value }));
        console.log('in child component' +JSON.stringify(this.pickListOptions))
        } else if (error) {
        console.log(error);
        }
    }
     
    hidePickListOptions(event) {
        this.clearSearchResults();
    }
        
    /** 
     * Filter the values to whatever text was entered - case insensitive 
     * */
    doSearch(event) {
        const input = event.detail.value.toLowerCase();
        const result = this.pickListOptions.filter((pickListOption) =>
            pickListOption.label.toLowerCase().includes(input));
        
        this.searchResults = [...result];
        if(!input){//when removing the search element directly
            this.selectedpicklistvalue='';
            this.notifyParentComponent();
        }
    }
    
    /** 
     * Set the selected value 
     * */
    selectSearchResult(event) {
        const selectedValue = event.currentTarget.dataset.value;
        console.log('event.currentTarget.dataset.value',event.currentTarget.dataset.value);
        this.selectedSearchResult = this.pickListOptions.find(
            (pickListOption) => pickListOption.value === selectedValue
        );
        this.selectedpicklistvalue=this.selectedSearchResult.value;
        this.clearSearchResults();
        this.notifyParentComponent();
    }
    
    /**
     * Clear the results
     * */
    clearSearchResults() {
        this.showSearchResults=false;
        this.searchResults = [];
    }
    
    /**
     * Invoked when inputbox is focused
     */
    showPickListOptions() {                
        if (!this.showSearchResults) {
            this.showSearchResults=true;
            this.searchResults = [...this.pickListOptions];
            
        }
    }

    notifyParentComponent(){
        let attributeChangeEvent=(this.targetComp==='AppPage') ? new CustomEvent('selected',{detail:this.selectedpicklistvalue}) 
                                  : new FlowAttributeChangeEvent('selectedpicklistvalue',this.selectedpicklistvalue);
        if(attributeChangeEvent){
            this.dispatchEvent(attributeChangeEvent);
        }
    }
}