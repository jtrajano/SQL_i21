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

		-- Tax Authority
		IF EXISTS(SELECT * FROM  INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'tblTFTaxAuthority' AND COLUMN_NAME = 'intMasterId') 
		BEGIN
			EXEC('UPDATE tblTFTaxAuthority SET intMasterId = null')
		END

		-- Reporting Component Criteria
		IF EXISTS(SELECT * FROM  INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'tblTFReportingComponentCriteria') 
		BEGIN
			EXEC('DELETE FROM tblTFReportingComponentCriteria')
		END

		-- Reporting Component Configuration
		IF EXISTS(SELECT * FROM  INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'tblTFReportingComponentConfiguration') 
		BEGIN
			EXEC('DELETE FROM tblTFReportingComponentConfiguration')
		END
	
		-- Reporting Component Field
		IF EXISTS(SELECT * FROM  INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'tblTFReportingComponentField') 
		BEGIN
			EXEC('DELETE FROM tblTFReportingComponentField')
		END

		-- Reporting Component Destination State
		IF EXISTS(SELECT * FROM  INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'tblTFReportingComponentDestinationState') 
		BEGIN
			EXEC('DELETE FROM tblTFReportingComponentDestinationState')
		END

		-- Reporting Component Origin State
		IF EXISTS(SELECT * FROM  INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'tblTFReportingComponentOriginState') 
		BEGIN
			EXEC('DELETE FROM tblTFReportingComponentOriginState')
		END

		-- Reporting Component Product Code
		IF EXISTS(SELECT * FROM  INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'tblTFReportingComponentProductCode') 
		BEGIN
			EXEC('DELETE FROM tblTFReportingComponentProductCode')
		END

		-- Filing Packet
		IF EXISTS(SELECT * FROM  INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'tblTFFilingPacket') 
		BEGIN
			EXEC('DELETE FROM tblTFFilingPacket')
		END

		-- Tax Category
		IF EXISTS(SELECT * FROM  INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'tblTFTaxCategory') 
		BEGIN
			EXEC('DELETE FROM tblTFTaxCategory  WHERE intTaxCategoryId NOT IN(SELECT DISTINCT intTaxCategoryId FROM tblSMTaxCode WHERE intTaxCategoryId IS NOT NULL)')
		END

		IF EXISTS(SELECT * FROM  INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'tblTFTaxCategory' AND COLUMN_NAME = 'intMasterId') 
		BEGIN
			EXEC('UPDATE tblTFTaxCategory SET intMasterId = NULL')
		END
		
		-- Product Code
		IF EXISTS(SELECT * FROM  INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'tblTFProductCode') 
		BEGIN
			EXEC('DELETE FROM tblTFProductCode WHERE intProductCodeId NOT IN (SELECT A.intProductCodeId FROM (
			SELECT DISTINCT intProductCodeId FROM tblICItemMotorFuelTax WHERE intProductCodeId IS NOT NULL
			UNION
			SELECT DISTINCT intProductCodeId FROM tblTFTransaction WHERE intProductCodeId IS NOT NULL) A)')	
		END

		IF EXISTS(SELECT * FROM  INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'tblTFProductCode' AND COLUMN_NAME = 'intMasterId') 
		BEGIN
			EXEC('UPDATE tblTFProductCode SET intMasterId = NULL')
		END

		-- Terminal Control Number
		IF EXISTS(SELECT * FROM  INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'tblTFTerminalControlNumber') 
		BEGIN
			EXEC('DELETE FROM tblTFTerminalControlNumber WHERE intTerminalControlNumberId NOT IN (SELECT DISTINCT intTerminalControlNumberId FROM tblTRSupplyPoint WHERE intTerminalControlNumberId IS NOT NULL)')
		END

		IF EXISTS(SELECT * FROM  INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'tblTFTerminalControlNumber' AND COLUMN_NAME = 'intMasterId') 
		BEGIN
			EXEC('UPDATE tblTFTerminalControlNumber SET intMasterId = NULL')
		END

		-- Reporting Component
		IF EXISTS(SELECT * FROM  INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'tblTFReportingComponent') 
		BEGIN
			EXEC('DELETE FROM tblTFReportingComponent WHERE intReportingComponentId NOT IN (SELECT DISTINCT intReportingComponentId FROM tblTFTransaction WHERE intReportingComponentId IS NOT NULL)')
		END

		IF EXISTS(SELECT * FROM  INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'tblTFReportingComponent' AND COLUMN_NAME = 'intMasterId') 
		BEGIN
			EXEC('UPDATE tblTFReportingComponent SET intMasterId = NULL')
		END

		INSERT INTO tblSMCleanupLog VALUES('MFT', 'Overall-Cleanup', GETDATE(), GETUTCDATE(), 1)

		PRINT('MFT Cleanup - END')

	END
END