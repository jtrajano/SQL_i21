
PRINT('MFT Cleanup - Start')

IF EXISTS(SELECT * FROM  INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'tblTFTransaction') 
BEGIN
	PRINT('Truncate tblTFTransaction')
    EXEC('TRUNCATE TABLE tblTFTransaction')
END

-- Update Component Type from 5(EFile Main) to 4(EFile). EFile Main is obsolete
IF EXISTS(SELECT * FROM  INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'tblTFReportingComponent' AND COLUMN_NAME = 'intComponentTypeId') 
BEGIN
	PRINT('Update obsolete Component Type')
    EXEC('UPDATE tblTFReportingComponent SET intComponentTypeId = 4 WHERE intComponentTypeId = 5')
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

		-- Reporting Component Criteria
		IF EXISTS(SELECT * FROM  INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'tblTFReportingComponentCriteria') 
		BEGIN
			EXEC('TRUNCATE TABLE tblTFReportingComponentCriteria')
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
	
		-- Reporting Component Field
		IF EXISTS(SELECT * FROM  INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'tblTFReportingComponentField') 
		BEGIN
			EXEC('TRUNCATE TABLE tblTFReportingComponentField')
		END

		-- Reporting Component Destination State
		IF EXISTS(SELECT * FROM  INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'tblTFReportingComponentDestinationState') 
		BEGIN
			EXEC('TRUNCATE TABLE tblTFReportingComponentDestinationState')
		END

		-- Reporting Component Origin State
		IF EXISTS(SELECT * FROM  INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'tblTFReportingComponentOriginState') 
		BEGIN
			EXEC('TRUNCATE TABLE tblTFReportingComponentOriginState')
		END

		-- Origin Destination State
		IF EXISTS(SELECT * FROM  INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'tblTFOriginDestinationState') 
		BEGIN
			EXEC('DELETE FROM tblTFOriginDestinationState')
		END
		
		-- Reporting Component Product Code
		IF EXISTS(SELECT * FROM  INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'tblTFReportingComponentProductCode') 
		BEGIN
			EXEC('TRUNCATE TABLE tblTFReportingComponentProductCode')
		END

		-- Old Table that rename to tblTFReportingComponentProductCode
		IF EXISTS(SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'tblTFValidProductCode') 
		BEGIN
			EXEC('TRUNCATE TABLE tblTFValidProductCode')
		END

		-- Old Table that rename to tblTFReportingComponentVendor
		IF EXISTS(SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'tblTFValidVendor') 
		BEGIN
			EXEC('TRUNCATE TABLE tblTFValidVendor')
		END

		-- Old Table that rename to tblTFReportingComponentField
		IF EXISTS(SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'tblTFScheduleFields') 
		BEGIN
			EXEC('TRUNCATE TABLE tblTFScheduleFields')
		END

		-- Filing Packet
		IF EXISTS(SELECT * FROM  INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'tblTFFilingPacket') 
		BEGIN
			EXEC('TRUNCATE TABLE tblTFFilingPacket')
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
			EXEC('DELETE FROM tblTFReportingComponent')
		END

		IF EXISTS(SELECT * FROM  INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'tblTFReportingComponent' AND COLUMN_NAME = 'intMasterId') 
		BEGIN
			EXEC('UPDATE tblTFReportingComponent SET intMasterId = NULL')
		END

		INSERT INTO tblSMCleanupLog VALUES('MFT', 'Overall-Cleanup', GETDATE(), GETUTCDATE(), 1)	

	END
END

PRINT('MFT Cleanup - END')