-- Explore survey table
SELECT * FROM survey LIMIT 10;


-- Get unique questions in the survey table to understand the funnel
SELECT DISTINCT question AS 'survey_question_funnel'
FROM survey;


-- Count the responses for each question to understand dropout throughout the survey
SELECT question, COUNT(question) AS ‘num_responses’
FROM survey
GROUP BY question;


-- Explore quiz, home try-on, and purchase tables
SELECT * FROM quiz LIMIT 5;
SELECT * FROM home_try_on LIMIT 5;
SELECT * FROM purchase LIMIT 5;


-- Create new table joining quiz, home_try_on, and purchase tables by user_id  setting up the funnel data to be analyzed further
SELECT 
  quiz.user_id,
  CASE WHEN home_try_on.user_id IS NOT NULL 
    THEN 'True' ELSE 'False' 
  END AS 'is_home_try_on',
  home_try_on.number_of_pairs,
  CASE WHEN purchase.user_id IS NOT NULL 
    THEN 'True' ELSE 'False' 
  END AS 'is_purchase'
FROM quiz
LEFT JOIN home_try_on
  ON quiz.user_id = home_try_on.user_id
LEFT JOIN purchase 
  ON quiz.user_id = purchase.user_id
GROUP BY quiz.user_id 
LIMIT 10;


-- Join all three tables to get count of users in each funnel step
WITH results_table AS 
(
SELECT 
  quiz.user_id,
  CASE WHEN home_try_on.user_id IS NOT NULL 
    THEN 'True' ELSE 'False' 
  END AS 'is_home_try_on',
  home_try_on.number_of_pairs,
  CASE WHEN purchase.user_id IS NOT NULL 
    THEN 'True' ELSE 'False' 
  END AS 'is_purchase'
FROM quiz
LEFT JOIN home_try_on
  ON quiz.user_id = home_try_on.user_id
LEFT JOIN purchase 
  ON quiz.user_id = purchase.user_id
GROUP BY quiz.user_id 
)
SELECT 'quiz' AS 'funnel_step', COUNT(*) AS 'count'
FROM results_table
UNION
SELECT 'home_try_on' AS 'funnel_step', COUNT(*) AS 'count'
FROM results_table 
WHERE is_home_try_on = 'True'
UNION
SELECT 'purchase' AS 'funnel_step', COUNT(*) AS 'count'
FROM results_table 
WHERE is_purchase = 'True'
ORDER BY 2 DESC;




-- Join all three funnel tables to create a reference table for analyzing the funnel
WITH results_table AS 
(
SELECT 
  quiz.user_id,
  CASE WHEN home_try_on.user_id IS NOT NULL 
    THEN 'True' 
    ELSE 'False' 
  END AS 'is_home_try_on',
  home_try_on.number_of_pairs,
  CASE WHEN purchase.user_id IS NOT NULL 
    THEN 'True' 
    ELSE 'False' 
  END AS 'is_purchase'
FROM quiz
LEFT JOIN home_try_on
  ON quiz.user_id = home_try_on.user_id
LEFT JOIN purchase 
  ON quiz.user_id = purchase.user_id
GROUP BY quiz.user_id 
)
SELECT number_of_pairs, COUNT(*) AS 'count', SUM(is_purchase) as 'purchase', ROUND((1.0*SUM(is_purchase))/COUNT(*)*100,2) AS 'conversion_rate'
FROM results_table
WHERE is_home_try_on = 1
GROUP BY number_of_pairs;


-- Assuming every product has sold at least one unit, use the purchase table to get the current product offering
SELECT model_name, color
FROM purchase
WHERE style LIKE 'Women%'
GROUP BY model_name, color;


-- Changing around the format for the product offering to count by general color way
WITH product_offering AS (
  SELECT model_name, color
  FROM purchase
  WHERE style LIKE 'Women%'
  GROUP BY model_name, color
)
SELECT
  CASE 
    WHEN color LIKE '%Tortoise' THEN 'Tortoise'
    WHEN color LIKE '%Black' THEN 'Black'
    WHEN color LIKE '%Crystal' THEN 'Crystal'
    WHEN color LIKE '%Neutral' THEN 'Neutral'
    WHEN color LIKE '%Two-Tone' THEN 'Two-Tone'
    ELSE 'Other'
  END AS 'style_color',
COUNT(*) AS 'count'
FROM product_offering
GROUP BY 1;


-- Find color with the most interest from the quiz responses
SELECT color, COUNT(*) AS 'count'
FROM quiz
WHERE style LIKE 'Women%'
GROUP BY color
ORDER BY 2 DESC;