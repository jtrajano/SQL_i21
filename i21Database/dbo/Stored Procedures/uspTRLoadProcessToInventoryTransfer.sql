CREATE PROCEDURE [dbo].[uspTRLoadProcessToInventoryTransfer]
	 @intLoadHeaderId AS INT
	,@intUserId AS INT	
	,@ysnRecap AS BIT
	,@ysnPostOrUnPost AS BIT
	,@BatchId NVARCHAR(20) = NULL
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
    SELECT TR.intInventoryReceiptId,intInventoryTransferId FROM	tblTRLoadHeader TL 
	        JOIN tblTRLoadReceipt TR 
				ON TR.intLoadHeaderId = TL.intLoadHeaderId	
			JOIN tblTRLoadDistributionHeader DH 
				ON TL.intLoadHeaderId = DH.intLoadHeaderId		
			JOIN tblTRLoadDistributionDetail DD 
				ON DH.intLoadDistributionHeaderId = DD.intLoadDistributionHeaderId		
            LEFT JOIN vyuICGetItemStock IC
			    ON IC.intItemId = TR.intItemId and IC.intLocationId = TR.intCompanyLocationId         			
    WHERE	TL.intLoadHeaderId = @intLoadHeaderId
	        AND IC.strType != 'Non-Inventory' 
			AND ((TR.strOrigin = 'Location' AND DH.strDestination = 'Location') 
			or (TR.strOrigin = 'Terminal' AND DH.strDestination = 'Location' and TR.intCompanyLocationId != DH.intCompanyLocationId)
			or (TR.strOrigin = 'Location' AND DH.strDestination = 'Customer' and TR.intCompanyLocationId != DH.intCompanyLocationId)
			or (TR.strOrigin = 'Terminal' AND DH.strDestination = 'Customer' and TR.intCompanyLocationId != DH.intCompanyLocationId AND (TR.dblUnitCost != 0 or TR.dblFreightRate != 0 or TR.dblPurSurcharge != 0)))
			AND ISNULL(intInventoryTransferId, '') <> ''
	
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
		,[strActualCostId]
        ,[intItemId]
        ,[intLotId]
        ,[intItemUOMId]
        ,[dblQuantityToTransfer]
        ,[strNewLotId]
        ,[intFromSubLocationId]
        ,[intToSubLocationId]
        ,[intFromStorageLocationId]
        ,[intToStorageLocationId]
        ,[intInventoryTransferId]
        ,[intSourceId]   
		,[strSourceId]  
		,[strSourceScreenName]
    )
    SELECT [dtmTransferDate]		= MIN(TL.dtmLoadDateTime)
		,[strTransferType]          = 'Location to Location'
		,[intSourceType]            = 3
		,[strDescription]           = MIN(IC.strDescription)
		,[intFromLocationId]        = TR.intCompanyLocationId
		,[intToLocationId]          = DH.intCompanyLocationId
		,[ysnShipmentRequired]      = 0
		,[intStatusId]              = 1
		,[intShipViaId]             = MIN(TL.intShipViaId)
		,[intFreightUOMId]          = MIN(ItemUOM.intUnitMeasureId)
		,[strActualCostId]			= (CASE WHEN MIN(TR.strOrigin) = 'Terminal' AND MIN(DH.strDestination) = 'Customer'
												THEN MIN(TL.strTransaction)
											WHEN MIN(TR.strOrigin) = 'Location' AND MIN(DH.strDestination) = 'Customer' AND MIN(TR.intCompanyLocationId) = MIN(DH.intCompanyLocationId)
												THEN NULL
											WHEN MIN(TR.strOrigin) = 'Location' AND MIN(DH.strDestination) = 'Customer' AND MIN(TR.intCompanyLocationId) != MIN(DH.intCompanyLocationId)
												THEN MIN(TL.strTransaction)
											WHEN MIN(TR.strOrigin) = 'Location' AND MIN(DH.strDestination) = 'Location'
												THEN NULL
											END)
		,[intItemId]                = MIN(TR.intItemId)
		,[intLotId]                 = NULL
		,[intItemUOMId]             = MIN(ItemUOM.intItemUOMId)
		,[dblQuantityToTransfer]    = SUM(DD.dblUnits)
		,[strNewLotId]              = NULL
		,[intFromSubLocationId]     = NULL
		,[intToSubLocationId]       = NULL
		,[intFromStorageLocationId] = NULL
		,[intToStorageLocationId]   = NULL
		,[intInventoryTransferId]   = MIN(TR.intInventoryTransferId)
		,[intSourceId]              = TR.intLoadReceiptId
		,[strSourceId]				= MIN(TL.strTransaction)
		,[strSourceScreenName]		= 'Transport Loads'
    FROM	tblTRLoadHeader TL 	        
			JOIN tblTRLoadDistributionHeader DH 
				ON TL.intLoadHeaderId = DH.intLoadHeaderId		
			JOIN tblTRLoadDistributionDetail DD 
				ON DH.intLoadDistributionHeaderId = DD.intLoadDistributionHeaderId
			JOIN tblTRLoadReceipt TR 
				ON TR.intLoadHeaderId = TL.intLoadHeaderId AND TR.strReceiptLine IN (SELECT Item FROM fnTRSplit(DD.strReceiptLink,','))
            LEFT JOIN vyuICGetItemStock IC
			    ON IC.intItemId = TR.intItemId AND IC.intLocationId = TR.intCompanyLocationId   	
			LEFT JOIN tblTRSupplyPoint SP 
				ON SP.intSupplyPointId = TR.intSupplyPointId
			LEFT JOIN tblICItemUOM ItemUOM ON ItemUOM.intItemId = TR.intItemId AND ItemUOM.ysnStockUnit = 1
    WHERE	TL.intLoadHeaderId = @intLoadHeaderId
	        AND IC.strType != 'Non-Inventory'
			AND ((TR.strOrigin = 'Location' AND DH.strDestination = 'Location') 
			OR (TR.strOrigin = 'Terminal' AND DH.strDestination = 'Location' AND TR.intCompanyLocationId != DH.intCompanyLocationId)
			OR (TR.strOrigin = 'Location' AND DH.strDestination = 'Customer' AND TR.intCompanyLocationId != DH.intCompanyLocationId)
			OR (TR.strOrigin = 'Terminal' AND DH.strDestination = 'Customer' AND TR.intCompanyLocationId != DH.intCompanyLocationId AND (TR.dblUnitCost != 0 OR TR.dblFreightRate != 0 OR TR.dblPurSurcharge != 0)))
	GROUP BY TR.intLoadReceiptId, TR.intCompanyLocationId, DH.intCompanyLocationId


	UPDATE @TransferEntries
	SET intInventoryTransferId = tblPatch.intInventoryTransferId
	FROM (
		SELECT Header.intInventoryTransferId
			, intLoadReceiptId = Detail.intSourceId
			, intFromLocId = Header.intFromLocationId
			, intToLocId = Header.intToLocationId
			, Detail.dblQuantity
		FROM tblICInventoryTransfer Header
		LEFT JOIN tblICInventoryTransferDetail Detail ON Detail.intInventoryTransferId = Header.intInventoryTransferId
		WHERE intSourceType = 3
	)tblPatch
	WHERE intSourceId = tblPatch.intLoadReceiptId
		AND intFromLocationId = tblPatch.intFromLocId
		AND intToLocationId = tblPatch.intToLocId
		AND dblQuantity = tblPatch.dblQuantity


	--if No Records to Process exit
    SELECT @total = COUNT(*) FROM @TransferEntries;
    IF (@total = 0)
	   RETURN;

    -- Call uspICAddInventoryTransfer stored procedure.
    EXEC dbo.uspICAddInventoryTransfer
            @TransferEntries
            ,@intUserId

	-- Update the Inventory Transfer Key to the Transaction Table
	UPDATE	TR
	SET		intInventoryTransferId = addResult.intInventoryTransferId
	FROM	dbo.tblTRLoadReceipt TR INNER JOIN #tmpAddInventoryTransferResult addResult
				ON TR.intLoadReceiptId = addResult.intSourceId;
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
		FROM	tblSMUserSecurity 
		WHERE	intEntityId = @intUserId
		if @ysnRecap = 0
		BEGIN
	    	EXEC dbo.uspICPostInventoryTransfer @ysnPostOrUnPost, 0, @strTransactionId, @intEntityId;			
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