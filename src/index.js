const { Kafka } = require("kafkajs");

const { KAFKA_BROKERS } = process.env;

// Split our broker string
const brokers = KAFKA_BROKERS.split(",");

console.log("Broker list:", brokers);

const kafka = new Kafka({
  clientId: "msk",
  brokers,
});

const producer = kafka.producer();

async function run() {
  await producer.connect();

  console.log("Kafka is connected!");

  setInterval(async () => {
    console.log("Pinging kafka...");

    await producer.send({
      topic: "test-topic",
      messages: [{ value: "Testing" }],
    });
  }, 2000);
}

run().then(() => {
  console.log("Kafka running...");
});
