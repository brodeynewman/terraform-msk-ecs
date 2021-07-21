const { Kafka } = require("kafkajs");

const { KAFKA_BROKERS } = process.env;

// Split our broker string
const brokers = KAFKA_BROKERS.split(",");

console.log("Broker list:", brokers);

const kafka = new Kafka({
  clientId: "msk",
  brokers,
  // MSK cluster has TLS enabled by default
  ssl: {
    rejectUnauthorized: false,
  },
});

let inc = 0;

async function runProducer() {
  const producer = kafka.producer();

  await producer.connect();

  console.log("Kafka producer is connected!");

  setInterval(async () => {
    console.log("Pinging kafka...");

    await producer.send({
      topic: "test-topic",
      messages: [{ value: "Testing", num: inc++ }],
    });
  }, 2000);
}

async function runConsumer() {
  const consumer = kafka.consumer({ groupId: "my-group" });

  await consumer.connect();
  await consumer.subscribe({ topic: "test-topic" });

  console.log("Kafka consumer is connected!");

  await consumer.run({
    eachMessage: async ({ topic, partition, message }) => {
      console.log("Received new message from consumer", {
        topic,
        partition,
        message: message.value.toString(),
      });
    },
  });
}

runProducer().then(() => {
  console.log("Kafka producer running...");
});

runConsumer().then(() => {
  console.log("Kafka consume running...");
});
