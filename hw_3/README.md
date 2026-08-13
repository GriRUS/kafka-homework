# ДЗ 3: Kafka transactions

Цель: локально запустить Kafka и показать, что consumer с `isolation.level=read_committed` читает сообщения из подтвержденной транзакции и не читает сообщения из отмененной транзакции.

## Что сделано

- Kafka запускается локально в режиме KRaft без ZooKeeper.
- Используется локальная Kafka из `.local/kafka_2.13-3.9.2`.
- Создаются два топика: `topic1` и `topic2`.
- Java producer:
  - открывает первую транзакцию;
  - отправляет по 5 сообщений в `topic1` и `topic2`;
  - подтверждает транзакцию;
  - открывает вторую транзакцию;
  - отправляет по 2 сообщения в `topic1` и `topic2`;
  - отменяет транзакцию.
- Java consumer читает оба топика с `isolation.level=read_committed`.

## Быстрый запуск

Из корня репозитория:

```bash
./hw_3/scripts/run-demo.sh
```

Скрипт сам запустит Kafka, пересоздаст `topic1` и `topic2`, скомпилирует Java-код, запустит producer и затем consumer.

Остановка Kafka:

```bash
./hw_3/scripts/stop.sh
```

## Пошаговый запуск

```bash
./hw_3/scripts/start.sh
./hw_3/scripts/reset-topics.sh
./hw_3/scripts/run-producer.sh
./hw_3/scripts/run-consumer.sh
```

Проверить топики:

```bash
./hw_3/scripts/status.sh
```

## Ожидаемый результат

В выводе producer должно быть видно:

- `COMMITTING first transaction`
- `First transaction committed`
- `ABORTING second transaction`
- `Second transaction aborted`

В выводе consumer должно быть ровно 10 сообщений:

- 5 сообщений из `topic1`;
- 5 сообщений из `topic2`;
- `Visible aborted messages: 0`.

Сообщения из второй, отмененной транзакции содержат `tx=aborted`, но consumer с `read_committed` их не выводит.

## Где делать скриншоты

1. Запуск Kafka и создание топиков:

```bash
./hw_3/scripts/start.sh
./hw_3/scripts/reset-topics.sh
```

2. Producer с commit и abort:

```bash
./hw_3/scripts/run-producer.sh
```

3. Consumer, который видит только подтвержденные сообщения:

```bash
./hw_3/scripts/run-consumer.sh
```

Можно также сделать один общий скриншот после:

```bash
./hw_3/scripts/run-demo.sh
```
