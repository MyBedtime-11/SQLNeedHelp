-- In this project, I will only focus on the USA pricing
SELECT *
FROM mobiles_dataset;

# Create a copy of the table, change the field names so it is easier to use later
CREATE TABLE `mobiles_staging` (
  `company` text,
  `model` text,
  `weight` text,
  `RAM` text,
  `front_camera` text,
  `back_camera` text,
  `processor` text,
  `battery` text,
  `screen_size` text,
  `price_pakistan` text,
  `price_inda` text,
  `price_china` text,
  `price_usa` text,
  `price_dubai` text,
  `launched_year` int DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

SELECT *
FROM mobiles_staging;

# Copy the entire dataset into mobiles_staging
INSERT INTO mobiles_staging
SELECT *
FROM mobiles_dataset;

-- Check for duplicates in dataset using window function and delete them

# Created a temporary table with the dupli_check column
CREATE TEMPORARY TABLE duplicate_check
SELECT *,
ROW_NUMBER() OVER(PARTITION BY company, model, weight, RAM, front_camera, back_camera, processor, battery, screen_size, price_pakistan, price_inda, price_china, price_usa, price_dubai, launched_year) AS dupli_check
FROM mobiles_staging
ORDER BY dupli_check DESC;

SELECT *
FROM duplicate_check ;

# Create another new table to delete the duplicates
CREATE TABLE `mobiles_staging2` (
  `company` text,
  `model` text,
  `weight` text,
  `RAM` text,
  `front_camera` text,
  `back_camera` text,
  `processor` text,
  `battery` text,
  `screen_size` text,
  `price_pakistan` text,
  `price_inda` text,
  `price_china` text,
  `price_usa` text,
  `price_dubai` text,
  `launched_year` int DEFAULT NULL,
  `dupli_check` int 
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

INSERT INTO mobiles_staging2
SELECT *
FROM duplicate_check;

DELETE
FROM mobiles_staging2
WHERE dupli_check > 1;


-- Standardizing the data

# Take a look at each of the columns
SELECT DISTINCT battery
FROM mobiles_staging2
ORDER BY 1;

SELECT *
FROM mobiles_staging2
where back_camera like "13MP%";

# Columns that need fixing:
# fromt_camera - Remove all words
# back_camera - Remove all words
# Battery - remove commas
# prices_usa - remove .00, remove commas

# Remove all words from front_camera
UPDATE mobiles_staging2
SET front_camera = REPLACE(front_camera, ' (UDC)', '');

UPDATE mobiles_staging2
SET front_camera = REPLACE(front_camera, ' (ultrawide)', '');

UPDATE mobiles_staging2
SET front_camera = REPLACE(front_camera, ' (telephoto)', '');

# Remove all words from back camera
UPDATE mobiles_staging2
SET back_camera = REPLACE(back_camera, ' (Main)', '');

UPDATE mobiles_staging2
SET back_camera = REPLACE(back_camera, ' (wide)', '');

UPDATE mobiles_staging2
SET back_camera = REPLACE(back_camera, ' (ultrawide)', '');

UPDATE mobiles_staging2
SET back_camera = REPLACE(back_camera, ' (Ultra-wide)', '');

UPDATE mobiles_staging2
SET back_camera = REPLACE(back_camera, ' (telephoto)', '');

UPDATE mobiles_staging2
SET back_camera = REPLACE(back_camera, ' (Macro)', '');

UPDATE mobiles_staging2
SET back_camera = REPLACE(back_camera, ' (periscope telephoto)', '');

UPDATE mobiles_staging2
SET back_camera = REPLACE(back_camera, ' (Depth)', '');

UPDATE mobiles_staging2
SET back_camera = REPLACE(back_camera, ' (Telephoto)', '');


# Remove commas from battery
UPDATE mobiles_staging2
SET battery = REPLACE(battery, ',', '');


# Updates price_usa
UPDATE mobiles_staging2
SET price_usa = REPLACE(price_usa, ',', '');

UPDATE mobiles_staging2
SET price_usa = REPLACE(price_usa, '.00', '');

UPDATE mobiles_staging2
SET price_usa = REPLACE(price_usa, '39622', '396.22');

SELECT DISTINCT price_usa
FROM mobiles_staging2
ORDER BY 1;


-- Change data types
-- weight, battey and price to integer

# Weight
UPDATE mobiles_staging2
SET weight = REPLACE(weight, 'g', '');

alter table mobiles_staging2
modify column weight integer;

alter table mobiles_staging2
rename column weight to weight_in_grams;

# Battery
UPDATE mobiles_staging2
SET battery = REPLACE(battery, 'mAh', '');

alter table mobiles_staging2
modify column battery integer;

alter table mobiles_staging2
rename column battery to battery_in_mAh;

# Price 
UPDATE mobiles_staging2
SET price_usa = REPLACE(price_usa, 'USD ', '');

alter table mobiles_staging2
modify column price_usa integer;

alter table mobiles_staging2
rename column price_usa to `launched_price_in_usa(USD)`;

-- Drop columns not needed 

alter table mobiles_staging2
drop column dupli_check;

alter table mobiles_staging2
drop column price_pakistan;

alter table mobiles_staging2
drop column price_inda;

alter table mobiles_staging2
drop column price_china;

alter table mobiles_staging2
drop column price_dubai;

SELECT *
FROM mobiles_staging2;



























