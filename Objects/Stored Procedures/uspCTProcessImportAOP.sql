CREATE PROCEDURE [dbo].[uspCTProcessImportAOP]
	
	@intUserId	INT

 AS
 BEGIN TRY
	DECLARE	 @ErrMsg				NVARCHAR(MAX),
			 @intImportAOPId		INT,
			 @intContractHeaderId	INT

	SELECT @intImportAOPId = MIN(intImportAOPId) FROM tblCTImportAOP WHERE ysnImported IS NULL

	WHILE	ISNULL(@intImportAOPId,0) > 0
	BEGIN
		BEGIN TRY

		EXEC uspCTImportAOP @intImportAOPId,'AOP Import', @intUserId, NULL

			UPDATE	tblCTImportAOP
			SET		ysnImported			=	  1,
					intImportedById		=	  @intUserId,
					dtmImported			=	  GETDATE()
			WHERE	intImportAOPId		=	  @intImportAOPId
		END TRY
		BEGIN CATCH
			SET @ErrMsg = ERROR_MESSAGE() 
			UPDATE	tblCTImportAOP
			SET		ysnImported			=	  0,
					intImportedById		=	  @intUserId,
					dtmImported			=	  GETDATE(),
					strErrorMsg			=	  @ErrMsg
			WHERE	intImportAOPId		=	  @intImportAOPId
		END CATCH

		SELECT @intImportAOPId = MIN(intImportAOPId) FROM tblCTImportAOP WHERE ysnImported IS NULL AND intImportAOPId > @intImportAOPId
	END

 END TRY
BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()  
	RAISERROR (@ErrMsg,18,1,'WITH NOWAIT')
END CATCH
