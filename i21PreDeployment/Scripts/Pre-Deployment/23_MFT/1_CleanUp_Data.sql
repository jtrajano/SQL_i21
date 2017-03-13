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

IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = N'tblTFReportingComponentConfiguration')
		BEGIN
			UPDATE tblTFReportingComponentConfiguration
			SET ysnConfiguration = 0
			WHERE ysnConfiguration IS NULL
		END