import ballerinax/hubspot.crm.contact;
import ballerinax/trigger.asgardeo;
import ballerina/log;
import ballerina/http;

configurable asgardeo:ListenerConfig config = ?;

listener http:Listener httpListener = new (8090);
listener asgardeo:Listener webhookListener = new (config, httpListener);

service asgardeo:RegistrationService on webhookListener {

    remote function onAddUser(asgardeo:AddUserEvent event) returns error? {      
        
        log:printInfo(event.toJsonString());
        asgardeo:AddUserData? userData = event.eventData;
        if (userData is asgardeo:AddUserData) {
          contact:Client contactEp = check new (clientConfig = {
          auth : {
              token: "CLqGkKreMBINAAEAUAAAASAAAAAEARiChegMIOOwwhco_f1UMhSfL_wKnugOaR2tqyq2Z6_TaIIthDowAAAAQQAAAAAAAAAAAAAAAACGAAAAAAAAAAAAIAAAAAAA4DEAAAAAAEADgAEAABACQhSmgRSzwSZQNniLon71QlLpuYlj8EoDZXUxUgBaAA"
            }
          });
          contact:SimplePublicObject createResponse = check contactEp->create(payload = {
            "properties": {
              "email": userData.userName,
              "firstname": userData.claims["http://wso2.org/claims/givenname"],
              "lastname": userData.claims["http://wso2.org/claims/lastname"],
              "lifecyclestage": "marketingqualifiedlead"
            }
          });
          log:printInfo(createResponse.toJsonString());
        }
    }

    remote function onConfirmSelfSignup(asgardeo:GenericEvent event) returns error? {
    
        log:printInfo(event.toJsonString());
    }

    remote function onAcceptUserInvite(asgardeo:GenericEvent event) returns error? {

        log:printInfo(event.toJsonString());
    }
}

service /ignore on httpListener {
}
