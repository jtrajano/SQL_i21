CREATE PROCEDURE [dbo].[uspCTProcessImportBalance]
	
	@intUserId	INT

 AS
 BEGIN TRY
	DECLARE	 @ErrMsg				NVARCHAR(MAX),
			 @intImportBalanceId	INT,
			 @intContractHeaderId	INT

	SELECT @intImportBalanceId = MIN(intImportBalanceId) FROM tblCTImportBalance WHERE ysnImported IS NULL

	WHILE	ISNULL(@intImportBalanceId,0) > 0
	BEGIN
		BEGIN TRY

			EXEC uspCTImportBalance @intImportBalanceId,'Balance Import', @intUserId, NULL

			UPDATE	tblCTImportBalance
			SET		ysnImported			=	  1,
					intImportedById		=	  @intUserId,
					dtmImported			=	  GETDATE()
			WHERE	intImportBalanceId	=	  @intImportBalanceId
		END TRY
		BEGIN CATCH
			SET @ErrMsg = ERROR_MESSAGE() 
			UPDATE	tblCTImportBalance
			SET		ysnImported			=	  0,
					intImportedById		=	  @intUserId,
					dtmImported			=	  GETDATE(),
					strErrorMsg			=	  @ErrMsg
			WHERE	intImportBalanceId	=	  @intImportBalanceId
		END CATCH

		SELECT @intImportBalanceId = MIN(intImportBalanceId) FROM tblCTImportBalance WHERE ysnImported IS NULL AND intImportBalanceId > @intImportBalanceId
	END

 END TRY
BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()  
	RAISERROR (@ErrMsg,18,1,'WITH NOWAIT')
END CATCH