CREATE DATABASE business;
USE business;

CREATE TABLE IF NOT EXISTS transactions (
        id VARCHAR(50) PRIMARY KEY,
		card_id VARCHAR(20),
		business_id VARCHAR(10),
		timestamp TIMESTAMP,
		amount DECIMAL(20, 2),
		declined BOOLEAN,
		product_ids INT,
		user_id INT,
		lat FLOAT,
		longitude FLOAT
        );

CREATE TABLE IF NOT EXISTS products (
        id VARCHAR(10) PRIMARY KEY,
        product_name VARCHAR(50),
        price DECIMAL(20, 2),
        colour VARCHAR(10),
        weight DECIMAL(4, 2),
        warehouse_id VARCHAR(10)
        );
        
CREATE TABLE IF NOT EXISTS companies (
        company_id VARCHAR(10) PRIMARY KEY,
        company_name VARCHAR(100),
        phone VARCHAR(20),
        email VARCHAR(50),
        country VARCHAR(50),
        website VARCHAR(100)
        );

CREATE TABLE IF NOT EXISTS credit_cards (
		id VARCHAR(20) PRIMARY KEY,
        user_id INT,
        iban VARCHAR(50),
        pan VARCHAR(20),
		pin CHAR(4),
		cvv CHAR(3),
        track1 VARCHAR(100),
        track2 VARCHAR(100),
        expiring_date DATE
        );

CREATE TABLE IF NOT EXISTS users (
		id INT PRIMARY KEY,
        name VARCHAR(20),
        surname VARCHAR(50),
        phone VARCHAR(20),
        email VARCHAR(50),
        birth_date DATE,
        country VARCHAR(50),
        city VARCHAR(50),
        postal_code VARCHAR(10),
        address VARCHAR(50)
         );

-- Com que product_ids és una llista, cal fer una altra taula que anomenaré transaction_products:
CREATE TABLE IF NOT EXISTS transaction_products (
    transaction_id VARCHAR(50),
    product_id VARCHAR(10),
    PRIMARY KEY (transaction_id, product_id),
    FOREIGN KEY (transaction_id) REFERENCES transactions(id),
    FOREIGN KEY (product_id) REFERENCES products(id)
);

-- i eliminar la columna que no cal
DESCRIBE transactions;
ALTER TABLE transactions
DROP COLUMN product_ids;
DESCRIBE transactions;

-- establir les FK
ALTER TABLE business.credit_cards
ADD CONSTRAINT FK_user_creditcards
FOREIGN KEY (user_id) REFERENCES users(id);

ALTER TABLE business.transactions
ADD CONSTRAINT FK_creditcards_transactions
FOREIGN KEY (card_id) REFERENCES credit_cards(id);

ALTER TABLE business.transactions
ADD CONSTRAINT FK_companies_transactions
FOREIGN KEY (business_id) REFERENCES companies(company_id);

ALTER TABLE business.transactions
ADD CONSTRAINT FK_users_transactions
FOREIGN KEY (user_id) REFERENCES users(id);

-- segueixo exercici 1
-- IMPORTAR
-- passos previs. Per PRICE: fer-lo VARCHAR i treure $ amb SUBSTRING després. Fer-lo DECIMAL al final:

ALTER TABLE products
MODIFY COLUMN price VARCHAR(20); 

SELECT SUBSTRING(price,2,len(price))
FROM products;

SELECT c.*
FROM credit_cards c;

DESCRIBE companies;
DESCRIBE credit_cards;
DESCRIBE products;
DESCRIBE transaction_products;
DESCRIBE transactions;
DESCRIBE users;

SELECT p.*
FROM products p;

SELECT SUBSTRING(price, 2) AS price_sense_dolar 
FROM products;

UPDATE products SET price = REPLACE(price, '$', '');

SET SQL_SAFE_UPDATES = 0;
UPDATE products SET price = REPLACE(price, '$', '');
SET SQL_SAFE_UPDATES = 1;

ALTER TABLE products
MODIFY COLUMN price DECIMAL(12,2);

-- faig diagrama
-- afegeixo FK
ALTER TABLE transaction_products
ADD CONSTRAINT fk_transaction_products_transaction
FOREIGN KEY (transaction_id)
REFERENCES transactions(id)
ON DELETE CASCADE
ON UPDATE CASCADE;

ALTER TABLE transaction_products
ADD CONSTRAINT fk_transaction_products_product
FOREIGN KEY (product_id)
REFERENCES products(id)
ON DELETE CASCADE
ON UPDATE CASCADE;

-- canvio nom de columna a companies 
ALTER TABLE companies RENAME COLUMN company_id TO id;

-- creació indexs
-- transaction_products.product_id
CREATE INDEX idx_transaction_products_product
ON transaction_products (product_id);
-- transaction_products.transaction_id
CREATE INDEX idx_transaction_products_transaction
ON transaction_products (transaction_id);
-- credit_cards.user_id
CREATE INDEX idx_credit_cards_user
ON credit_cards (user_id);

-- NIVELL 1. ex 1
SELECT u.*
FROM users u
WHERE id IN (
    SELECT user_id
    FROM transactions
    GROUP BY user_id
    HAVING COUNT(*) > 30
);

-- perquè es vegin el nombre de transaccions, ja que amb més de 30 el resultat és nul
SELECT u.id,
       u.name,
       COUNT(t.id) AS num_transaccions
FROM users u
JOIN transactions t ON u.id = t.user_id
GROUP BY u.id, u.name
HAVING COUNT(t.id) > 1
ORDER BY num_transaccions DESC;

-- Nivell 1 ex2
SELECT c.company_name,
		cc.iban,
       AVG(t.amount) AS mitjana_amount
FROM transactions t
JOIN credit_cards cc ON t.card_id = cc.id
JOIN companies c ON t.business_id = c.id
WHERE c.company_name = 'Donec Ltd'
GROUP BY cc.iban;

-- queda buit, ho provo d'altres maneres, com amb una subconsulta
SELECT iban, AVG(amount) AS mitjana_amount
FROM (
    SELECT t.amount, cc.iban
    FROM transactions t
    JOIN credit_cards cc ON t.card_id = cc.id
    JOIN companies c ON t.business_id = c.id
    WHERE c.company_name = 'Donec Ltd'
) AS sub
GROUP BY iban;

-- El resultat és zero, per tant comprovo que efectivament l'empresa s'escrigui així, sí; i també que hi hagi transaccions fetes per aquesta empresa.
SELECT *
FROM transactions t
JOIN companies c ON t.business_id = c.id
WHERE c.company_name = 'Donec Ltd';

-- Nivell 2 ex 1
CREATE TABLE credit_card_status (
    card_id INT PRIMARY KEY,
    status ENUM('active', 'inactive') NOT NULL
);

-- Nivell 3 ex 1
SELECT p.id,
       p.product_name,
       COUNT(tp.transaction_id) AS vegades_venut
FROM products p
JOIN transaction_products tp ON p.id = tp.product_id
GROUP BY p.id, p.product_name
ORDER BY vegades_venut DESC;

-- no he guardat el que he fet primera hora! de 26-05-25 he ESBORRAT LES DADES per tornar-les a importar
-- he canviat configuració per poder importar arxius LOCALS
-- Ara intento seguir important de nou les dades

SHOW VARIABLES LIKE 'local_infile';

LOAD DATA LOCAL INFILE 'C:/SQL/SQLimports/companies.csv'
INTO TABLE companies
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"' 
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(id, company_name, phone, email, country, website);

-- importar credit_cards
-- problema amb data date

ALTER TABLE credit_cards
MODIFY COLUMN expiring_date VARCHAR(20);

LOAD DATA LOCAL INFILE 'C:/SQL/SQLimports/credit_cards.csv'
INTO TABLE credit_cards
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"' 
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(id, user_id, iban, pan, pin, cvv, track1, track2, expiring_date);

-- no tenia la columna user_id, l'afegeixo
ALTER TABLE credit_cards
ADD COLUMN user_id INT;

SELECT c.*
FROM credit_cards c;

ALTER TABLE credit_cards
MODIFY COLUMN expiring_date DATE;

DELETE FROM credit_cards;

-- queda pendent arreglar data
ALTER TABLE credit_cards
ADD COLUMN date_expiring DATE;

UPDATE credit_cards
SET date_expiring = STR_TO_DATE(expiring_date, '%m/%d/%y');


-- importar products
-- he de tornar a posar en VARCHAR price
ALTER TABLE products
MODIFY COLUMN price VARCHAR(20);

LOAD DATA LOCAL INFILE 'C:/SQL/SQLimports/products.csv'
INTO TABLE products
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"' 
LINES TERMINATED BY '\n'
IGNORE 1 LINES;
(id, product_name, price, colour, weight, warehouse_id);

-- trec el simbol $
UPDATE products SET price = REPLACE(price, '$', '');
ALTER TABLE products
MODIFY COLUMN price DECIMAL(12,2);

SELECT p.*
FROM products p;

-- importar users
ALTER TABLE users
MODIFY COLUMN birth_date VARCHAR(20);

LOAD DATA LOCAL INFILE 'C:/SQL/SQLimports/users_ca.csv'
INTO TABLE users
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"' 
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(id, name, surname, phone, email, birth_date, country, city, postal_code, address);

-- vaig important totes les diferents taules a una mateixa
LOAD DATA LOCAL INFILE 'C:/SQL/SQLimports/users_uk.csv'
INTO TABLE users
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"' 
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(id, name, surname, phone, email, birth_date, country, city, postal_code, address);

LOAD DATA LOCAL INFILE 'C:/SQL/SQLimports/users_usa.csv'
INTO TABLE users
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"' 
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(id, name, surname, phone, email, birth_date, country, city, postal_code, address);

ALTER TABLE users
ADD COLUMN date_birthdate DATE;

UPDATE users
SET date_birthdate = STR_TO_DATE(birth_date, '%b %d, %Y');

ALTER TABLE users
DROP COLUMN birth_date;

SELECT u.*
FROM users u;

-- importar transactions
LOAD DATA LOCAL INFILE 'C:/SQL/SQLimports/transactions.csv'
INTO TABLE transactions
FIELDS TERMINATED BY ';' 
ENCLOSED BY '"' 
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(id, card_id, business_id, timestamp, amount, declined, product_ids, user_id, lat, longitude);


-- veig que he de utilitzar ";" per als finals camp
-- torno a afegir products_id

LOAD DATA LOCAL INFILE 'C:/SQL/SQLimports/transactions.csv'
INTO TABLE transactions
FIELDS TERMINATED BY ';' 
ENCLOSED BY '"' 
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(id, card_id, business_id, timestamp, amount, declined, product_ids, user_id, lat, longitude);

ALTER TABLE business
RENAME COLUMN lat to latitude;

SELECT t.*
FROM transactions t;

-- Ara toca transaction_products
SELECT *
FROM raw_transactions
ORDER BY transaction_id;

CREATE TABLE raw_transactions AS
SELECT id, product_ids
FROM transactions;

ALTER TABLE raw_transactions
RENAME COLUMN id to transaction_id;

-- omplir de dades (visualitza però no inserta!) Més avall la opció amb INSERT
WITH RECURSIVE split AS (
  SELECT
    transaction_id,
    TRIM(SUBSTRING_INDEX(product_ids, ',', 1)) AS product_id,
    SUBSTRING(product_ids, LOCATE(',', product_ids) + 1) AS rest
  FROM raw_transactions
  UNION ALL
  SELECT
    transaction_id,
    TRIM(SUBSTRING_INDEX(rest, ',', 1)) AS product_id,
    SUBSTRING(rest, LOCATE(',', rest) + 1) AS rest
  FROM split
  WHERE rest IS NOT NULL AND rest != '' AND rest LIKE '%,%'
)
SELECT transaction_id, product_id FROM split
UNION
SELECT transaction_id, TRIM(rest) FROM split WHERE rest NOT LIKE '%,'
ORDER BY transaction_id;

-- canvio uns noms
ALTER TABLE raw_transactions
RENAME COLUMN product_ids to product_id;

DROP TABLE transaction_products;

ALTER TABLE raw_transactions RENAME transaction_products;

SELECT *
FROM raw_transactions;

-- amb INSERT
INSERT INTO transaction_products (transaction_id, product_id)
SELECT transaction_id, product_id FROM (
  WITH RECURSIVE split AS (
    SELECT
      transaction_id,
      TRIM(SUBSTRING_INDEX(product_ids, ',', 1)) AS product_id,
      SUBSTRING(product_ids, LOCATE(',', product_ids) + 1) AS rest
    FROM raw_transactions
    UNION ALL
    SELECT
      transaction_id,
      TRIM(SUBSTRING_INDEX(rest, ',', 1)) AS product_id,
      SUBSTRING(rest, LOCATE(',', rest) + 1) AS rest
    FROM split
    WHERE rest IS NOT NULL AND rest != '' AND rest LIKE '%,%'
  )
  SELECT transaction_id, product_id FROM split
  UNION
  SELECT transaction_id, TRIM(rest) FROM split WHERE rest NOT LIKE '%,'
) AS resultats;

SELECT * FROM raw_transactions;

-- m'adono que la separació per product_id no és del tot correcte
-- esborro la taula i inserto query modificada
DELETE FROM transaction_products;

-- Fins aquí: He estat provant una via complicada amb WITH RECURSIVE split que ha tingut resultats parcialment bons, o sigui erronis.
-- 1 resultat: obtenir només 1 transaction i 1 product_id / obtenir 1 transaction i totes les variables de combinació de product ids...

-- ho torno a provar: per poder saber si ho faig bé, abans vull comptar quantes raws hauria de tenir al final:

SELECT SUM(LENGTH(product_id) - LENGTH(REPLACE(product_id, ',', '')) + 1) AS total_products
FROM raw_transactions;

WITH RECURSIVE split AS (
  SELECT 
    transaction_id,
    1 AS idx,
    TRIM(SUBSTRING_INDEX(product_id, ',', 1)) AS product_id,
    LENGTH(product_id) - LENGTH(REPLACE(product_id, ',', '')) + 1 AS total
  FROM raw_transactions
  UNION ALL
  SELECT 
    transaction_id,
    idx + 1,
    TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(product_id, ',', idx + 1), ',', -1)) AS product_id,
    total
  FROM split
  WHERE idx < total
)
SELECT transaction_id, product_id FROM split
ORDER BY transaction_id;

CREATE TABLE transaction_products (
  t_p_id INT AUTO_INCREMENT PRIMARY KEY,
  transaction_id VARCHAR(50),
  product_id INT
);

INSERT INTO transaction_products (transaction_id, product_id)
SELECT transaction_id, product_id FROM split;

INSERT INTO transaction_products (transaction_id, product_id)
WITH RECURSIVE split AS (
  SELECT 
    transaction_id,
    1 AS idx,
    TRIM(SUBSTRING_INDEX(product_id, ',', 1)) AS product_id,
    LENGTH(product_id) - LENGTH(REPLACE(product_id, ',', '')) + 1 AS total
  FROM raw_transactions
  UNION ALL
  SELECT 
    transaction_id,
    idx + 1,
    TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(product_id, ',', idx + 1), ',', -1)) AS product_id,
    total
  FROM split
  WHERE idx < total
)
SELECT transaction_id, product_id FROM split;

SELECT *
FROM transaction_products;
ORDER BY transaction_id;

SELECT *
FROM transaction_products
ORDER BY t_p_id;

SELECT *
FROM raw_transactions;

-- ESTRATÈGIA NOVA:
SELECT rt.transaction_id, 
       parsed.product_id 
FROM raw_transactions rt, 
     JSON_TABLE(CONCAT('[', rt.product_id, ']'), '$[*]' COLUMNS(product_id INT PATH '$')) AS parsed;

-- ENCAPSULO en un INSERT
INSERT INTO transaction_products (transaction_id, product_id)
SELECT rt.transaction_id, parsed.product_id
FROM raw_transactions rt, 
     JSON_TABLE(CONCAT('[', rt.product_id, ']'), '$[*]' COLUMNS(product_id INT PATH '$')) AS parsed;

SHOW VARIABLES LIKE 'datadir';

-- problema amb 1000 rows limit
SHOW VARIABLES LIKE 'cte_max_recursion_depth';
-- ho canvio temporalment
SET GLOBAL cte_max_recursion_depth = 2000;

-- torno a esborrar les dades de transaction_products per a tornar a omplir-ho.
DELETE FROM transaction_products;

-- faré blocs de 1000 per esquivar limitació
INSERT INTO transaction_products (transaction_id, product_id)
SELECT rt.transaction_id, parsed.product_id
FROM raw_transactions rt, 
     JSON_TABLE(CONCAT('[', rt.product_id, ']'), '$[*]' COLUMNS(product_id INT PATH '$')) AS parsed
LIMIT 1000 OFFSET 0;

INSERT INTO transaction_products (transaction_id, product_id)
SELECT rt.transaction_id, parsed.product_id
FROM raw_transactions rt, 
     JSON_TABLE(CONCAT('[', rt.product_id, ']'), '$[*]' COLUMNS(product_id INT PATH '$')) AS parsed
LIMIT 1000 OFFSET 1000;

-- finalment m'adono que la limitació és del Workbench i canviant a preferences, ja ho soluciono (ho tinc al Canva, explicació de ChatGPT).

-- ara creo una columna amb valor únic en aquesta taula.
ALTER TABLE transaction_products
ADD COLUMN t_p_id INT NOT NULL AUTO_INCREMENT,
ADD UNIQUE(t_p_id);

-- igualar tipus dada id de proiduct per relacio
ALTER TABLE transaction_products
MODIFY COLUMN product_id VARCHAR(10); 

-- crear relació
ALTER TABLE transaction_products
ADD CONSTRAINT fk_product_id
FOREIGN KEY (product_id)
REFERENCES products(id)
ON DELETE CASCADE
ON UPDATE CASCADE;

-- faig t_p_id que sigui PRIMARY KEY
ALTER TABLE transaction_products
ADD PRIMARY KEY (t_p_id);

-- esborro product_ids a transactions (la llista inicial)
ALTER TABLE transactions
DROP COLUMN product_ids;

-- afegeico FK a companies
ALTER TABLE transactions 
ADD CONSTRAINT fk_business_id 
FOREIGN KEY (business_id) 
REFERENCES companies(id);

-- 29-05-25
-- CONSULTES CONSULTES CONSULTES FINALMENT

-- Nivell 1 ex.1
-- Realitza una subconsulta que mostri tots els usuaris amb més de 30 transaccions utilitzant almenys 2 taules.
SELECT u.*
FROM users u
WHERE id IN (
    SELECT user_id
    FROM transactions
    GROUP BY user_id
    HAVING COUNT(*) > 30
);

-- Nivell 1 ex.2
-- Mostra la mitjana d'amount per IBAN de les targetes de crèdit a la companyia Donec Ltd, utilitza almenys 2 taules.

SELECT c.company_name,
		cc.iban,
       AVG(t.amount) AS mitjana_amount
FROM transactions t
JOIN credit_cards cc ON t.card_id = cc.id
JOIN companies c ON t.business_id = c.id
WHERE c.company_name = 'Donec Ltd'
GROUP BY cc.iban;

-- Nivell 2 ex 1
-- Crea una nova taula que reflecteixi l'estat de les targetes de crèdit basat en si les últimes tres transaccions van ser declinades i genera la següent consulta:
-- Quantes targetes estan actives?

CREATE TABLE credit_card_status (
    card_id INT PRIMARY KEY,
    status ENUM('active', 'inactive') NOT NULL
);

-- Nivell 3 ex.1
-- Crea una taula amb la qual puguem unir les dades del nou arxiu products.csv amb la base de dades creada, tenint en compte que des de transaction tens product_ids. 
-- (ja la he fet abans) 
-- Genera la següent consulta: Necessitem conèixer el nombre de vegades que s'ha venut cada producte.

SELECT p.id,
       p.product_name,
       COUNT(tp.transaction_id) AS vegades_venut
FROM products p
JOIN transaction_products tp ON p.id = tp.product_id
GROUP BY p.id, p.product_name
ORDER BY vegades_venut DESC;

-- vull veure quants productes hi handlerSELECT COUNT(DISTINCT product_id)
SELECT COUNT(DISTINCT product_id)
FROM transaction_products;
-- hi ha 26 productes diferents, coincideix amb el nombre de rows que dona a dalt.

-- aquí ja no val: afegeixo proves que faig per a intentar seguir NIVELL 2, però que no em funcionen bé
SELECT card_id
FROM TRANSACTIONS
WHERE declined = 0
GROUP BY card_id;
HAVING COUNT(*) >= 3;

DESCRIBE credit_card_status;
DESCRIBE transactions;

SELECT t.card_id,
		t.id,
        t.declined
FROM transactions t
WHERE t.declined = 1;

SELECT card_id
FROM TRANSACTIONS
WHERE declined = 1
GROUP BY card_id
-- HAVING COUNT(*) >= 3
ORDER BY MAX(id) DESC;

WITH RankedTransactions AS (
    SELECT card_id, declined,
           ROW_NUMBER() OVER (PARTITION BY card_id ORDER BY id DESC) AS rn
    FROM TRANSACTIONS
)
SELECT card_id
FROM RankedTransactions
WHERE declined = 0 AND rn <= 3
GROUP BY card_id;
HAVING COUNT(*) = 3;

WITH RankedTransactions AS (
    SELECT card_id, declined,
           ROW_NUMBER() OVER (PARTITION BY card_id ORDER BY id DESC) AS rn
    FROM TRANSACTIONS
)
SELECT card_id, COUNT(*) AS num_declined
FROM RankedTransactions
WHERE declined = 1 AND rn <= 3
GROUP BY card_id;