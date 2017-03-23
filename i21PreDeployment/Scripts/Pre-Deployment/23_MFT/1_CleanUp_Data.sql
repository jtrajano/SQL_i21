IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = N'tblTFReportingComponentProductCode')
		BEGIN
			DELETE FROM tblTFReportingComponentProductCode
			WHERE intProductCodeId IS NULL

			UPDATE tblTFReportingComponentProductCode
			SET intConcurrencyId = 1
			WHERE intConcurrencyId IS NULL
		END

IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = N'tblTFReportingComponent')
		BEGIN
			UPDATE tblTFReportingComponent
			SET intConcurrencyId = 1
			WHERE intConcurrencyId IS NULL
		END

IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = N'tblTFFilingPacket')
		BEGIN
			DELETE FROM tblTFFilingPacket WHERE intReportingComponentId = '70' AND intTaxAuthorityId = 27
			DELETE FROM tblTFFilingPacket WHERE intReportingComponentId = '161' AND intTaxAuthorityId = 14
		END

IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = N'tblTFReportingComponentField')
		BEGIN
			DELETE FROM tblTFReportingComponentField
		END

IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = N'tblTFReportingComponentConfiguration')
		BEGIN
		  IF EXISTS(SELECT *
          FROM   INFORMATION_SCHEMA.COLUMNS
          WHERE  TABLE_NAME = 'tblTFReportingComponentConfiguration'
                 AND COLUMN_NAME = 'ysnConfiguration') 
				 BEGIN
					UPDATE tblTFReportingComponentConfiguration
					SET ysnConfiguration = 0
					WHERE ysnConfiguration IS NULL
				 END
				
		  IF EXISTS(SELECT *
          FROM   INFORMATION_SCHEMA.COLUMNS
          WHERE  TABLE_NAME = 'tblTFReportingComponentConfiguration'
                 AND COLUMN_NAME = 'intReportingComponentId') 
				 BEGIN
					DELETE FROM tblTFReportingComponentConfiguration
					WHERE intReportingComponentId = 0 
					OR intReportingComponentId IS NULL
				 END
		END
