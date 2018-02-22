
CREATE PROCEDURE [dbo].[uspSMRepAddLogReaderAgent] 
@login sysname,
@password sysname
AS
    SET QUOTED_IDENTIFIER OFF
	SET ANSI_NULLS ON
	SET NOCOUNT ON
	SET XACT_ABORT ON

BEGIN
	DECLARE @result int;
		EXEC @result = sp_addlogreader_agent  @publisher_security_mode = 0, @publisher_login = @login, @publisher_password = @password
	UPDATE tblSMReplicationSPResult SET result = @result
	
END
