CREATE PROCEDURE [dbo].[uspSMLogPerformanceRuntime]
      @strModuleName            NVARCHAR(200)
	, @strScreenName            NVARCHAR(200)
    , @strProcedureName         NVARCHAR(200)
    , @ysnStart		            BIT = 1
	, @intUserId	            INT = NULL
    , @intPerformanceLogId      INT = NULL
    , @strGroup                 NVARCHAR(500) = NULL OUTPUT
    , @intNewPerformanceLogId   INT = NULL OUTPUT
AS
 
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON

DECLARE @ysnLogPerformanceRuntime BIT = 0
DECLARE @dtmPerformanceLoggingEffectivity DATETIME = NULL

SELECT TOP 1 @ysnLogPerformanceRuntime = ISNULL(ysnLogPerformanceRuntime, 0), @dtmPerformanceLoggingEffectivity = DATEADD(dd, 0, DATEDIFF(dd, 0, dtmPerformanceLoggingEffectivity))
FROM tblSMCompanyPreference
ORDER BY intCompanyPreferenceId DESC

IF @ysnLogPerformanceRuntime = 0 OR (@ysnLogPerformanceRuntime = 1 AND @dtmPerformanceLoggingEffectivity < DATEADD(dd, 0, DATEDIFF(dd, 0, GETUTCDATE())))
    RETURN

IF ISNULL(@strGroup, '') = ''
BEGIN
    SET @strGroup = NEWID()
END

BEGIN
    IF ISNULL(@ysnStart, 0) = 1
        BEGIN
            DECLARE @strBuildNumber NVARCHAR(50) = NULL
            
            SELECT TOP 1 @strBuildNumber = strVersionNo
            FROM tblSMBuildNumber
            ORDER BY intVersionID DESC

            INSERT INTO tblSMPerformanceLog (
                  strModuleName
                , strScreenName
                , strProcedureName
                , strBuildNumber
                , strGroup
                , dtmStartDateTime
                , intUserId
            )
            SELECT strModuleName        = @strModuleName 
                , strScreenName		    = @strScreenName
                , strProcedureName		= @strProcedureName
                , strBuildNumber		= @strBuildNumber
                , strGroup              = @strGroup
                , dtmStartDateTime		= GETUTCDATE()
                , intUserId				= @intUserId

            SET @intNewPerformanceLogId = SCOPE_IDENTITY()
        END
    ELSE
        BEGIN
            UPDATE tblSMPerformanceLog
            SET dtmEndDateTime = GETUTCDATE()
            WHERE intPerformanceLogId = @intPerformanceLogId
        END
END