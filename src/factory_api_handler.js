const axios = require('axios').default;

const handler = async (event) => {
  
  for (const record of event.Records) {
    console.log("Message Body: ", record);
    console.log("Message Body: ", JSON.parse(record.body));

    axios.post(process.env.INCREASE_URI, record.body)
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
