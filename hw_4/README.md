# ДЗ 4: Kafka Streams

Цель: разработать Kafka Streams приложение, которое считает количество событий с одинаковым key в рамках сессии 5 минут.

## Что сделано

- Kafka запускается локально в режиме KRaft без ZooKeeper.
- Используется локальная Kafka из `.local/kafka_2.13-3.9.2`.
- Создаются топики:
  - `events` - входные события;
  - `event-counts` - обновления счетчика по сессиям.
- Java Kafka Streams приложение:
  - читает `KStream<String, String>` из `events`;
  - отбрасывает записи без key;
  - группирует события через `groupByKey`;
  - считает события в `SessionWindows` с inactivity gap 5 минут;
  - хранит состояние в `event-session-counts-store`;
  - пишет результат в `event-counts` и печатает обновления в stdout.

## Быстрый запуск

Из корня репозитория:

```bash
./hw_4/scripts/run-demo.sh
```

Скрипт запустит Kafka, пересоздаст топики, скомпилирует приложение, запустит Kafka Streams, отправит тестовые сообщения через `kafka-console-producer.sh` и прочитает результат из `event-counts`.

Остановка Kafka:

```bash
./hw_4/scripts/stop.sh
```

## Пошаговый запуск

1. Запустить Kafka:

```bash
./hw_4/scripts/start.sh
```

2. Создать или пересоздать топики:

```bash
./hw_4/scripts/reset-topics.sh
```

3. Запустить Kafka Streams приложение:

```bash
./hw_4/scripts/run-app.sh
```

4. В отдельном терминале отправить сообщения через console producer:

```bash
./hw_4/scripts/run-producer.sh
```

Пример ввода:

```text
user-1:first event
user-1:second event
user-2:another event
user-1:third event
```

5. В отдельном терминале прочитать результаты:

```bash
./hw_4/scripts/run-consumer.sh
```

Пример результата:

```text
user-1 -> {"key":"user-1","count":1,"sessionStart":"2026-01-01T10:00:00Z","sessionEnd":"2026-01-01T10:00:00Z"}
user-1 -> {"key":"user-1","count":2,"sessionStart":"2026-01-01T10:00:00Z","sessionEnd":"2026-01-01T10:00:05Z"}
user-2 -> {"key":"user-2","count":1,"sessionStart":"2026-01-01T10:00:10Z","sessionEnd":"2026-01-01T10:00:10Z"}
user-1 -> {"key":"user-1","count":3,"sessionStart":"2026-01-01T10:00:00Z","sessionEnd":"2026-01-01T10:00:15Z"}
```

В реальном запуске timestamps будут соответствовать времени отправки сообщений producer-ом.

## Настройки

Переменные окружения можно переопределить перед запуском скриптов:

- `BOOTSTRAP_SERVER`, по умолчанию `127.0.0.1:9092`.
- `APPLICATION_ID`, по умолчанию `hw4-event-session-counter`.
- `INPUT_TOPIC`, по умолчанию `events`.
- `OUTPUT_TOPIC`, по умолчанию `event-counts`.
- `SESSION_GAP_MINUTES`, по умолчанию `5`.

## Где делать скриншоты

1. Запуск Kafka и создание топиков:

```bash
./hw_4/scripts/start.sh
./hw_4/scripts/reset-topics.sh
```

2. Запуск Kafka Streams приложения:

```bash
./hw_4/scripts/run-app.sh
```

3. Отправка сообщений через console producer:

```bash
./hw_4/scripts/run-producer.sh
```

4. Чтение результата:

```bash
./hw_4/scripts/run-consumer.sh
```
