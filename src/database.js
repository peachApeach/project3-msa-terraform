const mysql = require('mysql2/promise');
require('dotenv').config()

const {
  HOSTNAME: host,
  USERNAME: user,
  PASSWORD: password,
  DATABASE: database,
  DBPORT : port = 33306
} = process.env;

const connectDb = async (req, res, next) => {
  try {
    req.conn = await mysql.createConnection({ host, user, password, database, port })
    next()
  }
  catch(e) {
    console.log(e)
    res.status(500).json({ message: "데이터베이스 연결 오류" })
  }
}

const getProduct = (sku) => `
  SELECT BIN_TO_UUID(product_id) as product_id, name, price, stock, BIN_TO_UUID(factory_id) as factory_id, BIN_TO_UUID(ad_id) as ad_id
  FROM product
  WHERE sku = "${sku}"
`

const getFactory = (factory_id) => `
  SELECT BIN_TO_UUID(factory_id) as factory_id, identifier, name, manager_email
  FROM factory
  WHERE factory_id = UUID_TO_BIN('${factory_id}')
`

const getAdvertisement = (ad_id) => `
  SELECT BIN_TO_UUID(ad_id) as ad_id, status, manager_email
  FROM advertisement
  WHERE ad_id = UUID_TO_BIN('${ad_id}')
`

const setStock = (productId, stock) => `
  UPDATE product SET stock = ${stock} WHERE product_id = UUID_TO_BIN('${productId}')
`

const increaseStock = (productId, incremental) => `
  UPDATE product SET stock = stock + ${incremental} WHERE product_id = UUID_TO_BIN('${productId}')
`

module.exports = {
  connectDb,
  queries: {
    getProduct,
    getFactory,
    getAdvertisement,
    setStock,
    increaseStock
  }
}