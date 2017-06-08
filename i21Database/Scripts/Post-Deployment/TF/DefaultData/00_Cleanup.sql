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

DELETE FROM tblTFFilingPacket
WHERE intReportingComponentId IN (
		SELECT intReportingComponentId
		FROM tblTFReportingComponent RC
		LEFT JOIN (
			SELECT DISTINCT strFormCode, strScheduleCode, strType
			FROM tblTFReportingComponent
			WHERE strFormCode != 'EDI'
			GROUP BY strFormCode, strScheduleCode, strType
			HAVING COUNT(*) > 1
		) Dup ON Dup.strFormCode = RC.strFormCode
			AND Dup.strScheduleCode = RC.strScheduleCode
			AND Dup.strType = RC.strType
		WHERE ISNULL(Dup.strFormCode, '') != ''
			AND ISNULL(Dup.strScheduleCode, '') != ''
			AND ISNULL(Dup.strType, '') != ''
	) AND intReportingComponentId NOT IN (
		SELECT intReportingComponentId = MIN(intReportingComponentId)
		FROM tblTFReportingComponent RC
		LEFT JOIN (
			SELECT DISTINCT strFormCode, strScheduleCode, strType
			FROM tblTFReportingComponent
			WHERE strFormCode != 'EDI'
			GROUP BY strFormCode, strScheduleCode, strType
			HAVING COUNT(*) > 1
		) Dup ON Dup.strFormCode = RC.strFormCode
			AND Dup.strScheduleCode = RC.strScheduleCode
			AND Dup.strType = RC.strType
		WHERE ISNULL(Dup.strFormCode, '') != ''
			AND ISNULL(Dup.strScheduleCode, '') != ''
			AND ISNULL(Dup.strType, '') != ''
		GROUP BY Dup.strFormCode
			, Dup.strScheduleCode
			, Dup.strType	
	)

GO

DELETE FROM tblTFReportingComponent
WHERE intReportingComponentId IN (
		SELECT intReportingComponentId
		FROM tblTFReportingComponent RC
		LEFT JOIN (
			SELECT DISTINCT strFormCode, strScheduleCode, strType
			FROM tblTFReportingComponent
			WHERE strFormCode != 'EDI'
			GROUP BY strFormCode, strScheduleCode, strType
			HAVING COUNT(*) > 1
		) Dup ON Dup.strFormCode = RC.strFormCode
			AND Dup.strScheduleCode = RC.strScheduleCode
			AND Dup.strType = RC.strType
		WHERE ISNULL(Dup.strFormCode, '') != ''
			AND ISNULL(Dup.strScheduleCode, '') != ''
			AND ISNULL(Dup.strType, '') != ''
	) AND intReportingComponentId NOT IN (
		SELECT intReportingComponentId = MIN(intReportingComponentId)
		FROM tblTFReportingComponent RC
		LEFT JOIN (
			SELECT DISTINCT strFormCode, strScheduleCode, strType
			FROM tblTFReportingComponent
			WHERE strFormCode != 'EDI'
			GROUP BY strFormCode, strScheduleCode, strType
			HAVING COUNT(*) > 1
		) Dup ON Dup.strFormCode = RC.strFormCode
			AND Dup.strScheduleCode = RC.strScheduleCode
			AND Dup.strType = RC.strType
		WHERE ISNULL(Dup.strFormCode, '') != ''
			AND ISNULL(Dup.strScheduleCode, '') != ''
			AND ISNULL(Dup.strType, '') != ''
		GROUP BY Dup.strFormCode
			, Dup.strScheduleCode
			, Dup.strType	
	)

GO