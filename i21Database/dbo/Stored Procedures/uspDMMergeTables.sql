CREATE PROCEDURE [dbo].[uspDMMergeTables]
    @remoteDBServer NVARCHAR(MAX),
    @remoteDB NVARCHAR(MAX),
    @remoteDBUserId NVARCHAR(MAX),
    @remoteDBPassword NVARCHAR(MAX)
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON

DECLARE @SQLString NVARCHAR(MAX) = '';

IF EXISTS(SELECT * FROM sys.servers WHERE name = N'REMOTEDBSERVER')
    EXECUTE sp_dropserver 'REMOTEDBSERVER', 'droplogins';

EXECUTE sp_addlinkedserver @server = N'REMOTEDBSERVER',
    @srvproduct = N'',
    @provider = N'SQLNCLI',
    @datasrc = @remoteDBServer;

EXECUTE sp_addlinkedsrvlogin 'REMOTEDBSERVER', 'false', NULL, @remoteDBUserId, @remoteDBPassword;

IF @remoteDBServer IS NOT NULL
BEGIN

    EXEC sp_configure 'remote query timeout', 0;

    RECONFIGURE;

    EXEC uspDMAlterConstraint;

    EXEC uspDMMergeEMTables
		@remoteDB = @remoteDB;

	EXEC uspDMMergeSMTables
		@remoteDB = @remoteDB;

    EXEC uspDMMergeGRTables
		@remoteDB = @remoteDB;

    EXEC uspDMMergeCTTables
		@remoteDB = @remoteDB;

    EXEC uspDMMergeLGTables
		@remoteDB = @remoteDB;

    EXEC uspDMMergeICTables
		@remoteDB = @remoteDB;

    EXEC uspDMMergeQMTables
        @remoteDB = @remoteDB;

    EXEC uspDMMergeSCTables
		@remoteDB = @remoteDB;

    EXEC uspDMAlterConstraint 'Check';

END