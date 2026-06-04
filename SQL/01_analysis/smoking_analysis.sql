-- Total Male Female 

    SELECT 
    gender,
    COUNT(gender) AS count
    FROM framingham_cleaned  
    GROUP BY gender


  -- How Many Male Effect By Coronary Heart Disease

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


  SELECT 
     COUNT(id)
  FROM framingham_cleaner
  WHERE is_smoker = 'No'






  

     SELECT * FROM  framingham_cleaned

