const DocumentClient = require("aws-sdk/clients/dynamodb").DocumentClient;
const dynamodb = new DocumentClient();
const sqs = require("aws-sdk/clients/sqs");

// EPOCH: milliseconds passed since 1970-01-01 00:00:00
const fromStringToEpoch = (str) => Date.parse(str);
const nowEpoch = () => new Date().getTime();
const millisecondsInADay = 24.0 * 60.0 * 60.0 * 1000.0;
const saveItemToDynamoDb = async (item) => {
  const putRequest = {
    TableName: process.env.DYNAMODB_TABLE_NAME,
    Item: item,
  };
  await dynamodb.put(putRequest).promise();
};

module.exports.handler = async (event, context) => {
  const bodyContent = JSON.parse(event.body);
  const ownerId = bodyContent.ownerId;
  const timeToExecute = fromStringToEpoch(bodyContent.timeToExecute);
  const twoDaysLater = nowEpoch() + 2.0 * millisecondsInADay;
  const creationTime = new Date().toISOString();
  const item = {
    OwnerId: ownerId,
    TaskId: creationTime,
    TimeToExecute: bodyContent.timeToExecute,
  };

  if (timeToExecute > twoDaysLater) {
    item.TTL = (timeToExecute - 2.0 * millisecondsInADay) / 1000.0; // dynamodb ttl works with seconds ...
    saveItemToDynamoDb(item);
  } else {
    // If task has to run within 2 days ...
  }

  const itemId = `${ownerId}|${creationTime}`;
  return {
    statusCode: 201,
    headers: {},
    body: JSON.stringify({
      id: itemId,
    }),
    isBase64Encoded: false,
  };
};
