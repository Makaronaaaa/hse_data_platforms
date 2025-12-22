# Homework 6 (GreenPlum)

1. Открытие терминала и подключение к базе данных:
    ```
    ssh user@91.185.85.179
    ```
    Вводим пароль и можем продолжать работу.

2. Создаем директорию для выгрузки данных:
    ```
    mkdir ~/data/
    cd ~/data/
    ```

3. Загружаем данные из хранилища в созданный каталог и распаковываем их:

    ```
    curl -L -o ./data.zip https://www.kaggle.com/api/v1/datasets/download/saurabh00007/iriscsv
    unzip ./data.zip
    ```
    
4. Создаем отдельный терминал и запускаем gpfdist:
    ```
    gpfdist -d /home/user/data -p 8081
    ```

5. Теперь можем подключиться к базе:
    ```
    psql -d idp
    ```
6. Создаем EXTERNAL таблицу:
    ```
    CREATE EXTERNAL TABLE team_22 (
        Id               INTEGER,
        SepalLengthCm    FLOAT,
        SepalWidthCm     FLOAT,
        PetalLengthCm    FLOAT,
        PetalWidthCm     FLOAT,
        Species          TEXT
    )
    LOCATION ('gpfdist://localhost:8081/Iris.csv')
    FORMAT 'csv' (delimiter ',' header);
    ```
7. Теперь создаем "настоящую" таблицу:
    ```
    CREATE TABLE team_22_manages (
        Id               INTEGER,
        SepalLengthCm    FLOAT,
        SepalWidthCm     FLOAT,
        PetalLengthCm    FLOAT,
        PetalWidthCm     FLOAT,
        Species          TEXT
    )
    WITH (
        APPENDONLY=true,
        ORIENTATION=column,
        COMPRESSTYPE=zlib
    )
    DISTRIBUTED BY (Id);
8. Перемещаем в нее данные:
    ```
    INSERT INTO 
        team_22_managed
    SELECT 
        * 
    FROM 
        team_22;
    ```
9. Проверяем работоспособность Select запроса:
    ```
    SELECT 
        COUNT(*) 
    FROM 
        team_22_managed;
    ```
    вывод:
    ```
     count 
    -------
       150
    (1 row)
    ```
    Можем сделать вывод, что SQL запросы к базе тоже отрабатывают верно
