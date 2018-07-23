CREATE PROCEDURE [dbo].[uspCTGetImportedSessionSummary]
	@intSession BIGINT,
	@strType	NVARCHAR(50)
AS

BEGIN TRY

	DECLARE @ErrMsg				NVARCHAR(MAX),
			@intTotalCount		INT,
			@intSuccessCount	INT
	
	IF @strType = 'Contract'
	BEGIN
		SELECT	@intTotalCount = COUNT(1) FROM tblCTContractImport WHERE intSession = @intSession
		SELECT	@intSuccessCount = COUNT(1) FROM tblCTContractImport WHERE intSession = @intSession AND strErrorMsg IS NULL

		SELECT  strErrorMsg,  strContractNumber, intContractSeq, 'Fail' AS strImportStatus 
		FROM	tblCTContractImport 
		WHERE	strErrorMsg IS NOT NULL
		AND		intSession = @intSession
		UNION ALL
		SELECT  LTRIM(@intSuccessCount) + ' of ' + LTRIM(@intTotalCount) + ' contracts imported successfully.' strErrorMsg,  NULL AS strContractNumber, NULL AS intContractSeq, 'Success' AS strImportStatus 
	END
	ELSE
	BEGIN
		SELECT	@intTotalCount = COUNT(1) FROM tblCTImportBalance WHERE intSession = @intSession
		SELECT	@intSuccessCount = COUNT(1) FROM tblCTImportBalance WHERE intSession = @intSession AND strErrorMsg IS NULL

		SELECT  strErrorMsg,  strContractNumber, intContractSeq, 'Fail' AS strImportStatus 
		FROM	tblCTImportBalance 
		WHERE	strErrorMsg IS NOT NULL
		AND		intSession = @intSession
		UNION ALL
		SELECT  LTRIM(@intSuccessCount) + ' of ' + LTRIM(@intTotalCount) + ' contracts applied successfully.' strErrorMsg,  NULL AS strContractNumber, NULL AS intContractSeq, 'Success' AS strImportStatus 
	END

END TRY

BEGIN CATCH

    SET @ErrMsg = ERROR_MESSAGE()  
    RAISERROR (@ErrMsg,18,1,'WITH NOWAIT')  
	
END CATCH