PRINT N'START- IC Add Constraint'
GO

-- Add the CHECK CONSTRAINTS in tblICItem 
IF NOT EXISTS(SELECT TOP 1 1 FROM sys.objects WHERE name = 'CK_AllowLotTrackingChange' AND type = 'C' AND parent_object_id = OBJECT_ID('tblICItem', 'U'))
BEGIN
	EXEC('
		ALTER TABLE tblICItem
		WITH NOCHECK ADD CONSTRAINT CK_AllowLotTrackingChange
		CHECK (dbo.fnAllowLotTrackingToChange(intItemId, strLotTracking) = 1)'
	);

END
GO 

-- Add a UNIQUE CONSTRAINT for tblICUnitMeasureConversion
IF NOT EXISTS(SELECT TOP 1 1 FROM sys.objects WHERE name = 'UC_tblICUnitMeasureConversion' AND type = 'UQ' AND parent_object_id = OBJECT_ID('tblICUnitMeasureConversion', 'U'))
BEGIN
	-- Remove the duplicate conversions
	EXEC('
		WITH CTE AS (
			SELECT	intUnitMeasureConversionId
					,intUnitMeasureId
					,rn = ROW_NUMBER() OVER (PARTITION BY intUnitMeasureId, intStockUnitMeasureId ORDER BY intUnitMeasureConversionId)
			FROM	tblICUnitMeasureConversion	 
		)
		DELETE FROM CTE WHERE rn > 1
	')

	-- Add the unique constraint 
	EXEC('
		ALTER TABLE tblICUnitMeasureConversion
		ADD CONSTRAINT UC_tblICUnitMeasureConversion UNIQUE (intUnitMeasureId, intStockUnitMeasureId);
		'
	);

END
GO

GO

-- Add the CHECK CONSTRAINTS in tblICItem
IF NOT EXISTS(SELECT TOP 1 1 FROM sys.objects WHERE name = 'CK_AllowItemTypeChange' AND type = 'C' AND parent_object_id = OBJECT_ID('tblICItem', 'U'))
BEGIN
	EXEC('
		ALTER TABLE tblICItem
		WITH NOCHECK ADD CONSTRAINT CK_AllowItemTypeChange
		CHECK (dbo.fnAllowItemTypeChange(intItemId, strType) = 1)'
	);

END

PRINT N'END - IC Add Constraint'
GO