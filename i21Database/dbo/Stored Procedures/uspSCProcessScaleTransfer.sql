CREATE PROCEDURE [dbo].[uspSCProcessScaleTransfer]
	@intTicketId AS INT
	,@intMatchTicketId AS INT
	,@strInOutIndicator AS NVARCHAR(1)
	,@intUserId AS INT
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @ErrorMessage NVARCHAR(4000);
DECLARE @ErrorSeverity INT;
DECLARE @ErrorState INT;
DECLARE @InventoryReceiptId AS INT; 
DECLARE @ErrMsg                    NVARCHAR(MAX);
 IF NOT EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#tmpAddInventoryTransferResult'))
    BEGIN
        CREATE TABLE #tmpAddInventoryTransferResult (
            intSourceId INT
			,intInventoryTransferId INT
        )
    END

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
    SELECT      -- Header
                [dtmTransferDate]           = GETDATE()
                ,[strTransferType]          = 'Location to Location'
                ,[intSourceType]            = 1
                ,[strDescription]           = (select top 1 strDescription from vyuICGetItemStock IC where SC.intItemId = IC.intItemId)
                ,[intFromLocationId]        = (select top 1 intLocationId from tblSCScaleSetup where intScaleSetupId = SC.intScaleSetupId)
                ,[intToLocationId]          = SC.intProcessingLocationId
                ,[ysnShipmentRequired]      = 1
                ,[intStatusId]              = 1
                ,[intShipViaId]             = SC.intFreightCarrierId
                ,[intFreightUOMId]          = (SELECT	TOP 1 
											            IU.intUnitMeasureId											
											            FROM dbo.tblICItemUOM IU 
											            WHERE	IU.intItemId = SC.intItemId and IU.ysnStockUnit = 1)
                -- Detail
                ,[intItemId]                = SC.intItemId
                ,[intLotId]                 = NULL
                ,[intItemUOMId]             = (SELECT	TOP 1 
											            IU.intItemUOMId											
											            FROM dbo.tblICItemUOM IU 
											            WHERE	IU.intItemId = SC.intItemId and IU.ysnStockUnit = 1)
                ,[dblQuantityToTransfer]    = SC.dblNetUnits
                ,[strNewLotId]              = NULL
                ,[intFromSubLocationId]     = NULL
                ,[intToSubLocationId]       = NULL
                ,[intFromStorageLocationId] = NULL
                ,[intToStorageLocationId]   = NULL
				,[ysnWeights]				= CASE
												WHEN SC.intWeightId > 0 THEN 1
												ELSE 0
											END
                -- Integration Field
				,[intInventoryTransferId]   = NULL
                ,[intSourceId]              = SC.intTicketId
				,[strSourceId]				= SC.strTicketNumber
				,[strSourceScreenName]		= 'Scale Ticket'
    FROM	tblSCTicket SC 
    WHERE	SC.intTicketId = @intTicketId 
			

	--if No Records to Process exit
    SELECT @total = COUNT(*) FROM @TransferEntries;
    IF (@total = 0)
	   RETURN;

    -- If the integrating module needs to know the created transfer(s), the create a temp table called tmpAddInventoryTransferResult
    -- The temp table will be accessed by uspICAddInventoryTransfer to send feedback on the created transfer transaction.
    --IF NOT EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#tmpAddInventoryTransferResult'))
    --BEGIN
    --    CREATE TABLE #tmpAddInventoryTransferResult (
    --        intSourceId INT
    --        ,intInventoryTransferId INT
    --    )
    --END
     
     
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

		SELECT	TOP 1 @intEntityId = [intEntityId] 
		FROM	dbo.tblSMUserSecurity 
		WHERE	[intEntityId] = @intUserId

		BEGIN
	    	EXEC dbo.uspICPostInventoryTransfer 1, 0, @strTransactionId, @intUserId;			
		END

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