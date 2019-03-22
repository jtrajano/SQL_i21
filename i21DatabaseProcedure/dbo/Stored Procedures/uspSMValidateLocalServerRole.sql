CREATE PROCEDURE [dbo].[uspSMValidateLocalServerRole]
    @localDBUserId NVARCHAR(MAX),
    @localDB NVARCHAR(MAX),
    @count INT OUT
    
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON

DECLARE @SQLString NVARCHAR(MAX) = '';

SET @SQLString = N'SELECT @count =  COUNT(*) FROM [master].sys.syslogins
WHERE name = @localDBUserId AND sysadmin = 1'

EXECUTE sp_executesql @SQLString, N'@count INT OUT, @localDBUserId NVARCHAR(MAX)', @localDBUserId = @localDBUserId, @count = @count OUT

