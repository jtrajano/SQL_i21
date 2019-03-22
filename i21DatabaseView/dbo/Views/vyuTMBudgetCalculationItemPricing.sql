CREATE VIEW [dbo].[vyuTMBudgetCalculationItemPricing]  
AS 

SELECT
	A.*
	,strItemNumber = B.strItemNo
FROM dbo.tblTMBudgetCalculationItemPricing A
INNER JOIN tblICItem B
	ON A.intItemId = B.intItemId
		
GO