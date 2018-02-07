



CREATE  PROCEDURE [dbo].[uspSMReplicationLogReaderSetUp]
@job_login as sysname,
@job_password as sysname,
@publisher_security_mode as sysname
As
Begin
    SET QUOTED_IDENTIFIER OFF
	SET ANSI_NULLS ON
	SET NOCOUNT ON
	SET XACT_ABORT ON

	EXEC sp_addlogreader_agent 
	@job_login = @job_login, 
	@job_password = @job_password,
	-- Explicitly specify the use of Windows Integrated Authentication (default) 
	-- when connecting to the Publisher.
	@publisher_security_mode = @publisher_security_mode;
		
End
