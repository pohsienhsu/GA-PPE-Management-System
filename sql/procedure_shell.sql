/*
CS4400: Introduction to Database Systems
Summer 2020
Phase III Template

Team 19
Po Hsien Hsu (phsu40)
Yeong Jer Tseng (ytseng35)
Nikhil Rajan (nrajan30)
Prahlad Jasti (pjasti3)

Directions:
Please follow all instructions from the Phase III assignment PDF.
This file must run without error for credit.
*/

/************** UTIL **************/
/* Feel free to add any utilty procedures you may need here */

-- Number:
-- Author: kachtani3@
-- Name: create_zero_inventory
-- Tested By: kachtani3@
DROP PROCEDURE IF EXISTS create_zero_inventory;
DELIMITER //
CREATE PROCEDURE create_zero_inventory(
	IN i_businessName VARCHAR(100),
    	IN i_productId CHAR(5)
)
BEGIN
-- Type solution below
	IF (i_productId NOT IN (
		SELECT product_id FROM InventoryHasProduct WHERE inventory_business = i_businessName))
    THEN INSERT INTO InventoryHasProduct (inventory_business, product_id, count)
		VALUES (i_businessName, i_productId, 0);
	END IF;

-- End of solution
END //
DELIMITER ;


/************** INSERTS **************/

-- Number: I1
-- Author: kachtani3@
-- Name: add_usage_log
DROP PROCEDURE IF EXISTS add_usage_log;
DELIMITER //
CREATE PROCEDURE add_usage_log(
	IN i_usage_log_id CHAR(5), 
    IN i_doctor_username VARCHAR(100),
    IN i_timestamp TIMESTAMP
)
BEGIN
-- Type solution below
	IF (i_usage_log_id NOT IN (SELECT id FROM usagelog) AND 
		i_doctor_username IN (SELECT username from doctor))
		THEN INSERT INTO usagelog (id, doctor, timestamp)
			VALUES (i_usage_log_id, i_doctor_username, i_timestamp);
	END IF;

-- End of solution
END //
DELIMITER ;

-- Number: I2
-- Author: ty.zhang@
-- Name: add_usage_log_entry
DROP PROCEDURE IF EXISTS add_usage_log_entry;
DELIMITER //
CREATE PROCEDURE add_usage_log_entry(
	IN i_usage_log_id CHAR(5), 
    IN i_product_id CHAR(5),
    IN i_count INT
)
BEGIN
-- Type solution below
	IF (i_usage_log_id IN (SELECT id FROM usagelog) AND 
		i_product_id IN (SELECT id FROM product) AND
		i_product_id NOT IN (SELECT product_id FROM usagelogentry WHERE usage_log_id = i_usage_log_id) AND
        i_product_id IN (SELECT product_id FROM inventoryhasproduct WHERE inventory_business in ((SELECT hospital FROM doctor WHERE username in (SELECT doctor FROM usagelog WHERE id = i_usage_log_id))) AND product_id = i_product_id) AND
		i_count <= ALL(SELECT count FROM inventoryhasproduct WHERE inventory_business in ((SELECT hospital FROM doctor WHERE username in (SELECT doctor FROM usagelog WHERE id = i_usage_log_id))) AND product_id = i_product_id))
		THEN INSERT INTO usagelogentry (usage_log_id, product_id, count) VALUES (i_usage_log_id, i_product_id, i_count);
        IF (i_count < ALL(SELECT count FROM inventoryhasproduct WHERE inventory_business in ((SELECT hospital FROM doctor WHERE username in (SELECT doctor FROM usagelog WHERE id = i_usage_log_id))) AND product_id = i_product_id))
			THEN UPDATE inventoryhasproduct SET count = count - i_count WHERE inventory_business in (SELECT hospital FROM doctor WHERE username in (SELECT doctor FROM usagelog WHERE id = i_usage_log_id)) AND product_id = i_product_id;
		ELSE
			DELETE FROM inventoryhasproduct WHERE inventory_business in (SELECT hospital FROM doctor WHERE username in (SELECT doctor FROM usagelog WHERE id = i_usage_log_id)) AND product_id = i_product_id;
		END IF;
	END IF;

-- End of solution
END //
DELIMITER ;

-- Number: I3
-- Author: yxie@
-- Name: add_business
DROP PROCEDURE IF EXISTS add_business;
DELIMITER //
CREATE PROCEDURE add_business(
	IN i_name VARCHAR(100),
    IN i_BusinessStreet VARCHAR(100),
    IN i_BusinessCity VARCHAR(100),
    IN i_BusinessState VARCHAR(30),
    IN i_BusinessZip CHAR(5),
    IN i_businessType ENUM('Hospital', 'Manufacturer'),
    IN i_maxDoctors INT,
    IN i_budget FLOAT(2),
    IN i_catalog_capacity INT,
    IN i_InventoryStreet VARCHAR(100),
    IN i_InventoryCity VARCHAR(100),
    IN i_InventoryState VARCHAR(30),
    IN i_InventoryZip CHAR(5)
)
BEGIN
-- Type solution below

If i_name not in (select name from business) and i_businessType = 'Hosiptal'
    then insert into business (name, address_street, address_city, address_state, address_zip)
		 values (i_name, i_BusinessStreet, i_BusinessCity, i_BusinessState, i_BusinessZip);
		 insert into hospital (name, max_doctors, budget)
         values (i_name, i_maxDoctors, i_budget);
         insert into inventory (owner, address_street, address_city, address_state, address_zip)
         values (i_name, i_InventoryStreet, i_InventoryCity, i_InventoryState, i_InventoryZip);
	Elseif i_name not in (select name from business) and i_businessType = 'Manufacturer'
	then insert into business (name, address_street, address_city, address_state, address_zip)
		 values (i_name, i_BusinessStreet, i_BusinessCity, i_BusinessState, i_BusinessZip);
         insert into manufacturer (name, catalog_capacity)
         values (i_name, i_catalog_capacity);
         insert into inventory (owner, address_street, address_city, address_state, address_zip)
         values (i_name, i_InventoryStreet, i_InventoryCity, i_InventoryState, i_InventoryZip);

end if;

-- End of solution
END //
DELIMITER ;

-- Number: I4
-- Author: kachtani3@
-- Name: add_transaction
DROP PROCEDURE IF EXISTS add_transaction;
DELIMITER //
CREATE PROCEDURE add_transaction(
	IN i_transaction_id CHAR(4), 
    IN i_hospital VARCHAR(100),
    IN i_date DATE
)
BEGIN
-- Type solution below

INSERT INTO Transaction(id, hospital, date) VALUES (i_transaction_id, i_hospital, i_date);

-- End of solution
END //
DELIMITER ;

-- Number: I5
-- Author: kachtani3@
-- Name: add_transaction_item
DROP PROCEDURE IF EXISTS add_transaction_item;
DELIMITER //
CREATE PROCEDURE add_transaction_item(
    IN i_transactionId CHAR(4),
    IN i_productId CHAR(5),
    IN i_manufacturerName VARCHAR(100),
    IN i_purchaseCount INT)
sp_main: BEGIN
-- Type solution below
	IF i_purchaseCount > 0
   	 AND ROUND((SELECT budget FROM hospital WHERE hospital.name = (SELECT hospital FROM transaction WHERE transaction.id = i_transactionId)),2) >=  ROUND((SELECT i_purchaseCount * price FROM CatalogItem WHERE CatalogItem.product_id = i_productId AND manufacturer = i_manufacturerName),2)
   	 AND IFNULL((SELECT count FROM InventoryHasProduct WHERE inventory_business = i_manufacturerName AND product_id = i_productId),0) >= i_purchaseCount
   	 
	THEN
   	 INSERT INTO TransactionItem(transaction_id, manufacturer, product_id, count) VALUES (i_transactionId, i_manufacturerName, i_productId, i_purchaseCount);
   	 UPDATE inventoryhasproduct SET count = count - i_purchaseCount WHERE inventory_business = i_manufacturerName AND product_id = i_productId;
   	 UPDATE hospital SET budget = budget - ROUND((SELECT i_purchaseCount * price FROM CatalogItem WHERE CatalogItem.product_id = i_productId AND manufacturer = i_manufacturerName),2) WHERE name = (SELECT hospital FROM transaction WHERE transaction.id = i_transactionId);
	 IF ((SELECT count(*) FROM InventoryHasProduct WHERE product_id = i_productId AND inventory_business = (SELECT hospital FROM Transaction WHERE Transaction.id = i_transactionId)) = 0)
     THEN
	  INSERT INTO InventoryHasProduct(inventory_business, product_id, count) VALUES((SELECT hospital FROM Transaction WHERE Transaction.id = i_transactionId), i_productId, i_purchaseCount);
	 ELSE
      UPDATE InventoryHasProduct SET count = (count + i_purchaseCount) WHERE inventory_business = (SELECT hospital FROM Transaction WHERE Transaction.id = i_transactionId) AND product_id = i_productId;
     END IF;
    END IF;

-- End of solution
END //
DELIMITER ;

-- Number: I6
-- Author: yxie@
-- Name: add_user
DROP PROCEDURE IF EXISTS add_user;
DELIMITER //
CREATE PROCEDURE add_user(
	IN i_username VARCHAR(100),
    IN i_email VARCHAR(100),
    IN i_password VARCHAR(100),
    IN i_fname VARCHAR(50),
    IN i_lname VARCHAR(50),
    IN i_userType ENUM('Doctor', 'Admin', 'Doctor-Admin'),
    IN i_managingBusiness VARCHAR(100),
    IN i_workingHospital VARCHAR(100)
)
sp_main: BEGIN
-- Type solution below
	IF ((SELECT COUNT(*) FROM User WHERE username = i_username) > 0) THEN LEAVE sp_main; END IF;
    IF ((SELECT COUNT(*) FROM User WHERE email = i_email) > 0) THEN LEAVE sp_main; END IF;
    
    
    INSERT INTO User(username, email, password, fname, lname) VALUES (i_username, i_email, SHA(i_password), i_fname, i_lname);
    IF (i_userType = 'Doctor')
    THEN
		INSERT INTO Doctor(username, hospital, manager) VALUES (i_username, i_workingHospital, null);
	ELSEIF (i_userType = 'Admin')
    THEN
		INSERT INTO Administrator(username, business) VALUES (i_username, i_managingBusiness);
	ELSEIF (i_userType = 'Doctor-Admin')
    THEN
		BEGIN
		INSERT INTO Doctor(username, hospital, manager) VALUES (i_username, i_workingHospital, null);
        INSERT INTO Administrator(username, business) VALUES (i_username, i_managingBusiness);
        END;
	END IF;
-- End of solution
END //
DELIMITER ;

-- Number: I7
-- Author: klin83@
-- Name: add_catalog_item
DROP PROCEDURE IF EXISTS add_catalog_item;
DELIMITER //
CREATE PROCEDURE add_catalog_item(
    IN i_manufacturerName VARCHAR(100),
	IN i_product_id CHAR(5),
    IN i_price FLOAT(2)
)
BEGIN
-- Type solution below
	IF((i_manufacturerName, i_product_id) NOT IN (SELECT manufacturer, product_id FROM catalogitem) AND (SELECT COUNT(*) FROM catalogitem WHERE manufacturer = i_manufacturerName) <= (SELECT catalog_capacity FROM manufacturer WHERE name = i_manufacturerName))
	THEN INSERT INTO catalogitem(manufacturer, product_id, price) VALUES (i_manufacturerName, i_product_id, IFNULL(i_price,0));
END IF;
-- End of solution
END //
DELIMITER ;
    
-- Number: I8
-- Author: ftsang3@
-- Name: add_product
DROP PROCEDURE IF EXISTS add_product;
DELIMITER //
CREATE PROCEDURE add_product(
	IN i_prod_id CHAR(5),
    IN i_color VARCHAR(30),
    IN i_name VARCHAR(30)
)
BEGIN
-- Type solution below
	IF (i_prod_id NOT IN (SELECT id FROM product) AND (i_color, i_name) NOT IN (SELECT name_color, name_type FROM product))
	THEN INSERT INTO product(id, name_color, name_type)
    	VALUES (i_prod_id, i_color, i_name);
	END IF;
-- End of solution
END //
DELIMITER ;


/************** DELETES **************/
-- NOTE: Do not circumvent referential ON DELETE triggers by manually deleting parent rows

-- Number: D1
-- Author: ty.zhang@
-- Name: delete_product
DROP PROCEDURE IF EXISTS delete_product;
DELIMITER //
CREATE PROCEDURE delete_product(
    IN i_product_id CHAR(5)
)
BEGIN
-- Type solution below
DELETE FROM product WHERE id = i_product_id;
-- End of solution
END //
DELIMITER ;

-- Number: D2
-- Author: kachtani3@
-- Name: delete_zero_inventory
DROP PROCEDURE IF EXISTS delete_zero_inventory;
DELIMITER //
CREATE PROCEDURE delete_zero_inventory()
BEGIN
-- Type solution below

delete from inventoryhasproduct where count = 0;

-- End of solution
END //
DELIMITER ;

-- Number: D3
-- Author: ftsang3@
-- Name: delete_business
DROP PROCEDURE IF EXISTS delete_business;
DELIMITER //
CREATE PROCEDURE delete_business(
    IN i_businessName VARCHAR(100)
)
BEGIN
-- Type solution below
	DELETE FROM Business where name = i_businessName;
-- End of solution
END //
DELIMITER ;

-- Number: D4
-- Author: ftsang3@
-- Name: delete_user
DROP PROCEDURE IF EXISTS delete_user;
DELIMITER //
CREATE PROCEDURE delete_user(
    IN i_username VARCHAR(100)
)
BEGIN
-- Type solution below
	DELETE FROM User WHERE username = i_username;
-- End of solution
END //
DELIMITER ;	

-- Number: D5
-- Author: klin83@
-- Name: delete_catalog_item
DROP PROCEDURE IF EXISTS delete_catalog_item;
DELIMITER //
CREATE PROCEDURE delete_catalog_item(
    IN i_manufacturer_name VARCHAR(100),
    IN i_product_id CHAR(5)
)
BEGIN
-- Type solution below
	DELETE FROM CatalogItem WHERE manufacturer - i_manufacturer_name and product_id = i_product_id;
-- End of solution
END //
DELIMITER ;


/************** UPDATES **************/

-- Number: U1
-- Author: kachtani3@
-- Name: add_subtract_inventory
DROP PROCEDURE IF EXISTS add_subtract_inventory;
DELIMITER //
CREATE PROCEDURE add_subtract_inventory(
	IN i_prod_id CHAR(5),
    IN i_businessName VARCHAR(100),
    IN i_delta INT
)
BEGIN
-- Type solution below
     IF (i_businessName IN (SELECT owner FROM inventory))
		THEN IF (i_prod_id IN (SELECT product_id FROM inventoryhasproduct WHERE i_businessName = inventory_business))
			THEN IF EXISTS(SELECT * FROM inventoryhasproduct WHERE i_businessName = inventory_business AND i_prod_id = product_id AND -1 * i_delta <= count)
				THEN IF EXISTS(SELECT * FROM inventoryhasproduct WHERE i_businessName = inventory_business AND i_prod_id = product_id AND -1 * i_delta < count)
					THEN UPDATE inventoryhasproduct SET count = count + i_delta WHERE i_businessName = inventory_business AND i_prod_id = product_id;
				ELSE
					DELETE FROM inventoryhasproduct WHERE i_businessName = inventory_business AND i_prod_id = product_id;
				END IF;
			END IF;
		ELSE
			IF (i_delta > 0)
				THEN INSERT INTO inventoryhasproduct(inventory_business, product_id, count) VALUES (i_businessName, i_prod_id, i_delta);
			END IF;
		END IF;
	END IF;

-- End of solution
END //
DELIMITER ;

-- Number: U2
-- Author: kachtani3@
-- Name: move_inventory
DROP PROCEDURE IF EXISTS move_inventory;
DELIMITER //
CREATE PROCEDURE move_inventory(
    IN i_supplierName VARCHAR(100),
    IN i_consumerName VARCHAR(100),
    IN i_productId CHAR(5),
    IN i_count INT)
sp_main: BEGIN
-- Type solution below
	IF (EXISTS(SELECT * FROM inventoryhasproduct WHERE i_supplierName = inventory_business AND i_productId = product_id AND i_count <= count))
		THEN CALL add_subtract_inventory(i_productId, i_supplierName, -1 * i_count);
		CALL add_subtract_inventory(i_productId, i_consumerName, i_count);
	END IF;
-- End of solution
END //
DELIMITER ;

-- Number: U3
-- Author: ty.zhang@
-- Name: rename_product_id
DROP PROCEDURE IF EXISTS rename_product_id;
DELIMITER //
CREATE PROCEDURE rename_product_id(
    IN i_product_id CHAR(5),
    IN i_new_product_id CHAR(5)
)
BEGIN
-- Type solution below

update product
    set id = i_new_product_id
    where id = i_product_id;

-- End of solution
END //
DELIMITER ;

-- Number: U4
-- Author: ty.zhang@
-- Name: update_business_address
DROP PROCEDURE IF EXISTS update_business_address;
DELIMITER //
CREATE PROCEDURE update_business_address(
    IN i_name VARCHAR(100),
    IN i_address_street VARCHAR(100),
    IN i_address_city VARCHAR(100),
    IN i_address_state VARCHAR(30),
    IN i_address_zip CHAR(5)
)
BEGIN
-- Type solution below

update business
    set address_street = i_address_street,
		address_city = i_address_city,
        address_state = i_address_state,
        address_zip = i_address_zip
	where name = i_name;

-- End of solution
END //
DELIMITER ;

-- Number: U5
-- Author: kachtani3@
-- Name: charge_hospital
DROP PROCEDURE IF EXISTS charge_hospital;
DELIMITER //
CREATE PROCEDURE charge_hospital(
    IN i_hospital_name VARCHAR(100),
    IN i_amount FLOAT(2))
sp_main: BEGIN
-- Type solution below
	 IF ((SELECT ROUND(budget,2) FROM hospital where name = i_hospital_name) > i_amount)
   	 THEN UPDATE hospital SET budget = budget - i_amount WHERE name = i_hospital_name;
	END IF;
-- End of solution
END //
DELIMITER ;

-- Number: U6
-- Author: yxie@
-- Name: update_business_admin
DROP PROCEDURE IF EXISTS update_business_admin;
DELIMITER //
CREATE PROCEDURE update_business_admin(
	IN i_admin_username VARCHAR(100),
	IN i_business_name VARCHAR(100)
)
sp_main: BEGIN
-- Type solution below
	IF (SELECT COUNT(business) FROM administrator WHERE business = (SELECT business FROM administrator WHERE username = i_admin_username)) > 1
   	 THEN UPDATE Administrator SET business = i_business_name WHERE username = i_admin_username;
	END IF;
-- End of solution
END //
DELIMITER ;

-- Number: U7
-- Author: ftsang3@
-- Name: update_doctor_manager
DROP PROCEDURE IF EXISTS update_doctor_manager;
DELIMITER //
CREATE PROCEDURE update_doctor_manager(
    IN i_doctor_username VARCHAR(100),
    IN i_manager_username VARCHAR(100)
)
BEGIN
-- Type solution below
IF i_doctor_username <> i_manager_username
    THEN
		UPDATE Doctor SET manager = i_manager_username WHERE username = i_doctor_username;
	END IF;
-- End of solution
END //
DELIMITER ;

-- Number: U8
-- Author: ftsang3@
-- Name: update_user_password
DROP PROCEDURE IF EXISTS update_user_password;
DELIMITER //
CREATE PROCEDURE update_user_password(
    IN i_username VARCHAR(100),
	IN i_new_password VARCHAR(100)
)
BEGIN
-- Type solution below
	UPDATE user SET password = SHA(i_new_password) WHERE username = i_username;
-- End of solution
END //
DELIMITER ;

-- Number: U9
-- Author: klin83@
-- Name: batch_update_catalog_item
DROP PROCEDURE IF EXISTS batch_update_catalog_item;
DELIMITER //
CREATE PROCEDURE batch_update_catalog_item(
    IN i_manufacturer_name VARCHAR(100),
    IN i_factor FLOAT(2))
BEGIN
-- Type solution below
	UPDATE CatalogItem SET price = price * i_factor WHERE manufacturer = i_manufacturer_name;
-- End of solution
END //
DELIMITER ;

/************** SELECTS **************/
-- NOTE: "SELECT * FROM USER" is just a dummy query
-- to get the script to run. You will need to replace that line 
-- with your solution.

-- Number: S1
-- Author: ty.zhang@
-- Name: hospital_transactions_report
DROP PROCEDURE IF EXISTS hospital_transactions_report;
DELIMITER //
CREATE PROCEDURE hospital_transactions_report(
    IN i_hospital VARCHAR(100),
    IN i_sortBy ENUM('', 'id', 'date'),
    IN i_sortDirection ENUM('', 'DESC', 'ASC')
)
BEGIN
    DROP TABLE IF EXISTS hospital_transactions_report_result;
    CREATE TABLE hospital_transactions_report_result(
        id CHAR(4),
        manufacturer VARCHAR(100),
        hospital VARCHAR(100),
        total_price FLOAT,
        date DATE);

    INSERT INTO hospital_transactions_report_result
-- Type solution below
	SELECT transaction_id, manufacturer, hospital, sum(price * count), date
    FROM (transactionitem RIGHT JOIN transaction ON transaction_id = transaction.id) NATURAL JOIN catalogitem
    GROUP BY id
    HAVING transaction.hospital = i_hospital
    ORDER BY 
    (CASE 
		WHEN i_sortBy = 'date' AND i_sortDirection = 'DESC' THEN date
	END) DESC,
    (CASE 
		WHEN i_sortBy = 'id' or i_sortBy = '' AND i_sortDirection = 'DESC' THEN id
	END) DESC,
    (CASE 
		WHEN i_sortBy = 'date' AND i_sortDirection = 'ASC' or i_sortDirection = '' THEN date
	END) ASC,
    (CASE 
		WHEN i_sortBy = 'id' or i_sortBy = '' AND i_sortDirection = 'ASC' or i_sortDirection = '' THEN date
	END) ASC;

-- End of solution
END //
DELIMITER ;

-- Number: S2
-- Author: ty.zhang@
-- Name: num_of_admin_list
DROP PROCEDURE IF EXISTS num_of_admin_list;
DELIMITER //
CREATE PROCEDURE num_of_admin_list()
BEGIN
    DROP TABLE IF EXISTS num_of_admin_list_result;
    CREATE TABLE num_of_admin_list_result(
        businessName VARCHAR(100),
        businessType VARCHAR(100),
        numOfAdmin INT);

    INSERT INTO num_of_admin_list_result
-- Type solution below
    (SELECT hospital.name as businessName, "Hospital" as businessType, count(*)
    FROM hospital JOIN administrator ON administrator.business = hospital.name
    GROUP BY hospital.name)
    UNION
    (SELECT manufacturer.name as businessName, "Manufacturer" as businessType, count(*)
    FROM manufacturer JOIN administrator ON administrator.business = manufacturer.name
    GROUP BY manufacturer.name);
-- End of solution
END //
DELIMITER ;

-- Number: S3
-- Author: ty.zhang@
-- Name: product_usage_list
DROP PROCEDURE IF EXISTS product_usage_list;
DELIMITER //
CREATE PROCEDURE product_usage_list()

BEGIN
    DROP TABLE IF EXISTS product_usage_list_result;
    CREATE TABLE product_usage_list_result(
        product_id CHAR(5),
        product_color VARCHAR(30),
        product_type VARCHAR(30),
        num INT);

    INSERT INTO product_usage_list_result
-- Type solution below
    SELECT id AS product_id, name_color AS product_color, name_type AS product_type, IFNULL(sum(usagelogentry.count), 0)
    FROM usagelogentry RIGHT JOIN product on product_id = id
    GROUP BY id
    ORDER BY sum(count) DESC;
-- End of solution
END //
DELIMITER ;

-- Number: S4
-- Author: ty.zhang@
-- Name: hospital_total_expenditure
DROP PROCEDURE IF EXISTS hospital_total_expenditure;
DELIMITER //
CREATE PROCEDURE hospital_total_expenditure()

BEGIN
    DROP TABLE IF EXISTS hospital_total_expenditure_result;
    CREATE TABLE hospital_total_expenditure_result(
        hospitalName VARCHAR(100),
        totalExpenditure FLOAT,
        transaction_count INT,
        avg_cost FLOAT);

    INSERT INTO hospital_total_expenditure_result
-- Type solution below
	select hospital.name as hospitalName, ifnull(round(sum(transactionitem.count * catalogitem.price),1),0) as totalExpenditure,
			count(distinct transaction.id) as transaction_count, ifnull(round(sum(transactionitem.count * catalogitem.price) / count(distinct transaction.id),2),0) as avg_cost
	from hospital left join transaction on hospital.name =  transaction.hospital
					left join transactionitem on id = transaction_id
					left join product on product_id = product.id
					left join catalogitem on transactionitem.manufacturer = catalogitem.manufacturer 
										and transactionitem.product_id = catalogitem.product_id
	group by hospital.name;


-- End of solution
END //
DELIMITER ;

-- Number: S5
-- Author: kachtani3@
-- Name: manufacturer_catalog_report
DROP PROCEDURE IF EXISTS manufacturer_catalog_report;
DELIMITER //
CREATE PROCEDURE manufacturer_catalog_report(
    IN i_manufacturer VARCHAR(100))
BEGIN
    DROP TABLE IF EXISTS manufacturer_catalog_report_result;
    CREATE TABLE manufacturer_catalog_report_result(
        name_color VARCHAR(30),
        name_type VARCHAR(30),
        price FLOAT(2),
        num_sold INT,
        revenue FLOAT(2));

    INSERT INTO manufacturer_catalog_report_result
-- Type solution below
	select name_color, name_type, price, ifnull(count, 0) as num_sold, round(price * ifnull(count, 0)) as revenue
	from catalogitem left join product on product_id = id
					left join transactionitem on catalogitem.manufacturer = transactionitem.manufacturer
											  and catalogitem.product_id = transactionitem.product_id
	where catalogitem.manufacturer = i_manufacturer
	group by catalogitem.product_id;

-- End of solution
END //
DELIMITER ;

-- Number: S6
-- Author: kachtani3@
-- Name: doctor_subordinate_usage_log_report
DROP PROCEDURE IF EXISTS doctor_subordinate_usage_log_report;
DELIMITER //
CREATE PROCEDURE doctor_subordinate_usage_log_report(
    IN i_drUsername VARCHAR(100))
BEGIN
    DROP TABLE IF EXISTS doctor_subordinate_usage_log_report_result;
    CREATE TABLE doctor_subordinate_usage_log_report_result(
        id CHAR(5),
        doctor VARCHAR(100),
        timestamp TIMESTAMP,
        product_id CHAR(5),
        count INT);

    INSERT INTO doctor_subordinate_usage_log_report_result
-- Type solution below
	select usagelog.id, doctor.username as doctor, timestamp, usagelogentry.product_id, usagelogentry.count
	from doctor left join user on doctor.username = user.username
            	left join usagelog on doctor.username = usagelog.doctor
            	left join usagelogentry on usagelog.id = usagelogentry.usage_log_id
	where (doctor.manager = i_drUsername OR doctor.username = i_drUsername) and id is not null;

-- End of solution
END //
DELIMITER ;

-- Number: S7
-- Author: klin83@
-- Name: explore_product
DROP PROCEDURE IF EXISTS explore_product;
DELIMITER //
CREATE PROCEDURE explore_product(
    IN i_product_id CHAR(5))
BEGIN
    DROP TABLE IF EXISTS explore_product_result;
    CREATE TABLE explore_product_result(
        manufacturer VARCHAR(100),
        count INT,
        price FLOAT(2));

    INSERT INTO explore_product_result
-- Type solution below
    SELECT inventory_business, count, price FROM InventoryHasProduct RIGHT JOIN catalogitem ON manufacturer = inventory_business AND inventoryhasproduct.product_id = catalogitem.product_id
    WHERE catalogitem.product_id = i_product_id;
-- End of solution
END //
DELIMITER ;

-- Number: S8
-- Author: klin83@
-- Name: show_product_usage
DROP PROCEDURE IF EXISTS show_product_usage;
DELIMITER //
CREATE PROCEDURE show_product_usage()
BEGIN
    DROP TABLE IF EXISTS show_product_usage_result;
    CREATE TABLE show_product_usage_result(
        product_id CHAR(5),
        num_used INT,
        num_available INT,
        ratio FLOAT);

    INSERT INTO show_product_usage_result
-- Type solution below
SELECT used.id AS product_id, used.num_used, IFNULL(invent.num_available, 0), IFNULL(FORMAT(used.num_used / invent.num_available, 2), 0) AS ratio
	FROM
	(SELECT prod.id, IFNULL(SUM(usg.usg_sum), 0) AS num_used FROM Product AS prod
	LEFT OUTER JOIN
	(SELECT usgEntry.product_id, sum(usgEntry.count) AS usg_sum FROM UsageLogEntry AS usgEntry
	GROUP BY usgEntry.product_id) as usg on prod.id = usg.product_id
	GROUP BY prod.id) AS used
	INNER JOIN
	(SELECT prod.id, ivhp.num_available
	FROM Product as prod
	LEFT OUTER JOIN
	(select product_id, sum(count) as num_available from InventoryHasProduct where Inventory_business in  
	(select m.name from Manufacturer as m)
	group by product_id) AS ivhp ON prod.id = ivhp.product_id) AS invent
	ON invent.id = used.id;

-- End of solution
END //
DELIMITER ;

-- Number: S9
-- Author: klin83@
-- Name: show_hospital_aggregate_usage
DROP PROCEDURE IF EXISTS show_hospital_aggregate_usage;
DELIMITER //
CREATE PROCEDURE show_hospital_aggregate_usage()
BEGIN
    DROP TABLE IF EXISTS show_hospital_aggregate_usage_result;
    CREATE TABLE show_hospital_aggregate_usage_result(
        hospital VARCHAR(100),
        items_used INT);

    INSERT INTO show_hospital_aggregate_usage_result
-- Type solution below
	select hospital.name as hospital, ifnull(sum(count), 0) as products_used
from hospital left join doctor on hospital.name = doctor.hospital
			  left join usagelog on doctor.username = usagelog.doctor
			  left join usagelogentry on usagelog.id = usagelogentry.usage_log_id
group by hospital.name;

-- End of solution
END //
DELIMITER ;

-- Number: S10
-- Author: ftsang3
-- Name: business_search
DROP PROCEDURE IF EXISTS business_search;
DELIMITER //
CREATE PROCEDURE business_search (
    IN i_search_parameter ENUM("name","street", "city", "state", "zip"),
    IN i_search_value VARCHAR(100))
BEGIN
	DROP TABLE IF EXISTS business_search_result;
    CREATE TABLE business_search_result(
        name VARCHAR(100),
		address_street VARCHAR(100),
		address_city VARCHAR(100),
		address_state VARCHAR(30),
		address_zip CHAR(5));

    INSERT INTO business_search_result
-- Type solution below
	SELECT name, address_street, address_city, address_state, address_zip FROM business WHERE (CASE
    WHEN i_search_parameter = 'name' THEN name
	WHEN i_search_parameter = 'street' then address_street
	WHEN i_search_parameter = 'city' then address_city
	WHEN i_search_parameter = 'state' then address_state
	WHEN i_search_parameter = 'zip' then address_zip
	ELSE NULL
	END) LIKE CONCAT('%', i_search_value, '%');
-- End of solution
END //
DELIMITER ;

-- Number: S11
-- Author: ftsang3@
-- Name: manufacturer_transaction_report
DROP PROCEDURE IF EXISTS manufacturer_transaction_report;
DELIMITER //
CREATE PROCEDURE manufacturer_transaction_report(
    IN i_manufacturer VARCHAR(100))
    
BEGIN
    DROP TABLE IF EXISTS manufacturer_transaction_report_result;
    CREATE TABLE manufacturer_transaction_report_result(
        id CHAR(4),
        hospital VARCHAR(100),
        `date` DATE,
        cost FLOAT(2),
        total_count INT);

    INSERT INTO manufacturer_transaction_report_result
-- Type solution below
        	SELECT transaction_id, hospital, date, SUM(ROUND(count*price,2)) as cost, SUM(count) as total_count FROM transactionitem as item INNER JOIN catalogitem as catalog ON item.product_id = catalog.product_id AND item.manufacturer = catalog.manufacturer INNER JOIN transaction on item.transaction_id = transaction.id WHERE catalog.manufacturer = i_manufacturer GROUP BY item.transaction_id;

-- End of solution
END //
DELIMITER ;

-- Number:
-- Author: yxie@
-- Name: get_user_types
-- Tested By: yxie@
DROP PROCEDURE IF EXISTS get_user_types;
DELIMITER //
CREATE PROCEDURE get_user_types()
BEGIN
DROP TABLE IF EXISTS get_user_types_result;
    CREATE TABLE get_user_types_result(
        username VARCHAR(100),
        UserType VARCHAR(50));
	INSERT INTO get_user_types_result
-- Type solution below
		SELECT username, 'Doctor' as UserType FROM doctor as doc WHERE NOT EXISTS (SELECT manager from doctor as man WHERE doc.username = man.manager) AND doc.username NOT IN (SELECT username FROM administrator) UNION SELECT username, 'Admin' FROM administrator WHERE username NOT IN (SELECT username from doctor) UNION SELECT username, 'Doctor-Admin' FROM administrator WHERE username IN (SELECT username from doctor) AND NOT EXISTS (SELECT manager FROM doctor where administrator.username = doctor.manager) UNION SELECT manager, 'Doctor-Manager' FROM doctor WHERE manager IS NOT NULL AND NOT EXISTS (SELECT username FROM administrator WHERE doctor.manager = administrator.username) UNION SELECT manager, 'Doctor-Admin-Manager' FROM doctor WHERE EXISTS (SELECT username FROM administrator WHERE doctor.manager = administrator.username);

-- End of solution
END //
DELIMITER ;





