public with sharing class GetInfoFromZipCode_LT {

    /**
    * @description: This method used to return zip code data from API to LWC
    * @author:Aravind
    * @params:countryCode,zipCode
    **/
    @AuraEnabled(cacheable=true)
    public static Map<string,Object> getZipCodeData(String countryCode,string zipCode){
        try{
            return ExternalCalloutResultHandler.getZipCodeData(countryCode,zipCode);
        }
        catch(Exception ex){
            throw new AuraHandledException(ex.getMessage());
        }      
    }

    /**
    * @description: This method used Upsert the places data to the DB
    * @author:Aravind
    * @params:placeRecords
    **/
    @AuraEnabled
    public static void upsertPlaces(List<PlacesFromPostalCode__c> placeRecords){
        try{
            upsert placeRecords External_Id__c;
        }catch(Exception ex){
            throw new AuraHandledException(ex.getMessage());
        }
    }
}