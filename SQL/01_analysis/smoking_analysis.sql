-- =====================================================
-- Framingham Heart Disease Analysis
-- Objective:
-- Explore factors associated with 10-year Coronary Heart Disease (CHD) risk.
-- =====================================================



-- =====================================================
-- 1. Gender Distribution
-- Determine the number of male and female participants.
-- =====================================================

    SELECT
        gender,
        COUNT(*) AS total_people
    FROM framingham_cleaned
    GROUP BY gender;


-- =====================================================
-- 2. CHD Risk Distribution by Gender
-- Analyze how CHD risk differs between males and females.
-- =====================================================

    SELECT 
      gender,
      COUNT(DISTINCT CASE WHEN chd_risk_10yr = 'Yes' THEN id END  ) AS effect_by_heart_disease,
      COUNT(DISTINCT CASE WHEN chd_risk_10yr = 'No' THEN id END  ) AS without_heart_disease,
      ROUND(COUNT(DISTINCT CASE WHEN chd_risk_10yr = 'Yes' THEN id END )  * 100.0 / COUNT(id),2) AS effect_by_heart_diseas_pcnt,
      ROUND(COUNT(DISTINCT CASE WHEN chd_risk_10yr = 'No' THEN id END  ) *100.0 / COUNT(id),2)   AS without_heart_disease_pcnt,
      COUNT(id) AS total
    FROM framingham_cleaned 
    GROUP BY gender





-- =====================================================
-- 3. Smoking Behaviour Among Individuals with CHD Risk
--
-- Insight:
-- Examine smoking prevalence and cigarette consumption
-- among people identified as having a 10-year CHD risk.
-- =====================================================

    SELECT
        gender,
        CASE
            WHEN age BETWEEN 30 AND 39 THEN '30-39'
            WHEN age BETWEEN 40 AND 49 THEN '40-49'
            WHEN age BETWEEN 50 AND 59 THEN '50-59'
            WHEN age BETWEEN 60 AND 69 THEN '60-69'
            WHEN age >= 70 THEN '70+'
            ELSE 'Unknown'
        END AS age_band,
            COUNT(*) AS total_people,
            SUM(CASE WHEN is_smoker = 'Yes' THEN 1 ELSE 0 END) AS smokers,
            SUM(CASE WHEN is_smoker = 'No' THEN 1 ELSE 0 END) AS non_smokers,
            ROUND( SUM(CASE WHEN is_smoker = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2 ) AS smoker_percentage,
            ROUND( SUM(CASE WHEN is_smoker = 'No' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2 ) AS non_smoker_percentage,
            ROUND( AVG(cigarettes_per_day)::NUMERIC, 2 ) AS avg_cigarettes_per_day
        FROM framingham_cleaned
        WHERE chd_risk_10yr = 'Yes'
        GROUP BY gender, age_band
        ORDER BY gender, age_band;



-- =====================================================
-- 4. Average Daily Cigarette Consumption by CHD Status
--
-- Compare smoking intensity between smokers with and
-- without CHD risk.
-- =====================================================

    SELECT
        chd_risk_10yr,
        ROUND( AVG(cigarettes_per_day)::NUMERIC, 2 ) AS avg_cigarettes_per_day
    FROM framingham_cleaned
    WHERE is_smoker = 'Yes'
    GROUP BY chd_risk_10yr;



-- =====================================================
-- 5. Average Age by CHD Status
--
-- Determine whether CHD risk tends to increase with age.
-- =====================================================

    SELECT
        chd_risk_10yr,
        ROUND(AVG(age), 2) AS average_age
    FROM framingham_cleaned
    GROUP BY chd_risk_10yr;



-- =====================================================
-- 6. Smoking Status vs CHD Risk
--
-- Evaluate the prevalence of CHD among smokers and
-- non-smokers.
-- =====================================================

    SELECT
        is_smoker,
        COUNT(*) AS total_people,
        SUM( CASE WHEN chd_risk_10yr = 'Yes' THEN 1 ELSE 0 END ) AS chd_cases,
        ROUND( SUM( CASE WHEN chd_risk_10yr = 'Yes' THEN 1 ELSE 0 END ) * 100.0 / COUNT(*),2 ) AS chd_percentage
    FROM framingham_cleaned
    GROUP BY is_smoker;



-- =====================================================
-- 7. Diabetes vs CHD Risk
--
-- Measure CHD prevalence among diabetic and
-- non-diabetic individuals.
-- =====================================================

    SELECT
        has_diabetes,
        COUNT(*) AS total_people,
        SUM(CASE WHEN chd_risk_10yr = 'Yes' THEN 1 ELSE 0 END ) AS chd_cases,
        ROUND( SUM( CASE WHEN chd_risk_10yr = 'Yes' THEN 1 ELSE 0 END ) * 100.0 / COUNT(*),2 ) AS chd_percentage
    FROM framingham_cleaned
    GROUP BY has_diabetes;



-- =====================================================
-- 8. Hypertension vs CHD Risk
--
-- Evaluate whether individuals with hypertension
-- exhibit higher CHD prevalence.
-- =====================================================

    SELECT
        has_hypertension,
        COUNT(*) AS total_people,
        SUM(CASE WHEN chd_risk_10yr = 'Yes' THEN 1 ELSE 0 END ) AS chd_cases,
        ROUND(SUM(CASE WHEN chd_risk_10yr = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*),2) AS chd_percentage
    FROM framingham_cleaned
    GROUP BY has_hypertension;



-- =====================================================
-- 9. Stroke History vs CHD Risk
--
-- Investigate whether participants with a prior
-- stroke history have elevated CHD prevalence.
-- =====================================================

    SELECT
        had_stroke,
        COUNT(*) AS total_people,
        SUM(CASE WHEN chd_risk_10yr = 'Yes' THEN 1 ELSE 0 END) AS chd_cases,
        ROUND( SUM( CASE WHEN chd_risk_10yr = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*),2) AS chd_percentage
    FROM framingham_cleaned
    GROUP BY had_stroke;



-- =====================================================
-- 10. BMI Category vs CHD Risk
--
-- Analyze how CHD prevalence varies across BMI groups.
--
-- Categories:
-- Normal     : BMI < 25
-- Overweight : BMI 25-29.9
-- Obese      : BMI >= 30
-- =====================================================

    SELECT
        CASE
            WHEN bmi IS NULL THEN 'Unknown'
            WHEN bmi < 25 THEN 'Normal'
            WHEN bmi < 30 THEN 'Overweight'
            ELSE 'Obese'
        END AS bmi_band,
        COUNT(*) AS total_people,
        SUM( CASE WHEN chd_risk_10yr = 'Yes' THEN 1 ELSE 0 END) AS chd_cases,
        ROUND( SUM( CASE WHEN chd_risk_10yr = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS chd_percentage
    FROM framingham_cleaned
    GROUP BY bmi_band
    ORDER BY chd_percentage DESC;



     SELECT * FROM  framingham_cleaned


     -- High-level KPIs for executive dashboard
     
    SELECT 
        COUNT(*) AS total_patients,
        ROUND(AVG(age)::numeric, 1) AS avg_age,
        ROUND(AVG(bmi)::numeric, 1) AS avg_bmi,
        ROUND(AVG(systolic_bp)::numeric, 0) AS avg_systolic_bp,
        ROUND(100.0 * SUM(CASE WHEN is_smoker = 'Yes' THEN 1 ELSE 0 END)/ COUNT(*), 2) AS smoker_pct,
        ROUND(100.0 * SUM(CASE WHEN has_hypertension = 'Yes' THEN 1 ELSE 0 END)/ COUNT(*), 2) AS hypertension_pct,
        ROUND(100.0 * SUM(CASE WHEN chd_risk_10yr = 'Yes' THEN 1 ELSE 0 END) / COUNT(*), 2) AS chd_risk_pct,
        ROUND(100.0 * SUM(CASE WHEN has_diabetes = 'Yes' THEN 1 ELSE 0 END) / COUNT(*) , 2) AS diabetes_pct
    FROM framingham_cleaned
    WHERE has_outlier_flag = False;  


       
        
      
        