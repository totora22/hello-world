-- SPRINT 3 NIVELL 1
SELECT c.*
from credit_card c where c.id = 'CcU-2938';

UPDATE credit_card 
    SET iban = 'R323456312213576817699999' 
    WHERE id = 'CcU-2938';

SELECT c.*
from credit_card c where c.id = 'CcU-2938';

INSERT INTO transaction (Id, credit_card_id, company_id, user_id, lat, longitude, amount, declined) 
    VALUES ('108B1D1D-5B23-A76C-55EF-C568E49A99DD', 'CcU-9999', 'b-9999', 9999, 829.999, -117.999, 111.11, 0);
    
SELECT c.*
from company c where c.id = 'b-9999';

INSERT INTO company (id) VALUES ('b-9999');

DESCRIBE credit_card;

ALTER TABLE credit_card
drop column pan;

-- SPRINT 3 NIVELL 2
-- Sprint3 Nivell 2 ex.1
SELECT t.*
FROM transaction t where t.id = 'ID 02C6201E-D90A-1859-B4EE-88D2986D3B02';

SELECT t.*
FROM transaction t where t.id = '02C6201E-D90A-1859-B4EE-88D2986D3B02';

DELETE FROM transaction 
    WHERE id = '02C6201E-D90A-1859-B4EE-88D2986D3B02'; 
    
SELECT t.*
FROM transaction t where t.id = '02C6201E-D90A-1859-B4EE-88D2986D3B02';

-- Sprint3 Nivell 2 ex.2
CREATE VIEW VistaMarketing AS vistamarketing;

SELECT ROUND(AVG(t.amount),2) AS mitjana, c.company_name AS Company, c.phone, c.country
FROM transaction t
INNER JOIN Company c ON c.id=t.company_id
GROUP BY c.id
ORDER BY mitjana DESC;

SELECT * 
FROM transactions.vistamarketing
WHERE country='Germany';

--Nivell 3 el tinc en un altre document. No el tinc ben resolt encara

