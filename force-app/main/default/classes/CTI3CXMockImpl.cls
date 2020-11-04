global class CTI3CXMockImpl implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest req) {
        HttpResponse r = new HttpResponse();
		r.setStatusCode(200);
        r.setBody('{}');        
        return r;
    }
}