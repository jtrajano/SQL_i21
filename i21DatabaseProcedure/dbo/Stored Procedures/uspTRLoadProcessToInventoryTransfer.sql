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
DECLARE @ErrMsg NVARCHAR(MAX);

IF NOT EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#tmpAddInventoryTransferResult'))
BEGIN
	CREATE TABLE #tmpAddInventoryTransferResult (intSourceId INT
		, intInventoryTransferId INT)
END

BEGIN TRY
	DECLARE @TransferEntries AS InventoryTransferStagingTable,
			@total as int;
       
	IF @ysnPostOrUnPost = 0 AND @ysnRecap = 0
	BEGIN
		INSERT INTO #tmpAddInventoryTransferResult
		SELECT DISTINCT Header.intInventoryTransferId, Header.intInventoryTransferId
		FROM tblICInventoryTransfer Header
		LEFT JOIN tblICInventoryTransferDetail Detail ON Detail.intInventoryTransferId = Header.intInventoryTransferId
		WHERE Header.intSourceType = 3
			AND intSourceId IN (SELECT intLoadReceiptId FROM tblTRLoadReceipt WHERE intLoadHeaderId = @intLoadHeaderId)

	
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
		,[strFromLocationActualCostId]
		,[strToLocationActualCostId]
        ,[intItemId]
        ,[intLotId]
        ,[intItemUOMId]
        ,[dblQuantityToTransfer]
		,[dblCost]
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
		,[strFromLocationActualCostId]	= (CASE WHEN MIN(TR.strOrigin) = 'Terminal'
												THEN MIN(TL.strTransaction)
											WHEN MIN(TR.strOrigin) = 'Location' AND MIN(DH.strDestination) = 'Customer' AND MIN(TR.intCompanyLocationId) = MIN(DH.intCompanyLocationId)
												THEN NULL
											WHEN MIN(TR.strOrigin) = 'Location' AND MIN(DH.strDestination) = 'Customer' AND MIN(TR.intCompanyLocationId) != MIN(DH.intCompanyLocationId)
												THEN NULL
											WHEN MIN(TR.strOrigin) = 'Location' AND MIN(DH.strDestination) = 'Location'
												THEN NULL
											END)
		,[strToLocationActualCostId]	= (CASE WHEN MIN(TR.strOrigin) = 'Terminal' AND MIN(DH.strDestination) = 'Customer'
												THEN MIN(TL.strTransaction)
											WHEN MIN(TR.strOrigin) = 'Terminal' AND MIN(DH.strDestination) = 'Location'
												THEN NULL
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
		,[dblCost]					= MIN(TR.dblUnitCost)
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
			OR (TR.strOrigin = 'Terminal' AND DH.strDestination = 'Customer' AND TR.intCompanyLocationId != DH.intCompanyLocationId))
			AND TR.intItemId = DD.intItemId /* If distribution item is different from the received item, then this is an auto-blend scenario where received items are blended together to be distributed as a new item (ex. E10 is 10% ethanol and 90% gasoline). */
	GROUP BY TR.intLoadReceiptId, TR.intCompanyLocationId, DH.intCompanyLocationId

	UNION ALL 

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
		,[strFromLocationActualCostId]	= (CASE WHEN MIN(TR.strOrigin) = 'Terminal'
												THEN MIN(TL.strTransaction)
											WHEN MIN(TR.strOrigin) = 'Location' AND MIN(DH.strDestination) = 'Customer' AND MIN(TR.intCompanyLocationId) = MIN(DH.intCompanyLocationId)
												THEN NULL
											WHEN MIN(TR.strOrigin) = 'Location' AND MIN(DH.strDestination) = 'Customer' AND MIN(TR.intCompanyLocationId) != MIN(DH.intCompanyLocationId)
												THEN NULL
											WHEN MIN(TR.strOrigin) = 'Location' AND MIN(DH.strDestination) = 'Location'
												THEN NULL
											END)
		,[strToLocationActualCostId]	= (CASE WHEN MIN(TR.strOrigin) = 'Terminal' AND MIN(DH.strDestination) = 'Customer'
												THEN MIN(TL.strTransaction)
											WHEN MIN(TR.strOrigin) = 'Terminal' AND MIN(DH.strDestination) = 'Location'
												THEN NULL
											WHEN MIN(TR.strOrigin) = 'Location' AND MIN(DH.strDestination) = 'Customer' AND MIN(TR.intCompanyLocationId) = MIN(DH.intCompanyLocationId)
												THEN NULL
											WHEN MIN(TR.strOrigin) = 'Location' AND MIN(DH.strDestination) = 'Customer' AND MIN(TR.intCompanyLocationId) != MIN(DH.intCompanyLocationId)
												THEN MIN(TL.strTransaction)
											WHEN MIN(TR.strOrigin) = 'Location' AND MIN(DH.strDestination) = 'Location' AND MIN(TR.intCompanyLocationId) != MIN(DH.intCompanyLocationId)
												THEN MIN(TL.strTransaction)
											END)
		,[intItemId]                = MIN(TR.intItemId)
		,[intLotId]                 = NULL
		,[intItemUOMId]             = MIN(ItemUOM.intItemUOMId)
		,[dblQuantityToTransfer]    = SUM(Blend.dblQuantity)
		,[dblCost]					= MIN(TR.dblUnitCost)
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
			LEFT JOIN tblTRLoadDistributionHeader DH ON TL.intLoadHeaderId = DH.intLoadHeaderId		
			LEFT JOIN tblTRLoadDistributionDetail DD ON DH.intLoadDistributionHeaderId = DD.intLoadDistributionHeaderId
			LEFT JOIN vyuTRGetLoadBlendIngredient Blend ON Blend.intLoadDistributionDetailId = DD.intLoadDistributionDetailId
			LEFT JOIN tblTRLoadReceipt TR ON TR.intLoadHeaderId = TL.intLoadHeaderId AND TR.strReceiptLine = Blend.strReceiptLink
            LEFT JOIN vyuICGetItemStock IC
			    ON IC.intItemId = TR.intItemId AND IC.intLocationId = TR.intCompanyLocationId   	
			LEFT JOIN tblTRSupplyPoint SP 
				ON SP.intSupplyPointId = TR.intSupplyPointId
			LEFT JOIN tblICItemUOM ItemUOM ON ItemUOM.intItemId = TR.intItemId AND ItemUOM.ysnStockUnit = 1
    WHERE	TL.intLoadHeaderId = @intLoadHeaderId
		AND ISNULL(DD.strReceiptLink, '') = ''
	    AND IC.strType != 'Non-Inventory'
		AND TR.intCompanyLocationId != DH.intCompanyLocationId
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
	BEGIN
		UPDATE tblTRLoadReceipt
		SET intInventoryTransferId = NULL
		WHERE intLoadHeaderId = @intLoadHeaderId
		RETURN;
	END

    -- Call uspICAddInventoryTransfer stored procedure.
    EXEC dbo.uspICAddInventoryTransfer
            @TransferEntries
            ,@intUserId

	-- Update the Inventory Transfer Key to the Transaction Table
	UPDATE	TR
	SET		intInventoryTransferId = addResult.intInventoryTransferId
	FROM	tblTRLoadReceipt TR INNER JOIN #tmpAddInventoryTransferResult addResult
				ON TR.intLoadReceiptId = addResult.intSourceId;
_PostOrUnPost:
	-- Post the Inventory Transfers                                            
	DECLARE @TransferId INT
			,@intEntityId INT
			,@strTransactionId NVARCHAR(50)

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
	    	EXEC dbo.uspICPostInventoryTransfer 
					@ysnPost = @ysnPostOrUnPost
					, @ysnRecap = 0
					, @strTransactionId = @strTransactionId
					, @intEntityUserSecurityId = @intEntityId
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