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


  -- Among individuals with a 10-year CHD risk, smoking behavior shows clear variation by gender.
  -- Males exhibit a higher smoking prevalence and greater average cigarette consumption compared to females, 
  -- while females demonstrate a higher proportion of non-smokers within the high-risk group.
  --   This suggests smoking is a strong contributing risk factor for CHD, although it is not the only determinant, 
  --   as other lifestyle and biological factors may also influence risk
  
  SELECT 
      gender,
      COUNT(*) AS total_people,
      ROUND(SUM(CASE WHEN is_smoker='Yes' THEN 1 ELSE 0 END)  * 100.0 / COUNT(*),2) AS smokers,
      ROUND(SUM(CASE WHEN is_smoker='No' THEN 1 ELSE 0 END)  * 100.0 / COUNT(*) ,2)AS non_smokers,
      ROUND(AVG(cigarettes_per_day)::numeric,2) AS avg_cigarettes_per_day
  FROM framingham_cleaned
  WHERE chd_risk_10yr = 'Yes'
  GROUP BY gender;


     SELECT * FROM  framingham_cleaned

