# terraform-formula

SaltStack-формула для установки [HashiCorp Terraform](https://www.terraform.io/) без использования пакетных менеджеров.

Формула скачивает предсобранные бинарники Terraform напрямую из зеркала релизов, устанавливает несколько версий параллельно и управляет переключением между ними через систему `alternatives`.

## Возможности

- Установка произвольного набора версий Terraform из ZIP-архивов
- Автоматическая верификация контрольных сумм (SHA256SUMS)
- Поддержка архитектур `amd64` (x86_64) и `arm64` (aarch64) с автоопределением
- Переключение между версиями через `update-alternatives`
- Очистка скачанных архивов после распаковки
- Идемпотентность: повторный запуск не перекачивает уже установленные версии

## Поддерживаемые ОС

| Семейство | Дистрибутивы          |
|-----------|-----------------------|
| Debian    | Debian 12, Ubuntu 20.04+ |
| RedHat    | Rocky Linux 9, CentOS, RHEL |

## Требования

- SaltStack >= 3001.1
- Доступ к зеркалу релизов Terraform (по умолчанию `hashicorp-releases.yandexcloud.net`)

## Структура

```
terraform/
  init.sls              # Точка входа, подключает install
  install/
    init.sls            # Основная логика: скачивание, распаковка, alternatives
  settings.jinja        # Дефолты, макросы для URL скачивания и хешей
FORMULA                 # Метаданные формулы
pillar.example          # Пример pillar-данных
.kitchen.yml            # Конфигурация Test Kitchen
```

## Что делает формула (по шагам)

1. Создает корневой каталог для бинарников (`/usr/local/tools`)
2. Для каждой указанной версии:
   - Скачивает ZIP-архив из зеркала
   - Проверяет SHA256-хеш по файлу `SHA256SUMS`
   - Распаковывает в отдельный подкаталог (`/usr/local/tools/<version>/terraform`)
   - Регистрирует версию в системе `alternatives` (симлинк `/usr/local/bin/terraform`)
   - Удаляет ZIP-архив

Приоритет в `alternatives` вычисляется из номера версии с удалением точек (например, `1.8.5` -> приоритет `185`), поэтому по умолчанию активна самая старшая версия.

## Конфигурация (Pillar)

Пример pillar-данных (`pillar.example`):

```yaml
terraform:
  url: 'https://hashicorp-releases.yandexcloud.net/terraform'
  versions:
    - '1.8.5'
    - '1.7.5'
    - '1.5.0'
  default: '1.8.5'
  arch: 'amd64'
  dirs:
    root: '/usr/local/tools'
```

| Параметр    | По умолчанию | Описание |
|-------------|-------------|----------|
| `url`       | `https://hashicorp-releases.yandexcloud.net/terraform` | Базовый URL зеркала релизов |
| `versions`  | `['1.8.5']` | Список версий для установки |
| `default`   | `1.8.5`     | Версия по умолчанию (информационное поле) |
| `arch`      | автоопределение из `grains.cpuarch` | Архитектура: `amd64` или `arm64` |
| `dirs.root` | `/usr/local/tools` | Каталог для размещения бинарников |

Все параметры опциональны. Pillar-данные мержатся с дефолтами из `settings.jinja`.

## Тестирование

Формула тестируется с помощью [Test Kitchen](https://kitchen.ci/) и Docker.

### Требования для тестов

- [Docker](https://docs.docker.com/get-docker/)
- Ruby с установленными гемами:
  - `test-kitchen`
  - `kitchen-docker`
  - `kitchen-salt`

### Установка зависимостей

```bash
gem install test-kitchen kitchen-docker kitchen-salt
```

### Запуск тестов

```bash
# Список доступных платформ
kitchen list

# Запуск полного цикла (create + converge + verify + destroy) на всех платформах
kitchen test

# Запуск на конкретной платформе
kitchen test terraform-debian-12-slim
kitchen test terraform-ubuntu-2004
kitchen test terraform-rockylinux-9-minimal

# Пошаговый запуск (удобно при отладке)
kitchen create terraform-debian-12-slim    # создать контейнер
kitchen converge terraform-debian-12-slim  # применить формулу
kitchen login terraform-debian-12-slim     # зайти в контейнер для проверки
kitchen destroy terraform-debian-12-slim   # удалить контейнер
```

### Тестовые платформы

| Платформа              | Docker-образ              | Предустановленные пакеты |
|------------------------|--------------------------|--------------------------|
| Debian 12              | `debian-12-slim`         | wget, curl, tar, mc, locales |
| Ubuntu 20.04           | `ubuntu-20.04`           | wget, curl, tar, mc, locales |
| Rocky Linux 9          | `rockylinux-9-minimal`   | wget, tar, mc, iproute, nmap-ncat |

При тестировании Salt устанавливается автоматически через [salt-bootstrap](https://github.com/saltstack/salt-bootstrap).

## Использование

Добавьте формулу в файловую систему Salt (`file_roots`) и включите стейт:

```yaml
# /srv/salt/top.sls
base:
  '*':
    - terraform
```

```yaml
# /srv/pillar/terraform.sls
terraform:
  versions:
    - '1.9.0'
    - '1.8.5'
```

После применения:

```bash
# Проверить установленные версии
ls /usr/local/tools/

# Посмотреть текущую активную версию
terraform --version

# Переключить версию
update-alternatives --config terraform
```