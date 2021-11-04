/*
	Parameters:

*/
CREATE PROCEDURE [uspICInventoryAdjustment_CreatePostQtyChangeFromInvShipmentDestination]
	@intInventoryShipmentId AS INT 
	,@dtmDate AS DATETIME 
	,@intEntityUserSecurityId AS INT 
	,@ysnPost AS BIT = 1
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS ON

DECLARE @strShipmentNumber AS NVARCHAR(50) 
		,@intInventoryShipmentItemId AS INT 

		-- Parameters for filtering:
		,@intItemId AS INT
		,@intLocationId AS INT	
		,@intSubLocationId AS INT	
		,@intStorageLocationId AS INT	
		,@strLotNumber AS NVARCHAR(50)
		,@intOwnershipType AS INT

		-- Parameters for the new values: 
		,@dblAdjustByQuantity AS NUMERIC(38,20)
		,@dblNewUnitCost AS NUMERIC(38,20)
		,@intItemUOMId AS INT 
		-- Parameters used for linking or FK (foreign key) relationships
		,@intSourceId AS INT
		,@intSourceTransactionTypeId AS INT
		,@intInventoryAdjustmentId AS INT 
		,@strDescription AS NVARCHAR(1000)
		
		,@intInventoryReceiptId AS INT
		,@intTicketId AS INT
		,@intInvoiceId AS INT
		,@IntegrationId AS InventoryAdjustmentIntegrationId

		,@intContractHeaderId AS INT
		,@intContractDetailId AS INT
		,@intEntityCustomerId AS INT 

DECLARE	@ErrorMessage NVARCHAR(4000)
		,@ErrorSeverity INT
		,@ErrorState INT 

/*******************************************************
	Validations
*******************************************************/

-- Validate if the shipment is posted. 
BEGIN 
	SET @strShipmentNumber = NULL 
	SELECT	TOP 1 
			@strShipmentNumber = s.strShipmentNumber
	FROM	tblICInventoryShipment s 
	WHERE	ISNULL(s.ysnPosted, 0) = 0 
			AND s.intInventoryShipmentId = @intInventoryShipmentId
	
	IF @strShipmentNumber IS NOT NULL 
	BEGIN
		-- 'The {Shipment Id} is not posted. Destination Qty can only be updated on a posted shipment.'
		EXEC uspICRaiseError 80192, @strShipmentNumber; 
		GOTO _ExitWithError
	END
END

/*******************************************************
	Create and post the inventory adjustment 
*******************************************************/
BEGIN 
	DECLARE destinationItems CURSOR LOCAL FAST_FORWARD
	FOR 
	SELECT	s.strShipmentNumber  
			,si.intInventoryShipmentItemId 
			,si.intItemId
			,s.intShipFromLocationId
			,intSubLocationId = case when sil.intLotId is not null then silot.intSubLocationId else si.intSubLocationId end
			,intStorageLocationId = case when sil.intLotId is not null then silot.intStorageLocationId else si.intStorageLocationId end
			,strLotNumber = silot.strLotNumber
			,dblCost = dbo.fnCalculateCostBetweenUOM(
				ISNULL(itemCost.intItemUOMId, stockUOM.intItemUOMId) 
				, stockUOM.intItemUOMId
				, ISNULL(itemCost.dblCost, itemPricing.dblLastCost)
			) 
			,stockUOM.intItemUOMId
			,[tt].intTransactionTypeId 
			,dblAdjustQty = dbo.fnCalculateQtyBetweenUOM(
				si.intItemUOMId
				, stockUOM.intItemUOMId
				, CASE WHEN @ysnPost = 1 THEN (si.dblQuantity - ISNULL(si.dblDestinationQuantity, 0)) ELSE -(si.dblQuantity - ISNULL(si.dblDestinationQuantity, 0)) END 
			) 
			, si.intOwnershipType
			, sc.intTicketId
			, inv.intInvoiceId
			, si.intOrderId
			, si.intLineNo
			, s.intEntityCustomerId

	FROM	tblICInventoryShipment s INNER JOIN tblICInventoryShipmentItem si
				ON s.intInventoryShipmentId = si.intInventoryShipmentId
			left join tblICInventoryShipmentItemLot as sil
				on sil.intInventoryShipmentItemId = si.intInventoryShipmentItemId
			left join tblICLot as silot
				on sil.intLotId = silot.intLotId
			INNER JOIN tblICItem i 
				ON i.intItemId = si.intItemId 
			INNER JOIN tblICCommodity c
				ON c.intCommodityId = i.intCommodityId
			INNER JOIN tblICAdjustInventoryTerms [at]
				ON [at].intAdjustInventoryTermsId = c.intAdjustInventorySales
			INNER JOIN tblICItemUOM stockUOM
				ON stockUOM.intItemId = si.intItemId 
				AND stockUOM.ysnStockUnit = 1
			INNER JOIN tblICItemLocation il
				ON il.intItemId = si.intItemId
				AND il.intLocationId = s.intShipFromLocationId 
			LEFT JOIN tblICInventoryTransactionType [tt]
				ON [tt].strName = 'Inventory Shipment'
			left join tblSCTicket as sc
				on s.intSourceType = 1 and si.intSourceId = sc.intTicketId and sc.intInventoryShipmentId = s.intInventoryShipmentId
			outer apply (
				select top 1 a.intInvoiceId from tblARInvoiceDetail as a					
					where a.intInventoryShipmentItemId = si.intInventoryShipmentItemId
			) as inv
			OUTER APPLY (
				SELECT	TOP 1 
						t.intItemUOMId 
						,t.dblCost 
				FROM	tblICInventoryTransaction t 
				WHERE	t.intItemId = si.intItemId
						AND t.strTransactionId = s.strShipmentNumber
						AND t.intTransactionId = s.intInventoryShipmentId
						AND t.intTransactionDetailId = si.intInventoryShipmentItemId	
						AND ISNULL(t.ysnIsUnposted, 0) = 0 		
			) itemCost 
			OUTER APPLY (			
				SELECT	TOP 1
						[ip].dblLastCost 
				FROM	tblICItemPricing [ip]
				WHERE	[ip].intItemId = si.intItemId
						AND [ip].intItemLocationId = il.intItemLocationId
			) itemPricing

	WHERE	s.intInventoryShipmentId = @intInventoryShipmentId
			AND [at].strTerms = 'Destination'
			AND si.dblQuantity - ISNULL(si.dblDestinationQuantity, 0) <> 0 

	OPEN destinationItems

	FETCH NEXT FROM destinationItems 
	INTO	@strShipmentNumber
			,@intInventoryShipmentItemId
			,@intItemId
			,@intLocationId
			,@intSubLocationId
			,@intStorageLocationId
			,@strLotNumber
			,@dblNewUnitCost
			,@intItemUOMId  
			,@intSourceTransactionTypeId
			,@dblAdjustByQuantity
			,@intOwnershipType			
			,@intTicketId
			,@intInvoiceId
			,@intContractHeaderId 
			,@intContractDetailId 
			,@intEntityCustomerId 

	WHILE @@FETCH_STATUS = 0
	BEGIN
		BEGIN TRY 
			declare @temp_integration_table as InventoryAdjustmentIntegrationId

			insert into @temp_integration_table(intInventoryShipmentId, intTicketId, intInvoiceId)
			select @intInventoryShipmentId, @intTicketId, @intInvoiceId

			EXEC [uspICInventoryAdjustment_CreatePostQtyChange]
				-- Parameters for filtering:
				@intItemId 
				,@dtmDate 
				,@intLocationId 
				,@intSubLocationId 
				,@intStorageLocationId 
				,@strLotNumber 
				,@intOwnershipType 

				-- Parameters for the new values: 
				,@dblAdjustByQuantity
				,@dblNewUnitCost
				,@intItemUOMId 

				-- Parameters used for linking or FK (foreign key) relationships
				,@intInventoryShipmentId
				,@intSourceTransactionTypeId
				,@intEntityUserSecurityId 
				,@intInventoryAdjustmentId OUTPUT
				,DEFAULT
				,@ysnPost
				,@temp_integration_table

				,@intContractHeaderId 
				,@intContractDetailId 
				,@intEntityCustomerId 

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
			
			GOTO _BreakLoop_With_Error
		END CATCH 

		FETCH NEXT FROM destinationItems 
		INTO	@strShipmentNumber
				,@intInventoryShipmentItemId
				,@intItemId
				,@intLocationId
				,@intSubLocationId
				,@intStorageLocationId
				,@strLotNumber
				,@dblNewUnitCost
				,@intItemUOMId  
				,@intSourceTransactionTypeId
				,@dblAdjustByQuantity
				,@intOwnershipType			
				,@intTicketId
				,@intInvoiceId
				,@intContractHeaderId 
				,@intContractDetailId 
				,@intEntityCustomerId 

	END

	GOTO _EndLoop

	_BreakLoop_With_Error: 
	CLOSE destinationItems
	DEALLOCATE destinationItems 
	GOTO _ExitWithError

	_EndLoop: 
	CLOSE destinationItems
	DEALLOCATE destinationItems 
END 

GOTO _Exit 

_ExitWithError: 
RETURN -1; 

_Exit:  