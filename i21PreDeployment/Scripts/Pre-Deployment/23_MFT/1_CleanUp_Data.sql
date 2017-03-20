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

			DECLARE @RCID INT
			DECLARE @CountDeleted INT
			SET @RCID = (SELECT TOP 1 intReportingComponentId 
			FROM tblTFReportingComponent 
			WHERE strType = 'NE EDI')

			IF (@RCID IS NOT NULL)
			BEGIN
				DELETE FROM tblTFFilingPacket 
				WHERE intReportingComponentId = @RCID

				SET @CountDeleted = (SELECT @@ROWCOUNT)
				IF(@CountDeleted > 0)
				BEGIN
					DELETE FROM tblTFReportingComponent 
					WHERE strType = 'NE EDI'
				END
			END
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
