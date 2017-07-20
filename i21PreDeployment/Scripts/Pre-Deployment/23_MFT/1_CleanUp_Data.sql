--IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = N'tblTFValidProductCode' AND COLUMN_NAME = 'intReportingComponentDetailId')
--BEGIN
--	IF NOT EXISTS(SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = N'tblTFValidProductCode' AND COLUMN_NAME = 'intReportingComponentId')
--	BEGIN
--		EXEC('ALTER TABLE tblTFValidProductCode ADD intReportingComponentId INT NULL DEFAULT(0)')
		
--		EXEC('UPDATE tblTFValidProductCode SET intReportingComponentId = intReportingComponentDetailId')
--	END
--END

--IF EXISTS(SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = N'tblTFValidOriginDestinationState' AND COLUMN_NAME = 'intValidDestinationStateId')
--BEGIN
--	IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = N'tblTFValidDestinationState' AND COLUMN_NAME = 'intOriginDestinationStateId')
--	BEGIN
--		EXEC('DELETE FROM tblTFValidDestinationState WHERE intOriginDestinationStateId NOT IN (SELECT intValidDestinationStateId FROM tblTFValidOriginDestinationState)')
--	END

--	IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = N'tblTFValidOriginState' AND COLUMN_NAME = 'intOriginDestinationStateId')
--	BEGIN
--		EXEC('DELETE FROM tblTFValidOriginState WHERE intOriginDestinationStateId NOT IN (SELECT intOriginDestinationStateId FROM tblTFValidOriginDestinationState)')
--	END
--END

--IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = N'tblTFValidProductCode' AND COLUMN_NAME = 'intProductCode')
--BEGIN
--	IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = N'tblTFValidProductCode' AND COLUMN_NAME = 'intValidProductCodeId')
--	BEGIN
--		IF EXISTS(SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = N'tblTFValidProductCode' AND COLUMN_NAME = 'intReportingComponentDetailId')
--		BEGIN
--			EXEC('UPDATE tblTFValidProductCode
--				SET tblTFValidProductCode.intProductCode = tblPatch.intProductCodeId
--				FROM (SELECT DISTINCT RCPC.intValidProductCodeId, RCPC.strProductCode, PC.intProductCodeId
--					FROM tblTFValidProductCode RCPC
--					LEFT JOIN tblTFReportingComponent RC ON RC.intReportingComponentId = RCPC.intReportingComponentDetailId
--					LEFT JOIN tblTFProductCode PC ON PC.intTaxAuthorityId = RC.intTaxAuthorityId AND PC.strProductCode = RCPC.strProductCode
--					) tblPatch
--				WHERE tblPatch.intValidProductCodeId = tblTFValidProductCode.intValidProductCodeId
--					AND ISNULL(tblTFValidProductCode.intProductCode, '''') = ''''
--					AND ISNULL(tblTFValidProductCode.strProductCode, '''') <> ''''')
--		END
--		ELSE IF EXISTS(SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = N'tblTFValidProductCode' AND COLUMN_NAME = 'intReportingComponentId')
--		BEGIN
--			EXEC('UPDATE tblTFValidProductCode
--				SET tblTFValidProductCode.intProductCode = tblPatch.intProductCodeId
--				FROM (SELECT DISTINCT RCPC.intValidProductCodeId, RCPC.strProductCode, PC.intProductCodeId
--					FROM tblTFValidProductCode RCPC
--					LEFT JOIN tblTFReportingComponent RC ON RC.intReportingComponentId = RCPC.intReportingComponentId
--					LEFT JOIN tblTFProductCode PC ON PC.intTaxAuthorityId = RC.intTaxAuthorityId AND PC.strProductCode = RCPC.strProductCode
--					) tblPatch
--				WHERE tblPatch.intValidProductCodeId = tblTFValidProductCode.intValidProductCodeId
--					AND ISNULL(tblTFValidProductCode.intProductCode, '''') = ''''
--					AND ISNULL(tblTFValidProductCode.strProductCode, '''') <> ''''')
--		END	

--		IF NOT EXISTS(SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = N'tblTFValidProductCode' AND COLUMN_NAME = 'intProductCodeId')
--		BEGIN
--			EXEC('ALTER TABLE tblTFValidProductCode ADD intProductCodeId INT NULL DEFAULT(0)')
		
--			EXEC('UPDATE tblTFValidProductCode SET intProductCodeId = intProductCode')
--		END
--	END
--END

--IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = N'tblTFTransactions' AND COLUMN_NAME = 'intReportingComponentId')
--BEGIN
--	EXEC('UPDATE tblTFTransactions
--		SET tblTFTransactions.intReportingComponentId = tblPatch.intReportingComponentId
--		FROM (
--			SELECT DISTINCT Trans.intTransactionId, RC.intReportingComponentId
--			FROM tblTFTransactions Trans
--			LEFT JOIN tblTFReportingComponent RC ON Trans.strFormCode = RC.strFormCode
--				AND Trans.strScheduleCode = RC.strScheduleCode
--				AND Trans.strType = RC.strType
--				AND Trans.intTaxAuthorityId = RC.intTaxAuthorityId
--		) tblPatch
--		WHERE tblTFTransactions.intTransactionId = tblPatch.intTransactionId
--			AND ISNULL(tblTFTransactions.intReportingComponentId, '''') = ''''')
--END

--IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = N'tblTFTransactions' AND COLUMN_NAME = 'intReportingComponentId')
--BEGIN
--	EXEC('DELETE FROM tblTFTransactions WHERE ISNULL(intReportingComponentId, '''') = ''''')
--END

--IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = N'tblTFTransactions' AND COLUMN_NAME = 'intReportingComponentDetailId')
--BEGIN
--	EXEC('UPDATE tblTFTransactions
--		SET tblTFTransactions.intProductCodeId = tblPatch.intProductCodeId
--		FROM (SELECT DISTINCT Trans.intTransactionId, Trans.strProductCode, PC.intProductCodeId
--			FROM tblTFTransactions Trans
--			LEFT JOIN tblTFReportingComponent RC ON RC.intReportingComponentId = Trans.intReportingComponentDetailId
--			LEFT JOIN tblTFProductCode PC ON PC.intTaxAuthorityId = RC.intTaxAuthorityId AND PC.strProductCode = Trans.strProductCode
--			) tblPatch
--		WHERE tblPatch.intTransactionId = tblTFTransactions.intTransactionId
--			AND ISNULL(tblTFTransactions.intProductCodeId, '''') = ''''
--			AND ISNULL(tblTFTransactions.strProductCode, '''') <> ''''')
--END

--IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = N'tblTFTransactions' AND COLUMN_NAME = 'intReportingComponentId')
--BEGIN	
--	EXEC('UPDATE tblTFTransactions
--		SET tblTFTransactions.intProductCodeId = tblPatch.intProductCodeId
--		FROM (SELECT DISTINCT Trans.intTransactionId, Trans.strProductCode, PC.intProductCodeId
--			FROM tblTFTransactions Trans
--			LEFT JOIN tblTFReportingComponent RC ON RC.intReportingComponentId = Trans.intReportingComponentId
--			LEFT JOIN tblTFProductCode PC ON PC.intTaxAuthorityId = RC.intTaxAuthorityId AND PC.strProductCode = Trans.strProductCode
--			) tblPatch
--		WHERE tblPatch.intTransactionId = tblTFTransactions.intTransactionId
--			AND ISNULL(tblTFTransactions.intProductCodeId, '''') = ''''
--			AND ISNULL(tblTFTransactions.strProductCode, '''') <> ''''')
--END

--IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = N'tblTFReportingComponentProductCode' AND COLUMN_NAME = 'intProductCodeId')
--		BEGIN
--			EXEC('DELETE FROM tblTFReportingComponentProductCode
--			WHERE intProductCodeId IS NULL')
--		END

--IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = N'tblTFReportingComponentProductCode' AND COLUMN_NAME = 'intConcurrencyId')
--		BEGIN
--			EXEC('UPDATE tblTFReportingComponentProductCode
--			SET intConcurrencyId = 1
--			WHERE intConcurrencyId IS NULL')
--		END

--IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = N'tblTFReportingComponent' AND COLUMN_NAME = 'intConcurrencyId')
--		BEGIN
--			EXEC('UPDATE tblTFReportingComponent
--			SET intConcurrencyId = 1
--			WHERE intConcurrencyId IS NULL')
--		END

--DECLARE @COUNT INT
--	SET @COUNT = (SELECT COUNT(*) Names 
--		FROM sys.columns 
--		WHERE OBJECT_ID = OBJECT_ID('tblTFFilingPacket')
--		AND Name in ('intReportingComponentId', 'intTaxAuthorityId'))
--		IF (@COUNT = 2)
--			BEGIN
--				EXEC('DELETE FROM tblTFFilingPacket WHERE intReportingComponentId = 70 AND intTaxAuthorityId = 27')
--				EXEC('DELETE FROM tblTFFilingPacket WHERE intReportingComponentId = 161 AND intTaxAuthorityId = 14')
--			END

--IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = N'tblTFReportingComponentField')
--		BEGIN
--			EXEC('DELETE FROM tblTFReportingComponentField')
--		END

--IF EXISTS(SELECT *
--          FROM   INFORMATION_SCHEMA.COLUMNS
--          WHERE  TABLE_NAME = 'tblTFReportingComponentConfiguration'
--                 AND COLUMN_NAME = 'ysnConfiguration') 
--				 BEGIN
--					EXEC('UPDATE tblTFReportingComponentConfiguration
--					SET ysnConfiguration = 0
--					WHERE ysnConfiguration IS NULL')
--				 END
				
--IF EXISTS(SELECT *
--          FROM   INFORMATION_SCHEMA.COLUMNS
--          WHERE  TABLE_NAME = 'tblTFReportingComponentConfiguration'
--                 AND COLUMN_NAME = 'intReportingComponentId') 
--				 BEGIN
--					EXEC('DELETE FROM tblTFReportingComponentConfiguration
--					WHERE intReportingComponentId = 0 
--					OR intReportingComponentId IS NULL')
--				 END

IF NOT EXISTS(SELECT * FROM  INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'tblSMCleanupLog') 
BEGIN
	CREATE TABLE [dbo].[tblSMCleanupLog]
	(
		[intCleanupLogId] INT NOT NULL PRIMARY KEY IDENTITY,
		[strModuleName] NVARCHAR(100) COLLATE Latin1_General_CI_AS NOT NULL,
		[strDesription] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NOT NULL,
		[dtmDate] DATETIME NOT NULL, 
		[dtmUtcDate] DATETIME NOT NULL, 
		[ysnActive] BIT NOT NULL
	)
END

IF EXISTS(SELECT * FROM  INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'tblSMCleanupLog') 
BEGIN
	
	IF NOT EXISTS(SELECT * FROM  tblSMCleanupLog WHERE strModuleName = 'MFT' AND strDesription = 'Overall-Cleanup' AND ysnActive = 1) 
	BEGIN
		
		PRINT('MFT Cleanup - Start')

		IF EXISTS(SELECT * FROM  INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'tblTFTaxAuthority') 
		BEGIN
			UPDATE tblTFTaxAuthority SET intMasterId = null
		END

		IF EXISTS(SELECT * FROM  INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'tblTFReportingComponentCriteria') 
		BEGIN
			DELETE FROM tblTFReportingComponentCriteria 
		END

		IF EXISTS(SELECT * FROM  INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'tblTFReportingComponentConfiguration') 
		BEGIN
			DELETE FROM tblTFReportingComponentConfiguration
		END
	
		IF EXISTS(SELECT * FROM  INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'tblTFReportingComponentField') 
		BEGIN
			DELETE FROM tblTFReportingComponentField
		END

		IF EXISTS(SELECT * FROM  INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'tblTFReportingComponentDestinationState') 
		BEGIN
			DELETE FROM tblTFReportingComponentDestinationState
		END

		IF EXISTS(SELECT * FROM  INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'tblTFReportingComponentOriginState') 
		BEGIN
			DELETE FROM tblTFReportingComponentOriginState
		END

		IF EXISTS(SELECT * FROM  INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'tblTFReportingComponentProductCode') 
		BEGIN
			DELETE FROM tblTFReportingComponentProductCode
		END

		IF EXISTS(SELECT * FROM  INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'tblTFFilingPacket') 
		BEGIN
			DELETE FROM tblTFFilingPacket
		END

		IF EXISTS(SELECT * FROM  INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'tblTFTaxCategory') 
		BEGIN
			DELETE FROM tblTFTaxCategory  WHERE intTaxCategoryId NOT IN(SELECT DISTINCT intTaxCategoryId FROM tblSMTaxCode WHERE intTaxCategoryId IS NOT NULL)	
			UPDATE tblTFTaxCategory SET intMasterId = NULL
		END

		IF EXISTS(SELECT * FROM  INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'tblTFProductCode') 
		BEGIN
			DELETE FROM tblTFProductCode WHERE intProductCodeId NOT IN (SELECT A.intProductCodeId FROM (
			SELECT DISTINCT intProductCodeId FROM tblICItemMotorFuelTax WHERE intProductCodeId IS NOT NULL
			UNION
			SELECT DISTINCT intProductCodeId FROM tblTFTransaction WHERE intProductCodeId IS NOT NULL) A)
			UPDATE tblTFProductCode SET intMasterId = NULL
		END

		IF EXISTS(SELECT * FROM  INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'tblTFTerminalControlNumber') 
		BEGIN
			DELETE FROM tblTFTerminalControlNumber WHERE intTerminalControlNumberId NOT IN (SELECT DISTINCT intTerminalControlNumberId FROM tblTRSupplyPoint WHERE intTerminalControlNumberId IS NOT NULL)
			UPDATE tblTFTerminalControlNumber SET intMasterId = NULL
		END

		IF EXISTS(SELECT * FROM  INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'tblTFReportingComponent') 
		BEGIN
			DELETE FROM tblTFReportingComponent WHERE intReportingComponentId NOT IN (SELECT DISTINCT intReportingComponentId FROM tblTFTransaction WHERE intReportingComponentId IS NOT NULL)
			UPDATE tblTFReportingComponent SET intMasterId = NULL
		END

		INSERT INTO tblSMCleanupLog VALUES('MFT', 'Overall-Cleanup', GETDATE(), GETUTCDATE(), 1)

		PRINT('MFT Cleanup - END')
	END
END