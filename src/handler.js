// const consumer = async (event) => {
//     await delay(15000);
//     for (const record of event.Records) {
//       console.log("Message Body: ", record.body);
  
//       let inputValue, outputValue
//       // TODO: Step 1을 참고하여, +1 를 하는 코드를 넣으세요
//       try{
//         let body = JSON.parse(event.body);
    
//         inputValue = parseInt(body.input);
//         outputValue = inputValue+1;
  
//         const message = `메시지를 받았습니다. 입력값: ${inputValue}, 결과: ${outputValue}`
//         console.log(message)
//       }
//       catch {
//         console.log("숫자 값을 넣어주세요")
//       }
//     }
//   };
  
//   module.exports = {
//     consumer
//   };

module.exports.handler = async (event) => {
    console.log('Event: ', event);
    let responseMessage = 'Hello, World!';
  
    return {
      statusCode: 200,
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        message: responseMessage,
      }),
    }
  }