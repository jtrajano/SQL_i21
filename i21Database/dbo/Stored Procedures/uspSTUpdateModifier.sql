CREATE PROCEDURE [dbo].[uspSTUpdateModifier]
	@UDTItemUOMModifier StoreItemUOMModifier READONLY,
	@intItemId AS INT,
	@intFamilyId AS INT,
	@intClassId AS INT
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
	SET intFamilyId = CASE WHEN @intFamilyId = 0 THEN intFamilyId ELSE @intFamilyId END,
		intClassId = CASE WHEN @intClassId = 0 THEN intClassId ELSE @intClassId END

END
			