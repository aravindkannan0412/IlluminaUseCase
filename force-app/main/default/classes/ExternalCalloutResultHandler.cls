public with sharing class ExternalCalloutResultHandler {

    public class CustomException extends Exception {}

    /**
    * @description: This method used to check the input and call the external service
    * @author:Aravind
    * @params:countryCode,zipCode
    **/
    public static Map<String,Object> getZipCodeData(String countryCode, String zipCode){
        if (String.isBlank(countryCode) || String.isBlank(zipCode)) {
            throw new CustomException('Country name and Zip code cannot be empty.');
        }
        // Constructing the endpoint dynamically
        String endpoint = 'callout:ZipCodeCred/'+countryCode+'/'+ zipCode;
        string response=getDataFromExternalService(endpoint);
        Map<String,Object> zipcodeDetails=(Map<String,Object>) JSON.deserializeUntyped(response);
        return zipcodeDetails;
    }

    /**
    * @description: This method used to send request using HTTP classes
    * @author:Aravind
    * @params:endpoint
    **/
    private static string getDataFromExternalService(string endpoint) {
        Http http = new Http();
        HttpRequest req = new HttpRequest();
    
        try{
            req.setEndpoint(endpoint);
            req.setMethod('GET');
            req.setHeader('Accept', 'application/json');
            HttpResponse res = http.send(req);

            if (res.getStatusCode() != 200) {
                throw new CustomException(res.getStatusCode()+': Data Not Found ');   
            }
            return res.getBody();
        }catch (Exception e) {
            throw new CustomException(e.getMessage());
        }
    }
    
}