USE customerbehavior

SELECT * FROM cleanedcustomerbehavior

DELIMITER //
CREATE PROCEDURE CustomerBehavior()
	BEGIN
		SELECT * FROM cleanedcustomerbehavior;
	END //
DELIMITER ;

SELECT `Promo Code Used`, AVG(`Purchase Amount`) AS AverageAmount
FROM cleanedcustomerbehavior
GROUP BY `Promo Code Used`

SELECT `Customer ID`,
	AVG(`Purchase Amount`) OVER (PARTITION BY `Customer ID`) AS AverageAmount
FROM cleanedcustomerbehavior
GROUP BY `Customer ID`

WITH customer_stats AS (
    SELECT 
        `Customer ID`,
        `Purchase Amount`,
        AVG(`Purchase Amount`) OVER() AS Overall_Average,
        AVG(`Purchase Amount`) OVER(PARTITION BY `Customer ID`) AS Customer_Average,
        SUM(`Purchase Amount`) OVER(PARTITION BY `Customer ID`) AS Total_Spend
    FROM cleanedcustomerbehavior
),
filtered_customers AS (
	SELECT 
		DISTINCT `Customer ID`,
        Customer_Average,
        Total_Spend
        FROM customer_stats
        WHERE Customer_Average > Overall_Average
),
ranked_customers AS (
		SELECT *,
			DENSE_RANK() OVER (ORDER BY Total_Spend DESC) AS Spending_Rank
		FROM filtered_customers
)
SELECT * FROM ranked_customers
ORDER BY Spending_Rank