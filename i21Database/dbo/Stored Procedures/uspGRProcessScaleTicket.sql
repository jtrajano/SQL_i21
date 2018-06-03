CREATE PROCEDURE [dbo].[uspGRProcessScaleTicket]
	@intUserId	INT
 AS
 BEGIN TRY
	DECLARE @ErrMsg					NVARCHAR(MAX),
			@strTicketNo            Nvarchar(40),
			@intTicketLVStagingId	INT,
			@intTicketId	INT

	DELETE tblSCTicketLVStaging WHERE strTicketNumber IS NULL
	
	SELECT @intTicketLVStagingId = MIN(intTicketLVStagingId) FROM tblSCTicketLVStaging 
	WHERE ysnImported IS NULL

	WHILE	ISNULL(@intTicketLVStagingId,0) > 0
	BEGIN		
		BEGIN TRY
			
			SET @strTicketNo = NULL
			SELECT @strTicketNo = strTicketNumber FROM tblSCTicketLVStaging WHERE intTicketLVStagingId = @intTicketLVStagingId
			EXEC uspGRCreateScaleTicket @intTicketLVStagingId,@strTicketNo,@intUserId, NULL, @intTicketId OUTPUT
			
			UPDATE	tblSCTicketLVStaging
			SET		ysnImported				=	1,
					intImportedById			=	@intUserId,
					dtmImported				=	GETDATE(),
					intTicketId				=	@intTicketId
			--WHERE	intTicketLVStagingId	=	@intTicketLVStagingId
			  WHERE strTicketNumber         =   @strTicketNo

		END TRY

		BEGIN CATCH
			SET @ErrMsg = ERROR_MESSAGE() 
			
			UPDATE	tblSCTicketLVStaging
			SET		ysnImported			=	0,
					intImportedById		=	@intUserId,
					dtmImported			=	GETDATE(),
					strErrorMsg			=	@ErrMsg
			WHERE	intTicketLVStagingId	=	@intTicketLVStagingId

		END CATCH

		SELECT @intTicketLVStagingId = MIN(intTicketLVStagingId) FROM tblSCTicketLVStaging WHERE ysnImported IS NULL 
		AND intTicketLVStagingId > @intTicketLVStagingId AND ISNULL(strTicketNumber,'') <> @strTicketNo
		
	END

 END TRY
BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()  
	RAISERROR (@ErrMsg,18,1,'WITH NOWAIT')
END CATCH
