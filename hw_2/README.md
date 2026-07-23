# ДЗ 2: Kafka KRaft и безопасность

Цель: развернуть локальную Kafka в режиме KRaft, включить SASL/PLAIN, создать пользователей, настроить ACL и проверить доступы.

## Что настроено

- Kafka: локальная установка из `.local/kafka_2.13-3.9.2`
- Java: локальный JDK из `.local/jdk`
- Режим Kafka: KRaft, без ZooKeeper
- Broker/client listener: `SASL_PLAINTEXT://127.0.0.1:9094`
- Controller listener: `CONTROLLER://127.0.0.1:9095` через `SASL_PLAINTEXT`
- Topic: `test`
- Авторизация: `org.apache.kafka.metadata.authorizer.StandardAuthorizer`
- Аутентификация: `SASL/PLAIN`

## Пользователи

| Пользователь | Пароль | Роль |
|---|---|---|
| `admin` | `admin-secret` | super user для администрирования |
| `controller` | `controller-secret` | внутренний пользователь KRaft controller |
| `broker` | `broker-secret` | внутренний пользователь broker |
| `writer` | `writer-secret` | может писать в `test` |
| `reader` | `reader-secret` | может читать из `test` через группу `reader-group` |
| `guest` | `guest-secret` | не имеет прав на `test` |

## Быстрый запуск

```bash
git switch hw_2
./hw_2/scripts/start.sh
./hw_2/scripts/create-topic-and-acls.sh
./hw_2/scripts/run-checks.sh
```

Остановка:

```bash
./hw_2/scripts/stop.sh
```

## Ключевые команды

Сгенерировать UUID кластера и отформатировать папку журналов:

```bash
./hw_2/scripts/format.sh
```

Запустить broker/controller:

```bash
./hw_2/scripts/start.sh
```

Если нужно видеть живой лог broker/controller прямо в терминале:

```bash
./hw_2/scripts/start-foreground.sh
```

Создать topic `test`:

```bash
./.local/kafka_2.13-3.9.2/bin/kafka-topics.sh \
  --bootstrap-server 127.0.0.1:9094 \
  --command-config hw_2/config/clients/admin.properties \
  --create \
  --if-not-exists \
  --topic test \
  --partitions 1 \
  --replication-factor 1
```

Выдать права:

```bash
./.local/kafka_2.13-3.9.2/bin/kafka-acls.sh \
  --bootstrap-server 127.0.0.1:9094 \
  --command-config hw_2/config/clients/admin.properties \
  --add \
  --allow-principal User:writer \
  --operation Write \
  --topic test

./.local/kafka_2.13-3.9.2/bin/kafka-acls.sh \
  --bootstrap-server 127.0.0.1:9094 \
  --command-config hw_2/config/clients/admin.properties \
  --add \
  --allow-principal User:reader \
  --operation Read \
  --topic test

./.local/kafka_2.13-3.9.2/bin/kafka-acls.sh \
  --bootstrap-server 127.0.0.1:9094 \
  --command-config hw_2/config/clients/admin.properties \
  --add \
  --allow-principal User:reader \
  --operation Read \
  --group reader-group
```

Проверить доступы:

```bash
./hw_2/scripts/run-checks.sh
```

## Что должно получиться

- `writer` успешно пишет сообщение в `test`.
- `reader` не может писать, но успешно читает сообщение из `test`.
- `guest` не может писать и читать `test`.
- `admin` видит топики и ACL, потому что указан в `super.users`.

## Где делать скриншоты

1. Запуск KRaft и UUID кластера:

```bash
./hw_2/scripts/start.sh
```

2. Созданный topic и ACL:

```bash
./hw_2/scripts/create-topic-and-acls.sh
```

3. Проверка трёх пользователей:

```bash
./hw_2/scripts/run-checks.sh
```

На третьем скриншоте будут видны успешная запись `writer`, успешное чтение `reader` и ошибки доступа для `guest`.
