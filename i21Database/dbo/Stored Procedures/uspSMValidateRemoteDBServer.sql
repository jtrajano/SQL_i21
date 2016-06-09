CREATE PROCEDURE [dbo].[uspSMValidateRemoteDBServer]
    @remoteDBServer NVARCHAR(MAX),
    @remoteDB NVARCHAR(MAX),
    @remoteDBUserId NVARCHAR(MAX),
    @remoteDBPassword NVARCHAR(MAX)
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON

DECLARE @SQLString NVARCHAR(MAX);

IF EXISTS(SELECT * FROM sys.servers WHERE name = N'REMOTEDBSERVER')
    EXECUTE sp_dropserver 'REMOTEDBSERVER', 'droplogins';

EXECUTE sp_addlinkedserver @server = N'REMOTEDBSERVER',
    @srvproduct = N'',
    @provider = N'SQLNCLI',
    @datasrc = @remoteDBServer;

EXECUTE sp_addlinkedsrvlogin 'REMOTEDBSERVER', 'false', NULL, @remoteDBUserId, @remoteDBPassword;

SET @SQLString = N'EXEC(''SELECT * FROM REMOTEDBSERVER.' + @remoteDB + '.dbo.tblSMOfflineConfiguration'')';

EXECUTE sp_executesql @SQLString;