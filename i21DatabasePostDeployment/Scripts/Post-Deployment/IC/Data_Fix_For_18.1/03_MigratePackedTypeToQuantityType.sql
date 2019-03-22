PRINT N'BEGIN - IC Data Fix for 18.1. #3'
GO

IF EXISTS (SELECT 1 FROM (SELECT TOP 1 dblVersion = CAST(LEFT(strVersionNo, 4) AS NUMERIC(18,1)) FROM tblSMBuildNumber ORDER BY intVersionID DESC) v WHERE v.dblVersion <= 18.1)
BEGIN 
	UPDATE tblICUnitMeasure
	SET strUnitType = 'Quantity'
	WHERE strUnitType = 'Packed'
END 

GO
PRINT N'END - IC Data Fix for 18.1. #3'
GO 