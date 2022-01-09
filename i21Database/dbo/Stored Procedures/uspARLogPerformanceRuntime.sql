CREATE PROCEDURE [dbo].[uspARLogPerformanceRuntime]
	  @strScreenName            NVARCHAR(200)
    , @strProcedureName         NVARCHAR(200)
    , @strRequestId             NVARCHAR(500)
    , @ysnStart		            BIT = 1
	, @intUserId	            INT = NULL
    , @intPerformanceLogId      INT = NULL
    , @intNewPerformanceLogId   INT = NULL OUTPUT
AS
 
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON

DECLARE @ysnLogPerformanceRuntime BIT = 0

SELECT TOP 1 @ysnLogPerformanceRuntime = ISNULL(ysnLogPerformanceRuntime, 0)
FROM tblARCompanyPreference
ORDER BY intCompanyPreferenceId DESC

IF @ysnLogPerformanceRuntime = 0
    RETURN

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
                , strRequestId
                , dtmStartDateTime
                , intUserId
            )
            SELECT strScreenName		= @strScreenName
                , strProcedureName		= @strProcedureName
                , strBuildNumber		= @strBuildNumber
                , strRequestId          = @strRequestId
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