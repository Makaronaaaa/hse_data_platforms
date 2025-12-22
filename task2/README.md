# Практическое задание №2

**Развертывание Hadoop HDFS и YARN кластера с веб-интерфейсами**

## Предисловие

В реализации `task1` было добавлена функция очистки данных оставшихся после предыдущих запусков развертывания, и она была встроена в playbook файл, который запускал развертывание. Но в реализации `task2` для удобства мы сделали отдельный файл `reset.yml`

## Инструкция по использованию

### 1. Предварительные требования

На вашей машине должны быть установлены:

Для Linux 
```bash
sudo apt update
sudo apt install -y ansible sshpass
```

Для macOS
```bash
brew install ansible
brew insta
```

### 2. Клонируйте репозиторий и перейдите в нужную папку:

```bash
git clone https://github.com/Makaronaaaa/hse_data_platforms.git
cd hse_data_platforms/task2
```
### 3. Настройте файл `inventory.ini`

Замените `YourPassword` на пароль, выданный для team-22:

```bash
[namenodes]
team-22-nn ansible_host=192.168.1.91 ansible_user=team ansible_ssh_pass=YourPassword ansible_become_pass=YourPassword

[datanodes]
team-22-nn ansible_host=192.168.1.91 ansible_user=team ansible_ssh_pass=YourPassword ansible_become_pass=YourPassword
team-22-dn-00 ansible_host=192.168.1.92 ansible_user=team ansible_ssh_pass=YourPassword ansible_become_pass=YourPassword
team-22-dn-01 ansible_host=192.168.1.93 ansible_user=team ansible_ssh_pass=YourPassword ansible_become_pass=YourPassword
```

### 4. Подготовьтесь к старту и запустите развертывание

Рекомендуется запустить очистку данных после прошлых запусков

```bash
ansible-playbook reset.yml
```

Полное развертывание запускается командой:
```bash
ansible-playbook deploy_all.yml
```

Или по отдельности:
```bash

ansible-playbook reset.yml

ansible-playbook deploy_hdfs.yml

ansible-playbook deploy_yarn.yml
```

### 5. Настройка доступа к веб-интерфейсам

После развертывания запустите этот скрипт, он в фоновом режиме создаст туннели

```bash
./setup_web_access.sh
```

Если скрипт не работает, создайте туннели вручную:

Откройте **три отдельных окна терминала** и выполните в каждом (для входа используйте пароль выданный команде 22):

```bash
# Терминал 1 - HDFS NameNode
ssh -L 9870:192.168.1.91:9870 team@176.109.91.43

# Терминал 2 - YARN ResourceManager  
ssh -L 8088:192.168.1.91:8088 team@176.109.91.43

# Терминал 3 - MapReduce JobHistory
ssh -L 19888:192.168.1.91:19888 team@176.109.91.43
```

## Как увидеть результат

### Веб-интерфейсы

После создания SSH-туннелей откройте в браузере:

- **HDFS NameNode:** http://localhost:9870
  - Ожидаемый результат: 3 Live Nodes, 0 Dead Nodes

- **YARN ResourceManager:** http://localhost:8088
  - Ожидаемый результат: 3 Active Nodes, 0 Lost Nodes

- **MapReduce JobHistory:** http://localhost:19888
  - Ожидаемый результат: страница истории задач

## Архитектура кластера

- **team-22-nn (192.168.1.91):**
  - NameNode + DataNode + Secondary NameNode
  - ResourceManager + NodeManager
  - JobHistory Server

- **team-22-dn-00 (192.168.1.92):**
  - DataNode + NodeManager

- **team-22-dn-01 (192.168.1.93):**
  - DataNode + NodeManager

## Особенности решения

### 1. Модульная архитектура
- **`reset.yml`** - отдельный playbook для полной очистки кластера
- **`deploy_hdfs.yml`** - развертывание только HDFS (без очистки)
- **`deploy_yarn.yml`** - развертывание только YARN
- **`deploy_all.yml`** - полное развертывание (HDFS + YARN)

### 2. Автоматизация доступа к веб-интерфейсам
- **`setup_web_access.sh`** - автоматически создает SSH-туннели для всех веб-интерфейсов
- Поддерживает `sshpass` для автоматического ввода пароля
- Фоновый режим работы - не блокирует терминал

### 3. Публикация портов
Решение "публикует" веб-интерфейсы через SSH-туннели на локальную машину:
- **9870** → HDFS NameNode UI
- **8088** → YARN ResourceManager UI  
- **19888** → MapReduce JobHistory UI


## Что делает deploy_all.yml

Playbook выполняет развертывание в 2 этапа:

### Этап 1: HDFS (deploy_hdfs.yml)
1. **Подготовка системы** - пользователь hadoop, SSH, /etc/hosts
2. **Установка Hadoop** - скачивание и распаковка Hadoop 3.3.6
3. **Конфигурация HDFS** - core-site.xml, hdfs-site.xml, workers
4. **Запуск сервисов** - NameNode, Secondary NameNode, DataNodes
5. **Проверка** - ожидание регистрации DataNodes, вывод отчета

### Этап 2: YARN (deploy_yarn.yml)
1. **Конфигурация YARN** - yarn-site.xml, mapred-site.xml
2. **Подготовка директорий** - /home/hadoop/hadoop_data/yarn/
3. **Запуск сервисов**:
   - ResourceManager (только на NameNode)
   - NodeManager (на всех узлах)
   - JobHistory Server (только на NameNode)
4. **Быстрая проверка** - проверка процессов и портов



## Ключевой результат

После выполнения `ansible-playbook deploy_all.yml` и `./setup_web_access.sh`:

1. **Полностью рабочий HDFS кластер:**
   - 3 Live DataNodes
   - Статус "Normal" у всех узлов
   - Доступ через http://localhost:9870

2. **Полностью рабочий YARN кластер:**
   - ResourceManager с 3 NodeManagers
   - 3 Active Nodes в веб-интерфейсе
   - Доступ через http://localhost:8088

3. **MapReduce JobHistory Server:**
   - Готов к приему информации о задачах
   - Доступ через http://localhost:19888

4. **Автоматический доступ** - все веб-интерфейсы доступны локально через SSH-туннели
