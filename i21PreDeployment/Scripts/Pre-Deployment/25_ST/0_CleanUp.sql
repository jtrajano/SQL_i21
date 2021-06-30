PRINT('')
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
-- [START] - Change datatype of tblSTTranslogRebates
----------------------------------------------------------------------------------------------------------------------------------
IF EXISTS(SELECT TOP 1 1 FROM  INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'tblSTTranslogRebates') 
	BEGIN
		IF EXISTS(SELECT TOP 1 1 FROM  INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'tblSTTranslogRebates' AND COLUMN_NAME = 'intCashierEmpNum')
			BEGIN
		
				PRINT('Alter tblSTTranslogRebates.intCashierEmpNum datatype to NVARCHAR(200)')
				EXEC('
						ALTER TABLE [tblSTTranslogRebates] ALTER COLUMN [intCashierEmpNum] NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL
					')

				PRINT('Rename tblSTTranslogRebates.intCashierEmpNum	to tblSTTranslogRebates.strCashierEmpNum')
				EXEC('
						EXEC sp_rename ''tblSTTranslogRebates.intCashierEmpNum'' , ''strCashierEmpNum'', ''COLUMN''
					')
			END

		IF EXISTS(SELECT TOP 1 1 FROM  INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'tblSTTranslogRebates' AND COLUMN_NAME = 'intOriginalCashierEmpNum')
			BEGIN
		
				PRINT('Alter tblSTTranslogRebates.intOriginalCashierEmpNum datatype to NVARCHAR(200)')
				EXEC('
						ALTER TABLE [tblSTTranslogRebates] ALTER COLUMN [intOriginalCashierEmpNum] NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL
					')

				PRINT('Rename tblSTTranslogRebates.intOriginalCashierEmpNum	to tblSTTranslogRebates.strOriginalCashierEmpNum')
				EXEC('
						EXEC sp_rename ''tblSTTranslogRebates.intOriginalCashierEmpNum'' , ''strOriginalCashierEmpNum'', ''COLUMN''
					')
			END

		IF EXISTS(SELECT TOP 1 1 FROM  INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'tblSTTranslogRebates' AND COLUMN_NAME = 'strTrlCatNumber')
			BEGIN
		
				PRINT('Alter tblSTTranslogRebates.strTrlCatNumber datatype to INT NULL')
				EXEC('
						ALTER TABLE [tblSTTranslogRebates] ALTER COLUMN [strTrlCatNumber] INT NULL
					')

				PRINT('Rename tblSTTranslogRebates.strTrlCatNumber	to tblSTTranslogRebates.intTrlCatNumber')
				EXEC('
						EXEC sp_rename ''tblSTTranslogRebates.strTrlCatNumber'' , ''intTrlCatNumber'', ''COLUMN''
					')
			END

		IF EXISTS(SELECT TOP 1 1 FROM  INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'tblSTTranslogRebates' AND COLUMN_NAME = 'strTrpCardInfoTrpcBatchNr')
			BEGIN
		
				PRINT('Alter tblSTTranslogRebates.strTrpCardInfoTrpcBatchNr datatype to INT NULL')
				EXEC('
						ALTER TABLE [tblSTTranslogRebates] ALTER COLUMN [strTrpCardInfoTrpcBatchNr] INT NULL
					')

				PRINT('Rename tblSTTranslogRebates.strTrpCardInfoTrpcBatchNr to tblSTTranslogRebates.intTrpCardInfoTrpcBatchNr')
				EXEC('
						EXEC sp_rename ''tblSTTranslogRebates.strTrpCardInfoTrpcBatchNr'' , ''intTrpCardInfoTrpcBatchNr'', ''COLUMN''
					')
			END

		IF EXISTS(SELECT TOP 1 1 FROM  INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'tblSTTranslogRebates' AND COLUMN_NAME = 'strTrpCardInfoTrpcSeqNr')
			BEGIN
		
				PRINT('Alter tblSTTranslogRebates.strTrpCardInfoTrpcSeqNr datatype to INT NULL')
				EXEC('
						ALTER TABLE [tblSTTranslogRebates] ALTER COLUMN [strTrpCardInfoTrpcSeqNr] INT NULL
					')

				PRINT('Rename tblSTTranslogRebates.strTrpCardInfoTrpcSeqNr to tblSTTranslogRebates.intTrpCardInfoTrpcSeqNr')
				EXEC('
						EXEC sp_rename ''tblSTTranslogRebates.strTrpCardInfoTrpcSeqNr'' , ''intTrpCardInfoTrpcSeqNr'', ''COLUMN''
					')
			END
	END
----------------------------------------------------------------------------------------------------------------------------------
-- [END] - Change datatype of tblSTTranslogRebates
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


----------------------------------------------------------------------------------------------------------------------------------
-- [START] - Encrypt Sapphire Password and Base Password 
----------------------------------------------------------------------------------------------------------------------------------
IF EXISTS(SELECT TOP 1 1 FROM  INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = N'tblSTRegister' AND COLUMN_NAME = N'strSAPPHIREPassword')
	BEGIN
			
		EXEC('
				-- Modify Datatype
				IF EXISTS(
							SELECT TOP 1 1
							FROM INFORMATION_SCHEMA.COLUMNS
							WHERE 
								 TABLE_NAME = ''tblSTRegister'' AND 
								 COLUMN_NAME = ''strSAPPHIREPassword'' AND
								 DATA_TYPE = ''nvarchar'' AND
								 CHARACTER_MAXIMUM_LENGTH = 100
						 )
					BEGIN
							ALTER TABLE tblSTRegister 
							ALTER COLUMN strSAPPHIREPassword NVARCHAR(MAX);
					END



				-- Note: <= 100 in length are the not encrypted passwords
				--       344 in length are the encrypted passwords
				UPDATE tblSTRegister
				SET strSAPPHIREPassword = dbo.fnAESEncryptASym(strSAPPHIREPassword)
				WHERE LEN(strSAPPHIREPassword) <= 100 
			')		
		
		

	END

IF EXISTS(SELECT TOP 1 1 FROM  INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = N'tblSTRegister' AND COLUMN_NAME = N'strSAPPHIREBasePassword')
	BEGIN
			
		EXEC('
				-- Modify Datatype
				IF EXISTS(
							SELECT TOP 1 1
							FROM INFORMATION_SCHEMA.COLUMNS
							WHERE 
								 TABLE_NAME = ''tblSTRegister'' AND 
								 COLUMN_NAME = ''strSAPPHIREBasePassword'' AND
								 DATA_TYPE = ''nvarchar'' AND
								 CHARACTER_MAXIMUM_LENGTH = 100
						 )
					BEGIN
							ALTER TABLE tblSTRegister 
							ALTER COLUMN strSAPPHIREBasePassword NVARCHAR(MAX);
					END



				-- Note: <= 100 in length are the not encrypted passwords
				--       344 in length are the encrypted passwords
				UPDATE tblSTRegister
				SET strSAPPHIREBasePassword = dbo.fnAESEncryptASym(strSAPPHIREBasePassword)
				WHERE LEN(strSAPPHIREBasePassword) <= 100 
			')		
		
	END
----------------------------------------------------------------------------------------------------------------------------------
-- [END] - Encrypt Sapphire Password and Base Password 
----------------------------------------------------------------------------------------------------------------------------------


----------------------------------------------------------------------------------------------------------------------------------
-- [START] - Remove Constraints 
----------------------------------------------------------------------------------------------------------------------------------
IF EXISTS (
SELECT
* 
FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS 
WHERE CONSTRAINT_NAME ='AK_tblSTSubcategoryRegProd_strRegProdCode'
and TABLE_NAME = 'tblSTSubcategoryRegProd' ) 
BEGIN
	ALTER TABLE tblSTSubcategoryRegProd
	DROP CONSTRAINT AK_tblSTSubcategoryRegProd_strRegProdCode
END
----------------------------------------------------------------------------------------------------------------------------------
-- [END] - Remove Duplicate data of tblSTSubcategoryRegProd  
----------------------------------------------------------------------------------------------------------------------------------


----------------------------------------------------------------------------------------------------------------------------------
-- [START] - Consolidate duplicate records of tblSTSubcategoryRegProd
----------------------------------------------------------------------------------------------------------------------------------
IF EXISTS(SELECT TOP 1 1 FROM  INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = N'tblSTSubcategoryRegProd') 
	BEGIN
		
	IF EXISTS(SELECT TOP 1 COUNT(1) FROM tblSTSubcategoryRegProd GROUP BY strRegProdCode HAVING COUNT(1) > 1) 
	BEGIN
		print 'STORE > Begin consolidating duplicate records of tblSTSubcategoryRegProd'

		DECLARE @tblTempSubcategoryRegProd TABLE 
		(
			 intRegProdId			   INT,
			 strRegProdCode			   NVARCHAR(MAX)
		)
		DECLARE @tblTempPromotionSalesList TABLE 
		(
			 intRegProdId			   INT,
			 intPromoSalesListId	   INT,
			 strRegProdCode			   NVARCHAR(MAX)
		)

		INSERT INTO @tblTempSubcategoryRegProd
		(
			intRegProdId,
			strRegProdCode
		)

		SELECT intRegProdId,strRegProdCode FROM (
				SELECT intRegProdId, intPartitionNo ,strRegProdCode
				FROM (
					SELECT intPartitionNo = ROW_NUMBER() OVER (PARTITION BY strRegProdCode ORDER BY strRegProdCode) , intRegProdId, strRegProdCode 
					FROM tblSTSubcategoryRegProd ) 
					as subquery where intPartitionNo = 1
			) as subquery1

		
		IF EXISTS(SELECT TOP 1 1 FROM  INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = N'tblSTPromotionSalesList') 
		BEGIN
			INSERT INTO @tblTempPromotionSalesList 
		(
			 intRegProdId
			,strRegProdCode		
			,intPromoSalesListId
		)
		SELECT
			 tblSTSubcategoryRegProd.intRegProdId
			,tblSTSubcategoryRegProd.strRegProdCode		
			,tblSTPromotionSalesList.intPromoSalesListId
		FROM 
		tblSTPromotionSalesList
		INNER JOIN tblSTSubcategoryRegProd
		ON tblSTPromotionSalesList.intRegProdId = tblSTSubcategoryRegProd.intRegProdId

			UPDATE @tblTempPromotionSalesList SET intRegProdId = [@tblTempSubcategoryRegProd].intRegProdId FROM @tblTempSubcategoryRegProd WHERE [@tblTempSubcategoryRegProd].strRegProdCode = [@tblTempPromotionSalesList].strRegProdCode
			UPDATE tblSTPromotionSalesList SET tblSTPromotionSalesList.intRegProdId = [@tblTempPromotionSalesList].intRegProdId FROM @tblTempPromotionSalesList WHERE [@tblTempPromotionSalesList].intPromoSalesListId = tblSTPromotionSalesList.intPromoSalesListId
		END

		DELETE FROM tblSTSubcategoryRegProd WHERE intRegProdId NOT IN ( SELECT intRegProdId FROM @tblTempSubcategoryRegProd ) 
		print 'STORE > End consolidating duplicate records of tblSTSubcategoryRegProd'
	END

END
----------------------------------------------------------------------------------------------------------------------------------
-- [END] - Consolidate duplicate records of tblSTSubcategoryRegProd
----------------------------------------------------------------------------------------------------------------------------------


----------------------------------------------------------------------------------------------------------------------------------
-- [START] - Consolidate duplicate records of tblSTLotteryGame
----------------------------------------------------------------------------------------------------------------------------------
IF EXISTS(SELECT TOP 1 1 FROM  INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = N'tblSTLotteryGame') 
	BEGIN
		
	IF EXISTS(SELECT TOP 1 COUNT(1) FROM tblSTLotteryGame GROUP BY strGame,strState HAVING COUNT(1) > 1) 
	BEGIN
		print 'STORE > Begin consolidating duplicate records of tblSTLotteryGame'

		--***************INSERT LOTTERY GAME INTO TEMP TABLE******************--
		
		IF EXISTS(SELECT TOP 1 1 FROM  INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = N'tblSTLotterGameFromOldVersion') 
		BEGIN
			EXEC ('DELETE FROM tblSTLotterGameFromOldVersion')
		END
		
		CREATE TABLE tblSTLotterGameFromOldVersion
		(
				intLotteryGameId	int
			,strState			nvarchar(max)	
			,strGame			nvarchar(max)	
			,intItemId			int
			,intStartingNumber	int
			,intEndingNumber	int
			,intTicketPerPack	int
			,dtmExpirationDate	datetime
			,dblInventoryCost	numeric(18,6)
			,dblTicketValue		numeric(18,6)
			,intConcurrencyId	int	
			,dtmUpgradeDate		datetime	
			,strVersion			nvarchar(max)	
		)

		DECLARE @version NVARCHAR(MAX)
		DECLARE @upgradeDate DATETIME 
		
		SELECT TOP 1 @version = strVersionNo FROM tblSMBuildNumber ORDER BY intVersionID DESC
		SET @upgradeDate = GETDATE()

		INSERT INTO tblSTLotterGameFromOldVersion(
			 intLotteryGameId	
			,strState			
			,strGame			
			,intItemId			
			,intStartingNumber	
			,intEndingNumber	
			,intTicketPerPack	
			,dtmExpirationDate	
			,dblInventoryCost	
			,dblTicketValue		
			,intConcurrencyId	
			,dtmUpgradeDate	
			,strVersion		
		)
		SELECT 
			 intLotteryGameId	
			,strState			
			,strGame			
			,intItemId			
			,intStartingNumber	
			,intEndingNumber	
			,intTicketPerPack	
			,dtmExpirationDate	
			,dblInventoryCost	
			,dblTicketValue		
			,intConcurrencyId	
			,@upgradeDate	
			,@version		
		FROM tblSTLotteryGame

		--***************INSERT LOTTERY GAME INTO TEMP TABLE******************--

		DECLARE @tblTempLotteryGame TABLE 
		(
			 intLotteryGameId				INT,
			 strGame						NVARCHAR(MAX)
		)

		DECLARE @tblTempReceiveLottery TABLE 
		(
			 intLotteryGameId				INT,
			 intReceiveLotteryId			INT,
			 strGame						NVARCHAR(MAX)
		)

		DECLARE @tblTempLotteryBook TABLE 
		(
			 intLotteryGameId				INT,
			 intLotteryBookId				INT,
			 strGame						NVARCHAR(MAX)
		)

		INSERT INTO @tblTempLotteryGame
		(
			intLotteryGameId,
			strGame
		)

		SELECT intLotteryGameId,strGame FROM (
				SELECT intLotteryGameId, intPartitionNo ,strGame
				FROM (
					SELECT intPartitionNo = ROW_NUMBER() OVER (PARTITION BY strGame, strState ORDER BY strGame,strState) , intLotteryGameId, strGame 
					FROM tblSTLotteryGame ) 
					as subquery where intPartitionNo = 1
			) as subquery1

		

		IF EXISTS(SELECT TOP 1 1 FROM  INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = N'tblSTLotteryBook') 
		BEGIN
			INSERT INTO @tblTempLotteryBook 
		(
			 intLotteryGameId
			,strGame		
			,intLotteryBookId
		)
		SELECT
			 tblSTLotteryGame.intLotteryGameId
			,tblSTLotteryGame.strGame		
			,tblSTLotteryBook.intLotteryBookId
		FROM 
		tblSTLotteryBook
		INNER JOIN tblSTLotteryGame
		ON tblSTLotteryBook.intLotteryGameId = tblSTLotteryGame.intLotteryGameId

			UPDATE @tblTempLotteryBook SET intLotteryGameId = [@tblTempLotteryGame].intLotteryGameId FROM @tblTempLotteryGame WHERE [@tblTempLotteryGame].strGame = [@tblTempLotteryBook].strGame
			UPDATE tblSTLotteryBook SET tblSTLotteryBook.intLotteryGameId = [@tblTempLotteryBook].intLotteryGameId FROM @tblTempLotteryBook WHERE [@tblTempLotteryBook].intLotteryBookId = tblSTLotteryBook.intLotteryBookId
		END


		IF EXISTS(SELECT TOP 1 1 FROM  INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = N'tblSTReceiveLottery') 
		BEGIN
			INSERT INTO @tblTempReceiveLottery 
		(
			 intLotteryGameId
			,strGame		
			,intReceiveLotteryId
		)
		SELECT
			 tblSTLotteryGame.intLotteryGameId
			,tblSTLotteryGame.strGame		
			,tblSTReceiveLottery.intReceiveLotteryId
		FROM 
		tblSTReceiveLottery
		INNER JOIN tblSTLotteryGame
		ON tblSTReceiveLottery.intLotteryGameId = tblSTLotteryGame.intLotteryGameId

			UPDATE @tblTempReceiveLottery SET intLotteryGameId = [@tblTempLotteryGame].intLotteryGameId FROM @tblTempLotteryGame WHERE [@tblTempLotteryGame].strGame = [@tblTempReceiveLottery].strGame
			UPDATE tblSTReceiveLottery SET tblSTReceiveLottery.intLotteryGameId = [@tblTempReceiveLottery].intLotteryGameId FROM @tblTempReceiveLottery WHERE [@tblTempReceiveLottery].intReceiveLotteryId = tblSTReceiveLottery.intReceiveLotteryId
		END

		DELETE FROM tblSTLotteryGame WHERE intLotteryGameId NOT IN ( SELECT intLotteryGameId FROM @tblTempLotteryGame ) 
		print 'STORE > End consolidating duplicate records of tblSTLotteryGame'
	END

END
----------------------------------------------------------------------------------------------------------------------------------
-- [END] - Consolidate duplicate records of tblSTLotteryGame
----------------------------------------------------------------------------------------------------------------------------------





PRINT('*** ST Cleanup - End ***')
PRINT('')