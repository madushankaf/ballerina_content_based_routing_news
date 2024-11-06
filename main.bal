import ballerina/http;
import ballerina/log;

type NewsRequest record {
    string 'type;
};

listener http:Listener newsApiListener = new (8084);

service /newsapi on newsApiListener {

    resource function post news( NewsRequest req) returns http:Response|error {
        // Retrieve the 'type' parameter from the request JSON payload.
        http:Response response = new;
        if req.'type == "sports" {
            // Send GET request to BBC sports feed
            http:Client sportsClient = check new ("https://feeds.bbci.co.uk");
            log:printInfo("Sending request to BBC sports feed");
            xml sportsResponse = check sportsClient->get("/sport/rss.xml");
            // Convert XML to JSON and set it as the payload
            json sportsJson = { "data": sportsResponse.toString() };
            response.setJsonPayload(sportsJson);

        } else if req.'type == "news" {
            // Send GET request to NY Times homepage feed
            http:Client newsClient = check new ("https://rss.nytimes.com");
            log:printInfo("Sending request to NY Times homepage feed");
            xml newsResponse = check newsClient->get("/services/xml/rss/nyt/HomePage.xml");
            // Convert XML to JSON and set it as the payload
            json newsJson = { "data": newsResponse.toString() };
            response.setJsonPayload(newsJson);
        } else {
            // Handle unrecognized types.
            log:printError("Unrecognized news type");
            response.statusCode = 400;
            response.setJsonPayload({ "message": "Unsuccessful request" });
        }

        // // Forward the response to the client.
        return response;
    }
}
