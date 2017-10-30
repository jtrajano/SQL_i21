CREATE PROCEDURE [dbo].[uspSMValidateRemoteServerRole]
    @remoteDBUserId NVARCHAR(MAX),
    @remoteDB NVARCHAR(MAX),
    @count INT OUT
    
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON

DECLARE @SQLString NVARCHAR(MAX) = '';

SET @SQLString = N'SELECT @count =  COUNT(*) FROM REMOTEDBSERVER.[master].sys.syslogins
WHERE name = @remoteDBUserId AND sysadmin = 1'

EXECUTE sp_executesql @SQLString, N'@count INT OUT, @remoteDBUserId NVARCHAR(MAX)', @remoteDBUserId = @remoteDBUserId, @count = @count OUT

