PRINT ('Cleanup Tax Form tables')

IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = N'tblTFValidOriginState' AND COLUMN_NAME = 'strFilter')
		BEGIN
			EXEC('DELETE FROM tblTFValidOriginState
			WHERE ISNULL(strFilter, '''') = ''''')
		END

IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = N'tblTFReportingComponent' AND COLUMN_NAME = 'strScheduleName')
		BEGIN
			EXEC('DELETE FROM tblTFReportingComponent WHERE strScheduleName = ''NE EDI file''')
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

GO

