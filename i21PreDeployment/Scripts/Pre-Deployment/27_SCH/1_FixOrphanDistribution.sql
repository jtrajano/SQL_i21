
--=====================================================================================================================================
-- 	UPDATE FIELDS OF REPORT CRITERIA TABLES
---------------------------------------------------------------------------------------------------------------------------------------

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblSCHReportDistribution]') AND type in (N'U'))
BEGIN
	IF EXISTS (SELECT TOP 1 1 FROM tblSCHSchedule)
	BEGIN
		UPDATE tblSCHReportDistribution 
		SET intScheduleId = (SELECT TOP 1 intScheduleId FROM tblSCHSchedule)
		WHERE intScheduleId NOT IN (SELECT intScheduleId FROM tblSCHSchedule)
	END
	ELSE
	BEGIN
		DELETE FROM tblSCHReportDistribution WHERE intScheduleId NOT IN (SELECT intScheduleId FROM tblSCHSchedule)
	END
END
GO


