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





-- Among individuals with a 10-year CHD risk,
--  smoking behavior varies significantly across both gender and age bands.
--   Males generally exhibit higher smoking prevalence and higher average cigarette consumption compared to females across most age groups.+
--  The 50–59 age band shows the highest concentration of smoking activity, indicating increased behavioral risk in mid-to-late adulthood.
  
  SELECT 
      gender,
       CASE 
        WHEN age BETWEEN 30 AND 39 THEN '30-39'
        WHEN age BETWEEN 40 AND 49 THEN '40-49'
        WHEN age BETWEEN 50 AND 59 THEN '50-59'
        WHEN age BETWEEN 60 AND 69 THEN '60-69'
        WHEN age >= 70 THEN '70+'
    END AS age_band,
      COUNT(*) AS total_people,
      SUM(CASE WHEN is_smoker='Yes' THEN 1 ELSE 0 END) AS smokers,
      SUM(CASE WHEN is_smoker='No' THEN 1 ELSE 0 END) AS non_smokers,
      ROUND(SUM(CASE WHEN is_smoker='Yes' THEN 1 ELSE 0 END)  * 100.0 / COUNT(*),2) AS smokers_prcnt,
      ROUND(SUM(CASE WHEN is_smoker='No' THEN 1 ELSE 0 END)  * 100.0 / COUNT(*) ,2)AS non_smokers_prcnt,
      ROUND(AVG(cigarettes_per_day)::numeric,2) AS avg_cigarettes_per_day
  FROM framingham_cleaned
  WHERE chd_risk_10yr = 'Yes'
  GROUP BY gender,age_band 
  ORDER BY gender,age_band ;

  
-- Smokers with CHD risk consume an average of 20.61 cigarettes per day compared to
-- 17.96 cigarettes per day among smokers without CHD risk

  SELECT
    chd_risk_10yr,
    ROUND(AVG(cigarettes_per_day)::numeric,2) AS avg_cigarettes_per_day
  FROM framingham_cleaned
  WHERE is_smoker = 'Yes'
  GROUP BY chd_risk_10yr;

-- How Much Age Effect The CHD 

  SELECT
    chd_risk_10yr,
    ROUND(AVG(age),2) AS avg_age
  FROM framingham_cleaned
  GROUP BY chd_risk_10yr;


  -- Smoking vs CHD 

      SELECT
      is_smoker,
      COUNT(*) AS total_people,
      SUM(CASE WHEN chd_risk_10yr='Yes' THEN 1 ELSE 0 END) AS chd_cases,
      ROUND(
          SUM(CASE WHEN chd_risk_10yr='Yes' THEN 1 ELSE 0 END) * 100.0
          / COUNT(*), 2
      ) AS chd_percentage
  FROM framingham_cleaned
  GROUP BY is_smoker;






 -- How Much Diabetes Effect Chd 

  SELECT
      has_diabetes,
      COUNT(*) AS total_people,
      SUM(CASE WHEN chd_risk_10yr='Yes' THEN 1 ELSE 0 END) AS chd_cases,
      ROUND(
          SUM(CASE WHEN chd_risk_10yr='Yes' THEN 1 ELSE 0 END) * 100.0
          / COUNT(*), 2
      ) AS chd_percentage
  FROM framingham_cleaned
  GROUP BY has_diabetes;

 -- How Much Hypertension Effect Chd 

  SELECT
      has_hypertension,
      COUNT(*) AS total_people,
      SUM(CASE WHEN chd_risk_10yr='Yes' THEN 1 ELSE 0 END) AS chd_cases,
      ROUND(
          SUM(CASE WHEN chd_risk_10yr='Yes' THEN 1 ELSE 0 END) * 100.0
          / COUNT(*), 2
      ) AS chd_percentage
  FROM framingham_cleaned
  GROUP BY has_hypertension;

  -- How Much Stroke Effect The CHD 
  
  SELECT
      had_stroke,
      COUNT(*) AS total_people,
      SUM(CASE WHEN chd_risk_10yr='Yes' THEN 1 ELSE 0 END) AS chd_cases,
      ROUND(
          SUM(CASE WHEN chd_risk_10yr='Yes' THEN 1 ELSE 0 END) * 100.0
          / COUNT(*), 2
      ) AS chd_percentage
  FROM framingham_cleaned
  GROUP BY had_stroke;


  ---"BMI demonstrates a clear relationship with CHD risk. Individuals with a normal BMI show a CHD prevalence of 12.20%,
  --  compared with 17.14% among overweight individuals and 19.48% among obese individuals.
  --   The findings suggest that excess body weight is associated with increased cardiovascular risk,
  --    with obese individuals exhibiting the highest prevalence of CHD risk

  SELECT
      CASE
          WHEN bmi < 25 THEN 'Normal'
          WHEN bmi < 30 THEN 'Overweight'
          ELSE 'Obese'
      END AS bmi_band,
      COUNT(*) AS total_people,
      SUM(CASE WHEN chd_risk_10yr = 'Yes' THEN 1 ELSE 0 END) AS chd_cases,
      ROUND(
          SUM(CASE WHEN chd_risk_10yr = 'Yes' THEN 1 ELSE 0 END) * 100.0
          / COUNT(*),
          2
      ) AS chd_percentage
  FROM framingham_cleaned
  GROUP BY bmi_band
  ORDER BY chd_percentage DESC;


    -- Top Risk Age Group

   SELECT
        CASE
            WHEN age BETWEEN 30 AND 39 THEN '30-39'
            WHEN age BETWEEN 40 AND 49 THEN '40-49'
            WHEN age BETWEEN 50 AND 59 THEN '50-59'
            WHEN age BETWEEN 60 AND 69 THEN '60-69'
            ELSE '70+'
        END AS age_band,
    COUNT(*) AS total_people,
    SUM(CASE WHEN chd_risk_10yr='Yes' THEN 1 ELSE 0 END) AS chd_cases,
    ROUND( SUM(CASE WHEN chd_risk_10yr='Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS chd_percentage
    FROM framingham_cleaned
    GROUP BY age_band
    ORDER BY chd_percentage DESC;








  

     SELECT * FROM  framingham_cleaned












SELECT
    gender,
    COUNT(CASE WHEN chd_risk_10yr = 'Yes' THEN 1 END) AS chd_cases,
    COUNT(CASE WHEN chd_risk_10yr = 'No' THEN 1 END) AS non_chd_cases,

    ROUND(
        COUNT(CASE WHEN chd_risk_10yr = 'Yes' THEN 1 END)
        * 100.0 / COUNT(*),
        2
    ) AS chd_percentage,

    ROUND(
        COUNT(CASE WHEN chd_risk_10yr = 'No' THEN 1 END)
        * 100.0 / COUNT(*), 2) AS non_chd_percentage,

    COUNT(*) AS total_people
FROM framingham_cleaned
GROUP BY gender;



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

    ROUND(
        SUM(CASE WHEN is_smoker = 'Yes' THEN 1 ELSE 0 END)
        * 100.0 / COUNT(*),
        2
    ) AS smoker_percentage,

    ROUND(
        SUM(CASE WHEN is_smoker = 'No' THEN 1 ELSE 0 END)
        * 100.0 / COUNT(*),
        2
    ) AS non_smoker_percentage,

    ROUND(
        AVG(cigarettes_per_day)::NUMERIC,
        2
    ) AS avg_cigarettes_per_day

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
    ROUND(
        AVG(cigarettes_per_day)::NUMERIC,
        2
    ) AS avg_cigarettes_per_day
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

    SUM(
        CASE
            WHEN chd_risk_10yr = 'Yes' THEN 1
            ELSE 0
        END
    ) AS chd_cases,

    ROUND(
        SUM(
            CASE
                WHEN chd_risk_10yr = 'Yes' THEN 1
                ELSE 0
            END
        ) * 100.0 / COUNT(*),
        2
    ) AS chd_percentage

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

    SUM(
        CASE
            WHEN chd_risk_10yr = 'Yes' THEN 1
            ELSE 0
        END
    ) AS chd_cases,

    ROUND(
        SUM(
            CASE
                WHEN chd_risk_10yr = 'Yes' THEN 1
                ELSE 0
            END
        ) * 100.0 / COUNT(*),
        2
    ) AS chd_percentage

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

    SUM(
        CASE
            WHEN chd_risk_10yr = 'Yes' THEN 1
            ELSE 0
        END
    ) AS chd_cases,

    ROUND(
        SUM(
            CASE
                WHEN chd_risk_10yr = 'Yes' THEN 1
                ELSE 0
            END
        ) * 100.0 / COUNT(*),
        2
    ) AS chd_percentage

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

    SUM(
        CASE
            WHEN chd_risk_10yr = 'Yes' THEN 1
            ELSE 0
        END
    ) AS chd_cases,

    ROUND(
        SUM(
            CASE
                WHEN chd_risk_10yr = 'Yes' THEN 1
                ELSE 0
            END
        ) * 100.0 / COUNT(*),
        2
    ) AS chd_percentage

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

    SUM(
        CASE
            WHEN chd_risk_10yr = 'Yes' THEN 1
            ELSE 0
        END
    ) AS chd_cases,

    ROUND(
        SUM(
            CASE
                WHEN chd_risk_10yr = 'Yes' THEN 1
                ELSE 0
            END
        ) * 100.0 / COUNT(*),
        2
    ) AS chd_percentage

FROM framingham_cleaned
GROUP BY bmi_band
ORDER BY chd_percentage DESC;
