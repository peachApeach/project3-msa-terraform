const serverless = require("serverless-http");
const express = require("express");
const app = express();
app.use(express.json())

const AWS = require("aws-sdk") 
const sns = new AWS.SNS({ region: "ap-northeast-2" }) 

const {
  connectDb,
  queries: { getProduct, getFactory, getAdvertisement,  setStock }
} = require('./database')

app.get("/", connectDb, async (req, res, next) => {
  const [ result ] = await req.conn.query(
    getProduct('CP-502101')
  )

  await req.conn.end()
  if (result.length > 0) {
    return res.status(200).json(result[0]);
  } else {
    return res.status(400).json({ message: "상품 없음" });
  }
});

app.get("/product/donut", connectDb, async (req, res, next) => {
  const [ result ] = await req.conn.query(
    getProduct('CP-502101')
  )

  await req.conn.end()
  if (result.length > 0) {
    return res.status(200).json(result[0]);
  } else {
    return res.status(400).json({ message: "상품 없음" });
  }
});

app.post("/checkout", connectDb, async (req, res, next) => {
  console.log(req.body.productSku)
  console.log(getProduct(req.body.productSku))

  const [ productArr ] = await req.conn.query(
    getProduct(req.body.productSku)
  )
  
  console.log(productArr)

  const [ factoryArr ] = await req.conn.query( getFactory( productArr[0].factory_id) )
  const [ adArr ] = await req.conn.query( getAdvertisement( productArr[0].ad_id) )


  if (productArr.length > 0) {
    const product = productArr[0]
    if (product.stock > 0) {
      await req.conn.query(setStock(product.product_id, product.stock - 1))
      return res.status(200).json({ message: `구매 완료! 남은 재고: ${product.stock - 1}`});
    }
    else {
      const now = new Date().toString()
      const message = `도너츠 재고가 없습니다. 제품을 생산해주세요! \n메시지 작성 시각: ${now}`
      const params = {
        Message: message,
        Subject: '도너츠 재고 부족',
        MessageAttributes: {
          MessageAttributeGroupId: {
            StringValue: "1",
            DataType: "String",
          },
          MessageAttributeProductId: {
            StringValue: product.product_id,
            DataType: "String",
          },
          MessageAttributeProductCnt: {
            StringValue: "1",
            DataType: "String",
          },
          MessageAttributeFactoryId: {
            StringValue: factoryArr[0].identifier,
            DataType: "String",
          },
          MessageAttributeRequester: {
            StringValue: "유희진",
            DataType: "String",
          },
          CallbackUrl : {
            StringValue: "https://j87j7mxtb7.execute-api.ap-northeast-2.amazonaws.com/product/donut",
            DataType: "String",
          }
        },
        TopicArn: process.env.TOPIC_ARN
      }

      const result = await sns.publish(params).promise()
      
      await req.conn.end()
      return res.status(200).json({ message: `구매 실패! 남은 재고: ${product.stock}`});
    }
  } else {
    await req.conn.end()
    return res.status(400).json({ message: "상품 없음" });
  }
});

app.use((req, res, next) => {
  return res.status(404).json({
    error: "Not Found",
  });
});

module.exports.handler = serverless(app);
module.exports.app = app;
