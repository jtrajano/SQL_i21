		CREATE PROCEDURE [dbo].[uspSMReplicationAddSubscriptionForRemote]
		 @PublicationName NVARCHAR(50),
		 @RemoteServerName NVARCHAR(50),
		 @RemoteDB NVARCHAR(50)

		AS
		BEGIN
		  exec sp_addsubscription 
			@publication = @PublicationName, 
			@subscriber = @RemoteServerName, 
			@destination_db = @RemoteDB, 
			@subscription_type = N'Pull', 
			@sync_type = N'replication support only', 
			@article = N'all', 
			@update_mode = N'read only', 
			@subscriber_type = 0, 
			@status = N'active' 

		END