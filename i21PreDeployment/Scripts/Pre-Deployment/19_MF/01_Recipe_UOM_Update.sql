--Update intUnitMeasureId to intItemUOMId in Recipe and WorkOrderRecipe tables

IF EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE name = 'intUOMId' AND object_id = object_id('tblMFRecipe'))
BEGIN
	IF EXISTS (SELECT * 
	  FROM sys.foreign_keys 
	   WHERE object_id = OBJECT_ID(N'FK_tblMFRecipe_tblICUnitMeasure_intUnitMeasureId_intUOMId')
	   AND parent_object_id = OBJECT_ID(N'tblMFRecipe')
	)
	BEGIN
		EXEC('ALTER TABLE [tblMFRecipe] DROP CONSTRAINT [FK_tblMFRecipe_tblICUnitMeasure_intUnitMeasureId_intUOMId]')

		EXEC('Update r Set r.intUOMId=iu.intItemUOMId 
		From tblMFRecipe r 
		Join tblICItemUOM iu on r.intItemId=iu.intItemId And r.intUOMId=iu.intUnitMeasureId')
	END
END
GO
IF EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE name = 'intUOMId' AND object_id = object_id('tblMFRecipeItem'))
BEGIN
	IF EXISTS (SELECT * 
	  FROM sys.foreign_keys 
	   WHERE object_id = OBJECT_ID(N'FK_tblMFRecipeItem_tblICUnitMeasure_intUnitMeasureId_intStandardUOMId')
	   AND parent_object_id = OBJECT_ID(N'tblMFRecipeItem')
	)
	BEGIN
		EXEC('ALTER TABLE [tblMFRecipeItem] DROP CONSTRAINT [FK_tblMFRecipeItem_tblICUnitMeasure_intUnitMeasureId_intStandardUOMId]')

		EXEC('Update ri Set ri.intUOMId=iu.intItemUOMId 
		From tblMFRecipeItem ri 
		Join tblICItemUOM iu on ri.intItemId=iu.intItemId And ri.intUOMId=iu.intUnitMeasureId')
	END
END
GO
IF EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE name = 'intUOMId' AND object_id = object_id('tblMFRecipeSubstituteItem'))
BEGIN
	IF EXISTS (SELECT * 
	  FROM sys.foreign_keys 
	   WHERE object_id = OBJECT_ID(N'FK_tblMFRecipeSubstituteItem_tblICUnitMeasure_intUnitMeasureId_intUOMId')
	   AND parent_object_id = OBJECT_ID(N'tblMFRecipeSubstituteItem')
	)
	BEGIN
		EXEC('ALTER TABLE [tblMFRecipeSubstituteItem] DROP CONSTRAINT [FK_tblMFRecipeSubstituteItem_tblICUnitMeasure_intUnitMeasureId_intUOMId]')

		EXEC('Update rs Set rs.intUOMId=iu.intItemUOMId 
		From tblMFRecipeSubstituteItem rs 
		Join tblICItemUOM iu on rs.intItemId=iu.intItemId And rs.intUOMId=iu.intUnitMeasureId')
	END
END
GO
IF EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE name = 'intUOMId' AND object_id = object_id('tblMFWorkOrderRecipe'))
BEGIN
	IF EXISTS (SELECT * 
	  FROM sys.foreign_keys 
	   WHERE object_id = OBJECT_ID(N'FK_tblMFWorkOrderRecipe_tblICUnitMeasure_intUnitMeasureId_intUOMId')
	   AND parent_object_id = OBJECT_ID(N'tblMFWorkOrderRecipe')
	)
	BEGIN
		EXEC('ALTER TABLE [tblMFWorkOrderRecipe] DROP CONSTRAINT [FK_tblMFWorkOrderRecipe_tblICUnitMeasure_intUnitMeasureId_intUOMId]')

		EXEC('Update r Set r.intUOMId=iu.intItemUOMId 
		From tblMFWorkOrderRecipe r 
		Join tblICItemUOM iu on r.intItemId=iu.intItemId And r.intUOMId=iu.intUnitMeasureId')
	END
END
GO
IF EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE name = 'intUOMId' AND object_id = object_id('tblMFWorkOrderRecipeItem'))
BEGIN
	IF EXISTS (SELECT * 
	  FROM sys.foreign_keys 
	   WHERE object_id = OBJECT_ID(N'FK_tblMFWorkOrderRecipeItem_tblICUnitMeasure_intUnitMeasureId_intStandardUOMId')
	   AND parent_object_id = OBJECT_ID(N'tblMFWorkOrderRecipeItem')
	)
	BEGIN
		EXEC('ALTER TABLE [tblMFWorkOrderRecipeItem] DROP CONSTRAINT [FK_tblMFWorkOrderRecipeItem_tblICUnitMeasure_intUnitMeasureId_intStandardUOMId]')

		EXEC('Update ri Set ri.intUOMId=iu.intItemUOMId 
		From tblMFWorkOrderRecipeItem ri 
		Join tblICItemUOM iu on ri.intItemId=iu.intItemId And ri.intUOMId=iu.intUnitMeasureId')
	END
END
GO
IF EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE name = 'intUOMId' AND object_id = object_id('tblMFWorkOrderRecipeSubstituteItem'))
BEGIN
	IF EXISTS (SELECT * 
	  FROM sys.foreign_keys 
	   WHERE object_id = OBJECT_ID(N'FK_tblMFWorkOrderRecipeSubstituteItem_tblICUnitMeasure_intUnitMeasureId_intUOMId')
	   AND parent_object_id = OBJECT_ID(N'tblMFWorkOrderRecipeSubstituteItem')
	)
	BEGIN
		EXEC('ALTER TABLE [tblMFWorkOrderRecipeSubstituteItem] DROP CONSTRAINT [FK_tblMFWorkOrderRecipeSubstituteItem_tblICUnitMeasure_intUnitMeasureId_intUOMId]')

		EXEC('Update rs Set rs.intUOMId=iu.intItemUOMId 
		From tblMFWorkOrderRecipeSubstituteItem rs 
		Join tblICItemUOM iu on rs.intItemId=iu.intItemId And rs.intUOMId=iu.intUnitMeasureId')
	END
END
GO
