
CREATE PROCEDURE [dbo].[uspSMRepRestoreSubscription]
AS
BEGIN
    SET QUOTED_IDENTIFIER OFF
	SET ANSI_NULLS ON
	SET NOCOUNT ON
	SET XACT_ABORT ON

	DECLARE @parentMultiCompanyId int;

	DECLARE @query nvarchar(max) = N'';
	SET @query =  @query + N'	
								IF [dbo].fnSMRepDatabaseExists(''@db'') = 1
									BEGIN
										
										EXEC sp_helpsubscription
											@publication = ''i21Publication'',	
											@subscriber = @@SERVERNAME,
											@destination_db = ''@db'',
											@found = @found OUTPUT;	

										IF @found = 0
											BEGIN 
												exec uspSMRepAddSubscription
												@publication = N''i21Publication'',
												@subscriber_servername = @@SERVERNAME,
												@subscriber_db = N''@db'',
												@subscriber_login = N''irelyinstaller'',
												@subscriber_password = N''RPWc3BK5'',
												@sync_type = N''replication support only''
											END
									END;
									
									';

	DECLARE @toExecQuery nvarchar(max) = N'';
	

	select @parentMultiCompanyId = intMultiCompanyId from  tblSMMultiCompany where strDatabaseName = DB_NAME()
	Select @toExecQuery += REPLACE(@query,'@db', strDatabaseName) from tblSMMultiCompany where intMultiCompanyParentId = @parentMultiCompanyId;
	set @toExecQuery = N'DEClARE @found as int; ' + @toExecQuery;



	EXEC ( @toExecQuery )
END		
	



		
