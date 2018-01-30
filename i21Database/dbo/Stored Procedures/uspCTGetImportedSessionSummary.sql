CREATE PROCEDURE [dbo].[uspCTGetImportedSessionSummary]
	@intSession BIGINT
AS

BEGIN TRY

    DECLARE @ErrMsg			  NVARCHAR(MAX),
		  @intTotalCount	  INT,
		  @intSuccessCount	  INT

    SELECT @intTotalCount = COUNT(1) FROM tblCTContractImport WHERE intSession = @intSession
    SELECT @intSuccessCount = COUNT(1) FROM tblCTContractImport WHERE intSession = @intSession AND strErrorMsg IS NULL

    SELECT  strErrorMsg,  strContractNumber, intContractSeq, 'Fail' AS strImportStatus 
    FROM	  tblCTContractImport WHERE strErrorMsg IS NOT NULL
    AND	  intSession = @intSession
    UNION ALL
    SELECT  LTRIM(@intSuccessCount) + ' of ' + LTRIM(@intTotalCount) + ' contracts imported successfully.' strErrorMsg,  NULL AS strContractNumber, NULL AS intContractSeq, 'Success' AS strImportStatus 

END TRY

BEGIN CATCH

    SET @ErrMsg = ERROR_MESSAGE()  
    RAISERROR (@ErrMsg,18,1,'WITH NOWAIT')  
	
END CATCH