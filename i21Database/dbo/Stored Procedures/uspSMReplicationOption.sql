

CREATE  PROCEDURE [dbo].[uspSMReplicationOption]
@publicationDB as sysname
AS
BEGIN
    SET QUOTED_IDENTIFIER OFF
	SET ANSI_NULLS ON
	SET NOCOUNT ON
	SET XACT_ABORT ON

-- Enable transactional or snapshot replication on the publication database.
    EXEC sp_replicationdboption 
	@dbname=@publicationDB, 
	@optname=N'publish',
	@value = N'true';
END