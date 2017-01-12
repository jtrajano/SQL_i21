CREATE PROC uspRKConvertProductType
	 @strCommodityAttributeId nvarchar(max)
AS

DECLARE @List VARCHAR(8000)
SELECT @List=COALESCE(@List + ',', '')+ltrim(intCommodityAttributeId) from tblICCommodityAttribute 
WHERE strDescription IN(select Ltrim(rtrim(Item)) Collate Latin1_General_CI_AS from [dbo].[fnSplitString](@strCommodityAttributeId, ',')) and strType= 'ProductType'

SELECT @List