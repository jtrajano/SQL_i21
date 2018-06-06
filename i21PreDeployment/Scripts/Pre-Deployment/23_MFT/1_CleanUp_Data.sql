
PRINT('MFT Cleanup - Start')

IF EXISTS(SELECT * FROM  INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'tblTFTransactions') 
BEGIN
	-- Old table
	PRINT('Drop tblTFTransactions')
    EXEC('DROP TABLE tblTFTransactions')
END

IF EXISTS(SELECT * FROM  INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'tblTFValidProductCode') 
BEGIN
	-- Old table
	PRINT('Drop tblTFValidProductCode')
    EXEC('DROP TABLE tblTFValidProductCode')
END

IF EXISTS(SELECT * FROM  INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'tblTFTaxCriteria') 
BEGIN
	-- Old table
	PRINT('Drop tblTFTaxCriteria')
    EXEC('DROP TABLE tblTFTaxCriteria')
END

-- Old Table that rename to tblTFReportingComponentVendor
IF EXISTS(SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'tblTFValidVendor') 
BEGIN
	-- Old table
	PRINT('Drop tblTFValidVendor')
	EXEC('DROP TABLE tblTFValidVendor')
END

-- Old Table that rename to tblTFReportingComponentField
IF EXISTS(SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'tblTFScheduleFields') 
BEGIN
	-- Old table
	PRINT('Drop tblTFScheduleFields')
	EXEC('DROP TABLE tblTFScheduleFields')
END

-- Reporting Component Criteria
IF EXISTS(SELECT * FROM  INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'tblTFReportingComponentCriteria') 
BEGIN
	PRINT('Truncate tblTFReportingComponentCriteria')
	EXEC('TRUNCATE TABLE tblTFReportingComponentCriteria')
END

-- Reporting Component Field
IF EXISTS(SELECT * FROM  INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'tblTFReportingComponentField') 
BEGIN
	PRINT('Truncate tblTFReportingComponentField')
	EXEC('TRUNCATE TABLE tblTFReportingComponentField')
END

-- Reporting Component Destination State
IF EXISTS(SELECT * FROM  INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'tblTFReportingComponentDestinationState') 
BEGIN
	PRINT('Truncate tblTFReportingComponentDestinationState')
	EXEC('TRUNCATE TABLE tblTFReportingComponentDestinationState')
END

-- Reporting Component Origin State
IF EXISTS(SELECT * FROM  INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'tblTFReportingComponentOriginState') 
BEGIN
	PRINT('Truncate tblTFReportingComponentOriginState')
	EXEC('TRUNCATE TABLE tblTFReportingComponentOriginState')
END

-- Reporting Component Product Code
IF EXISTS(SELECT * FROM  INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'tblTFReportingComponentProductCode') 
BEGIN
	PRINT('Truncate tblTFReportingComponentProductCode')
	EXEC('TRUNCATE TABLE tblTFReportingComponentProductCode')
END

IF EXISTS(SELECT * FROM  INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'tblTFTransactionSummary') 
BEGIN
	PRINT('Truncate tblTFTransactionSummary')
    EXEC('TRUNCATE TABLE tblTFTransactionSummary')
END	

IF EXISTS(SELECT * FROM  INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'tblTFTransactionDynamicOR') 
BEGIN
	PRINT('Truncate tblTFTransactionDynamicOR')
    EXEC('TRUNCATE TABLE tblTFTransactionDynamicOR')
END

IF EXISTS(SELECT * FROM  INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'tblTFTransaction') 
BEGIN
	PRINT('Truncate tblTFTransaction')
    EXEC('DELETE FROM tblTFTransaction')
END

-- Update Component Type from 5(EFile Main) to 4(EFile). EFile Main is obsolete
IF EXISTS(SELECT * FROM  INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'tblTFReportingComponent' AND COLUMN_NAME = 'intComponentTypeId') 
BEGIN
	PRINT('Update obsolete Component Type')
    EXEC('UPDATE tblTFReportingComponent SET intComponentTypeId = 4 WHERE intComponentTypeId = 5')
	EXEC('UPDATE tblTFReportingComponent SET intComponentTypeId = 4 WHERE intComponentTypeId = 7')
END

-- Clean up of all non-unique strTemplateItemId in tblTFReportingComponentConfiguration
IF EXISTS(SELECT * FROM  INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'tblTFReportingComponentConfiguration' AND COLUMN_NAME = 'strTemplateItemId') 
BEGIN
	PRINT('Cleanup of non-unique TemplateItemId in tblTFReportingComponentConfiguration')

	EXEC('UPDATE tblTFReportingComponentConfiguration SET strTemplateItemId = NEWID() WHERE intReportingComponentConfigurationId IN (
		SELECT A.intReportingComponentConfigurationId FROM tblTFReportingComponentConfiguration A
		INNER JOIN (SELECT intReportingComponentId, strTemplateItemId FROM tblTFReportingComponentConfiguration 
		GROUP BY intReportingComponentId, strTemplateItemId
		HAVING COUNT(strTemplateItemId) > 1) B 
		ON A.intReportingComponentId = B.intReportingComponentId AND A.strTemplateItemId = B.strTemplateItemId)')

	EXEC('UPDATE tblTFReportingComponentConfiguration SET strTemplateItemId = NEWID() WHERE strTemplateItemId IS NULL')

	IF EXISTS(SELECT * FROM  INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'tblTFReportingComponentConfiguration' AND COLUMN_NAME = 'intMasterId') 
	BEGIN
		EXEC('DELETE tblTFReportingComponentConfiguration WHERE intMasterId IS NULL')
	END
END

IF NOT EXISTS(SELECT * FROM  INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'tblSMCleanupLog') 
BEGIN
	PRINT('Create tblSMCleanupLog')
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
		
		PRINT('Cleanup MFT Tables')

		-- Tax Authority
		IF EXISTS(SELECT * FROM  INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'tblTFTaxAuthority' AND COLUMN_NAME = 'intMasterId') 
		BEGIN
			EXEC('UPDATE tblTFTaxAuthority SET intMasterId = null')
		END

		IF EXISTS(SELECT * FROM  INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'tblTFTaxAuthority' AND COLUMN_NAME = 'ysnFilingForThisTA') 
		BEGIN
			EXEC('UPDATE tblTFTaxAuthority SET ysnFilingForThisTA = 0')
		END

		-- Reporting Component Configuration
		IF EXISTS(SELECT * FROM  INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'tblTFReportingComponentConfiguration' AND COLUMN_NAME = 'ysnUserDefinedValue' ) 
		BEGIN
			EXEC('DELETE FROM tblTFReportingComponentConfiguration WHERE ysnUserDefinedValue = 0')
		END
		ELSE IF EXISTS(SELECT * FROM  INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'tblTFReportingComponentConfiguration' AND COLUMN_NAME = 'ysnDynamicConfiguration' ) 
		BEGIN
			EXEC('DELETE FROM tblTFReportingComponentConfiguration')
		END

		-- Origin Destination State
		IF EXISTS(SELECT * FROM  INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'tblTFOriginDestinationState') 
		BEGIN
			EXEC('DELETE FROM tblTFOriginDestinationState')
		END

		-- Tax Category
		IF EXISTS(SELECT * FROM  INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'tblTFTaxCategory') AND EXISTS(SELECT * FROM  INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'tblSMTaxCode')
		BEGIN
			EXEC('DELETE FROM tblTFTaxCategory  WHERE intTaxCategoryId NOT IN(SELECT DISTINCT intTaxCategoryId FROM tblSMTaxCode WHERE intTaxCategoryId IS NOT NULL)')
		END

		IF EXISTS(SELECT * FROM  INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'tblTFTaxCategory' AND COLUMN_NAME = 'intMasterId') 
		BEGIN
			EXEC('UPDATE tblTFTaxCategory SET intMasterId = NULL')
		END
		
		-- Product Code
		IF EXISTS(SELECT * FROM  INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'tblTFProductCode')  AND EXISTS(SELECT * FROM  INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'tblICItemMotorFuelTax') AND EXISTS(SELECT * FROM  INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'tblTFTransaction')
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
		IF EXISTS(SELECT * FROM  INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'tblTFTerminalControlNumber') AND EXISTS(SELECT * FROM  INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'tblTRSupplyPoint')
		BEGIN
			EXEC('DELETE FROM tblTFTerminalControlNumber WHERE intTerminalControlNumberId NOT IN (SELECT DISTINCT intTerminalControlNumberId FROM tblTRSupplyPoint WHERE intTerminalControlNumberId IS NOT NULL)')
		END

		IF EXISTS(SELECT * FROM  INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'tblTFTerminalControlNumber' AND COLUMN_NAME = 'intMasterId') 
		BEGIN
			EXEC('UPDATE tblTFTerminalControlNumber SET intMasterId = NULL')
		END

		-- Filing Packet
		IF EXISTS(SELECT * FROM  INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'tblTFFilingPacket') 
		BEGIN
			PRINT('Truncate tblTFFilingPacket')
			EXEC('TRUNCATE TABLE tblTFFilingPacket')
		END

		-- Reporting Component
		IF EXISTS(SELECT * FROM  INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'tblTFReportingComponent') 
		BEGIN
			EXEC('DELETE FROM tblTFReportingComponent')
		END

		IF EXISTS(SELECT * FROM  INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'tblTFReportingComponent' AND COLUMN_NAME = 'intMasterId') 
		BEGIN
			EXEC('UPDATE tblTFReportingComponent SET intMasterId = NULL')
		END

		INSERT INTO tblSMCleanupLog VALUES('MFT', 'Overall-Cleanup', GETDATE(), GETUTCDATE(), 1)	

	END

END

IF EXISTS(SELECT * FROM  INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'tblTFTaxAuthorityBeginEndInventoryDetail') 
BEGIN
	EXEC('DROP TABLE tblTFTaxAuthorityBeginEndInventoryDetail')
END

IF EXISTS(SELECT * FROM  INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'tblTFTaxAuthorityBeginEndInventory' AND COLUMN_NAME = 'intEntityLocationId') 
BEGIN
	EXEC('TRUNCATE TABLE tblTFTaxAuthorityBeginEndInventory')
END


IF EXISTS(SELECT * FROM  INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'tblTFReportingComponent') 
BEGIN
	IF NOT EXISTS(SELECT * FROM  INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'tblTFReportingComponent' AND COLUMN_NAME = 'strStoredProcedure') 
	BEGIN
		EXEC('ALTER TABLE tblTFReportingComponent ADD strStoredProcedure NVARCHAR(100)')
		IF EXISTS(SELECT * FROM  INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'tblTFReportingComponent' AND (COLUMN_NAME = 'strSPInventory' OR COLUMN_NAME = 'strSPInvoice' OR COLUMN_NAME = 'strSPRunReport'))
		BEGIN
			EXEC('UPDATE tblTFReportingComponent SET strStoredProcedure = (CASE WHEN strTransactionType = ''Inventory'' THEN strSPInventory WHEN strTransactionType = ''Invoice'' THEN strSPInvoice ELSE strSPRunReport END)')
		END
	END
END



PRINT('MFT Cleanup - END')

GO