-- SPRINT 2
-- ex 2 ULTILIZANT JOIN
-- Llistat dels països que estan fent compres.

SELECT DISTINCT c.Country
FROM Company c
INNER JOIN Transaction t ON c.id=t.company_id
WHERE declined=0;

-- Des de quants països es realitzen les compres.

SELECT COUNT(DISTINCT c.Country)
FROM Company c
INNER JOIN Transaction t ON c.id=t.company_id;

-- Identifica la companyia amb la mitjana més gran de vendes.
-- incloc suma total de vendes i num de transaccions per a poder comprovar. He afegit un ROUND de 2 decimals.

SELECT ROUND(AVG(t.amount),2) AS mitjana, c.company_name, SUM(t.amount) AS suma_vendes, COUNT(t.id) AS num_transaccions 
FROM Transaction t
INNER JOIN Company c ON c.id=t.company_id
WHERE DECLINED = 0
GROUP BY t.company_id
ORDER BY mitjana DESC
LIMIT 1;

-- ex 3 Utilitzant només subconsultes (sense utilitzar JOIN):
-- Mostra totes les transaccions realitzades per empreses d'Alemanya.
-- No sé si incloure les declinades o no?. Ordeno per data

SELECT t.*
FROM Transaction t
WHERE company_id IN (SELECT id FROM company c WHERE country = 'Germany')
ORDER BY timestamp;

-- Llista les empreses que han realitzat transaccions per un amount superior a la mitjana de totes les transaccions.

SELECT company_id, ROUND(AVG(amount),2) AS mitjana
FROM Transaction
WHERE amount > ( 
	SELECT AVG(amount)
	FROM Transaction
    WHERE declined=0)
GROUP BY company_id
ORDER BY mitjana DESC;

-- També he volgut identificar la que havia fet més amount
SELECT company_id, amount
FROM transaction T
WHERE amount = (SELECT MAX(amount) FROM transaction);

-- Eliminaran del sistema les empreses que no tenen transaccions registrades, entrega el llistat d'aquestes empreses.

SELECT id
FROM company
WHERE id NOT IN (
  SELECT company_id
  FROM transaction
  )
  AND WHERE declined = 1 AND NOT declined = 0
);

-- sembla que no n'hi ha, per tant, totes les empreses han realitzat transaccions.
-- per comprovar, les comptaré, i resulta que sí, són 100 empreses en ambdos casos:

SELECT COUNT(DISTINCT id)
FROM company c;

SELECT COUNT(DISTINCT company_id)
FROM transaction t;

-- veient això faig llista d'empreses que només tenen transacció declinada. 
-- ! AIXÒ NO HO HE ACABAT NO ESTÀ BÉEEE NO HO ENTREGO
SELECT c.id, c.company_name, t.declined 
FROM Company c
JOIN Transaction t ON t.company_id=c.id
WHERE declined = 1 AND NOT declined = 0
GROUP BY t.company_id;

-- NIVELL 2
-- ex. 1
-- Identifica els cinc dies que es va generar la quantitat més gran d'ingressos a l'empresa per vendes. Mostra la data de cada transacció juntament amb el total de les vendes.

SELECT DATE(timestamp) AS data_transaccio, SUM(amount) AS total_vendes
FROM transaction
WHERE declined = 0
GROUP BY DATE(timestamp)
ORDER BY total_vendes DESC
LIMIT 5;

-- ex 2
-- Quina és la mitjana de vendes per país? Presenta els resultats ordenats de major a menor mitjà.

SELECT c.country, ROUND(AVG(t.amount),2) AS mitjana_vendes
FROM transaction t
JOIN company c ON t.company_id = c.id
WHERE t.declined = 0
GROUP BY c.country
ORDER BY mitjana_vendes DESC;
    
-- ex 3
-- En la teva empresa, es planteja un nou projecte per a llançar algunes campanyes publicitàries per a fer competència a la companyia "Non Institute". Per a això, et demanen la llista de totes les transaccions realitzades per empreses que estan situades en el mateix país que aquesta companyia.
-- ex 3 1
-- Mostra el llistat aplicant JOIN i subconsultes.

SELECT t.*
FROM transaction t
JOIN company c ON t.company_id = c.id
WHERE c.country = (
        SELECT country
        FROM company 
        WHERE company_name = 'Non Institute'
        LIMIT 1
    );

-- Mostra el llistat aplicant solament subconsultes

SELECT t.*
FROM transaction t
WHERE company_id IN (
    SELECT id
    FROM company
    WHERE country = (
        SELECT country
        FROM company
        WHERE company_name = 'Non Institute'
        LIMIT 1
    ));

-- NIVELL 3
-- ex 1
-- Presenta el nom, telèfon, país, data i amount, d'aquelles empreses que van realitzar transaccions amb un valor comprès entre 100 i 200 euros i en alguna d'aquestes dates: 29 d'abril del 2021, 20 de juliol del 2021 i 13 de març del 2022. Ordena els resultats de major a menor quantitat.

SELECT c.company_name, c.phone, c.country, DATE(t.timestamp) AS data_transaccio, t.amount
FROM transaction t
JOIN company c ON t.company_id = c.id
WHERE t.amount BETWEEN 100 AND 200
    AND DATE(t.timestamp) IN ('2021-04-29', '2021-07-20', '2022-03-13')
    AND t.declined = 0
ORDER BY t.amount DESC;

-- ex 2
-- Necessitem optimitzar l'assignació dels recursos i dependrà de la capacitat operativa que es requereixi, per la qual cosa et demanen la informació sobre la quantitat de transaccions que realitzen les empreses, però el departament de recursos humans és exigent i vol un llistat de les empreses on especifiquis si tenen més de 4 transaccions o menys.

SELECT c.company_name, COUNT(t.id) AS num_transaccions,
    CASE 
        WHEN COUNT(t.id) > 4 THEN 'Més de 4'
        ELSE '4 o menys'
    END AS classificacio
FROM company c
LEFT JOIN transaction t ON c.id = t.company_id
GROUP BY c.company_name
ORDER BY num_transaccions DESC;