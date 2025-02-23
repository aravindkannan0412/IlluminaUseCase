@isTest
private with sharing class ZipCodeHandlersTest {
    private static string username='ZipCodeHandlersTest'+System.currentTimeMillis()+'@company.com';
    private static string email='ZipCodeHandlersTest'+System.currentTimeMillis()+'@gmail.com';

    @testSetup static void setup() {
        user u=UseCaseRelatedTestDataFactory.insertUser(username,email);
    }

    @isTest static void getZipCodeDataPositiveTest(){
        User testUser=[Select Id from User where LastName='useCaseTester' limit 1];
        system.runAs(testUser){
             Map<String,object> zipCodeData=new Map<String,object>();

             string responseBody='{"post code": "90210", "country": "United States", "country abbreviation": "US", "places": [{"place name": "Beverly Hills", "longitude": "-118.4065", "state": "California", "state abbreviation": "CA", "latitude": "34.0901"}]}';


             ZipCodeHttpMockTest mockinstance= new ZipCodeHttpMockTest(200,new Map<String,String>{'Content-Type'=>'application/json; charset=utf-8'},responseBody,'OK');

             Test.startTest();
                Test.setMock(HttpCalloutMock.class, mockinstance);
                zipCodeData=GetInfoFromZipCode_LT.getZipCodeData('US','90210');
             Test.stopTest();

             Assert.areEqual(zipCodeData.get('country'), 'United States');
        }
    }

    @isTest static void getZipCodeDataNegativeTest(){
        User testUser=[Select Id from User where LastName='useCaseTester' limit 1];
        system.runAs(testUser){
            Map<String,object> zipCodeData=new Map<String,object>();

            string responseBody='{"error": "Unauthorized"}';

            ZipCodeHttpMockTest mockinstance= new ZipCodeHttpMockTest(401,new Map<String,String>{'Content-Type'=>'application/json; charset=utf-8'},responseBody,'Unauthorized');
            try{
                Test.startTest();
                    Test.setMock(HttpCalloutMock.class, mockinstance);
                    zipCodeData=GetInfoFromZipCode_LT.getZipCodeData('US','90210');
                Test.stopTest();
            }
            catch(Exception ex){
                Assert.isNotNull(ex);
            }

        }
    }

    @isTest static void upsertPlacesTest(){
        User testUser=[Select Id from User where LastName='useCaseTester' limit 1];
        system.runAs(testUser){
            Test.startTest();
                PlacesFromPostalCode__c placesFromPostCodeRec=UseCaseRelatedTestDataFactory.createPlacesFromPostalCode();
                GetInfoFromZipCode_LT.upsertPlaces(new List<PlacesFromPostalCode__c>{placesFromPostCodeRec});
            Test.stopTest();

            Integer placesCount=[Select COUNT() from PlacesFromPostalCode__c];

            Assert.areEqual(placesCount, 1);
        }
    }

    @isTest static void exceptionTestOnUpsert(){
        User testUser=[Select Id from User where LastName='useCaseTester' limit 1];
        system.runAs(testUser){
            try{
                Test.startTest();
                    PlacesFromPostalCode__c placesFromPostCodeRec=UseCaseRelatedTestDataFactory.createPlacesFromPostalCode();
                    GetInfoFromZipCode_LT.upsertPlaces(new List<PlacesFromPostalCode__c>{placesFromPostCodeRec,placesFromPostCodeRec});
                Test.stopTest();
            }
            catch(Exception ex){
                Assert.isNotNull(ex);
            }
        }
    }
}