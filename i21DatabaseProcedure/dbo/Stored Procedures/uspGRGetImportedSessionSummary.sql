CREATE PROCEDURE [dbo].[uspGRGetImportedSessionSummary]
	@intSession BIGINT
AS

BEGIN TRY

    DECLARE @ErrMsg			  NVARCHAR(MAX),
		  @intTotalCount	  INT,
		  @intSuccessCount	  INT

    SELECT @intTotalCount = COUNT(1) FROM tblSCTicketLVStaging WHERE intSession = @intSession AND strData = 'Header'
    SELECT @intSuccessCount = COUNT(1) FROM tblSCTicketLVStaging WHERE intSession = @intSession AND strErrorMsg IS NULL AND strData = 'Header'

    SELECT  strErrorMsg     = strErrorMsg
		   ,strTicketNumber	= strTicketNumber
		   ,strImportStatus =  'Fail'  
    FROM tblSCTicketLVStaging 
	WHERE strErrorMsg IS NOT NULL AND intSession = @intSession

    UNION ALL
	SELECT  strErrorMsg     = LTRIM(@intSuccessCount) + ' of ' + LTRIM(@intTotalCount) + ' tickets imported successfully.'
		   ,strTicketNumber	= NULL
		   ,strImportStatus = 'Success'

    

END TRY

BEGIN CATCH

    SET @ErrMsg = ERROR_MESSAGE()  
    RAISERROR (@ErrMsg,18,1,'WITH NOWAIT')  
	
END CATCH