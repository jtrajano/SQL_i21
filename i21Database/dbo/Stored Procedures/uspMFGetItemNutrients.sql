CREATE PROCEDURE [dbo].[uspMFGetItemNutrients]
	@intItemId int
AS

Select p.intProductValueId AS intItemId,pp.intPropertyId,vp.dblMinValue AS dblValue
From tblQMProduct p 
Join tblQMProductProperty pp on p.intProductId=pp.intProductId
Join tblQMProductPropertyValidityPeriod vp on pp.intProductPropertyId=vp.intProductPropertyId
Where p.intProductValueId=@intItemId AND p.intProductTypeId=2