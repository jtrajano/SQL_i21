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

			DECLARE @RCID1 INT
			
			DECLARE @CountDeleted INT
			SET @RCID1 = (SELECT TOP 1 intReportingComponentId 
			FROM tblTFReportingComponent 
			WHERE strType = 'NE EDI')

			IF (@RCID1 IS NOT NULL)
			BEGIN
				DELETE FROM tblTFFilingPacket 
				WHERE intReportingComponentId = @RCID1

				SET @CountDeleted = (SELECT @@ROWCOUNT)
				IF(@CountDeleted > 0)
				BEGIN
					DELETE FROM tblTFReportingComponent 
					WHERE strType = 'NE EDI'
				END
			END

			DECLARE @RCID2 INT
			SET @CountDeleted = 0
			SET @RCID2 = (SELECT TOP 1 intReportingComponentId 
			FROM tblTFReportingComponent 
			WHERE strType = 'EDI' AND strScheduleName = 'NE EDI file')

			IF (@RCID2 IS NOT NULL)
			BEGIN
				DELETE FROM tblTFFilingPacket 
				WHERE intReportingComponentId = @RCID2

				SET @CountDeleted = (SELECT @@ROWCOUNT)
				IF(@CountDeleted > 0)
				BEGIN
					DELETE FROM tblTFReportingComponent 
					WHERE strType = 'EDI' AND strScheduleName = 'NE EDI file'
				END
			END
		END

IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = N'tblTFReportingComponentConfiguration')
		BEGIN
			UPDATE tblTFReportingComponentConfiguration
			SET ysnConfiguration = 0
			WHERE ysnConfiguration IS NULL

			DELETE FROM tblTFReportingComponentConfiguration
			WHERE intReportingComponentId = 0 OR intReportingComponentId IS NULL
		END
