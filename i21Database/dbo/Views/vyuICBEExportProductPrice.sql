CREATE VIEW [dbo].[vyuICBEExportProductPrice]  
AS 

SELECT 
	 ID = intItemId
	 ,name = strShortName
	 ,perUnit = dblStandardCost
FROM vyuICGetItemPricing
GO