CREATE PROCEDURE [dbo].[uspApiSchemaTransformRecipeFinalize]
AS

--Default Configuration for Blending Process 

--Add Factory to Items that has Recipe 
Insert Into tblICItemFactory(intItemId,intFactoryId,ysnDefault)
Select i.intItemId,cl.intCompanyLocationId,1
From (Select distinct i.intItemId From tblICItem i join tblMFRecipe r on i.intItemId=r.intItemId
Join tblMFManufacturingProcess mp on r.intManufacturingProcessId=mp.intManufacturingProcessId AND mp.intAttributeTypeId=2) i 
Cross Join tblSMCompanyLocation cl
Where 
CONVERT(varchar(200),cl.intCompanyLocationId) + CONVERT(varchar(200),i.intItemId) 
not in (Select CONVERT(varchar(200),intFactoryId) + CONVERT(varchar(200),intItemId) From tblICItemFactory)

--Add Cell to Items that has Recipe 
Insert Into tblICItemFactoryManufacturingCell(intItemFactoryId,intManufacturingCellId,ysnDefault)
Select ifc.intItemFactoryId,mc.intManufacturingCellId,1
From tblICItemFactory ifc 
join tblMFManufacturingCell mc on ifc.intFactoryId=mc.intLocationId AND mc.strCellName='Default'
Where intItemFactoryId
not in (Select intItemFactoryId From tblICItemFactoryManufacturingCell)

--Update PackType in Blend Items 
Update i
Set i.intPackTypeId=(Select TOP 1 intPackTypeId From tblMFPackType Where strPackName='Default')
From tblICItem i join tblMFRecipe r on i.intItemId=r.intItemId
Join tblMFManufacturingProcess mp on r.intManufacturingProcessId=mp.intManufacturingProcessId AND mp.intAttributeTypeId=2
Where i.intPackTypeId is null