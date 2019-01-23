PRINT N'BEGIN - STORE Item Movement Data Fix for Gross Sales = NULL'
GO

IF EXISTS(SELECT * FROM  INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'tblSTCheckoutItemMovements' AND COLUMN_NAME = 'dblGrossSales') 
	BEGIN
		EXEC('
				IF EXISTS(SELECT TOP 1 1 FROM tblSTCheckoutItemMovements WHERE dblGrossSales IS NULL)
					BEGIN
						PRINT ''Updating Item Movement Gross sales amount that is = NULL''

						UPDATE tblSTCheckoutItemMovements
						SET dblGrossSales = (dblCurrentPrice * intQtySold)
						WHERE dblGrossSales IS NULL
					END
			')
	END

GO
PRINT N'END - STORE - Item Movement Data Fix for Gross Sales = NULL'
GO