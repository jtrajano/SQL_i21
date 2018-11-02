﻿CREATE PROCEDURE [dbo].[uspGRProcessScaleTicket]
	@intUserId	INT
 AS
 BEGIN TRY

	DECLARE @ErrMsg					NVARCHAR(MAX),
			@strTicketNo            Nvarchar(40),
			@intTicketLVStagingId	INT,
			@intTicketId	INT

	DELETE tblSCTicketLVStaging WHERE strTicketNumber IS NULL	
	UPDATE tblSCTicketLVStaging SET intOriginTicketId = 0  WHERE intOriginTicketId IS NULL

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
				
				WHERE	intTicketLVStagingId	=	@intTicketLVStagingId
			  --WHERE strTicketNumber         =   @strTicketNo

		END TRY

		BEGIN CATCH
			SET @ErrMsg = ERROR_MESSAGE() 
			
			IF @ErrMsg LIKE '%Violation of UNIQUE KEY constraint%'
			BEGIN 
				SET @ErrMsg = 'Ticket '+LTRIM(@strTicketNo)+' is exist.' 
			END
			
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
	IF XACT_STATE() != 0 AND @@TRANCOUNT > 0 COMMIT TRANSACTION
 END TRY
BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()  
	RAISERROR (@ErrMsg,18,1,'WITH NOWAIT')
END CATCH
