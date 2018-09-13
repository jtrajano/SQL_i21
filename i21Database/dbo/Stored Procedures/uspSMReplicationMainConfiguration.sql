

CREATE PROCEDURE  [dbo].[uspSMReplicationMainConfiguration]
 @publicationName nvarchar(50),
 @publicationdb nvarchar(50) ,
 @WindowsAgentAccount nvarchar(50),
 @WindowsAgentPassword nvarchar(50),
 @SQLAccount nvarchar(50),
 @SQLPassword nvarchar(50) 
 AS
 BEGIN
	---Configuring Replication
	exec sp_replicationdboption
		@dbname = @publicationdb, --The upgraded database
		@optname = N'publish',
		@value = N'true'

	
	--execute this on the database of the upgraded build.
	exec sp_changedbowner 'sa'  

	exec sp_addlogreader_agent 
		 @publisher_security_mode = 0,
		 @publisher_login = @SQLAccount, -- SQL Server account, usually has sysadmin privilege
		 @publisher_password = @SQLPassword, -- SQL Server account password
		 @job_login = @WindowsAgentAccount, -- Windows account configured for replication
		 @job_password = @WindowsAgentPassword -- Windows account password      


	--execute this on the database of the upgraded build.
	exec sp_addpublication
		@publication = @publicationName, -- Equivalent to concatenated [DATABASE_NAME] + "Publication", ex: '1830ProdPublication'
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

	
	 exec uspSMDisconReplicationAddBidirectionalArticle
		@result = 0,
		@publication = @publicationName

END