
CREATE PROCEDURE [dbo].[uspSMReplicationPullSubscription]
@MainServer NVARCHAR(100),
@MainDatabase NVARCHAR(100),
@MainPublicationName NVARCHAR(MAX),
@MainSqlAccount NVARCHAR(50),
@MainSqlPassword NVARCHAR(50),
@RemoteAgentAccount NVARCHAR(100),
@RemoteAgentPassword NVARCHAR(50)
AS

BEGIN

	Exec sp_addpullsubscription 
		@publisher=  @MainServer, 
		@publisher_db= @MainDatabase, 
		@publication=  @MainPublicationName,  
		@subscription_type=  'pull',
		@description=  'Pull subscription for remote from main server' 

		exec sp_addpullsubscription_agent
 @publisher = @MainServer, 
 @publisher_db =@MainDatabase, 
 @publication = @MainPublicationName,
  @distributor = @MainServer,
   @distributor_security_mode = 0,
 --@distribution_db = 'distribution',
    @distributor_login = @MainSqlAccount,
	 @distributor_password = @MainSqlPassword,
	  @enabled_for_syncmgr = N'False',
	   @frequency_type = 64,
	    @frequency_interval = 0, 
		@frequency_relative_interval = 0,
		 @frequency_recurrence_factor = 0, 
		 @frequency_subday = 0,
		  @frequency_subday_interval = 0, 
		  @active_start_time_of_day = 0, 
		  @active_end_time_of_day = 235959, 
		  @active_start_date = 20180709, 
		  @active_end_date = 99991231, 
		  @alt_snapshot_folder = N'', 
		  @working_directory = N'', 
		  @use_ftp = N'False', 
		  @job_login = @RemoteAgentAccount,
		   @job_password = @RemoteAgentPassword, 
		   @publication_type = 0
END
GO

