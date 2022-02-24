CREATE PROCEDURE [dbo].[uspSCCheckUpdateTicketProcessed]
	@intTicketId  INT 
	,@intUserId INT
	,@ysnStartProcess BIT
AS
BEGIN
	SET QUOTED_IDENTIFIER OFF
	SET ANSI_NULLS ON
	SET NOCOUNT ON
	SET XACT_ABORT ON
	SET ANSI_WARNINGS OFF

	DECLARE @ErrorMessage NVARCHAR(4000);
	DECLARE @ErrorSeverity INT;
	DECLARE @ErrorState INT;

	DECLARE @ysnInProgress BIT	
	DECLARE @intProcessingUser INT
	DECLARE @intRecordTicketId INT

	BEGIN TRY
	
		-- check Record
		SELECT TOP 1
			@ysnInProgress = ysnInProgress
			,@intProcessingUser = intUserId
			,@intRecordTicketId = intTicketId
		FROM tblSCTicketOnProcess
		WHERE intTicketId = @intTicketId

		IF @ysnStartProcess = 1 
		BEGIN
			-- insert record 
			IF @intRecordTicketId IS NULL
			BEGIN
				INSERT INTO tblSCTicketOnProcess(
					intTicketId
					,intUserId
					,ysnInProgress
				)
				SELECT 
					intTicketId = @intTicketId
					,intUserId = @intUserId
					,ysnInProgress = 1
			END
			ELSE
			BEGIN
				IF @ysnInProgress = 1
				BEGIN
					RAISERROR('Record is being processed by another user.', 11, 1);
				END 
				ELSE
				BEGIN
					UPDATE tblSCTicketOnProcess 
					SET ysnInProgress = 1
						,intUserId = @intUserId 
					WHERE intTicketId = @intTicketId
				END
			END
		END
		ELSE
		BEGIN
			UPDATE tblSCTicketOnProcess 
			SET ysnInProgress = 0
				,intUserId = @intUserId 
			WHERE intTicketId = @intTicketId
		END

	END TRY
	BEGIN CATCH
		SELECT 
			@ErrorMessage = ERROR_MESSAGE(),
			@ErrorSeverity = ERROR_SEVERITY(),
			@ErrorState = ERROR_STATE();

		-- Use RAISERROR inside the CATCH block to return error
		-- information about the original error that caused
		-- execution to jump to the CATCH block.
		RAISERROR (
			@ErrorMessage, -- Message text.
			@ErrorSeverity, -- Severity.
			@ErrorState -- State.
		);
	END CATCH	
END
