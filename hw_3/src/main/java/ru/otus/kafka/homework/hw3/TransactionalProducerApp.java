package ru.otus.kafka.homework.hw3;

import java.util.List;
import java.util.Properties;
import java.util.concurrent.ExecutionException;
import org.apache.kafka.clients.producer.KafkaProducer;
import org.apache.kafka.clients.producer.ProducerConfig;
import org.apache.kafka.clients.producer.ProducerRecord;
import org.apache.kafka.clients.producer.RecordMetadata;
import org.apache.kafka.common.KafkaException;
import org.apache.kafka.common.serialization.StringSerializer;

public final class TransactionalProducerApp {
    private static final List<String> TOPICS = List.of("topic1", "topic2");
    private static final String DEFAULT_BOOTSTRAP_SERVER = "127.0.0.1:9092";
    private static final String TRANSACTIONAL_ID = "hw-3-transactional-producer";

    private TransactionalProducerApp() {
    }

    public static void main(String[] args) {
        String bootstrapServer = args.length > 0 ? args[0] : DEFAULT_BOOTSTRAP_SERVER;

        Properties properties = new Properties();
        properties.put(ProducerConfig.BOOTSTRAP_SERVERS_CONFIG, bootstrapServer);
        properties.put(ProducerConfig.KEY_SERIALIZER_CLASS_CONFIG, StringSerializer.class.getName());
        properties.put(ProducerConfig.VALUE_SERIALIZER_CLASS_CONFIG, StringSerializer.class.getName());
        properties.put(ProducerConfig.TRANSACTIONAL_ID_CONFIG, TRANSACTIONAL_ID);
        properties.put(ProducerConfig.ACKS_CONFIG, "all");
        properties.put(ProducerConfig.ENABLE_IDEMPOTENCE_CONFIG, "true");
        properties.put(ProducerConfig.MAX_IN_FLIGHT_REQUESTS_PER_CONNECTION, "5");

        try (KafkaProducer<String, String> producer = new KafkaProducer<>(properties)) {
            System.out.printf("Connecting to Kafka at %s%n", bootstrapServer);
            producer.initTransactions();

            sendCommittedTransaction(producer);
            sendAbortedTransaction(producer);

            System.out.println("Producer finished");
        }
    }

    private static void sendCommittedTransaction(KafkaProducer<String, String> producer) {
        executeTransaction(producer, "first", "committed", 5, true);
    }

    private static void sendAbortedTransaction(KafkaProducer<String, String> producer) {
        executeTransaction(producer, "second", "aborted", 2, false);
    }

    private static void executeTransaction(
            KafkaProducer<String, String> producer,
            String transactionDisplayName,
            String transactionMarker,
            int messagesPerTopic,
            boolean commit) {
        boolean transactionStarted = false;
        try {
            System.out.printf("%nBEGIN %s transaction%n", transactionDisplayName);
            producer.beginTransaction();
            transactionStarted = true;

            for (String topic : TOPICS) {
                for (int messageNumber = 1; messageNumber <= messagesPerTopic; messageNumber++) {
                    ProducerRecord<String, String> record = record(topic, transactionMarker, messageNumber);
                    RecordMetadata metadata = producer.send(record).get();
                    System.out.printf(
                            "sent %s -> partition=%d offset=%d key=%s value=%s%n",
                            metadata.topic(),
                            metadata.partition(),
                            metadata.offset(),
                            record.key(),
                            record.value());
                }
            }

            if (commit) {
                System.out.printf("COMMITTING %s transaction%n", transactionDisplayName);
                producer.commitTransaction();
                System.out.printf("%s transaction committed%n", capitalize(transactionDisplayName));
            } else {
                System.out.printf("ABORTING %s transaction%n", transactionDisplayName);
                producer.abortTransaction();
                System.out.printf("%s transaction aborted%n", capitalize(transactionDisplayName));
            }
        } catch (InterruptedException exception) {
            Thread.currentThread().interrupt();
            abortIfNeeded(producer, transactionStarted);
            throw new IllegalStateException("Producer was interrupted", exception);
        } catch (ExecutionException | KafkaException exception) {
            abortIfNeeded(producer, transactionStarted);
            throw new IllegalStateException("Transaction failed", exception);
        }
    }

    private static ProducerRecord<String, String> record(String topic, String transactionName, int messageNumber) {
        String key = transactionName + "-" + topic + "-" + messageNumber;
        String value = String.format("tx=%s topic=%s message=%d", transactionName, topic, messageNumber);
        return new ProducerRecord<>(topic, key, value);
    }

    private static void abortIfNeeded(KafkaProducer<String, String> producer, boolean transactionStarted) {
        if (!transactionStarted) {
            return;
        }

        try {
            producer.abortTransaction();
        } catch (KafkaException ignored) {
            // The original exception is more useful for this demo.
        }
    }

    private static String capitalize(String value) {
        if (value.isEmpty()) {
            return value;
        }
        return Character.toUpperCase(value.charAt(0)) + value.substring(1);
    }
}
