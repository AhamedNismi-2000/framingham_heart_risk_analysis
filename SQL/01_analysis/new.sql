    -- =====================================================
    -- Framingham Heart Disease SQL Analysis
    -- Dataset : framingham_cleaned.csv (4,240 rows)
    -- Dialect : PostgreSQL
    -- Objective: Explore factors associated with
    --            10-year Coronary Heart Disease (CHD) risk.
    -- Last Updated: Enhanced & corrected version
    -- =====================================================
    -- NOTE: All analytical queries filter has_outlier_flag = False
    --       (removes 581 flagged outlier rows) for cleaner results.
    --       Section 0 (KPIs) and Section 1 (counts) show both
    --       total and clean figures for transparency.
    -- =====================================================



    -- =====================================================
    -- 0. HIGH-LEVEL KPIs  (Executive / Dashboard Summary)
    -- =====================================================

    SELECT
        COUNT(*)                                                                          AS total_patients,
        SUM(CASE WHEN has_outlier_flag = False THEN 1 ELSE 0 END)                        AS clean_patients,
        ROUND(AVG(age)::NUMERIC, 1)                                                       AS avg_age,
        ROUND(AVG(bmi)::NUMERIC, 1)                                                       AS avg_bmi,
        ROUND(AVG(systolic_bp)::NUMERIC, 0)                                               AS avg_systolic_bp,
        ROUND(100.0 * SUM(CASE WHEN is_smoker        = 'Yes' THEN 1 ELSE 0 END) / COUNT(*), 2) AS smoker_pct,
        ROUND(100.0 * SUM(CASE WHEN has_hypertension = 'Yes' THEN 1 ELSE 0 END) / COUNT(*), 2) AS hypertension_pct,
        ROUND(100.0 * SUM(CASE WHEN has_diabetes     = 'Yes' THEN 1 ELSE 0 END) / COUNT(*), 2) AS diabetes_pct,
        ROUND(100.0 * SUM(CASE WHEN chd_risk_10yr   = 'Yes' THEN 1 ELSE 0 END) / COUNT(*), 2) AS chd_risk_pct
    FROM framingham_cleaned;



    -- =====================================================
    -- 1. GENDER DISTRIBUTION
    -- Count of male and female participants (clean data).
    -- =====================================================

    SELECT
        gender,
        COUNT(*)  AS total_people
    FROM framingham_cleaned
    WHERE has_outlier_flag = False
    GROUP BY gender
    ORDER BY gender;



    -- =====================================================
    -- 2. CHD RISK DISTRIBUTION BY GENDER
    -- FIX: Removed COUNT(DISTINCT id) — no id column exists.
    --      Using SUM(CASE...) which is correct and portable.
    -- =====================================================

    SELECT
        gender,
        SUM(CASE WHEN chd_risk_10yr = 'Yes' THEN 1 ELSE 0 END)                              AS chd_cases,
        SUM(CASE WHEN chd_risk_10yr = 'No'  THEN 1 ELSE 0 END)                              AS no_chd_cases,
        ROUND(100.0 * SUM(CASE WHEN chd_risk_10yr = 'Yes' THEN 1 ELSE 0 END) / COUNT(*), 2) AS chd_pct,
        ROUND(100.0 * SUM(CASE WHEN chd_risk_10yr = 'No'  THEN 1 ELSE 0 END) / COUNT(*), 2) AS no_chd_pct,
        COUNT(*)                                                                              AS total
    FROM framingham_cleaned
    WHERE has_outlier_flag = False
    GROUP BY gender
    ORDER BY gender;



    -- =====================================================
    -- 3. SMOKING BEHAVIOUR BY GENDER & AGE BAND
    --    (Among CHD-positive individuals only)
    -- =====================================================

    SELECT
        gender,
        CASE
            WHEN age BETWEEN 30 AND 39 THEN '30-39'
            WHEN age BETWEEN 40 AND 49 THEN '40-49'
            WHEN age BETWEEN 50 AND 59 THEN '50-59'
            WHEN age BETWEEN 60 AND 69 THEN '60-69'
            WHEN age >= 70              THEN '70+'
            ELSE 'Unknown'
        END                                                                                   AS age_band,
        COUNT(*)                                                                              AS total_chd_patients,
        SUM(CASE WHEN is_smoker = 'Yes' THEN 1 ELSE 0 END)                                   AS smokers,
        SUM(CASE WHEN is_smoker = 'No'  THEN 1 ELSE 0 END)                                   AS non_smokers,
        ROUND(100.0 * SUM(CASE WHEN is_smoker = 'Yes' THEN 1 ELSE 0 END) / COUNT(*), 2)      AS smoker_pct,
        ROUND(100.0 * SUM(CASE WHEN is_smoker = 'No'  THEN 1 ELSE 0 END) / COUNT(*), 2)      AS non_smoker_pct,
        ROUND(AVG(cigarettes_per_day)::NUMERIC, 2)                                            AS avg_cigarettes_per_day
    FROM framingham_cleaned
    WHERE chd_risk_10yr  = 'Yes'
    AND has_outlier_flag = False
    GROUP BY gender, age_band
    ORDER BY gender, age_band;



    -- =====================================================
    -- 4. AVERAGE DAILY CIGARETTE CONSUMPTION BY CHD STATUS
    --    (Smokers only — compares intensity between groups)
    -- =====================================================

    SELECT
        chd_risk_10yr,
        COUNT(*)                                           AS smoker_count,
        ROUND(AVG(cigarettes_per_day)::NUMERIC, 2)         AS avg_cigarettes_per_day,
        ROUND(MIN(cigarettes_per_day)::NUMERIC, 0)         AS min_cigarettes,
        ROUND(MAX(cigarettes_per_day)::NUMERIC, 0)         AS max_cigarettes
    FROM framingham_cleaned
    WHERE is_smoker       = 'Yes'
    AND has_outlier_flag = False
    GROUP BY chd_risk_10yr
    ORDER BY chd_risk_10yr DESC;



    -- =====================================================
    -- 5. AVERAGE AGE BY CHD STATUS
    --    Does CHD risk increase with age?
    -- =====================================================

    SELECT
        chd_risk_10yr,
        COUNT(*)                          AS patient_count,
        ROUND(AVG(age)::NUMERIC, 2)       AS avg_age,
        MIN(age)                          AS min_age,
        MAX(age)                          AS max_age
    FROM framingham_cleaned
    WHERE has_outlier_flag = False
    GROUP BY chd_risk_10yr
    ORDER BY chd_risk_10yr DESC;



    -- =====================================================
    -- 6. AGE GROUP BREAKDOWN — CHD RISK TREND
    --    Visualise how CHD risk rate climbs with age.
    -- =====================================================

    WITH age_groups AS (
        SELECT
            CASE
                WHEN age < 40              THEN '18-39'
                WHEN age BETWEEN 40 AND 49 THEN '40-49'
                WHEN age BETWEEN 50 AND 59 THEN '50-59'
                WHEN age BETWEEN 60 AND 69 THEN '60-69'
                ELSE '70+'
            END AS age_group,
            chd_risk_10yr
        FROM framingham_cleaned
        WHERE has_outlier_flag = False
    )
    SELECT
        age_group,
        COUNT(*)                                                                              AS patient_count,
        SUM(CASE WHEN chd_risk_10yr = 'Yes' THEN 1 ELSE 0 END)                               AS chd_cases,
        ROUND(100.0 * SUM(CASE WHEN chd_risk_10yr = 'Yes' THEN 1 ELSE 0 END) / COUNT(*), 2)  AS chd_risk_pct
    FROM age_groups
    GROUP BY age_group
    ORDER BY MIN(CASE age_group
        WHEN '18-39' THEN 1 WHEN '40-49' THEN 2
        WHEN '50-59' THEN 3 WHEN '60-69' THEN 4 ELSE 5 END);



    -- =====================================================
    -- 7. SMOKING STATUS VS CHD RISK
    --    CHD prevalence among smokers vs non-smokers.
    -- =====================================================

    SELECT
        is_smoker,
        COUNT(*)                                                                              AS total_people,
        SUM(CASE WHEN chd_risk_10yr = 'Yes' THEN 1 ELSE 0 END)                               AS chd_cases,
        ROUND(100.0 * SUM(CASE WHEN chd_risk_10yr = 'Yes' THEN 1 ELSE 0 END) / COUNT(*), 2)  AS chd_pct
    FROM framingham_cleaned
    WHERE has_outlier_flag = False
    GROUP BY is_smoker
    ORDER BY is_smoker;



    -- =====================================================
    -- 8. GENDER + SMOKING COMBINATION VS CHD RISK
    -- =====================================================

    SELECT
        gender,
        is_smoker,
        COUNT(*)                                                                              AS total,
        SUM(CASE WHEN chd_risk_10yr = 'Yes' THEN 1 ELSE 0 END)                               AS chd_positive,
        ROUND(100.0 * AVG(CASE WHEN chd_risk_10yr = 'Yes' THEN 1.0 ELSE 0.0 END), 2)         AS chd_risk_pct,
        ROUND(AVG(cigarettes_per_day)::NUMERIC, 1)                                            AS avg_cigarettes
    FROM framingham_cleaned
    WHERE has_outlier_flag    = False
    AND cigarettes_per_day IS NOT NULL
    GROUP BY gender, is_smoker
    ORDER BY gender, chd_risk_pct DESC;



    -- =====================================================
    -- 9. DIABETES VS CHD RISK
    -- =====================================================

    SELECT
        has_diabetes,
        COUNT(*)                                                                              AS total_people,
        SUM(CASE WHEN chd_risk_10yr = 'Yes' THEN 1 ELSE 0 END)                               AS chd_cases,
        ROUND(100.0 * SUM(CASE WHEN chd_risk_10yr = 'Yes' THEN 1 ELSE 0 END) / COUNT(*), 2)  AS chd_pct
    FROM framingham_cleaned
    WHERE has_outlier_flag = False
    GROUP BY has_diabetes
    ORDER BY has_diabetes;



    -- =====================================================
    -- 10. HYPERTENSION VS CHD RISK
    -- =====================================================

    SELECT
        has_hypertension,
        COUNT(*)                                                                              AS total_people,
        SUM(CASE WHEN chd_risk_10yr = 'Yes' THEN 1 ELSE 0 END)                               AS chd_cases,
        ROUND(100.0 * SUM(CASE WHEN chd_risk_10yr = 'Yes' THEN 1 ELSE 0 END) / COUNT(*), 2)  AS chd_pct
    FROM framingham_cleaned
    WHERE has_outlier_flag = False
    GROUP BY has_hypertension
    ORDER BY has_hypertension;



    -- =====================================================
    -- 11. BLOOD PRESSURE MEDICATION EFFECTIVENESS
    --     Compare CHD risk across hypertension + medication combos.
    -- =====================================================

    SELECT
        has_hypertension,
        on_bp_medication,
        COUNT(*)                                                                                     AS patient_count,
        ROUND(100.0 * SUM(CASE WHEN chd_risk_10yr = 'Yes' THEN 1 ELSE 0 END)::NUMERIC / COUNT(*), 2) AS chd_risk_pct,
        ROUND(AVG(systolic_bp)::NUMERIC,  0)                                                          AS avg_sbp,
        ROUND(AVG(diastolic_bp)::NUMERIC, 0)                                                          AS avg_dbp
    FROM framingham_cleaned
    WHERE has_outlier_flag = False
    GROUP BY has_hypertension, on_bp_medication
    ORDER BY has_hypertension DESC, on_bp_medication DESC;



    -- =====================================================
    -- 12. STROKE HISTORY VS CHD RISK
    -- =====================================================

    SELECT
        had_stroke,
        COUNT(*)                                                                              AS total_people,
        SUM(CASE WHEN chd_risk_10yr = 'Yes' THEN 1 ELSE 0 END)                               AS chd_cases,
        ROUND(100.0 * SUM(CASE WHEN chd_risk_10yr = 'Yes' THEN 1 ELSE 0 END) / COUNT(*), 2)  AS chd_pct
    FROM framingham_cleaned
    WHERE has_outlier_flag = False
    GROUP BY had_stroke
    ORDER BY had_stroke;



    -- =====================================================
    -- 13. BMI CATEGORY VS CHD RISK
    -- FIX: ORDER BY uses full expression (not alias) for
    --      compatibility across SQL engines.
    -- Categories follow WHO standard:
    --   Normal     : BMI < 25
    --   Overweight : BMI 25 – 29.9
    --   Obese      : BMI >= 30
    -- =====================================================

    SELECT
        CASE
            WHEN bmi IS NULL THEN 'Unknown'
            WHEN bmi < 25    THEN 'Normal (<25)'
            WHEN bmi < 30    THEN 'Overweight (25-29.9)'
            ELSE                  'Obese (30+)'
        END                                                                                    AS bmi_band,
        COUNT(*)                                                                               AS total_people,
        SUM(CASE WHEN chd_risk_10yr = 'Yes' THEN 1 ELSE 0 END)                                AS chd_cases,
        ROUND(100.0 * SUM(CASE WHEN chd_risk_10yr = 'Yes' THEN 1 ELSE 0 END) / COUNT(*), 2)   AS chd_pct
    FROM framingham_cleaned
    WHERE has_outlier_flag = False
    GROUP BY bmi_band
    ORDER BY ROUND(100.0 * SUM(CASE WHEN chd_risk_10yr = 'Yes' THEN 1 ELSE 0 END) / COUNT(*), 2) DESC;



    -- =====================================================
    -- 14. CLINICAL METRICS COMPARISON BY CHD STATUS
    --     Average BP, cholesterol, BMI, glucose, heart rate
    --     split between CHD-positive and CHD-negative groups.
    -- =====================================================

    SELECT
        chd_risk_10yr,
        COUNT(*)                                        AS patient_count,
        ROUND(AVG(systolic_bp)::NUMERIC,       1)       AS avg_systolic_bp,
        ROUND(AVG(diastolic_bp)::NUMERIC,      1)       AS avg_diastolic_bp,
        ROUND(AVG(total_cholesterol)::NUMERIC, 1)       AS avg_cholesterol,
        ROUND(AVG(bmi)::NUMERIC,               1)       AS avg_bmi,
        ROUND(AVG(glucose_level)::NUMERIC,     1)       AS avg_glucose,
        ROUND(AVG(heart_rate)::NUMERIC,        1)       AS avg_heart_rate
    FROM framingham_cleaned
    WHERE has_outlier_flag = False
    GROUP BY chd_risk_10yr
    ORDER BY chd_risk_10yr DESC;



    -- =====================================================
    -- 15. EDUCATION LEVEL VS CHD RISK
    --     Socioeconomic factor analysis.
    -- =====================================================

    SELECT
        education_level,
        COUNT(*)                                                                              AS total_patients,
        SUM(CASE WHEN chd_risk_10yr = 'Yes' THEN 1 ELSE 0 END)                               AS chd_cases,
        ROUND(100.0 * SUM(CASE WHEN chd_risk_10yr = 'Yes' THEN 1 ELSE 0 END) / COUNT(*), 2)  AS chd_risk_pct,
        ROUND(AVG(age)::NUMERIC, 1)                                                           AS avg_age,
        ROUND(100.0 * SUM(CASE WHEN is_smoker = 'Yes' THEN 1 ELSE 0 END) / COUNT(*), 2)      AS smoker_pct
    FROM framingham_cleaned
    WHERE has_outlier_flag   = False
    AND education_level   != 'Unknown'
    GROUP BY education_level
    ORDER BY chd_risk_pct DESC;



    -- =====================================================
    -- =====================================================
    -- NEW QUERIES — ADDED FOR RICHER ANALYSIS & DASHBOARD
    -- =====================================================
    -- =====================================================



    -- =====================================================
    -- 16. MULTI RISK FACTOR STACKING VS CHD RISK  ⭐
    --     Counts how many of 4 risk factors each person
    --     carries (smoking, hypertension, diabetes, stroke).
    --     Shows CHD rate climbing with each added factor.
    --     → Best Power BI visual: Clustered column chart.
    -- =====================================================

    SELECT
        (CASE WHEN is_smoker        = 'Yes' THEN 1 ELSE 0 END
    + CASE WHEN has_hypertension = 'Yes' THEN 1 ELSE 0 END
    + CASE WHEN has_diabetes     = 'Yes' THEN 1 ELSE 0 END
    + CASE WHEN had_stroke       = 'Yes' THEN 1 ELSE 0 END) AS risk_factor_count,
        COUNT(*)                                                                              AS total_patients,
        SUM(CASE WHEN chd_risk_10yr = 'Yes' THEN 1 ELSE 0 END)                               AS chd_cases,
        ROUND(100.0 * SUM(CASE WHEN chd_risk_10yr = 'Yes' THEN 1 ELSE 0 END) / COUNT(*), 2)  AS chd_pct
    FROM framingham_cleaned
    WHERE has_outlier_flag = False
    GROUP BY risk_factor_count
    ORDER BY risk_factor_count;



    -- =====================================================
    -- 17. CHOLESTEROL RISK BANDS VS CHD
    --     Follows standard clinical thresholds.
    -- =====================================================

    SELECT
        CASE
            WHEN total_cholesterol < 200              THEN '1. Desirable (<200)'
            WHEN total_cholesterol BETWEEN 200 AND 239 THEN '2. Borderline (200-239)'
            ELSE                                           '3. High (240+)'
        END                                                                                    AS cholesterol_band,
        COUNT(*)                                                                               AS total_patients,
        SUM(CASE WHEN chd_risk_10yr = 'Yes' THEN 1 ELSE 0 END)                                AS chd_cases,
        ROUND(100.0 * SUM(CASE WHEN chd_risk_10yr = 'Yes' THEN 1 ELSE 0 END) / COUNT(*), 2)   AS chd_pct
    FROM framingham_cleaned
    WHERE has_outlier_flag = False
    GROUP BY cholesterol_band
    ORDER BY cholesterol_band;



    -- =====================================================
    -- 18. BLOOD PRESSURE CATEGORY VS CHD  (JNC-8 Standard)
    --     Useful for clinical BP stage storytelling.
    -- =====================================================

    SELECT
        CASE
            WHEN systolic_bp < 120              THEN '1. Normal (<120)'
            WHEN systolic_bp BETWEEN 120 AND 129 THEN '2. Elevated (120-129)'
            WHEN systolic_bp BETWEEN 130 AND 139 THEN '3. Stage 1 HBP (130-139)'
            ELSE                                     '4. Stage 2 HBP (140+)'
        END                                                                                    AS bp_category,
        COUNT(*)                                                                               AS total_patients,
        SUM(CASE WHEN chd_risk_10yr = 'Yes' THEN 1 ELSE 0 END)                                AS chd_cases,
        ROUND(100.0 * SUM(CASE WHEN chd_risk_10yr = 'Yes' THEN 1 ELSE 0 END) / COUNT(*), 2)   AS chd_pct,
        ROUND(AVG(systolic_bp)::NUMERIC, 1)                                                    AS avg_sbp
    FROM framingham_cleaned
    WHERE has_outlier_flag = False
    GROUP BY bp_category
    ORDER BY bp_category;



    -- =====================================================
    -- 19. GLUCOSE RISK BANDS VS CHD
    --     Catches pre-diabetic zone often missed by the
    --     binary has_diabetes flag.
    -- =====================================================

    SELECT
        CASE
            WHEN glucose_level < 100              THEN '1. Normal (<100)'
            WHEN glucose_level BETWEEN 100 AND 125 THEN '2. Pre-diabetic (100-125)'
            ELSE                                       '3. Diabetic Range (126+)'
        END  AS glucose_band,
        COUNT(*)   AS total_patients,
        SUM(CASE WHEN chd_risk_10yr = 'Yes' THEN 1 ELSE 0 END)  AS chd_cases,
        ROUND(100.0 * SUM(CASE WHEN chd_risk_10yr = 'Yes' THEN 1 ELSE 0 END) / COUNT(*), 2) AS chd_pct,
        ROUND(AVG(glucose_level)::NUMERIC, 1) AS avg_glucose
    FROM framingham_cleaned
    WHERE has_outlier_flag = False
    GROUP BY glucose_band
    ORDER BY glucose_band;



    -- =====================================================
    -- 20. HEART RATE BANDS VS CHD
    --     Low/Normal/Elevated resting heart rate zones.
    -- =====================================================

    SELECT
        CASE
            WHEN heart_rate < 60              THEN '1. Low (<60 bpm)'
            WHEN heart_rate BETWEEN 60 AND 99  THEN '2. Normal (60-99 bpm)'
            ELSE                                   '3. Elevated (100+ bpm)'
        END AS hr_band,
        COUNT(*)  AS total_patients,
        SUM(CASE WHEN chd_risk_10yr = 'Yes' THEN 1 ELSE 0 END)AS chd_cases,
        ROUND(100.0 * SUM(CASE WHEN chd_risk_10yr = 'Yes' THEN 1 ELSE 0 END) / COUNT(*), 2) AS chd_pct
    FROM framingham_cleaned
    WHERE has_outlier_flag = False
    GROUP BY hr_band
    ORDER BY hr_band;



    -- =====================================================
    -- 21. GENDER × AGE GROUP × CHD RISK MATRIX
    --     Full breakdown for Power BI matrix / heatmap.
    -- =====================================================

    SELECT
        gender,
        CASE
            WHEN age < 40              THEN '18-39'
            WHEN age BETWEEN 40 AND 49 THEN '40-49'
            WHEN age BETWEEN 50 AND 59 THEN '50-59'
            WHEN age BETWEEN 60 AND 69 THEN '60-69'
            ELSE '70+'
        END  AS age_group,
        COUNT(*)  AS total_patients,
        SUM(CASE WHEN chd_risk_10yr = 'Yes' THEN 1 ELSE 0 END) AS chd_cases,
        ROUND(100.0 * SUM(CASE WHEN chd_risk_10yr = 'Yes' THEN 1 ELSE 0 END) / COUNT(*), 2)AS chd_pct
    FROM framingham_cleaned
    WHERE has_outlier_flag = False
    GROUP BY gender, age_group
    ORDER BY gender,
            MIN(CASE age_group
                WHEN '18-39' THEN 1 WHEN '40-49' THEN 2
                WHEN '50-59' THEN 3 WHEN '60-69' THEN 4 ELSE 5 END);


