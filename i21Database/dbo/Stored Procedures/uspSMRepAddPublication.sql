

CREATE PROCEDURE [dbo].[uspSMRepAddPublication]
@publication as sysname,
@alt_snapshot_folder as sysname,
@login  sysname,
@password  sysname,
@pre_snapshot_script nvarchar(255),
@post_snapshot_script nvarchar(255)
As
Begin
    SET QUOTED_IDENTIFIER OFF
	SET ANSI_NULLS ON
	SET NOCOUNT ON
	SET XACT_ABORT ON
-- Enable transactional or snapshot replication on the publication database.

Declare @result int;
 exec @result = sp_addpublication 
   @publication = @publication,
   @pre_snapshot_script = @pre_snapshot_script, 
   @post_snapshot_script =  @post_snapshot_script, 
   @description = N'Transactional publication',
   @sync_method = N'concurrent', 
   @retention = 0, 
   @allow_push = N'true', 
   @allow_pull = N'true', 
   @allow_anonymous = N'true', 
   @enabled_for_internet = N'false', 
   @snapshot_in_defaultfolder =  N'false', 
   @compress_snapshot = N'false',
    @ftp_port = 21, 
    @allow_subscription_copy = N'false',
    @add_to_active_directory = N'false', 
    @repl_freq = N'continuous', 
    @status = N'active', 
    @independent_agent = N'true', 
    @immediate_sync = N'true', 
    @allow_sync_tran = N'false',
    @allow_queued_tran = N'false', 
    @allow_dts = N'false',
    @replicate_ddl = 0, -- 0 to ensure that schema changes where not be replicated 
    @allow_initialize_from_backup = N'false',
    @enabled_for_p2p = N'false', 
    @enabled_for_het_sub = N'false',
	@alt_snapshot_folder= @alt_snapshot_folder;



    EXEC @result = sp_addpublication_snapshot 
			@publication = @publication, 	
			@publisher_security_mode = 0, 
			@publisher_login = @login, 
			@publisher_password =@password;

    UPDATE tblSMReplicationSPResult SET result = @result;	

End