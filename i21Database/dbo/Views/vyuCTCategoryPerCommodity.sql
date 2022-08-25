CREATE VIEW [dbo].[vyuCTCategoryPerCommodity]
AS 
	 SELECT DISTINCT 
			strCategory as strCategoryCode, 
			intCategoryId,
			ISNULL(intCommodityId,0) AS intCommodityId,
			strCommodity
     FROM [dbo].[vyuICSearchItem] AS [Extent1]
        WHERE ( NOT ((N'Bundle' = [Extent1].[strType]) 
		AND ([Extent1].[strType] IS NOT NULL)))		

GO