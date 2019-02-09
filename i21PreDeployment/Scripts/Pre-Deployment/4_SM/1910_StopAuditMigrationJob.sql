GO
	PRINT N'START STOP AUDIT MIGRATION JOB'
	BEGIN
		DECLARE @jobId BINARY(16)

		SELECT @jobId = job_id FROM msdb.dbo.sysjobs where [name] = 'i21_AuditLog_Migration_Job'

		IF(@jobId is not null)
			begin
				EXEC msdb.dbo.sp_update_job @job_name='i21_AuditLog_Migration_Job',@enabled = 0--disable job
			end
	END
	PRINT N'END AUDIT MIGRATION JOB'
GO
