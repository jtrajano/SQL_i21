GO
	PRINT N'START REMOVE AUDIT MIGRATION JOB'
	BEGIN
		DECLARE @jobId BINARY(16)
		DECLARE @CURRENT_DB nvarchar(max)
		SET @CURRENT_DB = DB_NAME()

		SELECT @jobId = job_id FROM msdb.dbo.sysjobs where [name] = 'i21_AuditLog_Migration_Job_' +@CURRENT_DB

		IF(@jobId is not null)
			begin
				--EXEC msdb.dbo.sp_update_job @job_name='i21_AuditLog_Migration_Job',@enabled = 0--disable job
				exec msdb.dbo.sp_delete_job @job_id = @jobId
			end

	--	IF(EXISTS(SELECT TOP 1 1 FROM sys.columns WHERE NAME = N'ysnAuditBatchMigrated' AND OBJECT_ID  = OBJECT_ID(N'tblSMCompanySetup')))
		IF(EXISTS(SELECT * FROM  INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'tblSMCompanySetup' AND COLUMN_NAME = 'ysnAuditBatchMigrated'))
			begin
				exec(' update tblSMCompanySetup set ysnAuditBatchMigrated = null ')
			end
	END
	PRINT N'END REMOVE AUDIT MIGRATION JOB'
GO
