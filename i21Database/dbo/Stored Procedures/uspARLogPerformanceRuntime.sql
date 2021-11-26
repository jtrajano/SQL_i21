CREATE PROCEDURE [dbo].[uspARLogPerformanceRuntime]
	  @strScreenName            NVARCHAR(200)
    , @strProcedureName         NVARCHAR(200)
    , @ysnStart		            BIT = 1
	, @intUserId	            INT = NULL
    , @intPerformanceLogId      INT = NULL
    , @intNewPerformanceLogId   INT = NULL OUTPUT
AS
 
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF
 
BEGIN
    IF ISNULL(@ysnStart, 0) = 1
        BEGIN
            DECLARE @strBuildNumber NVARCHAR(50) = NULL
            
            SELECT TOP 1 @strBuildNumber = strVersionNo
            FROM tblSMBuildNumber
            ORDER BY intVersionID DESC

            INSERT INTO tblARPerformanceLog (
                strScreenName
                , strProcedureName
                , strBuildNumber
                , dtmStartDateTime
                , intUserId
            )
            SELECT strScreenName		= @strScreenName
                , strProcedureName		= @strProcedureName
                , strBuildNumber		= @strBuildNumber
                , dtmStartDateTime		= GETDATE()
                , intUserId				= @intUserId

            SET @intNewPerformanceLogId = SCOPE_IDENTITY()
        END
    ELSE
        BEGIN
            UPDATE tblARPerformanceLog
            SET dtmEndDateTime = GETDATE()
            WHERE intPerformanceLogId = @intPerformanceLogId
        END
END