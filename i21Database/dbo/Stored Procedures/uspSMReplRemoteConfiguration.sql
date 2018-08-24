

CREATE PROCEDURE [dbo].[uspSMReplicationRemoteConfiguration]
 @PublicationName nvarchar(50),
 @Publicationdb nvarchar(50) ,
 @RemoteAgentAccount nvarchar(50),
 @RemoteAgentPassword nvarchar(50),
 @RemoteSqlAccount nvarchar(50),
 @RemoteSqlPassword nvarchar(50),
 @MainServer nvarchar(50),
 @MainDatabase nvarchar(50),
 @MainSqlAccount nvarchar(50),
 @MainSqlPassword nvarchar(50)


 AS
 BEGIN
	---Configuring Replication
	EXEC sp_replicationdboption
		@dbname =@Publicationdb, --The upgraded database
		@optname = N'publish',
		@value = N'true'

	
	--execute this on the database of the upgraded build.
	EXEC sp_changedbowner 'sa'  

	EXEC sp_addlogreader_agent 
		 @publisher_security_mode = 0,
		 @publisher_login = @RemoteSqlAccount, -- SQL Server account, usually has sysadmin privilege
		 @publisher_password = @RemoteSqlPassword, -- SQL Server account password
		 @job_login = @RemoteAgentAccount, -- Windows account configured for replication
		 @job_password = @RemoteAgentPassword -- Windows account password      


	--execute this on the database of the upgraded build.
	EXEC sp_addpublication
		@publication = @PublicationName, -- Equivalent to concatenated [DATABASE_NAME] + "Publication", ex: '1830ProdPublication'
		@description = 'This is Description',
		@sync_method = N'concurrent',
		@retention = 0,
		@allow_push = N'true',
		@allow_pull = N'true',
		@allow_anonymous = N'false',
		@enabled_for_internet = N'false',
		@snapshot_in_defaultfolder = N'false',
		@compress_snapshot = N'false',
		@ftp_port = 21,
		@allow_subscription_copy = N'false',
		@add_to_active_directory = N'false',
		@repl_freq = N'continuous',
		@status = N'active',
		@independent_agent = N'true',
		@immediate_sync = N'false',
		@allow_sync_tran = N'false',
		@allow_queued_tran = N'false',
		@allow_dts = N'false',
		@replicate_ddl = 0,
		@allow_initialize_from_backup = N'false',
		@enabled_for_p2p = N'false',
		@enabled_for_het_sub = N'false'

	
	 EXEC uspSMDisconReplicationAddBidirectionalArticle
		@result = 0,
		@publication =@PublicationName

	 EXEC sp_addsubscription  
		 @publication = @PublicationName, 
		 @subscriber = @MainServer,  
		 @destination_db =  @MainDatabase, 
         @sync_type =  'replication support only',
		 @subscription_type = 'push',
		 @update_mode = N'read only',
		 @status = N'active'   

	EXEC sp_addpushsubscription_agent 
		 @publication= @PublicationName,  
		 @subscriber =  @MainServer,  
		 @subscriber_db =  @MainDatabase, 
		 @subscriber_security_mode =  0, 
		 @subscriber_login = @MainSqlAccount , 
		 @subscriber_password =  @MainSqlPassword, 
		 @job_login = @RemoteAgentAccount ,  
		 @job_password =  @RemoteAgentPassword,  
		 @frequency_type = 64, 
		@frequency_interval = 0, 
		@frequency_relative_interval = 0, 
		@frequency_recurrence_factor = 0, 
		@frequency_subday = 0, 
		@frequency_subday_interval = 0, 
		@active_start_time_of_day = 0, 
		@active_end_time_of_day = 235959, 
		@active_start_date = 20180426, 
		@active_end_date = 99991231, 
		@enabled_for_syncmgr = N'False', 
		@dts_package_location = N'Distributor'  

 


END
GO

