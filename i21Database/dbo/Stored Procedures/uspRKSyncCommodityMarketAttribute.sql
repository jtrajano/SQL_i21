CREATE PROCEDURE [dbo].[uspRKSyncCommodityMarketAttribute]
AS
DECLARE @List NVARCHAR(800)
;WITH CommaTrimmed AS (
	SELECT 
	CASE when right(RTRIM(strCommodityAttributeId),1) = ',' then SUBSTRING(RTRIM(strCommodityAttributeId),1,LEN(RTRIM(strCommodityAttributeId))-1)
	ELSE strCommodityAttributeId END strCommodityAttributeId
	FROM tblRKCommodityMarketMapping WHERE strCommodityAttributeId is not null
)
SELECT @List= COALESCE(@List + CASE WHEN strCommodityAttributeId <> '' THEN ',' ELSE '' END, '') + LTRIM(strCommodityAttributeId) 
FROM CommaTrimmed 
MERGE INTO tblRKCommodityMarketMappingAttribute
WITH (HOLDLOCK)
AS RMAttributeTable
USING(
	select Value from dbo.[fnICSplitStringToTable](@List,',') WHERE Value is not null
) AS Source
ON 
RMAttributeTable.intCommodityAttributeId = Source.Value
WHEN NOT MATCHED BY Target
THEN INSERT (intCommodityAttributeId) VALUES(Source.Value)
WHEN NOT MATCHED BY SOURCE THEN DELETE;

