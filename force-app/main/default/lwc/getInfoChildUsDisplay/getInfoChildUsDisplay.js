import { LightningElement,api } from 'lwc';

const COLUMNS = [
    { label: 'Place Name', fieldName: 'PlaceName__c', type:'text' },
    { label: 'Postal Code', fieldName: 'PostalCode__c', type:'text' },
    { label: 'Country', fieldName: 'Country__c',type:'text'},
    { label: 'Country Code', fieldName: 'CountryCode__c' ,type:'text'},
    { label: 'State', fieldName: 'State__c' ,type:'text'},
    { label: 'State Code', fieldName: 'StateAbbreviation__c' },
    { label: 'Latitude', fieldName: 'PlaceLocation__Latitude__s',type:'number',typeAttributes:{formatStyle:'decimal', maximumFractionDigits: 6}},
    { label: 'Longitude', fieldName: 'PlaceLocation__Longitude__s',type:'number',typeAttributes:{formatStyle:'decimal', maximumFractionDigits: 6} },
];

export default class GetInfoChildUsDisplay extends LightningElement {

    @api recordList;
    cols=COLUMNS;
    
}