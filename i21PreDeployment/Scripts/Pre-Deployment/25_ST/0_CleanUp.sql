PRINT('ST Cleanup - Start')

----------------------------------------------------------------------------------------------------------------------------------
-- Start: Mark Up/Down Clean Up
----------------------------------------------------------------------------------------------------------------------------------
IF EXISTS(SELECT * FROM  INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'tblSTMarkUpDownDetail') 
BEGIN
	IF EXISTS(SELECT * FROM  INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'tblSTMarkUpDownDetail' AND COLUMN_NAME = 'intItemId') 
		BEGIN
			PRINT('Altering tblSTMarkUpDownDetail Item Ids')
			EXEC('
					ALTER TABLE tblSTMarkUpDownDetail
					ALTER COLUMN intItemId INT NULL
				')

			PRINT('Updating tblSTMarkUpDownDetail Item Ids from 0 to Null')
			EXEC('
					UPDATE tblSTMarkUpDownDetail
					SET intItemId = NULL
					WHERE intItemId = 0
				')
		END

	IF EXISTS(SELECT * FROM  INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'tblSTMarkUpDownDetail' AND COLUMN_NAME = 'intCategoryId') 
		BEGIN
			PRINT('Altering tblSTMarkUpDownDetail Category Ids')
			EXEC('
					ALTER TABLE tblSTMarkUpDownDetail
					ALTER COLUMN intCategoryId INT NULL
				')

			PRINT('Updating tblSTMarkUpDownDetail Category Ids from 0 to Null')
			EXEC('
					UPDATE tblSTMarkUpDownDetail
					SET intCategoryId = NULL
					WHERE intCategoryId = 0
				')
		END
END
----------------------------------------------------------------------------------------------------------------------------------
-- End: Mark Up/Down Clean Up
----------------------------------------------------------------------------------------------------------------------------------




----------------------------------------------------------------------------------------------------------------------------------
-- Start: File Field Mapping Alter
----------------------------------------------------------------------------------------------------------------------------------
DECLARE @intImportFileHeaderId INT
DECLARE @strLayoutTitle AS NVARCHAR(100)

SET @strLayoutTitle = 'Passport - TLM'
IF EXISTS(SELECT intImportFileHeaderId FROM tblSMImportFileHeader WHERE strLayoutTitle = @strLayoutTitle)
	BEGIN
		SELECT @intImportFileHeaderId = intImportFileHeaderId FROM tblSMImportFileHeader WHERE strLayoutTitle = @strLayoutTitle

		-- ALTER
		UPDATE tblSMImportFileHeader
		SET strLayoutTitle = @strLayoutTitle + ' 3.3'
		WHERE strLayoutTitle = @strLayoutTitle
	END

SET @strLayoutTitle = 'Passport - MSM'
IF EXISTS(SELECT intImportFileHeaderId FROM tblSMImportFileHeader WHERE strLayoutTitle = @strLayoutTitle)
	BEGIN
		SELECT @intImportFileHeaderId = intImportFileHeaderId FROM tblSMImportFileHeader WHERE strLayoutTitle = @strLayoutTitle

		-- ALTER
		UPDATE tblSMImportFileHeader
		SET strLayoutTitle = @strLayoutTitle + ' 3.3'
		WHERE strLayoutTitle = @strLayoutTitle
	END

SET @strLayoutTitle = 'Passport - MCM'
IF EXISTS(SELECT intImportFileHeaderId FROM tblSMImportFileHeader WHERE strLayoutTitle = @strLayoutTitle)
	BEGIN
		SELECT @intImportFileHeaderId = intImportFileHeaderId FROM tblSMImportFileHeader WHERE strLayoutTitle = @strLayoutTitle

		-- ALTER
		UPDATE tblSMImportFileHeader
		SET strLayoutTitle = @strLayoutTitle + ' 3.3'
		WHERE strLayoutTitle = @strLayoutTitle
	END

SET @strLayoutTitle = 'Passport - FGM'
IF EXISTS(SELECT intImportFileHeaderId FROM tblSMImportFileHeader WHERE strLayoutTitle = @strLayoutTitle)
	BEGIN
		SELECT @intImportFileHeaderId = intImportFileHeaderId FROM tblSMImportFileHeader WHERE strLayoutTitle = @strLayoutTitle

		-- ALTER
		UPDATE tblSMImportFileHeader
		SET strLayoutTitle = @strLayoutTitle + ' 3.3'
		WHERE strLayoutTitle = @strLayoutTitle
	END

SET @strLayoutTitle = 'Passport - ISM'
IF EXISTS(SELECT intImportFileHeaderId FROM tblSMImportFileHeader WHERE strLayoutTitle = @strLayoutTitle)
	BEGIN
		SELECT @intImportFileHeaderId = intImportFileHeaderId FROM tblSMImportFileHeader WHERE strLayoutTitle = @strLayoutTitle

		-- ALTER
		UPDATE tblSMImportFileHeader
		SET strLayoutTitle = @strLayoutTitle + ' 3.3'
		WHERE strLayoutTitle = @strLayoutTitle
	END
----------------------------------------------------------------------------------------------------------------------------------
-- End: File Field Mapping Alter
----------------------------------------------------------------------------------------------------------------------------------


PRINT('ST Cleanup - End')