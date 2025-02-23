@isTest
global class ZipCodeHttpMockTest implements HttpCalloutMock {

    protected Integer code;
    protected Map<String,String> responseHeaders;
    protected string responseBody;
    protected string status;


    public ZipCodeHttpMockTest(Integer code,Map<String,String> responseHeaders,string responseBody,string status) {
        this.code=code;
        this.responseHeaders=responseHeaders;
        this.responseBody=responseBody;
        this.status=status;
    }

    /**
    * @description: This method used to from responses using HTTP classes
    * @author:Aravind
    * @params:HTTPRequest
    **/
    global HTTPResponse respond(HTTPRequest req) {

        
        // Create a fake response
        HttpResponse res = new HttpResponse();
        for(string key:this.responseHeaders.keySet()){
            res.setHeader(key,this.responseHeaders.get(key));
        }
        res.setBody(this.responseBody);
        res.setStatusCode(this.code);
        res.setStatus(this.status);

        return res;
    }
}