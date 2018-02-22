


CREATE  PROCEDURE [dbo].[uspSMRepAddSubscription]
@publication as sysname,
@subscriber_servername as sysname,
@subscriber_db as sysname,
@subscriber_login as sysname,
@subscriber_password as sysname
As
Begin
    SET QUOTED_IDENTIFIER OFF
	SET ANSI_NULLS ON
	SET NOCOUNT ON
	SET XACT_ABORT ON
DECLARE @resultsub int;
DECLARE @resultagent int;

	exec @resultsub = sp_addsubscription 
        @publication =  @publication, 
        @subscriber = @subscriber_servername, 
        @destination_db = @subscriber_db, 
        @subscription_type = N'Push', 
        @sync_type = N'automatic', 
        @article = N'all', 
        @update_mode = N'read only', 
        @subscriber_type = 0;


    
        exec @resultagent = sp_addpushsubscription_agent 
        @publication = @publication, 
        @subscriber = @subscriber_servername,
        @subscriber_db = @subscriber_db, 
        @subscriber_security_mode = 0, 
        @subscriber_login = @subscriber_login, 
        @subscriber_password =  @subscriber_password, 
        @frequency_type = 64, 
        @frequency_interval = 0,
        @frequency_relative_interval = 0, 
        @frequency_recurrence_factor = 0, 
        @frequency_subday = 0, 
        @frequency_subday_interval = 0, 
        @active_start_time_of_day = 0, 
        @active_end_time_of_day = 235959, 
        @active_start_date = 20180122, 
        @active_end_date = 99991231, 
        @enabled_for_syncmgr = N'False', 
        @dts_package_location = N'Distributor';
        
    
	    
       IF(@resultsub = 0 and @resultagent = 0)
	         UPDATE tblSMReplicationSPResult SET result = 0;

		ELSE
			UPDATE tblSMReplicationSPResult SET result = 1;	 
		
End
