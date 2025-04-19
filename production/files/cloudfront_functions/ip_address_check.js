function handler(event) {
  var request = event.request;
  var IP_WHITE_LIST = [
    // Please Change!
    "192.168.0.1",
  ];

  if (IP_WHITE_LIST.includes(event.viewer.ip)) {
    return request;
  } else {
    var response = {
      statusCode: 403,
      statusDescription: "Forbidden"
    }

    return response;
  }
}
