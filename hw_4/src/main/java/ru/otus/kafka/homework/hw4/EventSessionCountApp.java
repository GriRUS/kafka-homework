package ru.otus.kafka.homework.hw4;

import org.apache.kafka.common.serialization.Serdes;
import org.apache.kafka.common.utils.Bytes;
import org.apache.kafka.streams.KafkaStreams;
import org.apache.kafka.streams.KeyValue;
import org.apache.kafka.streams.StreamsBuilder;
import org.apache.kafka.streams.StreamsConfig;
import org.apache.kafka.streams.Topology;
import org.apache.kafka.streams.errors.StreamsUncaughtExceptionHandler;
import org.apache.kafka.streams.kstream.Consumed;
import org.apache.kafka.streams.kstream.Grouped;
import org.apache.kafka.streams.kstream.Materialized;
import org.apache.kafka.streams.kstream.Produced;
import org.apache.kafka.streams.kstream.SessionWindows;
import org.apache.kafka.streams.state.SessionStore;

import java.time.Duration;
import java.time.Instant;
import java.util.Locale;
import java.util.Properties;
import java.util.concurrent.CountDownLatch;

public class EventSessionCountApp {
    private static final String DEFAULT_BOOTSTRAP_SERVERS = "127.0.0.1:9092";
    private static final String DEFAULT_INPUT_TOPIC = "events";
    private static final String DEFAULT_OUTPUT_TOPIC = "event-counts";
    private static final String DEFAULT_APPLICATION_ID = "hw4-event-session-counter";
    private static final String DEFAULT_STATE_DIR = "hw_4/runtime/streams-state";
    private static final String STORE_NAME = "event-session-counts-store";

    public static void main(String[] args) throws InterruptedException {
        String bootstrapServers = argOrDefault(args, 0, DEFAULT_BOOTSTRAP_SERVERS);
        String inputTopic = argOrDefault(args, 1, DEFAULT_INPUT_TOPIC);
        String outputTopic = argOrDefault(args, 2, DEFAULT_OUTPUT_TOPIC);
        Duration sessionGap = Duration.ofMinutes(parsePositiveLong(argOrDefault(args, 3, "5"), "session gap minutes"));
        String stateDir = argOrDefault(args, 4, DEFAULT_STATE_DIR);
        String applicationId = argOrDefault(args, 5, DEFAULT_APPLICATION_ID);

        Properties properties = buildProperties(bootstrapServers, applicationId, stateDir);
        Topology topology = buildTopology(inputTopic, outputTopic, sessionGap);
        KafkaStreams streams = new KafkaStreams(topology, properties);

        CountDownLatch stopSignal = new CountDownLatch(1);
        streams.setUncaughtExceptionHandler(exception -> {
            System.err.printf("Kafka Streams failed: %s%n", exception.getMessage());
            return StreamsUncaughtExceptionHandler.StreamThreadExceptionResponse.SHUTDOWN_CLIENT;
        });
        streams.setStateListener((newState, oldState) -> {
            System.out.printf("Kafka Streams state changed: %s -> %s%n", oldState, newState);
            if (newState == KafkaStreams.State.ERROR || newState == KafkaStreams.State.NOT_RUNNING) {
                stopSignal.countDown();
            }
        });
        Runtime.getRuntime().addShutdownHook(new Thread(() -> {
            streams.close(Duration.ofSeconds(10));
            stopSignal.countDown();
        }));

        System.out.printf(
                "Starting Kafka Streams app: bootstrap=%s input=%s output=%s sessionGap=%s applicationId=%s%n",
                bootstrapServers,
                inputTopic,
                outputTopic,
                sessionGap,
                applicationId
        );
        streams.start();
        stopSignal.await();
    }

    static Topology buildTopology(String inputTopic, String outputTopic, Duration sessionGap) {
        StreamsBuilder builder = new StreamsBuilder();

        builder.stream(inputTopic, Consumed.with(Serdes.String(), Serdes.String()))
                .filter((key, value) -> key != null && !key.isBlank())
                .groupByKey(Grouped.with(Serdes.String(), Serdes.String()))
                .windowedBy(SessionWindows.ofInactivityGapWithNoGrace(sessionGap))
                .count(Materialized.<String, Long, SessionStore<Bytes, byte[]>>as(STORE_NAME)
                        .withKeySerde(Serdes.String())
                        .withValueSerde(Serdes.Long()))
                .toStream()
                .filter((windowedKey, count) -> count != null)
                .map((windowedKey, count) -> KeyValue.pair(
                        windowedKey.key(),
                        toJson(
                                windowedKey.key(),
                                count,
                                windowedKey.window().start(),
                                windowedKey.window().end()
                        )
                ))
                .peek((key, value) -> System.out.printf("Session count update: %s -> %s%n", key, value))
                .to(outputTopic, Produced.with(Serdes.String(), Serdes.String()));

        return builder.build();
    }

    private static Properties buildProperties(String bootstrapServers, String applicationId, String stateDir) {
        Properties props = new Properties();
        props.put(StreamsConfig.APPLICATION_ID_CONFIG, applicationId);
        props.put(StreamsConfig.BOOTSTRAP_SERVERS_CONFIG, bootstrapServers);
        props.put(StreamsConfig.DEFAULT_KEY_SERDE_CLASS_CONFIG, Serdes.StringSerde.class.getName());
        props.put(StreamsConfig.DEFAULT_VALUE_SERDE_CLASS_CONFIG, Serdes.StringSerde.class.getName());
        props.put(StreamsConfig.COMMIT_INTERVAL_MS_CONFIG, "1000");
        props.put(StreamsConfig.STATE_DIR_CONFIG, stateDir);
        props.put(StreamsConfig.STATESTORE_CACHE_MAX_BYTES_CONFIG, "0");
        return props;
    }

    private static String toJson(String key, long count, long sessionStartMs, long sessionEndMs) {
        return String.format(
                Locale.ROOT,
                "{\"key\":\"%s\",\"count\":%d,\"sessionStart\":\"%s\",\"sessionEnd\":\"%s\"}",
                escapeJson(key),
                count,
                Instant.ofEpochMilli(sessionStartMs),
                Instant.ofEpochMilli(sessionEndMs)
        );
    }

    private static String argOrDefault(String[] args, int index, String defaultValue) {
        if (args.length <= index || args[index] == null || args[index].isBlank()) {
            return defaultValue;
        }
        return args[index];
    }

    private static long parsePositiveLong(String value, String name) {
        long parsed = Long.parseLong(value);
        if (parsed <= 0) {
            throw new IllegalArgumentException(name + " must be positive");
        }
        return parsed;
    }

    private static String escapeJson(String text) {
        StringBuilder escaped = new StringBuilder(text.length());
        for (int i = 0; i < text.length(); i++) {
            char c = text.charAt(i);
            switch (c) {
                case '"':
                    escaped.append("\\\"");
                    break;
                case '\\':
                    escaped.append("\\\\");
                    break;
                case '\b':
                    escaped.append("\\b");
                    break;
                case '\f':
                    escaped.append("\\f");
                    break;
                case '\n':
                    escaped.append("\\n");
                    break;
                case '\r':
                    escaped.append("\\r");
                    break;
                case '\t':
                    escaped.append("\\t");
                    break;
                default:
                    if (c < 0x20) {
                        escaped.append(String.format(Locale.ROOT, "\\u%04x", (int) c));
                    } else {
                        escaped.append(c);
                    }
            }
        }
        return escaped.toString();
    }
}
