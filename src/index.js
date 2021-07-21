const { Kafka } = require("kafkajs");

const {
  KAFKA_BROKER_1 = "",
  KAFKA_BROKER_2 = "",
  KAFKA_BROKER_3 = "",
} = process.env;

const kafka = new Kafka({
  clientId: "msk",
  brokers: [KAFKA_BROKER_1, KAFKA_BROKER_2, KAFKA_BROKER_3],
});

const producer = kafka.producer();

async function run() {
  await producer.connect();

  console.log("Kafka is connected!");

  await producer.send({
    topic: "test-topic",
    messages: [{ value: "Testing" }],
  });
}

run().then(() => {
  console.log("Kafka running...");
});
