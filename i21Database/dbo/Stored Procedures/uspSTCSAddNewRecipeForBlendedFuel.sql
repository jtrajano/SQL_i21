CREATE PROCEDURE [dbo].[uspSTCSAddNewRecipeForBlendedFuel]
	@intStoreId		INT
AS
BEGIN
	DECLARE		@ysnAutoBlend BIT = 0

	SELECT		@ysnAutoBlend = 1
	FROM		tblSTPumpItem a
	INNER JOIN	tblICItemUOM b
	ON			a.intItemUOMId = b.intItemUOMId
	INNER JOIN	tblICItem c
	ON			b.intItemId = c.intItemId
	WHERE		a.intStoreId = @intStoreId AND
				c.ysnAutoBlend = 1
	
	IF @ysnAutoBlend = 1
	BEGIN
		Insert Into tblICItemFactory(intItemId,intFactoryId,ysnDefault)
		Select i.intItemId,cl.intCompanyLocationId,1
		From (Select distinct i.intItemId From tblICItem i join tblMFRecipe r on i.intItemId=r.intItemId
		Join tblMFManufacturingProcess mp on r.intManufacturingProcessId=mp.intManufacturingProcessId AND mp.intAttributeTypeId=2) i 
		Cross Join tblSMCompanyLocation cl
		Where 
		CONVERT(varchar(200),cl.intCompanyLocationId) + CONVERT(varchar(200),i.intItemId) 
		not in (Select CONVERT(varchar(200),intFactoryId) + CONVERT(varchar(200),intItemId) From tblICItemFactory)

		Insert Into tblICItemFactoryManufacturingCell(intItemFactoryId,intManufacturingCellId,ysnDefault)
		Select ifc.intItemFactoryId,mc.intManufacturingCellId,1
		From tblICItemFactory ifc 
		join tblMFManufacturingCell mc on ifc.intFactoryId=mc.intLocationId AND mc.strCellName='Default'
		Where intItemFactoryId
		not in (Select intItemFactoryId From tblICItemFactoryManufacturingCell)
	END	
END