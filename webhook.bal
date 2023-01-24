import ballerinax/hubspot.crm.contact;
import ballerinax/trigger.asgardeo;
import ballerina/log;
import ballerina/http;

configurable asgardeo:ListenerConfig config = ?;

listener http:Listener httpListener = new (8090);
listener asgardeo:Listener webhookListener = new (config, httpListener);

contact:Client contactEp = check new (clientConfig = {
    auth : {
      refreshUrl: "https://api.hubapi.com/oauth/v1/token",
      refreshToken: "eu1-a362-015c-4126-b115-ffb1bb416dfd",
      clientId: "f43a5973-5fec-4be8-b4f7-991112ad6188",
      clientSecret: "f43a5973-5fec-4be8-b4f7-991112ad6188",
      scopes: ["contacts","crm.objects.contacts.write"]
    }
});

service asgardeo:RegistrationService on webhookListener {

    remote function onAddUser(asgardeo:AddUserEvent event) returns error? {      
        
        log:printInfo(event.toJsonString());
        asgardeo:AddUserData? userData = event.eventData;
        if (userData is asgardeo:AddUserData) {
          contact:SimplePublicObject createResponse = check contactEp->create(payload = {
            "properties": {
              "email": "example@hubspot.com",
              "firstname": "Jane",
              "lastname": "Doe",
              "phone": "(555) 555-5555",
              "company": "HubSpot",
              "website": "hubspot.com",
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
