CREATE PROCEDURE uspRKSyncCommodityMarketAttribute
AS
DECLARE @List NVARCHAR(800)
SELECT @List= COALESCE(@List + CASE WHEN strCommodityAttributeId <> '' THEN ',' ELSE '' END, '') + LTRIM(strCommodityAttributeId) 
FROM tblRKCommodityMarketMapping WHERE strCommodityAttributeId is not null
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


