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

