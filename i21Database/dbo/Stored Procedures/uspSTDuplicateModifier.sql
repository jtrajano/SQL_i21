CREATE PROCEDURE [dbo].[uspSTDuplicateModifier]
	@intOldItemId AS INT,
	@intNewItemId AS INT
AS

BEGIN
	INSERT INTO tblSTModifier
	(
		intItemUOMId
		, intModifier
		, dblModifierQuantity
		, dblModifierPrice
		, intConcurrencyId
	)
	SELECT 
		newUOM.intItemUOMId
		, intModifier
		, dblModifierQuantity
		, dblModifierPrice
		, 1
	FROM (SELECT uom.intItemUOMId, uom.intItemId, uom.intUnitMeasureId 
		  FROM tblICItemUOM uom
		  WHERE uom.intItemId = @intOldItemId
		  ) oldUOM
	JOIN (SELECT uom.intItemUOMId, uom.intItemId, uom.intUnitMeasureId 
		  FROM tblICItemUOM uom
		  WHERE uom.intItemId = @intNewItemId
		  ) newUOM
		ON oldUOM.intUnitMeasureId = newUOM.intUnitMeasureId 
	JOIN tblSTModifier md
		ON oldUOM.intItemUOMId = md.intItemUOMId 

END
			