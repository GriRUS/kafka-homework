# Kafka homework: локальный запуск с ZooKeeper

В проекте используется Apache Kafka 3.9.2 и локальный Temurin JDK 17. Они лежат
в игнорируемом Git каталоге `.local`, поэтому системная Java и Homebrew не нужны.

Адреса сервисов:

- Kafka Broker: `127.0.0.1:9092`
- ZooKeeper: `127.0.0.1:2181`
- топик: `test` (1 partition, replication factor 1)

## Запуск

Из корня проекта:

```bash
./scripts/start.sh
./scripts/status.sh
```

## Запись сообщений и скриншот producer

В первом окне Terminal:

```bash
cd /Users/grigorijtarasov/kafka-homework
./scripts/producer.sh
```

Введите несколько строк, нажимая Enter после каждой. Сделайте скриншот, затем
остановите producer сочетанием `Ctrl+C`.

## Чтение сообщений и скриншот consumer

Во втором окне Terminal:

```bash
cd /Users/grigorijtarasov/kafka-homework
./scripts/consumer.sh
```

Consumer прочитает топик с самого начала и покажет partition и offset каждого
сообщения. Сделайте скриншот и остановите consumer сочетанием `Ctrl+C`.

## Подключение из приложения

В настройках Kafka-клиента укажите bootstrap server:

```text
127.0.0.1:9092
```

Аутентификация и TLS для учебного локального стенда отключены (`PLAINTEXT`).

## Остановка

```bash
./scripts/stop.sh
```

Данные сохраняются в `.runtime`, логи — в `logs`. После повторного запуска
топик и сообщения останутся на месте.
