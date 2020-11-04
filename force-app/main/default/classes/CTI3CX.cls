public class CTI3CX {
	public static final string CALL_URL = Label.X3CXEndpoint + '/ws/add';
    
    public class CTI3CXResponse {
        public string status;
        public string data;
        public Integer id;
    }
    public static String calculateK(Integer phonenumber, Integer extension) {
        // Truncate operation
        Integer K = ((phonenumber + extension) / 2);
        Blob blobSum = Blob.valueOf(String.valueOf(K));
        return EncodingUtil.base64Encode(blobSum);
    }
    
    public static CTI3CX.CTI3CXResponse call(Integer phonenumber, Integer extension){
        CTI3CX.CTI3CXResponse ctiResponse = new CTI3CX.CTI3CXResponse();
        HttpRequest request = new HttpRequest();
        Http httpClient = new Http();
        HttpResponse response;
        
		String k = calculateK(phonenumber, extension);
        String endpoint = CALL_URL + '?n='+phonenumber+'&e='+extension+'&k='+k+'&date='+String.valueOf(Datetime.now());
        request.setEndpoint(endpoint);
        request.setMethod('GET');
        
        response = httpClient.send(request);
        if(response.getStatusCode() == 200) {
            ctiResponse = (CTI3CX.CTI3CXResponse) JSON.deserialize(response.getBody(), CTI3CX.CTI3CXResponse.class);
        } else {
            ctiResponse.status = String.valueOf(response.getStatusCode());
        }
        
		System.debug('response :: ' + response);
        System.debug('response.getBody() :: ' + response.getBody());
        return ctiResponse;
    }
}