GO
PRINT N'BEGIN - STORE Item Movement Data Fix for Gross Sales = NULL'
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
PRINT N'END - STORE - Item Movement Data Fix for Gross Sales = NULL'

----------------------------------------------------------------------------------------------------------------------------------
-- [START]: Update tblSTRegister.ysnTransctionLog to tblSTRegisterFileConfiguration.ysnActive
----------------------------------------------------------------------------------------------------------------------------------
IF EXISTS(
			SELECT TOP 1 1
			FROM tblSTRegisterFileConfiguration fc
			INNER JOIN tblSTRegister r
				ON fc.intRegisterId = r.intRegisterId
			WHERE r.strRegisterClass = N'SAPPHIRE/COMMANDER'
				AND fc.strFileType = N'Inbound'
				AND fc.strFilePrefix = N'vtransset-tlog'
				AND ISNULL(r.ysnTransctionLog, 0) != ISNULL(fc.ysnActive, 0)
		 )
	BEGIN

		UPDATE r
			SET r.ysnTransctionLog = ISNULL(fc.ysnActive, 0)
		FROM tblSTRegisterFileConfiguration fc
		INNER JOIN tblSTRegister r
			ON fc.intRegisterId = r.intRegisterId
		WHERE r.strRegisterClass = N'SAPPHIRE/COMMANDER'
			AND fc.strFileType = N'Inbound'
			AND fc.strFilePrefix = N'vtransset-tlog'
			AND ISNULL(r.ysnTransctionLog, 0) != ISNULL(fc.ysnActive, 0)

	END
----------------------------------------------------------------------------------------------------------------------------------
-- [END]: Update tblSTRegister.ysnTransctionLog to tblSTRegisterFileConfiguration.ysnActive
----------------------------------------------------------------------------------------------------------------------------------

GO