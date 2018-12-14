PRINT('ST Cleanup - Start')

----------------------------------------------------------------------------------------------------------------------------------
-- Start: Handheld Scanner Clean Up
----------------------------------------------------------------------------------------------------------------------------------
IF EXISTS(SELECT * FROM  INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'tblSTHandheldScanner') 
	BEGIN
		EXEC('
				IF EXISTS (SELECT TOP 1 1 FROM tblSTHandheldScanner)
					BEGIN
						DECLARE @intCountHandheld AS INT = (SELECT COUNT(intStoreId) FROM tblSTHandheldScanner)

						IF(@intCountHandheld > 1)
							BEGIN
								DECLARE @intStoreId AS INT
								DECLARE @intRecordCount AS INT
								DECLARE @intHandheldScannerId AS INT

								PRINT ''Removing extra Store Ids from tblSTHandheldScanner table''

								-- GET Store Ids
								DECLARE @tblStoreId AS TABLE
								(
									intStoreId INT
								)

								INSERT INTO @tblStoreId
								(
									intStoreId
								)
								SELECT DISTINCT 
									intStoreId
								FROM tblSTHandheldScanner



								-- Loop
								WHILE EXISTS (SELECT TOP (1) 1 FROM @tblStoreId)
									BEGIN
										SELECT TOP 1 @intStoreId = intStoreId FROM @tblStoreId
										SET @intRecordCount = (SELECT COUNT(intStoreId) FROM tblSTHandheldScanner WHERE intStoreId = @intStoreId)

										IF(@intRecordCount > 1)
											BEGIN
												SET @intHandheldScannerId = (SELECT TOP (1) intHandheldScannerId FROM tblSTHandheldScanner WHERE intStoreId = @intStoreId)

												DELETE FROM tblSTHandheldScanner
												WHERE intStoreId = @intStoreId
												AND intHandheldScannerId != @intHandheldScannerId
											END


										DELETE TOP (1) FROM @tblStoreId
									END

								PRINT ''Done removing extra Store Ids from tblSTHandheldScanner table''
							END
					END
			')
	END
----------------------------------------------------------------------------------------------------------------------------------
-- End: Handheld Scanner Clean Up
----------------------------------------------------------------------------------------------------------------------------------



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
IF EXISTS(SELECT * FROM  INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'tblSMImportFileHeader') 
BEGIN
	PRINT('Start: File Field Mapping Alter')
	EXEC
	('

		DECLARE @intImportFileHeaderId INT
		DECLARE @strLayoutTitle AS NVARCHAR(100)

		SET @strLayoutTitle = ''Passport - TLM''
		IF EXISTS(SELECT intImportFileHeaderId FROM tblSMImportFileHeader WHERE strLayoutTitle = @strLayoutTitle)
			BEGIN

				IF NOT EXISTS(SELECT intImportFileHeaderId FROM tblSMImportFileHeader WHERE strLayoutTitle = @strLayoutTitle + '' 3.3'')
					BEGIN
						SELECT @intImportFileHeaderId = intImportFileHeaderId FROM tblSMImportFileHeader WHERE strLayoutTitle = @strLayoutTitle

						-- ALTER
						UPDATE tblSMImportFileHeader
						SET strLayoutTitle = @strLayoutTitle + '' 3.3''
						WHERE strLayoutTitle = @strLayoutTitle
					END
			END

		SET @strLayoutTitle = ''Passport - MSM''
		IF EXISTS(SELECT intImportFileHeaderId FROM tblSMImportFileHeader WHERE strLayoutTitle = @strLayoutTitle)
			BEGIN
				
				IF NOT EXISTS(SELECT intImportFileHeaderId FROM tblSMImportFileHeader WHERE strLayoutTitle = @strLayoutTitle + '' 3.3'')
					BEGIN
						SELECT @intImportFileHeaderId = intImportFileHeaderId FROM tblSMImportFileHeader WHERE strLayoutTitle = @strLayoutTitle

						-- ALTER
						UPDATE tblSMImportFileHeader
						SET strLayoutTitle = @strLayoutTitle + '' 3.3''
						WHERE strLayoutTitle = @strLayoutTitle
					END

			END

		SET @strLayoutTitle = ''Passport - MCM''
		IF EXISTS(SELECT intImportFileHeaderId FROM tblSMImportFileHeader WHERE strLayoutTitle = @strLayoutTitle)
			BEGIN
				
				IF NOT EXISTS(SELECT intImportFileHeaderId FROM tblSMImportFileHeader WHERE strLayoutTitle = @strLayoutTitle + '' 3.3'')
					BEGIN
						SELECT @intImportFileHeaderId = intImportFileHeaderId FROM tblSMImportFileHeader WHERE strLayoutTitle = @strLayoutTitle

						-- ALTER
						UPDATE tblSMImportFileHeader
						SET strLayoutTitle = @strLayoutTitle + '' 3.3''
						WHERE strLayoutTitle = @strLayoutTitle
					END

			END

		SET @strLayoutTitle = ''Passport - FGM''
		IF EXISTS(SELECT intImportFileHeaderId FROM tblSMImportFileHeader WHERE strLayoutTitle = @strLayoutTitle)
			BEGIN
				
				IF NOT EXISTS(SELECT intImportFileHeaderId FROM tblSMImportFileHeader WHERE strLayoutTitle = @strLayoutTitle + '' 3.3'')
					BEGIN
						SELECT @intImportFileHeaderId = intImportFileHeaderId FROM tblSMImportFileHeader WHERE strLayoutTitle = @strLayoutTitle

						-- ALTER
						UPDATE tblSMImportFileHeader
						SET strLayoutTitle = @strLayoutTitle + '' 3.3''
						WHERE strLayoutTitle = @strLayoutTitle
					END

			END

		SET @strLayoutTitle = ''Passport - ISM''
		IF EXISTS(SELECT intImportFileHeaderId FROM tblSMImportFileHeader WHERE strLayoutTitle = @strLayoutTitle)
			BEGIN
			
				IF NOT EXISTS(SELECT intImportFileHeaderId FROM tblSMImportFileHeader WHERE strLayoutTitle = @strLayoutTitle + '' 3.3'')
					BEGIN
						SELECT @intImportFileHeaderId = intImportFileHeaderId FROM tblSMImportFileHeader WHERE strLayoutTitle = @strLayoutTitle

						-- ALTER
						UPDATE tblSMImportFileHeader
						SET strLayoutTitle = @strLayoutTitle + '' 3.3''
						WHERE strLayoutTitle = @strLayoutTitle
					END

			END
	')
	PRINT('End: File Field Mapping Alter')
END
----------------------------------------------------------------------------------------------------------------------------------
-- End: File Field Mapping Alter
----------------------------------------------------------------------------------------------------------------------------------





----------------------------------------------------------------------------------------------------------------------------------
-- Start: Delete tblSTStoreAppUploadHistory
----------------------------------------------------------------------------------------------------------------------------------
IF EXISTS(SELECT * FROM  INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'tblSTStoreAppUploadHistory') 
	BEGIN
		PRINT('Drop tblSTStoreAppUploadHistory')
		EXEC('
				DROP TABLE tblSTStoreAppUploadHistory
			')
	END
----------------------------------------------------------------------------------------------------------------------------------
-- End: Delete tblSTStoreAppUploadHistory
----------------------------------------------------------------------------------------------------------------------------------

PRINT('ST Cleanup - End')