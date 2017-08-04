﻿CREATE PROCEDURE [dbo].[uspSCProcessHoldTicket]
	@intTicketId AS INT
	,@intEntityId AS INT
	,@dblNetUnits AS NUMERIC (38,20)
	,@intUserId AS INT
	,@strInOutFlag AS NVARCHAR(2)
	,@ysnPost AS BIT
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @ErrorMessage NVARCHAR(4000);
DECLARE @ErrorSeverity INT;
DECLARE @ErrorState INT;

DECLARE @ErrMsg	NVARCHAR(MAX)
	,@InTransitTableType AS InTransitTableType;

BEGIN
	INSERT INTO @InTransitTableType (
		[intItemId]
		,[intItemLocationId]
		,[intItemUOMId]
		,[intLotId]
		,[intSubLocationId]
		,[intStorageLocationId]
		,[dblQty]
		,[intTransactionId]
		,[strTransactionId]
		,[intTransactionTypeId]
	)
	SELECT	[intItemId]				= SC.intItemId
			,[intItemLocationId]	= ICIL.intItemLocationId
			,[intItemUOMId]			= SC.intItemUOMIdTo
			,[intLotId]				= NULL
			,[intSubLocationId]		= SC.intSubLocationId
			,[intStorageLocationId]	= SC.intStorageLocationId
			,[dblQty]				= CASE WHEN @ysnPost = 1 THEN SC.dblNetUnits ELSE SC.dblNetUnits * -1 END
			,[intTransactionId]		= @intTicketId
			,[strTransactionId]		= SC.strTicketNumber
			,[intTransactionTypeId] = 1
	FROM	tblSCTicket SC 
	INNER JOIN dbo.tblICItemLocation ICIL ON ICIL.intItemId = SC.intItemId AND ICIL.intLocationId = SC.intProcessingLocationId
	WHERE SC.intTicketId = @intTicketId
END

BEGIN TRY
	BEGIN 
		IF @strInOutFlag = 'I'
			BEGIN
				EXEC dbo.uspICIncreaseInTransitInBoundQty @InTransitTableType;
			END
		ELSE
			BEGIN
				EXEC dbo.uspICIncreaseInTransitOutBoundQty @InTransitTableType;
			END
		
		IF @ysnPost = 0
		BEGIN
			update tblSCTicket SET strTicketStatus = 'R' WHERE intTicketId = @intTicketId
		END
	END
_Exit:
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
GO
