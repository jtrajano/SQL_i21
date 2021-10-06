CREATE PROCEDURE [dbo].[uspSCProcessScaleTransfer]
	@intTicketId AS INT
	,@intUserId AS INT
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS ON

DECLARE @ErrorMessage NVARCHAR(4000);
DECLARE @ErrorSeverity INT;
DECLARE @ErrorState INT;
DECLARE @lotType AS INT; 
DECLARE @ErrMsg  NVARCHAR(MAX);
 IF NOT EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#tmpAddInventoryTransferResult'))
    BEGIN
        CREATE TABLE #tmpAddInventoryTransferResult (
            intSourceId INT
			,intInventoryTransferId INT
        )
    END
SELECT @lotType = dbo.fnGetItemLotType(intItemId) FROM tblSCTicket WHERE intTicketId = @intTicketId

BEGIN TRY
DECLARE @TransferEntries AS InventoryTransferStagingTable,
        @total as int;

-- Insert the data needed to create the inventory transfer.
    INSERT INTO @TransferEntries (
        -- Header
        [dtmTransferDate]
        ,[strTransferType]
        ,[intSourceType]
        ,[strDescription]
        ,[intFromLocationId]
        ,[intToLocationId]
        ,[ysnShipmentRequired]
        ,[intStatusId]
        ,[intShipViaId]
        ,[intFreightUOMId]
        -- Detail
        ,[intItemId]
        ,[intLotId]
        ,[intItemUOMId]
        ,[dblQuantityToTransfer]
		,[intItemWeightUOMId]		
		,[dblGrossWeight]			
		,[dblTareWeight]			
        ,[strNewLotId]
        ,[intFromSubLocationId]
        ,[intToSubLocationId]
        ,[intFromStorageLocationId]
        ,[intToStorageLocationId]
		,[ysnWeights]
        -- Integration Field
		,[intInventoryTransferId]
        ,[intSourceId]   
		,[strSourceId]  
		,[strSourceScreenName]
    )
	SELECT      
		-- Header
		[dtmTransferDate]           = dtmTicketDateTime
		,[strTransferType]          = 'Location to Location'
		,[intSourceType]            = 1
		,[strDescription]           = (select top 1 strDescription from vyuICGetItemStock IC where SC.intItemId = IC.intItemId)
		,[intFromLocationId]        = CASE WHEN SC.intTicketTypeId = 10 THEN SC.intProcessingLocationId ELSE SCS.intLocationId END 
		,[intToLocationId]          = CASE WHEN SC.intTicketTypeId = 10 THEN SC.intTransferLocationId ELSE SC.intProcessingLocationId END 
		,[ysnShipmentRequired]      = CASE WHEN SC.intTicketTypeId = 10 THEN 0 ELSE 1 END
		,[intStatusId]              = 1
		,[intShipViaId]             = NULL
		,[intFreightUOMId]          = null
		-- Detail
		,[intItemId]                = SC.intItemId
		,[intLotId]                 = SC.intLotId
		,[intItemUOMId]             = SC.intItemUOMIdTo
		,[dblQuantityToTransfer]    = SC.dblNetUnits
		,[intItemWeightUOMId]		= CASE WHEN ISNULL(@lotType,0) != 0 AND ISNULL(IC.ysnLotWeightsRequired,0) = 1 THEN SC.intItemUOMIdFrom ELSE SC.intItemUOMIdTo END
		,[dblGrossWeight]			= CASE WHEN ISNULL(@lotType,0) != 0 AND ISNULL(IC.ysnLotWeightsRequired,0) = 1 THEN dbo.fnCalculateQtyBetweenUOM(SC.intItemUOMIdTo, SC.intItemUOMIdFrom, SC.dblGrossUnits) ELSE SC.dblGrossUnits END
		,[dblTareWeight]			= CASE WHEN ISNULL(@lotType,0) != 0 AND ISNULL(IC.ysnLotWeightsRequired,0) = 1 THEN dbo.fnCalculateQtyBetweenUOM(SC.intItemUOMIdTo, SC.intItemUOMIdFrom, SC.dblShrink) ELSE CASE WHEN SC.dblShrink > 0 THEN SC.dblShrink ELSE 0 END END
		,[strNewLotId]              = NULL
		,[intFromSubLocationId]     = SC.intSubLocationId
		,[intToSubLocationId]       = CASE WHEN SC.intTicketTypeId = 10 THEN SC.intSubLocationToId ELSE NULL END
		,[intFromStorageLocationId] = SC.intStorageLocationId
		,[intToStorageLocationId]   = CASE WHEN SC.intTicketTypeId = 10 THEN SC.intStorageLocationToId ELSE NULL END
		,[ysnWeights]				= CASE
										WHEN SC.intWeightId > 0 THEN 1
										ELSE 0
									END
		-- Integration Field
		,[intInventoryTransferId]   = NULL
		,[intSourceId]              = SC.intTicketId
		,[strSourceId]				= SC.strTicketNumber
		,[strSourceScreenName]		= 'Scale Ticket'
    FROM tblSCTicket SC 
	INNER JOIN tblSCScaleSetup SCS ON SC.intScaleSetupId = SCS.intScaleSetupId
	INNER JOIN tblICItem IC ON IC.intItemId = SC.intItemId
    WHERE SC.intTicketId = @intTicketId 

	--if No Records to Process exit
    SELECT @total = COUNT(*) FROM @TransferEntries;
    IF (@total = 0)
	   RETURN;

    -- Call uspICAddInventoryTransfer stored procedure.
    EXEC dbo.uspICAddInventoryTransfer
            @TransferEntries
            ,@intUserId
 
	-- Update the Inventory Transfer Key to the Transaction Table
	UPDATE	SC
	SET		SC.intInventoryTransferId = addResult.intInventoryTransferId
	FROM	dbo.tblSCTicket SC INNER JOIN #tmpAddInventoryTransferResult addResult
				ON SC.intTicketId = addResult.intSourceId;
_PostOrUnPost:
	-- Post the Inventory Transfers                                            
	DECLARE @TransferId INT
			,@intEntityId INT
			,@strTransactionId NVARCHAR(50);

	WHILE EXISTS (SELECT TOP 1 1 FROM #tmpAddInventoryTransferResult) 
	BEGIN
		SELECT TOP 1 
				@TransferId = intInventoryTransferId  
		FROM	#tmpAddInventoryTransferResult 
  
		-- Post the Inventory Transfer that was created
		SELECT	@strTransactionId = strTransferNo 
		FROM	tblICInventoryTransfer 
		WHERE	intInventoryTransferId = @TransferId

	    EXEC dbo.uspICPostInventoryTransfer 1, 0, @strTransactionId, @intUserId;			

		DELETE	FROM #tmpAddInventoryTransferResult 
		WHERE	intInventoryTransferId = @TransferId
	END;

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