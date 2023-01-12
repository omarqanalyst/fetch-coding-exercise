const fs = require("fs");
const zlib = require("zlib");

const unzipJson = (fileName) => {
  // Read the gzipped file
  const gzippedJson = fs.readFileSync(`${fileName}.json.gz`);

  // Unzip the file
  const jsonBuffer = zlib.gunzipSync(gzippedJson);

  // Convert the buffer to a string
  const jsonString = jsonBuffer.toString();

  return jsonString;
};

const parseJsonString = (jsonString) => {
  const jsonObjects = jsonString.split("\n").filter((s) => s);
  return jsonObjects.map((jsonObject) => JSON.parse(jsonObject));
};

const receiptsJson = unzipJson("receipts");
const usersJson = unzipJson("users");
const brandsJson = unzipJson("brands");

const dataReceipts = parseJsonString(receiptsJson);
console.log(dataReceipts.slice(0, 3), "\n", "______________", "\n"); // column 'rewardsReceiptItemList' has nested a object and can complicate creating queries.

const dataUsers = parseJsonString(usersJson);
console.log(dataUsers.slice(0, 3), "\n", "______________", "\n");

const dataBrands = parseJsonString(brandsJson);
console.log(dataBrands.slice(0, 3), "\n", "\n______________", "\n"); //// column 'cpg' also has nested a object and can complicate creating queries.
