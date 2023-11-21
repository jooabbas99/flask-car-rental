 -- creating database  
CREATE DATABASE IF NOT EXISTS CAR_RENTAL;

-- creating tables 

-- Vehichels Table 
-- this table is for defining the avilable cars with some discriptions
USE CAR_RENTAL;
CREATE TABLE IF NOT EXISTS VEHICLES (
	vid bigint not null auto_increment primary key,
    vtype enum("small","family","van") ,
    vmodel nvarchar(255) ,
    vmanifacture_year year,
    vname nvarchar(255),
    create_at datetime on update CURRENT_TIMESTAMP
);

-- Customers Table 
CREATE TABLE IF NOT EXISTS CUSTOMER (
	cid bigint not null auto_increment primary key,
    cname nvarchar(255) not null,
    cssn nvarchar(50) not null unique ,
    email nvarchar(100) unique,
    create_at datetime on update CURRENT_TIMESTAMP
);


-- create transaction table 

CREATE TABLE IF NOT EXISTS RENTAL_TRANSACTION ( 
	invoide_no bigint not null primary key ,
    amount double default 0.0,
    create_at datetime on update CURRENT_TIMESTAMP
);


-- create the Booking table 
-- this table is the relation table between the 3 entity type
CREATE TABLE IF NOT EXISTS BOOKING (
	b_status enum("Open","completed","in progress","Canceled") default "Open",
    create_at datetime on update CURRENT_TIMESTAMP,
    rental_start_date date not null ,
    rental_end_date date not null,
    invoice_id bigint not null ,
    cid bigint not null,
    vid bigint not null 

);
ALTER TABLE `booking` ADD FOREIGN KEY (`invoice_id`) REFERENCES `rental_transaction`(`invoide_no`) ON DELETE RESTRICT ON UPDATE RESTRICT;
ALTER TABLE `booking` ADD FOREIGN KEY (`vid`) REFERENCES `vehicles`(`vid`) ON DELETE RESTRICT ON UPDATE RESTRICT;
ALTER TABLE `booking` ADD FOREIGN KEY (`cid`) REFERENCES `customer`(`cid`) ON DELETE RESTRICT ON UPDATE RESTRICT;
-- add trigger to disable booking if the date is more than 1 week 

DELIMITER $$

CREATE TRIGGER booking_limit
BEFORE INSERT ON BOOKING
FOR EACH ROW
BEGIN
	declare msg nvarchar(255);
    IF EXISTS (
        SELECT 1
        FROM BOOKING
        WHERE 
            BOOKING.vid = NEW.vid
            AND (
                (BOOKING.rental_start_date < NEW.rental_end_date AND BOOKING.rental_end_date > NEW.rental_start_date)
                OR
                (BOOKING.rental_end_date > NEW.rental_start_date AND BOOKING.rental_start_date < NEW.rental_start_date)
                OR
                (BOOKING.rental_start_date >= NEW.rental_start_date AND BOOKING.rental_end_date <= NEW.rental_end_date)
            )
    ) THEN 
        SET msg = 'Can not insert. overlab';
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = msg;
    END IF;
    IF (NEW.rental_start_date - rental_end_date) > 7
    THEN 
		 SET msg = 'More Then 7 dayes';
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = msg;
    END IF;
    
END$$
DELIMITER ;
