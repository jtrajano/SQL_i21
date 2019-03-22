CREATE PROCEDURE [dbo].[uspMFGetItemNutrients]
	@strItemIds NVARCHAR(MAX)
AS

Select p.intProductValueId AS intItemId,pp.intPropertyId,vp.dblMinValue AS dblValue
From tblQMProduct p 
Join tblQMProductProperty pp on p.intProductId=pp.intProductId
Join tblQMProductPropertyValidityPeriod vp on pp.intProductPropertyId=vp.intProductPropertyId
Where p.intProductValueId in (Select * from dbo.[fnCommaSeparatedValueToTable](@strItemIds)) AND p.intProductTypeId=2