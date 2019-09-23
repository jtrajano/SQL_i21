﻿PRINT('')
PRINT('*** ST Cleanup - Start ***')

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
-- Start: Rename tblSTStoreAppUploadHistory
----------------------------------------------------------------------------------------------------------------------------------
IF EXISTS(SELECT TOP 1 1 FROM  INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'tblSTStoreAppUploadHistory') 
	BEGIN
		
		IF NOT EXISTS(SELECT TOP 1 1 FROM  INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'tblSTStoreAppHistoryReports')
			BEGIN
				PRINT('Rename tblSTStoreAppUploadHistory to tblSTStoreAppHistoryReports')
				EXEC('
						EXEC sp_rename ''dbo.tblSTStoreAppUploadHistory'', ''tblSTStoreAppHistoryReports''
					')

				PRINT('Rename tblSTStoreAppHistoryReports.stri21FolderPath to tblSTStoreAppHistoryReports.strServerFolderPath')
				EXEC('
						EXEC sp_rename ''tblSTStoreAppHistoryReports.stri21FolderPath'' , ''strServerFolderPath'', ''COLUMN''
					')

				PRINT('Rename tblSTStoreAppHistoryReports.stri21ConvertedFilename to tblSTStoreAppHistoryReports.strServerFilename')
				EXEC('
						EXEC sp_rename ''tblSTStoreAppHistoryReports.stri21ConvertedFilename'' , ''strServerFilename'', ''COLUMN''
					')
			END

	END
----------------------------------------------------------------------------------------------------------------------------------
-- End: Rename tblSTStoreAppUploadHistory
----------------------------------------------------------------------------------------------------------------------------------




----------------------------------------------------------------------------------------------------------------------------------
-- Start: tblSTCheckoutMarkUpDowns Clean Up
----------------------------------------------------------------------------------------------------------------------------------
IF EXISTS(SELECT TOP 1 1 FROM  INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'tblSTCheckoutMarkUpDowns') 
	BEGIN
		EXEC('
				IF EXISTS(SELECT TOP 1 1 FROM tblSTCheckoutMarkUpDowns
						  WHERE dblRetailUnit IS NULL
							AND dblAmount IS NULL
							AND dblShrink IS NULL
							AND strUpDownNotes IS NULL)
					BEGIN
						DELETE FROM tblSTCheckoutMarkUpDowns
						WHERE dblRetailUnit IS NULL
							AND dblAmount IS NULL
							AND dblShrink IS NULL
							AND strUpDownNotes IS NULL
					END
			')
	END
----------------------------------------------------------------------------------------------------------------------------------
-- End: tblSTCheckoutMarkUpDowns Clean Up
----------------------------------------------------------------------------------------------------------------------------------





----------------------------------------------------------------------------------------------------------------------------------
-- Start: Preview and Report table Clean Up 
----------------------------------------------------------------------------------------------------------------------------------
IF EXISTS(SELECT TOP 1 1 FROM  INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'tblSTUpdateItemDataPreview') 
	BEGIN
		PRINT(N'Remove all records from tblSTUpdateItemDataPreview')
		EXEC('
				DELETE FROM tblSTUpdateItemDataPreview
			')
	END

IF EXISTS(SELECT TOP 1 1 FROM  INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'tblSTUpdateItemPricingPreview') 
	BEGIN
		PRINT(N'Remove all records from tblSTUpdateItemPricingPreview')
		EXEC('
				DELETE FROM tblSTUpdateItemPricingPreview
			')
	END

IF EXISTS(SELECT TOP 1 1 FROM  INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'tblSTUpdateRebateOrDiscountPreview') 
	BEGIN
		PRINT(N'Remove all records from tblSTUpdateRebateOrDiscountPreview')
		EXEC('
				DELETE FROM tblSTUpdateRebateOrDiscountPreview
			')
	END
	
IF EXISTS(SELECT TOP 1 1 FROM  INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'tblSTUpdateRegisterItemReport') 
	BEGIN
		PRINT(N'Remove all records from tblSTUpdateRegisterItemReport')
		EXEC('
				DELETE FROM tblSTUpdateRegisterItemReport
			')
	END
----------------------------------------------------------------------------------------------------------------------------------
-- End: Preview and Report table Clean Up
----------------------------------------------------------------------------------------------------------------------------------





-- ===============================================================================================================================
-- [START] Drop tables
-- ===============================================================================================================================
IF EXISTS(SELECT TOP 1 1 FROM  INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'tblSTStoreGLAccount') 
	BEGIN
		PRINT(N'Drop table tblSTStoreGLAccount')
		EXEC('
				DROP TABLE tblSTStoreGLAccount
			')
	END

IF EXISTS(SELECT * FROM  INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'tblSTUpdateItemDataRevertHolder') 
	BEGIN
		PRINT(N'Drop table tblSTUpdateItemDataRevertHolder')
		EXEC('
				DROP TABLE tblSTUpdateItemDataRevertHolder
			')
	END
-- ===============================================================================================================================
-- [START] Drop tables
-- ===============================================================================================================================





----------------------------------------------------------------------------------------------------------------------------------
-- Start: Rename Commander - Trans Log to Commander - Transaction Log Rebates
----------------------------------------------------------------------------------------------------------------------------------
IF EXISTS(SELECT * FROM  INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'tblSMImportFileHeader') 
	BEGIN
		IF EXISTS(SELECT TOP 1 1 FROM tblSMImportFileHeader WHERE strLayoutTitle = 'Commander - Trans Log') 
			AND NOT EXISTS(SELECT TOP 1 1 FROM tblSMImportFileHeader WHERE strLayoutTitle = 'Commander - Transaction Log Rebate')
			BEGIN
				PRINT(N'Renaming Commander - Trans Log	to	Commander - Transaction Log Rebate')
				EXEC('
						UPDATE tblSMImportFileHeader
						SET strLayoutTitle = ''Commander - Transaction Log Rebate''
						WHERE strLayoutTitle = ''Commander - Trans Log''
					')
			END
	END
----------------------------------------------------------------------------------------------------------------------------------
-- End: Rename Commander - Trans Log to Commander - Transaction Log Rebates
----------------------------------------------------------------------------------------------------------------------------------



IF EXISTS(SELECT * FROM  INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'tblSTRetailAccount') 
	BEGIN
		PRINT(N'Drop table tblSTRetailAccount')
		EXEC('
				DROP TABLE tblSTRetailAccount
			')
	END


----------------------------------------------------------------------------------------------------------------------------------
-- Start: Remove records from tblSTTranslogRebates if intCheckoutId is not Existing on tblSTCheckoutHeader
----------------------------------------------------------------------------------------------------------------------------------
IF EXISTS(SELECT TOP 1 1 FROM  INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'tblSTTranslogRebates') 
	BEGIN
		IF EXISTS(SELECT TOP 1 1 FROM tblSTTranslogRebates WHERE intCheckoutId NOT IN (SELECT intCheckoutId FROM tblSTCheckoutHeader))
			BEGIN
				PRINT(N'There are transaction logs that has no Checkout existing. Removing transaction logs...')
				EXEC('
						DELETE FROM tblSTTranslogRebates WHERE intCheckoutId NOT IN (SELECT intCheckoutId FROM tblSTCheckoutHeader)
					')
			END
	END
----------------------------------------------------------------------------------------------------------------------------------
-- End: Remove records from tblSTTranslogRebates if intCheckoutId is not Existing on tblSTCheckoutHeader
----------------------------------------------------------------------------------------------------------------------------------


----------------------------------------------------------------------------------------------------------------------------------
-- Start: Rename tblSTRegisterSetup.strRegisterName and tblSTRegisterSetup.strXmlGateWayVersion
----------------------------------------------------------------------------------------------------------------------------------
IF EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = N'tblSTRegisterSetup' AND COLUMN_NAME = N'strRegisterName') 
	BEGIN
		
		IF NOT EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = N'tblSTRegisterSetup' AND COLUMN_NAME = N'strRegisterClass')
			BEGIN

				PRINT('Rename tblSTRegisterSetup.strRegisterName	to	   tblSTRegisterSetup.strRegisterClass')
				EXEC('
						EXEC sp_rename ''tblSTRegisterSetup.strRegisterName'' , ''strRegisterClass'', ''COLUMN''
					')

			END
	END

IF EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = N'tblSTRegisterSetup' AND COLUMN_NAME = N'strXmlGateWayVersion') 
	BEGIN
		
		IF NOT EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = N'tblSTRegisterSetup' AND COLUMN_NAME = N'strXmlVersion')
			BEGIN

				PRINT('Rename tblSTRegisterSetup.strXmlGateWayVersion	to	   tblSTRegisterSetup.strXmlVersion')
				EXEC('
						EXEC sp_rename ''tblSTRegisterSetup.strXmlGateWayVersion'' , ''strXmlVersion'', ''COLUMN''
					')

			END
	END
----------------------------------------------------------------------------------------------------------------------------------
-- End: Rename tblSTRegisterSetup.strRegisterName and tblSTRegisterSetup.strXmlGateWayVersion
----------------------------------------------------------------------------------------------------------------------------------



----------------------------------------------------------------------------------------------------------------------------------
-- Start: Remove records from tblSTRegisterSetup that strRegisterClass = null or empty and strXmlVersion is null or empty
----------------------------------------------------------------------------------------------------------------------------------
IF EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = N'tblSTRegisterSetup')
	BEGIN
		EXEC('
				DELETE FROM tblSTRegisterSetup
				WHERE strRegisterClass IS NULL
					AND strXmlVersion IS NULL

				DELETE FROM tblSTRegisterSetup
				WHERE strRegisterClass = ''''
					AND strXmlVersion = ''''
			')
	END
----------------------------------------------------------------------------------------------------------------------------------
-- End: Remove records from tblSTRegisterSetup that strRegisterClass = null or empty and strXmlVersion is null or empty
----------------------------------------------------------------------------------------------------------------------------------





----------------------------------------------------------------------------------------------------------------------------------
-- Start: DROP uspSTCStoreSQLScheduler
----------------------------------------------------------------------------------------------------------------------------------
IF EXISTS(SELECT TOP 1 1 FROM sys.objects WHERE type = 'P' AND name = 'uspSTCStoreSQLScheduler')
	BEGIN
			PRINT(N'Drop uspSTCStoreSQLScheduler')
			EXEC('
					DROP PROCEDURE [dbo].[uspSTCStoreSQLScheduler]
				')
	END
----------------------------------------------------------------------------------------------------------------------------------
-- End: DROP uspSTCStoreSQLScheduler
----------------------------------------------------------------------------------------------------------------------------------




----------------------------------------------------------------------------------------------------------------------------------
-- Start: Remove Job Scheduler named 'i21_PostRetailPrice_Maintenance_Job'
----------------------------------------------------------------------------------------------------------------------------------
PRINT(N'Validate current SQL user before removing Job Scheduler named i21_PostRetailPrice_Maintenance_Job.')

	-- Check if current user has sysadmin/serveradmin role
	-- Note: http://jira.irelyserver.com/browse/ST-1541
	DECLARE @isUserHasRole BIT = CAST(0 AS BIT)


	IF OBJECT_ID('tempdb..#TempSysAdmin') IS NOT NULL
		BEGIN
			DROP TABLE #TempSysAdmin
		END
		

	Create TABLE #TempSysAdmin
	(
		[ServerRole]	SYSNAME,
		[MemberName]	SYSNAME,
		[MemberSID]		VARBINARY(85)
	)


	INSERT INTO #TempSysAdmin EXEC sp_helpsrvrolemember 'sysadmin'

	IF OBJECT_ID('tempdb..#TempServerAdmin') IS NOT NULL
		BEGIN
			DROP TABLE #TempServerAdmin
		END
		

	Create TABLE #TempServerAdmin
	(
		[ServerRole]	sysname,
		[MemberName]	sysname,
		[MemberSID]		varbinary(85)
	)

	INSERT INTO #TempServerAdmin exec sp_helpsrvrolemember 'serveradmin'

	DECLARE @loginUser VARCHAR(250)
	SET @loginUser = SYSTEM_USER

	SELECT 
		@isUserHasRole = 1 
	FROM #TempSysAdmin 
	WHERE MemberName = @loginUser

	IF ISNULL(@isUserHasRole, 0) = 0
	BEGIN
		SELECT @isUserHasRole = 1 FROM #TempServerAdmin WHERE MemberName = @loginUser
	END

	-- VALIDATE
	IF ISNULL(@isUserHasRole, 0) = 1
		BEGIN
			PRINT(N'Current SQL user has rights to drop maintenenace plan i21_CStore_Daily_Maintenance_Job.')

			IF EXISTS (SELECT TOP 1 1 FROM msdb.dbo.sysjobs WHERE name = N'i21_CStore_Daily_Maintenance_Job')
				BEGIN
					PRINT(N'Will Drop i21_PostRetailPrice_Maintenance_Job.')

					EXEC('
							DECLARE @jobId binary(16)

							SELECT @jobId = job_id FROM msdb.dbo.sysjobs WHERE (name = N''i21_CStore_Daily_Maintenance_Job'')

							IF (@jobId IS NOT NULL)
								BEGIN
									EXEC msdb.dbo.sp_delete_job @jobId
								END
						')

					PRINT(N'Drop i21_CStore_Daily_Maintenance_Job successfully.')
				END

		END
	ELSE
		BEGIN
			PRINT N'CURRENT SQL USER IS NOT ALLOWED TO DROP MAINTENANCE PLAN. PLEASE CONTACT YOUR DATABASE ADMINISTRATOR FOR PERMISSION.'
		END
----------------------------------------------------------------------------------------------------------------------------------
-- End: Remove Job Scheduler named 'i21_PostRetailPrice_Maintenance_Job'
----------------------------------------------------------------------------------------------------------------------------------



----------------------------------------------------------------------------------------------------------------------------------
-- Start: Update tblSTRetailPriceAdjustmentDetail.intItemPricingId = NULL
----------------------------------------------------------------------------------------------------------------------------------
IF EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = N'tblSTRetailPriceAdjustmentDetail' AND COLUMN_NAME = 'intItemPricingId') 
	BEGIN

	
	DECLARE @sqlCommand NVARCHAR(MAX)
	DECLARE @count INT = 0
	SET @sqlCommand = 'SELECT @count = Count(1)
	FROM tblSTRetailPriceAdjustmentDetail
	WHERE intItemPricingId IS NULL'
	EXEC sp_executesql @sqlCommand, N'@count int OUTPUT',
	@count = @count OUTPUT

	SELECT @count 

		IF (@count > 0)
			BEGIN

				PRINT('Update tblSTRetailPriceAdjustmentDetail.intItemPricingId field')

				EXEC('
						UPDATE rpad
							SET intItemPricingId	= itemPricing.intItemPricingId
						FROM tblSTRetailPriceAdjustmentDetail rpad
						INNER JOIN tblICItemLocation itemLoc
							ON rpad.intCompanyLocationId = itemLoc.intLocationId
						INNER JOIN tblICItemUOM uom
							ON rpad.intItemUOMId = uom.intItemUOMId
						INNER JOIN tblICItem item
							ON uom.intItemId = item.intItemId
						INNER JOIN tblICItemPricing itemPricing
							ON item.intItemId = itemPricing.intItemId
								AND itemLoc.intItemLocationId = itemPricing.intItemLocationId
						WHERE rpad.intCompanyLocationId IS NOT NULL
							AND rpad.intItemUOMId IS NOT NULL
					')		
					
			END
	END
----------------------------------------------------------------------------------------------------------------------------------
-- End: Update tblSTRetailPriceAdjustmentDetail.intItemPricingId = NULL
----------------------------------------------------------------------------------------------------------------------------------


----------------------------------------------------------------------------------------------------------------------------------
-- Start: Add Retail Price Adjustment Number if there is  tblSTRetailPriceAdjustment.strRetailPriceAdjustmentNumber=NULL
----------------------------------------------------------------------------------------------------------------------------------
IF EXISTS(SELECT TOP 1 1 FROM  INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = N'tblSTRetailPriceAdjustment' AND COLUMN_NAME = N'strRetailPriceAdjustmentNumber') 
	BEGIN
		
		IF EXISTS(SELECT TOP 1 1 FROM sys.objects WHERE type = 'P' AND name = 'uspSTGetStartingNumber')
			BEGIN
				
				EXEC('
						IF EXISTS(SELECT TOP 1 1 FROM tblSTRetailPriceAdjustment WHERE strRetailPriceAdjustmentNumber IS NULL)
							BEGIN
									PRINT(N''There are Retail Price Adjustment that has no starting number. Updating Retail Price batch number'')

									----TEST BEFORE
									--BEGIN
									--	SELECT ''BEFORE'', strRetailPriceAdjustmentNumber, * FROM tblSTRetailPriceAdjustment
									--END

									-- CREATE TEMP TABLE
									DECLARE @tempTable TABLE
									(
										intRetailPriceAdjustmentId INT
									)

									-- INSERT TO TEMP TABLE
									INSERT INTO @tempTable
									(
										intRetailPriceAdjustmentId
									)
									SELECT DISTINCT
											intRetailPriceAdjustmentId = rpa.intRetailPriceAdjustmentId
									FROM tblSTRetailPriceAdjustment rpa
									WHERE rpa.strRetailPriceAdjustmentNumber IS NULL

									DECLARE @intRetailPriceAdjustmentId	INT,
											@strBatchId					NVARCHAR(100), 
											@ysnSuccess					BIT,
											@strMessage					NVARCHAR(1000)

									WHILE EXISTS(SELECT TOP 1 1 FROM @tempTable)
										BEGIN

											SELECT TOP 1
												@intRetailPriceAdjustmentId = temp.intRetailPriceAdjustmentId 
											FROM @tempTable temp


											EXEC [dbo].[uspSTGetStartingNumber]
													@strModule				= N''Store''
													, @strTransactionType	= N''Retail Price Adjustment''
													, @strPrefix			= N''RPA-''
													, @intLocationId		= NULL
													, @strBatchId			= @strBatchId OUTPUT
													, @ysnSuccess			= @ysnSuccess OUTPUT
													, @strMessage			= @strMessage OUTPUT

											--PRINT ''@strBatchId: '' + @strBatchId

											UPDATE rpa
												SET rpa.strRetailPriceAdjustmentNumber = @strBatchId
											FROM tblSTRetailPriceAdjustment rpa
											WHERE rpa.intRetailPriceAdjustmentId = @intRetailPriceAdjustmentId


											DELETE FROM @tempTable
											WHERE intRetailPriceAdjustmentId = @intRetailPriceAdjustmentId

										END

									----TEST AFTER
									--BEGIN
									--	SELECT ''AFTER'', strRetailPriceAdjustmentNumber, * FROM tblSTRetailPriceAdjustment
									--END
							END		
					')

			END
	END

----------------------------------------------------------------------------------------------------------------------------------
-- End: Add Retail Price Adjustment Number if there is  tblSTRetailPriceAdjustment.strRetailPriceAdjustmentNumber=NULL
----------------------------------------------------------------------------------------------------------------------------------



PRINT('*** ST Cleanup - End ***')
PRINT('')