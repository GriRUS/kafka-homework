# ДЗ 5: Kafka Connect и Debezium PostgreSQL CDC

Цель: развернуть Kafka Connect и настроить интеграцию с PostgreSQL через Debezium PostgreSQL CDC Source Connector.

## Что сделано

- Kafka запускается в Docker Compose.
- PostgreSQL запускается с `wal_level=logical`, чтобы Debezium мог читать WAL через `pgoutput`.
- В PostgreSQL создается тестовая таблица `inventory.clients`.
- Kafka Connect запускается из образа Debezium с готовым PostgreSQL CDC connector.
- Connector регистрируется через Kafka Connect REST API.
- Для сообщений используется JSON converter без схем.
- Добавлены SMT-трансформации:
  - `ExtractNewRecordState` - разворачивает Debezium envelope и оставляет полезную нагрузку записи;
  - `RegexRouter` - переименовывает топик из `pg.inventory.clients` в `postgres.clients`.

## Быстрый запуск

Из корня репозитория:

```bash
./hw_5/scripts/run-demo.sh
```

Скрипт поднимет Kafka, PostgreSQL и Kafka Connect, зарегистрирует Debezium connector, добавит тестовые записи в `inventory.clients` и прочитает события из Kafka-топика `postgres.clients`.

Остановка и очистка Docker-томов:

```bash
./hw_5/scripts/down.sh
```

## Пошаговый запуск

1. Запустить Kafka, PostgreSQL и Kafka Connect:

```bash
./hw_5/scripts/up.sh
```

2. Зарегистрировать Debezium PostgreSQL CDC Source Connector:

```bash
./hw_5/scripts/register-connector.sh
```

3. Добавить записи в PostgreSQL:

```bash
./hw_5/scripts/insert-records.sh
```

4. Проверить, что появились топики:

```bash
./hw_5/scripts/status.sh
```

5. Прочитать события из Kafka:

```bash
./hw_5/scripts/consume.sh
```

## Ожидаемый результат

В выводе consumer должны появиться записи из таблицы PostgreSQL. Пример:

```text
{"id":1001} -> {"id":1001,"first_name":"Ivan","last_name":"Petrov","gender":"male","card_number":"4111111111111111","bill":"5500.00",...}
{"id":1002} -> {"id":1002,"first_name":"Anna","last_name":"Sidorova","gender":"female","card_number":"5555555555554444","bill":"7300.50",...}
{"id":1003} -> {"id":1003,"first_name":"Pavel","last_name":"Ivanov","gender":"male","card_number":"4012888888881881","bill":"1200.75",...}
```

Топик после SMT-трансформации называется `postgres.clients`.

## Настройки

Переменные окружения можно переопределить перед запуском скриптов:

- `DEBEZIUM_VERSION`, по умолчанию `3.6`.
- `POSTGRES_VERSION`, по умолчанию `17`.
- `CONNECT_HOST_PORT`, по умолчанию `8083`.
- `POSTGRES_HOST_PORT`, по умолчанию `55432`.
- `CONNECT_URL`, по умолчанию `http://localhost:8083`.
- `CONNECTOR_NAME`, по умолчанию `postgres-clients-cdc`.
- `KAFKA_TOPIC`, по умолчанию `postgres.clients`.
- `MAX_MESSAGES`, по умолчанию `4`.

## Где делать скриншоты

1. Запуск стенда:

```bash
./hw_5/scripts/up.sh
```

2. Регистрация connector:

```bash
./hw_5/scripts/register-connector.sh
```

3. Добавление записей в PostgreSQL:

```bash
./hw_5/scripts/insert-records.sh
```

4. Проверка сообщений в Kafka:

```bash
./hw_5/scripts/consume.sh
```
