CREATE PROCEDURE [dbo].[uspCTProcessContractImport]
	
	@intUserId	INT

 AS
 BEGIN TRY
	DECLARE @ErrMsg					NVARCHAR(MAX),
			@intContractImportId	INT,
			@intContractHeaderId	INT

	SELECT @intContractImportId = MIN(intContractImportId) FROM tblCTContractImport WHERE ysnImported IS NULL

	WHILE	ISNULL(@intContractImportId,0) > 0
	BEGIN
		BEGIN TRY
			EXEC uspCTCreateContract @intContractImportId,'Contract Import', @intUserId, NULL, @intContractHeaderId OUTPUT
			UPDATE	tblCTContractImport
			SET		ysnImported				=	1,
					intImportedById			=	@intUserId,
					dtmImported				=	GETDATE(),
					intContractHeaderId		=	@intContractHeaderId
			WHERE	intContractImportId	=	@intContractImportId
		END TRY
		BEGIN CATCH
			SET @ErrMsg = ERROR_MESSAGE() 
			UPDATE	tblCTContractImport
			SET		ysnImported			=	0,
					intImportedById		=	@intUserId,
					dtmImported			=	GETDATE(),
					strErrorMsg			=	@ErrMsg
			WHERE	intContractImportId	=	@intContractImportId
		END CATCH

		SELECT @intContractImportId = MIN(intContractImportId) FROM tblCTContractImport WHERE ysnImported IS NULL AND intContractImportId > @intContractImportId
	END

 END TRY
BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()  
	RAISERROR (@ErrMsg,18,1,'WITH NOWAIT')
END CATCH
