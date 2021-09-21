CREATE PROCEDURE [dbo].[uspSTUpdateModifier]
	@UDTItemUOMModifier StoreItemUOMModifier READONLY,
	@intItemId AS INT,
	@strFamily AS VARCHAR(100),
	@strClass AS VARCHAR(100)
AS

BEGIN
	--Merge Modifier to UOM 
	--To Sync on Item Quick Entry screen 
	MERGE	
		INTO	dbo.tblSTModifier 
		WITH	(HOLDLOCK) 
		AS		modifier	
		USING (
			SELECT	* FROM @UDTItemUOMModifier
		) AS Source_Query  
			ON modifier.intItemUOMId = (SELECT TOP 1 intItemUOMId 
										FROM tblICItemUOM uom
											JOIN tblICUnitMeasure um
											ON uom.intUnitMeasureId = um.intUnitMeasureId
										WHERE intItemId = Source_Query.intItemId 
											AND strUnitMeasure = Source_Query.strUnitMeasure)
		WHEN MATCHED THEN 
			UPDATE 
			SET		intModifier = Source_Query.intModifier
					,dblModifierQuantity = Source_Query.dblModifierQuantity
					,dblModifierPrice = Source_Query.dblModifierPrice
						
		WHEN NOT MATCHED THEN 
			INSERT (
				intItemUOMId
				, intModifier
				, dblModifierQuantity
				, dblModifierPrice
				, intConcurrencyId
			)
			VALUES (
				(SELECT TOP 1 intItemUOMId 
										FROM tblICItemUOM uom
											JOIN tblICUnitMeasure um
											ON uom.intUnitMeasureId = um.intUnitMeasureId
										WHERE intItemId = Source_Query.intItemId 
											AND strUnitMeasure = Source_Query.strUnitMeasure)
				, Source_Query.intModifier
				, Source_Query.dblModifierQuantity
				, Source_Query.dblModifierPrice
				, 1
			);

	--Merge Family and Class to item Location 
	--To Sync on Item Quick Entry screen 
	--This will update all location Family and Class from what is selected on Item Quick Entry screen
	UPDATE tblICItemLocation
	SET intFamilyId = CASE WHEN @strFamily = '' THEN null ELSE (SELECT intSubcategoryId 
																	FROM tblSTSubcategory 
																	WHERE strSubcategoryType = 'F'
																	AND strSubcategoryId = @strFamily) END,
		intClassId = CASE WHEN @strClass = '' THEN null ELSE (SELECT intSubcategoryId 
																	FROM tblSTSubcategory 
																	WHERE strSubcategoryType = 'C'
																	AND strSubcategoryId = @strClass) END
	WHERE intItemId = @intItemId

END
			