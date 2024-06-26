DROP TABLE WORKERS_FACTORY_1;
DROP TABLE AUDIT_ROBOT;
DROP TABLE SUPPLIERS_BRING_TO_FACTORY_1;
DROP TABLE SUPPLIERS_BRING_TO_FACTORY_2;
DROP TABLE ROBOTS_HAS_SPARE_PARTS;
DROP TABLE ROBOTS_FROM_FACTORY;
DROP TABLE WORKERS_FACTORY_2 ;
DROP TABLE FACTORIES;
DROP TABLE SPARE_PARTS;
DROP TABLE SUPPLIERS;
DROP TABLE ROBOTS;

CREATE TABLE FACTORIES (
    id NUMBER GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    main_location VARCHAR2(255)
);

CREATE TABLE WORKERS_FACTORY_1 (
    id NUMBER GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    first_name VARCHAR2(100),
    last_name VARCHAR2(100),
    age NUMBER,
    first_day DATE,
    last_day DATE
);

CREATE TABLE WORKERS_FACTORY_2 (
    worker_id NUMBER GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    first_name VARCHAR2(100),
    last_name VARCHAR2(100),
    start_date DATE,
    end_date DATE
);

CREATE TABLE SUPPLIERS (
    supplier_id NUMBER GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    name VARCHAR2(100)
);

CREATE TABLE SPARE_PARTS (
    id NUMBER GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    color VARCHAR2(10) CHECK(color in ('red', 'gray', 'black', 'blue', 'silver')),
    name VARCHAR2(100)
);

CREATE TABLE SUPPLIERS_BRING_TO_FACTORY_1 (
    supplier_id NUMBER REFERENCES suppliers(supplier_id),
    spare_part_id NUMBER REFERENCES spare_parts(id),
    delivery_date DATE,
    quantity NUMBER CHECK(quantity > 0)
);

CREATE TABLE SUPPLIERS_BRING_TO_FACTORY_2 (
    supplier_id NUMBER REFERENCES suppliers(supplier_id) NOT NULL,
    spare_part_id NUMBER REFERENCES spare_parts(id) NOT NULL,
    delivery_date DATE,
    quantity NUMBER CHECK(quantity > 0),
    recipient_worker_id NUMBER REFERENCES workers_factory_2(worker_id) NOT NULL
);

CREATE TABLE ROBOTS (
    id NUMBER GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    model VARCHAR2(50)
);

CREATE TABLE ROBOTS_HAS_SPARE_PARTS (
    robot_id NUMBER REFERENCES robots(id),
    spare_part_id NUMBER REFERENCES spare_parts(id)
);

CREATE TABLE ROBOTS_FROM_FACTORY (
    robot_id NUMBER REFERENCES robots(id),
    factory_id NUMBER REFERENCES factories(id)
);

CREATE TABLE AUDIT_ROBOT (
    robot_id NUMBER REFERENCES robots(id),
    created_at DATE
);


-- Vue 1

CREATE OR REPLACE VIEW ALL_WORKERS AS
SELECT
    last_name,
    first_name,
    age,
    first_day AS start_date
FROM
    WORKERS_FACTORY_1
WHERE
    last_day IS NULL
UNION ALL
SELECT
    last_name,
    first_name,
    NULL as age,
    start_date
FROM
    WORKERS_FACTORY_2
WHERE
    end_date IS NULL
ORDER BY
    start_date DESC;


-- Vue 2

CREATE OR REPLACE VIEW ALL_WORKERS_ELAPSED AS
SELECT
    last_name,
    first_name,
    age,
    start_date,
    TRUNC(SYSDATE - start_date) AS days_elapsed
FROM
    ALL_WORKERS;


-- Vue 3

CREATE OR REPLACE VIEW BEST_SUPPLIERS AS
SELECT
    s.name AS supplier_name,
    SUM(sb.quantity) AS total_quantity
FROM
    SUPPLIERS s
JOIN
    SUPPLIERS_BRING_TO_FACTORY_1 sb ON s.supplier_id = sb.supplier_id
GROUP BY
    s.name
HAVING
    SUM(sb.quantity) > 1000
ORDER BY
    total_quantity DESC;


-- Vue 4

CREATE OR REPLACE VIEW ROBOTS_FACTORIES AS
SELECT
    r.id AS robot_id,
    f.main_location AS factory_location
FROM
    ROBOTS r
JOIN
    ROBOTS_FROM_FACTORY rf ON r.id = rf.robot_id
JOIN
    FACTORIES f ON rf.factory_id = f.id;