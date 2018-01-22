PRINT N'BEGIN - Migration for UOM > Packed Type to Quantity Type'
GO

UPDATE tblICUnitMeasure
SET strUnitType = 'Quantity'
WHERE strUnitType = 'Packed'

GO
PRINT N'END - Migration for UOM > Packed Type to Quantity Type'