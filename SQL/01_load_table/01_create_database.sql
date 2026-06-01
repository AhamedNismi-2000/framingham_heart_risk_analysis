
-- Create DataBase  
CREATE DATABASE framingham

-- Create Table 
CREATE TABLE framingham_cleaned (
    gender               VARCHAR(10),
    age                  INT,
    education_level      VARCHAR(25),
    is_smoker            VARCHAR(5),
    cigarettes_per_day   FLOAT,
    on_bp_medication     VARCHAR(5),
    had_stroke           VARCHAR(5),
    has_hypertension     VARCHAR(5),
    has_diabetes         VARCHAR(5),
    total_cholesterol    FLOAT,
    systolic_bp          FLOAT,
    diastolic_bp         FLOAT,
    bmi                  FLOAT,
    heart_rate           FLOAT,
    glucose_level        FLOAT,
    chd_risk_10yr        VARCHAR(5),
    has_outlier_flag     BOOLEAN
);



-- Load Table in the Database

    COPY framingham_cleaned
    FROM 'D:\Mine\Projects\framingham_heart_risk_analysis\Data\1_cleaned_data\framingham_cleaned.csv'
    WITH  (FORMAT csv , HEADER TRUE , DELIMITER ',' , ENCODING  'UTF8' )


  SELECT * FROM framingham_cleaned