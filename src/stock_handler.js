const axios = require('axios').default;

const handler = async (event) => {
  
  for (const record of event.Records) {
    console.log("Message Body: ", record);
    console.log("Message Body: ", JSON.parse(record.body));
    const messageAttributes = JSON.parse(record.body).MessageAttributes;
    console.log(messageAttributes)
    console.log(typeof(messageAttributes))

    const payload = {
      // TODO:
      // 어떤 형식으로 넣어야 할까요? Factory API 문서를 참고하세요.
      // 필요하다면 record.body를 활용하세요.
      MessageGroupId : messageAttributes.MessageAttributeGroupId.Value , 
      MessageAttributeProductId : messageAttributes.MessageAttributeProductId.Value,
      MessageAttributeProductCnt : messageAttributes.MessageAttributeProductCnt.Value,
      MessageAttributeFactoryId : messageAttributes.MessageAttributeFactoryId.Value,
      MessageAttributeRequester : messageAttributes.MessageAttributeRequester.Value,
      CallbackUrl : messageAttributes.CallbackUrl.Value
    }
    
    console.log(payload);

    axios.post(process.env.FACTORY_URL, payload)
    .then(function (response) {
      console.log(response);
    })
    .catch(function (error) {
      console.log(error);
    });
  }

};

module.exports = {
  handler,
};
