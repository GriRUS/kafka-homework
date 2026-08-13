package ru.otus.kafka.homework.hw3;

import java.time.Duration;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Properties;
import org.apache.kafka.clients.consumer.ConsumerConfig;
import org.apache.kafka.clients.consumer.ConsumerRecord;
import org.apache.kafka.clients.consumer.ConsumerRecords;
import org.apache.kafka.clients.consumer.KafkaConsumer;
import org.apache.kafka.common.serialization.StringDeserializer;

public final class ReadCommittedConsumerApp {
    private static final List<String> TOPICS = List.of("topic1", "topic2");
    private static final String DEFAULT_BOOTSTRAP_SERVER = "127.0.0.1:9092";
    private static final int EXPECTED_COMMITTED_MESSAGES = 10;

    private ReadCommittedConsumerApp() {
    }

    public static void main(String[] args) {
        String bootstrapServer = args.length > 0 ? args[0] : DEFAULT_BOOTSTRAP_SERVER;

        Properties properties = new Properties();
        properties.put(ConsumerConfig.BOOTSTRAP_SERVERS_CONFIG, bootstrapServer);
        properties.put(ConsumerConfig.GROUP_ID_CONFIG, "hw-3-read-committed-" + System.currentTimeMillis());
        properties.put(ConsumerConfig.KEY_DESERIALIZER_CLASS_CONFIG, StringDeserializer.class.getName());
        properties.put(ConsumerConfig.VALUE_DESERIALIZER_CLASS_CONFIG, StringDeserializer.class.getName());
        properties.put(ConsumerConfig.AUTO_OFFSET_RESET_CONFIG, "earliest");
        properties.put(ConsumerConfig.ENABLE_AUTO_COMMIT_CONFIG, "false");
        properties.put(ConsumerConfig.ISOLATION_LEVEL_CONFIG, "read_committed");

        System.out.printf("Reading from %s at %s%n", TOPICS, bootstrapServer);
        System.out.println("Consumer isolation.level=read_committed");

        List<ConsumerRecord<String, String>> visibleRecords = new ArrayList<>();
        int visibleAbortedMessages = 0;

        try (KafkaConsumer<String, String> consumer = new KafkaConsumer<>(properties)) {
            consumer.subscribe(TOPICS);

            long deadline = System.nanoTime() + Duration.ofSeconds(15).toNanos();
            int emptyPollsAfterExpectedRecords = 0;

            while (System.nanoTime() < deadline) {
                ConsumerRecords<String, String> records = consumer.poll(Duration.ofMillis(500));

                if (records.isEmpty()) {
                    if (visibleRecords.size() >= EXPECTED_COMMITTED_MESSAGES) {
                        emptyPollsAfterExpectedRecords++;
                    }
                    if (emptyPollsAfterExpectedRecords >= 3) {
                        break;
                    }
                    continue;
                }

                for (ConsumerRecord<String, String> record : records) {
                    visibleRecords.add(record);
                    if (record.value().contains("tx=aborted")) {
                        visibleAbortedMessages++;
                    }
                    System.out.printf(
                            "%s[%d]@%d key=%s value=%s%n",
                            record.topic(),
                            record.partition(),
                            record.offset(),
                            record.key(),
                            record.value());
                }
            }
        }

        printSummary(visibleRecords, visibleAbortedMessages);

        if (visibleRecords.size() != EXPECTED_COMMITTED_MESSAGES || visibleAbortedMessages != 0) {
            System.exit(1);
        }
    }

    private static void printSummary(List<ConsumerRecord<String, String>> records, int visibleAbortedMessages) {
        Map<String, Integer> recordsByTopic = new HashMap<>();
        for (String topic : TOPICS) {
            recordsByTopic.put(topic, 0);
        }
        for (ConsumerRecord<String, String> record : records) {
            recordsByTopic.computeIfPresent(record.topic(), (topic, count) -> count + 1);
        }

        System.out.println();
        System.out.println("Summary:");
        for (String topic : TOPICS) {
            System.out.printf("%s visible committed messages: %d%n", topic, recordsByTopic.get(topic));
        }
        System.out.printf("Total visible messages: %d%n", records.size());
        System.out.printf("Visible aborted messages: %d%n", visibleAbortedMessages);
    }
}
