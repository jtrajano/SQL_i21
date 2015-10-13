CREATE PROCEDURE [dbo].[uspTRProcessToInventoryTransfer]
	 @intTransportLoadId AS INT
	,@intUserId AS INT	
	,@ysnRecap AS BIT
	,@ysnPostOrUnPost AS BIT
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
       
if @ysnPostOrUnPost = 0 and @ysnRecap = 0
BEGIN
     INSERT  INTO #tmpAddInventoryTransferResult
    SELECT TR.intInventoryReceiptId,intInventoryTransferId FROM	tblTRTransportLoad TL 
	        JOIN tblTRTransportReceipt TR 
				ON TR.intTransportLoadId = TL.intTransportLoadId	
			JOIN tblTRDistributionHeader DH 
				ON TR.intTransportReceiptId = DH.intTransportReceiptId		
			JOIN tblTRDistributionDetail DD 
				ON DH.intDistributionHeaderId = DD.intDistributionHeaderId				
    WHERE	TL.intTransportLoadId = @intTransportLoadId 
			AND ((TR.strOrigin = 'Location' AND DH.strDestination = 'Location') 
			or (TR.strOrigin = 'Terminal' AND DH.strDestination = 'Location' and TR.intCompanyLocationId != DH.intCompanyLocationId)
			or (TR.strOrigin = 'Location' AND DH.strDestination = 'Customer' and TR.intCompanyLocationId != DH.intCompanyLocationId)
			or (TR.strOrigin = 'Terminal' AND DH.strDestination = 'Customer' and TR.intCompanyLocationId != DH.intCompanyLocationId AND (TR.dblUnitCost != 0 or TR.dblFreightRate != 0 or TR.dblPurSurcharge != 0)));
	
	SELECT @total = COUNT(*) FROM #tmpAddInventoryTransferResult;
    IF (@total = 0)
	   BEGIN
	     RETURN;
	   END
	ELSE
	    BEGIN
        	GOTO _PostOrUnPost;
		END
END

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
                -- Integration Field
                ,[intInventoryTransferId]
                ,[intSourceId]   
				,[strSourceId]  
				,[strSourceScreenName]
    )
    SELECT      -- Header
                [dtmTransferDate]           = TL.dtmLoadDateTime
                ,[strTransferType]          = 'Location to Location'
                ,[intSourceType]            = 3
                ,[strDescription]           = (select top 1 strDescription from vyuICGetItemStock IC where TR.intItemId = IC.intItemId)
                ,[intFromLocationId]        = TR.intCompanyLocationId
                ,[intToLocationId]          = DH.intCompanyLocationId
                ,[ysnShipmentRequired]      = 0
                ,[intStatusId]              = 1
                ,[intShipViaId]             = TL.intShipViaId
                ,[intFreightUOMId]          = (SELECT	TOP 1 
											            IU.intUnitMeasureId											
											            FROM dbo.tblICItemUOM IU 
											            WHERE	IU.intItemId = TR.intItemId and IU.ysnStockUnit = 1)
                -- Detail
                ,[intItemId]                = TR.intItemId
                ,[intLotId]                 = NULL
                ,[intItemUOMId]             = (SELECT	TOP 1 
											            IU.intItemUOMId											
											            FROM dbo.tblICItemUOM IU 
											            WHERE	IU.intItemId = TR.intItemId and IU.ysnStockUnit = 1)
                ,[dblQuantityToTransfer]    = DD.dblUnits
                ,[strNewLotId]              = NULL
                ,[intFromSubLocationId]     = NULL
                ,[intToSubLocationId]       = NULL
                ,[intFromStorageLocationId] = NULL
                ,[intToStorageLocationId]   = NULL
                -- Integration Field
                ,[intInventoryTransferId]   = TR.intInventoryTransferId
                ,[intSourceId]              = TR.intTransportReceiptId
				,[strSourceId]				= TL.strTransaction
				,[strSourceScreenName]		= 'Transport Load'

    FROM	tblTRTransportLoad TL 
	        JOIN tblTRTransportReceipt TR 
				ON TR.intTransportLoadId = TL.intTransportLoadId	
			JOIN tblTRDistributionHeader DH 
				ON TR.intTransportReceiptId = DH.intTransportReceiptId		
			JOIN tblTRDistributionDetail DD 
				ON DH.intDistributionHeaderId = DD.intDistributionHeaderId				
    WHERE	TL.intTransportLoadId = @intTransportLoadId 
			AND ((TR.strOrigin = 'Location' AND DH.strDestination = 'Location') 
			or (TR.strOrigin = 'Terminal' AND DH.strDestination = 'Location' and TR.intCompanyLocationId != DH.intCompanyLocationId)
			or (TR.strOrigin = 'Location' AND DH.strDestination = 'Customer' and TR.intCompanyLocationId != DH.intCompanyLocationId)
			or (TR.strOrigin = 'Terminal' AND DH.strDestination = 'Customer' and TR.intCompanyLocationId != DH.intCompanyLocationId AND (TR.dblUnitCost != 0 or TR.dblFreightRate != 0 or TR.dblPurSurcharge != 0)));

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
	UPDATE	TR
	SET		intInventoryTransferId = addResult.intInventoryTransferId
	FROM	dbo.tblTRTransportReceipt TR INNER JOIN #tmpAddInventoryTransferResult addResult
				ON TR.intTransportReceiptId = addResult.intSourceId;
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

		SELECT	TOP 1 @intEntityId = intEntityId 
		FROM	dbo.tblSMUserSecurity 
		WHERE	intUserSecurityID = @intUserId
		if @ysnRecap = 0
		BEGIN
	    	EXEC dbo.uspICPostInventoryTransfer @ysnPostOrUnPost, 0, @strTransactionId, @intUserId, @intEntityId;			
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