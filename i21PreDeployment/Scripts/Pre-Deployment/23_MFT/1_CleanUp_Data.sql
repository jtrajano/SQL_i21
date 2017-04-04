IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = N'tblTFReportingComponentProductCode' AND COLUMN_NAME = 'intProductCodeId')
		BEGIN
			EXEC('DELETE FROM tblTFReportingComponentProductCode
			WHERE intProductCodeId IS NULL')
		END

IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = N'tblTFReportingComponentProductCode' AND COLUMN_NAME = 'intConcurrencyId')
		BEGIN
			EXEC('UPDATE tblTFReportingComponentProductCode
			SET intConcurrencyId = 1
			WHERE intConcurrencyId IS NULL')
		END

IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = N'tblTFReportingComponent' AND COLUMN_NAME = 'intConcurrencyId')
		BEGIN
			EXEC('UPDATE tblTFReportingComponent
			SET intConcurrencyId = 1
			WHERE intConcurrencyId IS NULL')
		END

DECLARE @COUNT INT
	SET @COUNT = (SELECT COUNT(*) Names 
		FROM sys.columns 
		WHERE OBJECT_ID = OBJECT_ID('tblTFFilingPacket')
		AND Name in ('intReportingComponentId', 'intTaxAuthorityId'))
		IF (@COUNT = 2)
			BEGIN
				EXEC('DELETE FROM tblTFFilingPacket WHERE intReportingComponentId = 70 AND intTaxAuthorityId = 27')
				EXEC('DELETE FROM tblTFFilingPacket WHERE intReportingComponentId = 161 AND intTaxAuthorityId = 14')
			END

IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = N'tblTFReportingComponentField')
		BEGIN
			EXEC('DELETE FROM tblTFReportingComponentField')
		END

IF EXISTS(SELECT *
          FROM   INFORMATION_SCHEMA.COLUMNS
          WHERE  TABLE_NAME = 'tblTFReportingComponentConfiguration'
                 AND COLUMN_NAME = 'ysnConfiguration') 
				 BEGIN
					EXEC('UPDATE tblTFReportingComponentConfiguration
					SET ysnConfiguration = 0
					WHERE ysnConfiguration IS NULL')
				 END
				
IF EXISTS(SELECT *
          FROM   INFORMATION_SCHEMA.COLUMNS
          WHERE  TABLE_NAME = 'tblTFReportingComponentConfiguration'
                 AND COLUMN_NAME = 'intReportingComponentId') 
				 BEGIN
					EXEC('DELETE FROM tblTFReportingComponentConfiguration
					WHERE intReportingComponentId = 0 
					OR intReportingComponentId IS NULL')
				 END