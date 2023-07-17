const serverless = require("serverless-http");
const express = require("express");
const app = express();
app.use(express.json())
const axios = require('axios').default;

app.post("/", async (req, res, next) => {
  console.log(req.body)

  axios.post(`${process.env.INCREASE_URI}/product/donut`, req.body)
    .then(function (response) {
      console.log("success",response);
      return res.status(200).json({ message: `전송 성공!!!`});
    })
    .catch(function (error) {
      console.log("error",error);
      return res.status(400).json({ message: `전송 실패!!!`});
    });

});

app.use((req, res, next) => {
  return res.status(404).json({
    error: "Not Found",
  });
});

module.exports.handler = serverless(app);
module.exports.app = app;