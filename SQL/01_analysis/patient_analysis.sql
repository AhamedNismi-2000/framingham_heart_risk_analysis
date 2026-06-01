-- Total Male Female 

  SELECT 
   gender,
   COUNT(gender) AS count
  FROM framingham_cleaned  
  GROUP BY gender

-- How Many Male Effect By Coronary Heart Disease

SELECT 
   gender,
   COUNT(CASE WHEN chd_risk_10yr = 'Yes' THEN gender) AS effect_by_heart_disease,
   COUNT(gender) AS without_heart_disease

FROM framingham_cleaned 
WHERE chd_risk_10yr = 'Yes'
GROUP BY gender

