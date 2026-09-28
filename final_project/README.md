# Защищённый Kafka-кластер с мониторингом и контролем доступа

Итоговый проект: локальный кластер из трёх Kafka-брокеров в режиме KRaft. Клиенты подключаются с аутентификацией SASL/PLAIN поверх TLS, права ограничены ACL, состояние кластера и consumer lag отображаются в Grafana.

## Состав проекта

- 3 Kafka broker/controller узла, replication factor 3 и `min.insync.replicas=2`;
- топики `orders`, `payments`, `notifications`, `audit-events`;
- роли `order_service`, `payment_service`, `notification_service`, `auditor`, `monitoring`, `guest`;
- Prometheus с alert rules, JMX Exporter, Kafka Exporter и готовый Grafana dashboard;
- автоматическая проверка разрешённых и запрещённых операций.

## Модель доступа

| Пользователь | Разрешено | Запрещено |
|---|---|---|
| `order_service` | запись в `orders` | чтение и остальные топики |
| `payment_service` | чтение `orders`, запись в `payments` | остальные операции |
| `notification_service` | чтение `payments`, запись в `notifications` | остальные операции |
| `auditor` | чтение всех предметных топиков | запись |
| `monitoring` | чтение метаданных и offsets | запись |
| `guest` | только аутентификация | любые операции с топиками |
| `admin` | администрирование кластера | нет ограничений |

Пароли открыто лежат в конфигурации только потому, что это локальный учебный стенд. В промышленной среде их нужно хранить в secret manager.

## Запуск

Нужны Docker, Docker Compose, OpenSSL и Java `keytool`.

```bash
./final_project/scripts/up.sh
```

Первый запуск скачает Docker-образы и соберёт образ Kafka с JMX Exporter. После запуска доступны:

- Grafana: http://localhost:3000, логин и пароль `admin` / `admin`;
- Prometheus: http://localhost:9090;
- Kafka TLS listeners: `localhost:19092`, `localhost:29092`, `localhost:39092`.

Dashboard `Kafka: безопасность и состояние кластера` создаётся автоматически в папке `Kafka`.

## Демонстрация

```bash
./final_project/scripts/run-demo.sh
```

Скрипт показывает:

1. `order_service` записывает заказ с `acks=all`;
2. `payment_service` читает заказ и записывает платёж;
3. `auditor` читает платёж;
4. Kafka отклоняет запись от `guest`, чтение от `order_service` и запись от `auditor`.

Состояние топиков, репликации и consumer groups:

```bash
./final_project/scripts/status.sh
```

Остановка без удаления данных:

```bash
./final_project/scripts/down.sh
```

## Что показать на защите

1. `docker compose ps`: три здоровых Kafka-брокера и сервисы мониторинга.
2. Результат `run-demo.sh`: разрешённые действия проходят, запрещённые блокируются ACL.
3. Grafana: число доступных брокеров, поток сообщений и lag consumer groups.
4. Остановить один брокер командой `docker compose -f final_project/compose.yaml stop kafka-3`, повторить demo и показать, что запись с `acks=all` продолжает работать благодаря двум синхронным репликам.
