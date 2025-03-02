# otus-project-k8s
The final work of the OTUS lecture course "Kubernetes as a infrastructure platform"
### Описание решения
Решение адаптировано для развертывания на платформе [Selectel OpenStack](https://docs.selectel.ru/terraform/providers/) с использованием инструментов [Terraform](https://www.terraform.io/) и [KubeOne](https://docs.kubermatic.com/kubeone/v1.9/). 

В решении разворачиваются 3 управляющих ноды кластера и есть возможность развернуть необходимое количество worker-нод кластера k8s, с установкой характеристик нод через переменные `terraform.tfvars`

В работе используется 1 нода для нагрузок мониторинга, 1 нода для нагрузок логирования и 2 ноды для демо-приложения.

В процессе выполения работы удалось сконфигурировать CCM и CSI провайдер OpenStack Selectel, но к сожалению так и не удалось настроить динамические воркеры для управления worker-нодами кластера через CR

### Развертывание и настройка компонентов
Развертывание полностью автоматизировано через GitHub Actions, необходимые для развертывания переменные определены в переменных или секретах Actions.

Для отладочного развертывания необходимо скопировать файл `infra/secrets.sh` в `infra/.secrets.sh` и заполнить значения переменных

Переменные `SEL_S3_*` определяют реквизиты доступа к бакету для хранения файлов состояний Terraform

```shell
# Данные для доступа к хранилищу TF state
export SEL_S3_URL=
export SEL_S3_BUCKET=
export SEL_S3_KEY= # state filename, f.e. project.tfstate
export SEL_S3_ACCESS_KEY=
export SEL_S3_SECRET_KEY=
  
# администратор аккаунта и управления пользователями
export TF_VAR_sel_admin_user=
export TF_VAR_sel_admin_password=
export TF_VAR_sel_account_id=
```

Далее необходимо установить переменные окружения и запустить последовательно развертывание кластера k8s из папки `infra/bootstrap`, развертывание инструментов мониторинга и логирования (Grafana Prometheus Promtail Loki) из папки `infra/observability` и наконец развертывание тестового приложения Google Demo Online Boutique из папки `app/boutique`

```shell
source ./infra/.secrets.sh

pushd ./infra/bootstrap
./apply.sh
popd

pushd ./infra/observability
./apply.sh
popd

pushd ./app/boutique
./apply.sh
popd
```

### Подход к организации мониторинга и логирования
Для сбора и оперативного хранения метрик используются возможности prometheus-operator, визуализация через Grafana

Логи нагрузок кластера собираются через Promtail, хранятся в базе Loki и доступны через тот же интерфейс Grafana что и метрики кластера

### Changelog
| Дата | Изменение |
|-|-|
| 2024-12-15 | Инициализация проекта |
| 2025-02-08 | Опубликован код запуска кластера в Selectel через Terraform+Kubeone |
| 2025-02-08 | Настроен рабочий процесс GitHub Actions для автоматизации развертывания кластера |
| 2025-02-12 | Реализована установка и конфигурация prometheus-operator |
| 2025-03-02 | Настроена система логирования Grafana Loki |
| 2025-03-02 | Настроено развертывание тестового приложения Google Online Boutique Demo App |
| 2025-03-03 | Протестировано полное развертывание с нуля через пайплайн |
