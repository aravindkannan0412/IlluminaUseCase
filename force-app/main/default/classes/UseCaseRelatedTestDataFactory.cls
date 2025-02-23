@isTest
public with sharing class UseCaseRelatedTestDataFactory {
    private static final string LANG_EN_US='en_US';
    private static final string EMAILENCODING_KEY='utf-8';
    private static final string TIMEZONESID_KEY='Asia/Kolkata';

    /**
    * @description: This method is used to mock user creation
    * @author:Aravind
    * @params:userName,email
    **/
    public static User insertUser(String userName,String email){
       
        user u;
        try{
            Profile profile=[select id from profile where name='System Administrator' limit 1];
            Id userRoleId=[select Id from UserRole where DeveloperName ='CEO' limit 1]?.Id;

            u=new user();
            u.FirstName='TestUser1';
            u.LastName='useCaseTester';
            u.ProfileId=profile.id;
            u.Email=email;
            u.Username=userName;
            u.UserRoleId=userRoleId;
            u.LocaleSidKey=LANG_EN_US;
            u.EmailEncodingKey=EMAILENCODING_KEY;
            u.TimeZoneSidKey=TIMEZONESID_KEY;
            u.LanguageLocaleKey=LANG_EN_US;
            u.Alias=userName.left(8);
            u.CommunityNickname=userName.left(20);
            insert u;
        }
        catch(exception e){
        }

        return u;
       
    }

    /**
    * @description: This method is used to mock bulk Account creation
    * @author:Aravind
    * @params:N/A
    **/
    public static void createMultipleAccounts(){
        List<Account> testAccts = new List<Account>();
        for(Integer i=0;i<2;i++) {
            testAccts.add(new Account(Name = 'TestAcct'+i, 
                                      Risk__c='Low',
                                      Description='This is a very important account',
                                      AccountNumber='CD'+System.currentTimeMillis()+i));
        }
        insert testAccts;      
    }

    /**
    * @description: This method is used to mock PlacesFromPostalCode__c
    * @author:Aravind
    * @params:N/A
    **/
    public static PlacesFromPostalCode__c createPlacesFromPostalCode(){
        PlacesFromPostalCode__c place =new PlacesFromPostalCode__c();
        place.PostalCode__c='90210';
        place.Country__c='United States';
        place.CountryCode__c='US';
        place.PlaceName__c='Beverly Hills';
        place.State__c='California';
        place.StateAbbreviation__c='CA';
        place.PlaceLocation__Latitude__s=34.0901;
        place.PlaceLocation__Longitude__s=-118.4065;
        place.External_Id__c= 'BeverlyHills-US-90210-California';
        return place;
    }
}