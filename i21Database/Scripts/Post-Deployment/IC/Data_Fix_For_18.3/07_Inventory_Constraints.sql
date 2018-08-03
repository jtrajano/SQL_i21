PRINT N'BEGIN - IC Data Fix for 18.3. #7'
GO

IF EXISTS (SELECT 1 FROM (SELECT TOP 1 dblVersion = CAST(LEFT(strVersionNo, 4) AS NUMERIC(18,1)) FROM tblSMBuildNumber ORDER BY intVersionID DESC) v WHERE v.dblVersion <= 18.3)
BEGIN 
	-- Add the CHECK CONSTRAINTS in tblICItemUOM
	IF NOT EXISTS(SELECT TOP 1 1 FROM sys.objects WHERE name = 'CK_ItemUOMId_IS_NOT_USED' AND type = 'C' AND parent_object_id = OBJECT_ID('tblICItemUOM', 'U'))
	BEGIN
		EXEC('
			ALTER TABLE tblICItemUOM
			WITH NOCHECK ADD CONSTRAINT CK_ItemUOMId_IS_NOT_USED
			CHECK (dbo.fnICCheckItemUOMIdIsNotUsed(intItemId, intItemUOMId, intUnitMeasureId, dblUnitQty) = 1)
		');

	END
	-- Add the Check Constraints in tblICItemLocation
	IF NOT EXISTS(SELECT TOP 1 1 FROM sys.objects WHERE name = 'CK_ItemLocation_IS_NOT_USED' AND type = 'C' AND parent_object_id = OBJECT_ID('tblICItemLocation', 'U'))
	BEGIN
		EXEC ('
			ALTER TABLE tblICItemLocation
			WITH NOCHECK ADD CONSTRAINT CK_ItemLocation_IS_NOT_USED
			CHECK (dbo.fnICCheckItemLocationIdIsNotUsed([intItemLocationId], [intLocationId]) = 1)
		')
	END
END

PRINT N'END - IC Data Fix for 18.3. #7'
GO