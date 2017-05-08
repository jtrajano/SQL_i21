DECLARE @tblRemovedCategory TABLE (strName NVARCHAR(50) COLLATE Latin1_General_CI_AS)
INSERT INTO @tblRemovedCategory(strName)
SELECT'Begin Inventory'					COLLATE Latin1_General_CI_AS UNION 
SELECT 'Broker Expense'					COLLATE Latin1_General_CI_AS UNION 
SELECT 'Cash Over/Short'				COLLATE Latin1_General_CI_AS UNION
SELECT 'Contract Equity'				COLLATE Latin1_General_CI_AS UNION
SELECT 'Contract Purchase Gain/Loss'	COLLATE Latin1_General_CI_AS UNION
SELECT 'Contract Sales Gain/Loss'		COLLATE Latin1_General_CI_AS UNION
SELECT 'Credit Card Fee'				COLLATE Latin1_General_CI_AS UNION
SELECT 'Currency Equity'				COLLATE Latin1_General_CI_AS UNION
SELECT 'Currency Purchase Gain/Loss'	COLLATE Latin1_General_CI_AS UNION
SELECT 'Currency Sales Gain/Loss'		COLLATE Latin1_General_CI_AS UNION
SELECT 'Deferred Payable'				COLLATE Latin1_General_CI_AS UNION
SELECT 'Deposit Account'				COLLATE Latin1_General_CI_AS UNION
SELECT 'End Inventory'					COLLATE Latin1_General_CI_AS UNION
SELECT 'Fee Income'						COLLATE Latin1_General_CI_AS UNION
SELECT 'Freight AP Account'				COLLATE Latin1_General_CI_AS UNION
SELECT 'Freight Expenses'				COLLATE Latin1_General_CI_AS UNION
SELECT 'Freight Income'					COLLATE Latin1_General_CI_AS UNION
SELECT 'Interest Expense'				COLLATE Latin1_General_CI_AS UNION 
SELECT 'Options Expense'				COLLATE Latin1_General_CI_AS UNION
SELECT 'Options Income'					COLLATE Latin1_General_CI_AS UNION
SELECT 'Purchase Account'				COLLATE Latin1_General_CI_AS UNION
SELECT 'Revalue Sold'					COLLATE Latin1_General_CI_AS UNION 
SELECT 'Sales Adv Account'				COLLATE Latin1_General_CI_AS UNION 
SELECT'Storage Expense'					COLLATE Latin1_General_CI_AS UNION 
SELECT'Storage Income'					COLLATE Latin1_General_CI_AS UNION 
SELECT 'Storage Receivable'				COLLATE Latin1_General_CI_AS UNION 
SELECT'Variance Account'				COLLATE Latin1_General_CI_AS UNION 
SELECT'Write-Off Sold'					COLLATE Latin1_General_CI_AS UNION 
SELECT 'Fee Expense'					COLLATE Latin1_General_CI_AS UNION
SELECT 'Auto-Variance'					COLLATE Latin1_General_CI_AS UNION
SELECT 'Work In Progress'				COLLATE Latin1_General_CI_AS 

IF(EXISTS(SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'tblGLAccountCategory') AND EXISTS(SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'tblICCategoryAccount'))
BEGIN
DELETE a
FROM tblGLAccountCategory ac
	INNER JOIN @tblRemovedCategory rc ON rc.strName = ac.strAccountCategory
	INNER JOIN tblICCategoryAccount a ON a.intAccountCategoryId = ac.intAccountCategoryId
END

IF(EXISTS(SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'tblGLAccountCategory') AND EXISTS(SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'tblICItemAccount'))
BEGIN
DELETE a
FROM tblGLAccountCategory ac
	INNER JOIN @tblRemovedCategory rc ON rc.strName = ac.strAccountCategory
	INNER JOIN tblICItemAccount a ON a.intAccountCategoryId = ac.intAccountCategoryId
END