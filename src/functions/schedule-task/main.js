const DocumentClient = require("aws-sdk/clients/dynamodb").DocumentClient;
const dynamodb = new DocumentClient();

module.exports.handler = async (event, context) => {
  const bodyContent = JSON.parse(event.body);
  const ownerId = bodyContent.ownerId;
  const ttlEpochInSeconds = Date.parse(bodyContent.timeToExecute) / 1000.0; // dynamodb ttl works with seconds
  const timeToExecute = new Date().toISOString();
  const response = await dynamodb
    .put({
      TableName: process.env.DYNAMODB_TABLE_NAME,
      Item: {
        OwnerId: ownerId,
        TaskId: timeToExecute,
        TimeToExecute: timeToExecute,
        TTL: ttlEpochInSeconds,
      },
    })
    .promise();

  return {
    statusCode: 201,
    headers: {},
    body: JSON.stringify({
      taskId: `${ownerId}|${timeToExecute}`,
    }),
    isBase64Encoded: false,
  };
};
