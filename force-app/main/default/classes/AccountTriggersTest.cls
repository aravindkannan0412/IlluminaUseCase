@isTest
private with sharing class AccountTriggersTest {
    private static string username='AccountTriggersTest'+System.currentTimeMillis()+'@company.com';
    private static string email='AccountTriggersTest'+System.currentTimeMillis()+'@gmail.com';

    @testSetup static void setup() {
        // Create common test accounts
        user u=UseCaseRelatedTestDataFactory.insertUser(username,email);
        system.runAs(u){
            UseCaseRelatedTestDataFactory.createMultipleAccounts();
        }
          
    }

    @isTest static void testFailedEventsWithFail() {
        User testUser=[Select Id from User where LastName='useCaseTester' limit 1];

        system.runAs(testUser){
            List<CaseCreationEventFailure.CaseEventInfo> cbDataLst=new List<CaseCreationEventFailure.CaseEventInfo>();
            Account acc=[Select Id from Account limit 1];
            CaseCreatorEvent__e caseEvent=(CaseCreatorEvent__e) CaseCreatorEvent__e.sObjectType.newSObject(null, true);
            caseEvent.AccountId__c=acc.Id;
            caseEvent.Origin__c= 'InternalAccount';
            caseEvent.Priority__c='High';   
            caseEvent.Subject__c='helo';
            caseEvent.Description__c='hello hello'; 
            CaseCreationEventFailure.CaseEventInfo cb=new CaseCreationEventFailure.CaseEventInfo(caseEvent.EventUuid,caseEvent.AccountId__c);
            cbDataLst.add(cb);

            Test.startTest();
                EventBus.publish(caseEvent, new CaseCreationEventFailure(cbDataLst));
                Test.getEventBus().fail(); 
            Test.stopTest();

            List<Task> tasklist=[Select id from Task where WhatId=:acc.Id];
            Assert.isTrue(tasklist.size()!=0);

        }
    }

    @isTest static void testAccountUpdateWithPublishEvent(){

        User testUser=[Select Id from User where LastName='useCaseTester' limit 1];

        system.runAs(testUser){

           List<Account> accList=[Select Id,Risk__c from Account limit 2];
           set<Id> accIdset=new Set<Id>();

           for(Account acc:accList){
             acc.Risk__c='High';
             accIdset.add(acc.Id);
           }

           Test.startTest();
             update accList;
             Test.getEventBus().deliver();
           Test.stopTest();

           List<Case> caseList=[Select id From Case where AccountId In:accIdset];

           Assert.isTrue(caseList.size()!=0);
        }
    }

    @isTest static void testExceptionOnAccountMethods(){

        User testUser=[Select Id from User where LastName='useCaseTester' limit 1];

        system.runAs(testUser){
            List<Account> accList=[Select Id from Account limit 2];
            try{
                Test.startTest();
                    AccountTriggerUtility.createCaseOnHighPriorityAccounts(accList,null);
                Test.stopTest();
            }
            catch(Exception ex){
                Assert.isNotNull(ex);
            }
        }
    }
}