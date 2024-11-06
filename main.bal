import ballerina/http;
import ballerina/log;

type NewsRequest record {
    string 'type;
};

listener http:Listener newsApiListener = new (8084);

service /newsapi on newsApiListener {

    resource function post news(http:Caller caller, NewsRequest req) returns error? {
        // Retrieve the 'type' parameter from the request JSON payload.
    


        http:Response response;
        if req.'type == "sports" {
            // Send GET request to BBC sports feed
            http:Client sportsClient = check new("https://feeds.bbci.co.uk");
            http:Response|error sportsResponse = sportsClient->get("/sport/rss.xml");

            if sportsResponse is error {
                log:printError("Failed to retrieve sports feed", sportsResponse);
                response = new;
                response.setJsonPayload({ "message": "Service unavailable" });
                response.statusCode = 503;
            } else {
                response = sportsResponse;
            }
        } else if req.'type == "news" {
            // Send GET request to NY Times homepage feed
            http:Client newsClient = check new ("https://rss.nytimes.com");
            http:Response|error newsResponse = newsClient->get("/services/xml/rss/nyt/HomePage.xml");

            if newsResponse is error {
                log:printError("Failed to retrieve news feed", newsResponse);
                response = new;
                response.setJsonPayload({ "message": "Service unavailable" });
                response.statusCode = 503;
            } else {
                response = newsResponse;
            }
        } else {
            // Handle unrecognized types.
            check caller->respond({ "message": "Unsuccessful request" });
            return;
        }

        // Forward the response to the client.
        check caller->respond(response);
    }
}
