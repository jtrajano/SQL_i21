﻿CREATE PROCEDURE [dbo].[uspICInventoryShipmentAfterSave]
	@ShipmentId INT,
	@ForDelete BIT = 0,
	@UserId INT = NULL

AS

SET QUOTED_IDENTIFIER OFF  
SET ANSI_NULLS ON  
SET NOCOUNT ON  
SET XACT_ABORT ON  
SET ANSI_WARNINGS OFF  

	
DECLARE @ShipmentType AS INT
		,@ShipmentSourceType AS INT 
		,@InvoiceNo AS NVARCHAR(50)
		,@strItemNo AS NVARCHAR(50)

DECLARE @ShipmentType_SalesContract AS INT = 1
DECLARE @ShipmentType_SalesOrder AS INT = 2
DECLARE @ShipmentType_TransferOrder AS INT = 3
DECLARE @ShipmentType_Direct AS INT = 4

DECLARE @SourceType_None AS INT = 0
DECLARE @SourceType_Scale AS INT = 1
DECLARE @SourceType_InboundShipment AS INT = 2
DECLARE @SourceType_PickLot AS INT = 3

DECLARE @ErrMsg NVARCHAR(MAX)

DECLARE @Id INT = NULL,
		@intInventoryShipmentItemId	INT = NULL,
		@intContractDetailId		INT = NULL,
		@intSalesOrderDetailId		INT = NULL,
		@intFromItemUOMId			INT = NULL,
		@intToItemUOMId				INT = NULL,
		@dblQty						NUMERIC(18, 6) = 0,
		@intSalesOrderId			INT = NULL

-- Validate
BEGIN  
	-- 'The item {Item No} is already in {Sales Invoice Id}. Remove it from the Invoice first before you can modify it from the Shipment.'
	SELECT	TOP  1
			@InvoiceNo = i.strInvoiceNumber
			,@strItemNo = item.strItemNo
	FROM	tblARInvoiceDetail d INNER JOIN tblARInvoice i 
				ON i.intInvoiceId = d.intInvoiceId
			INNER JOIN tblICTransactionDetailLog si 
				ON si.intTransactionDetailId = d.intInventoryShipmentItemId
			INNER JOIN tblICItem item
				ON item.intItemId = si.intItemId
	WHERE	si.intTransactionId = @ShipmentId

	IF @InvoiceNo IS NOT NULL
	BEGIN
		EXEC uspICRaiseError 80092, @strItemNo, @InvoiceNo;
		GOTO OnError_Exit;
	END
END 

-- Initialize the Shipment Type and Source Type
IF (@ForDelete = 1)
BEGIN
	SELECT	@ShipmentType = intOrderType
			,@ShipmentSourceType = intSourceType
	FROM	tblICTransactionDetailLog
	WHERE	intTransactionId = @ShipmentId
			AND strTransactionType = 'Inventory Shipment'	
END
ELSE
BEGIN
	SELECT	@ShipmentType = intOrderType
			,@ShipmentSourceType = intSourceType
	FROM	tblICInventoryShipment
	WHERE	intInventoryShipmentId = @ShipmentId
END
			
-- Create snapshot of Shipment Items before Save
SELECT	intInventoryShipmentId = intTransactionId
		,intInventoryShipmentItemId = intTransactionDetailId
		,intOrderType
		,intOrderId = intOrderNumberId
		,intSourceType
		,intSourceId = intSourceNumberId
		,intLineNo
		,intItemId
		,intItemUOMId
		,dblQuantity
		,ysnLoad
		,intLoadShipped = intLoadReceive
INTO	#tmpLogShipmentItems
FROM	tblICTransactionDetailLog
WHERE	intTransactionId = @ShipmentId
		AND strTransactionType = 'Inventory Shipment'

-- Create current snapshot of Shipment Items after Save
SELECT	ShipmentItem.intInventoryShipmentId
		,ShipmentItem.intInventoryShipmentItemId
		,Shipment.intOrderType
		,ShipmentItem.intOrderId
		,Shipment.intSourceType
		,ShipmentItem.intSourceId
		,ShipmentItem.intLineNo
		,ShipmentItem.intItemId
		,ShipmentItem.intItemUOMId
		,ShipmentItem.dblQuantity
		--,ShipmentItem.strItemType
		,ShipmentItemSource.ysnLoad
		,ShipmentItem.intLoadShipped
INTO	#tmpShipmentItems
FROM	tblICInventoryShipmentItem ShipmentItem LEFT JOIN tblICInventoryShipment Shipment 
			ON Shipment.intInventoryShipmentId = ShipmentItem.intInventoryShipmentId
		LEFT JOIN vyuICGetShipmentItemSource ShipmentItemSource ON ShipmentItemSource.intInventoryShipmentItemId = ShipmentItem.intInventoryShipmentItemId
WHERE	ShipmentItem.intInventoryShipmentId = @ShipmentId 
		AND (ShipmentItem.strItemType IS NULL OR ShipmentItem.strItemType != 'Option')
UNION ALL
--FOR OPTION
SELECT	ShipmentItem.intInventoryShipmentId
		,ShipmentItem.intInventoryShipmentItemId
		,Shipment.intOrderType
		,ShipmentItem.intOrderId
		,Shipment.intSourceType
		,ShipmentItem.intSourceId
		,ShipmentItem.intLineNo
		,ItemBundle.intItemId
		,ItemBundleUOM.intItemUOMId
		,ShipmentItem.dblQuantity
		--,ShipmentItem.strItemType
		,ShipmentItemSource.ysnLoad
		,ShipmentItem.intLoadShipped
FROM	tblICInventoryShipmentItem ShipmentItem LEFT JOIN tblICInventoryShipment Shipment 
			ON Shipment.intInventoryShipmentId = ShipmentItem.intInventoryShipmentId
		LEFT JOIN vyuICGetShipmentItemSource ShipmentItemSource
			ON ShipmentItemSource.intInventoryShipmentItemId = ShipmentItem.intInventoryShipmentItemId
		INNER JOIN tblICItemBundle ItemBundle 
			ON ItemBundle.intItemBundleId = ShipmentItem.intParentItemLinkId 
			AND ShipmentItem.intItemId = ItemBundle.intBundleItemId
		INNER JOIN tblICItemUOM ItemBundleUOM
			ON ItemBundleUOM.intItemId = ItemBundle.intItemId 
			AND ItemBundleUOM.ysnStockUnit = 1
WHERE	ShipmentItem.intInventoryShipmentId = @ShipmentId
		
-- Call the CT sp only if Shipment type is a 'Sales Contract' and NOT Logistics (Inbound Shipment) and NOT Scale (Scale Ticket)
-- Logistics (Inbound Shipment) and Scale (Scale Ticket) will be calling uspCTUpdateScheduleQuantity on their own. 
IF (
	@ShipmentType = @ShipmentType_SalesContract
	AND ISNULL(@ShipmentSourceType, @SourceType_None) NOT IN (@SourceType_InboundShipment, @SourceType_Scale) 
)
BEGIN 
	-- Create temporary table for processing records
	DECLARE @tblContractsToProcess TABLE
	(
		intKeyId					INT IDENTITY,
		intInventoryShipmentItemId	INT,
		intContractDetailId			INT,
		intItemUOMId				INT,
		dblQty						NUMERIC(18,6)	
	)

	INSERT INTO @tblContractsToProcess(
		intInventoryShipmentItemId
		,intContractDetailId
		,intItemUOMId
		,dblQty
	)

	-- Changed Quantity/UOM
	SELECT	currentSnapshot.intInventoryShipmentItemId
			,currentSnapshot.intLineNo
			,currentSnapshot.intItemUOMId
			,CASE WHEN ISNULL(currentSnapshot.ysnLoad,0) = 0 THEN dbo.fnCalculateQtyBetweenUOM(currentSnapshot.intItemUOMId, ContractDetail.intItemUOMId, (CASE WHEN @ForDelete = 1 THEN currentSnapshot.dblQuantity ELSE (currentSnapshot.dblQuantity - previousSnapshot.dblQuantity) END))
				ELSE (CASE WHEN @ForDelete = 1 THEN currentSnapshot.intLoadShipped ELSE (currentSnapshot.intLoadShipped - previousSnapshot.intLoadShipped) END) END 
	FROM	#tmpShipmentItems currentSnapshot INNER JOIN #tmpLogShipmentItems previousSnapshot
				ON previousSnapshot.intInventoryShipmentId = currentSnapshot.intInventoryShipmentId
				AND previousSnapshot.intInventoryShipmentItemId = currentSnapshot.intInventoryShipmentItemId
			INNER JOIN tblCTContractDetail ContractDetail
				ON ContractDetail.intContractDetailId = currentSnapshot.intLineNo
	WHERE	currentSnapshot.intLineNo IS NOT NULL
			AND currentSnapshot.intLineNo = previousSnapshot.intLineNo
			AND currentSnapshot.intItemId = previousSnapshot.intItemId		
			AND (currentSnapshot.intItemUOMId <> previousSnapshot.intItemUOMId OR currentSnapshot.dblQuantity <> previousSnapshot.dblQuantity OR currentSnapshot.intLoadShipped <> previousSnapshot.intLoadShipped)

	--New Contract Selected
	UNION ALL 
	SELECT	currentSnapshot.intInventoryShipmentItemId
			,currentSnapshot.intLineNo
			,currentSnapshot.intItemUOMId
			,CASE WHEN ISNULL(currentSnapshot.ysnLoad, 0) = 0 THEN dbo.fnCalculateQtyBetweenUOM(currentSnapshot.intItemUOMId, previousSnapshot.intItemUOMId, currentSnapshot.dblQuantity)
				ELSE currentSnapshot.intLoadShipped END
	FROM	#tmpShipmentItems currentSnapshot INNER JOIN #tmpLogShipmentItems previousSnapshot
				ON previousSnapshot.intInventoryShipmentId = currentSnapshot.intInventoryShipmentId
				AND previousSnapshot.intInventoryShipmentItemId = currentSnapshot.intInventoryShipmentItemId
			INNER JOIN tblCTContractDetail ContractDetail
				ON ContractDetail.intContractDetailId = currentSnapshot.intLineNo
	WHERE	currentSnapshot.intLineNo IS NOT NULL
			AND currentSnapshot.intLineNo <> previousSnapshot.intLineNo		
			AND currentSnapshot.intItemId = previousSnapshot.intItemId		
	

	--Replaced Contract
	UNION ALL
	SELECT	currentSnapshot.intInventoryShipmentItemId
			,previousSnapshot.intLineNo
			,previousSnapshot.intItemUOMId
			,CASE WHEN ISNULL(previousSnapshot.ysnLoad, 0) = 0 THEN dbo.fnCalculateQtyBetweenUOM(previousSnapshot.intItemUOMId, ContractDetail.intItemUOMId, (-previousSnapshot.dblQuantity))
				ELSE previousSnapshot.intLoadShipped * -1 END
	FROM	#tmpShipmentItems currentSnapshot INNER JOIN #tmpLogShipmentItems previousSnapshot
				ON previousSnapshot.intInventoryShipmentId = currentSnapshot.intInventoryShipmentId
				AND previousSnapshot.intInventoryShipmentItemId = currentSnapshot.intInventoryShipmentItemId
			INNER JOIN tblCTContractDetail ContractDetail
				ON ContractDetail.intContractDetailId = currentSnapshot.intLineNo
	WHERE	currentSnapshot.intLineNo IS NOT NULL
			AND currentSnapshot.intLineNo <> previousSnapshot.intLineNo
			AND currentSnapshot.intItemId = previousSnapshot.intItemId
		
	--Removed Contract
	UNION ALL
	SELECT	currentSnapshot.intInventoryShipmentItemId
			,previousSnapshot.intLineNo
			,previousSnapshot.intItemUOMId
			,CASE WHEN ISNULL(previousSnapshot.ysnLoad, 0) = 0 THEN dbo.fnCalculateQtyBetweenUOM(previousSnapshot.intItemUOMId, ContractDetail.intItemUOMId, (-previousSnapshot.dblQuantity))
				ELSE previousSnapshot.intLoadShipped * -1 END
	FROM	#tmpShipmentItems currentSnapshot INNER JOIN #tmpLogShipmentItems previousSnapshot
				ON previousSnapshot.intInventoryShipmentId = currentSnapshot.intInventoryShipmentId
				AND previousSnapshot.intInventoryShipmentItemId = currentSnapshot.intInventoryShipmentItemId
			INNER JOIN tblCTContractDetail ContractDetail
				ON ContractDetail.intContractDetailId = currentSnapshot.intLineNo
	WHERE	currentSnapshot.intLineNo IS NULL
			AND previousSnapshot.intLineNo IS NOT NULL
			
	--Deleted Item
	UNION ALL	
	SELECT	previousSnapshot.intInventoryShipmentItemId
			,previousSnapshot.intLineNo
			,previousSnapshot.intItemUOMId
			,CASE WHEN ISNULL(previousSnapshot.ysnLoad, 0) = 0 THEN dbo.fnCalculateQtyBetweenUOM(previousSnapshot.intItemUOMId, ContractDetail.intItemUOMId, (-previousSnapshot.dblQuantity))
				ELSE previousSnapshot.intLoadShipped * -1 END
	FROM	#tmpLogShipmentItems previousSnapshot INNER JOIN tblCTContractDetail ContractDetail
				ON ContractDetail.intContractDetailId = previousSnapshot.intLineNo
			--INNER JOIN tblICInventoryShipmentItem ShipmentItem ON ShipmentItem.intInventoryShipmentItemId = previousSnapshot.intInventoryShipmentItemId
	WHERE	previousSnapshot.intLineNo IS NOT NULL
			AND previousSnapshot.intInventoryShipmentItemId NOT IN (SELECT intInventoryShipmentItemId FROM #tmpShipmentItems)
			--AND ShipmentItem.strItemType != 'Kit'
	
	--Added Item
	UNION ALL
	SELECT	currentSnapshot.intInventoryShipmentItemId
			,currentSnapshot.intLineNo
			,currentSnapshot.intItemUOMId
			,CASE WHEN ISNULL(currentSnapshot.ysnLoad, 0) = 0 THEN dbo.fnCalculateQtyBetweenUOM(currentSnapshot.intItemUOMId, ContractDetail.intItemUOMId, currentSnapshot.dblQuantity)
				ELSE currentSnapshot.intLoadShipped END
	FROM	#tmpShipmentItems currentSnapshot INNER JOIN tblCTContractDetail ContractDetail
				ON ContractDetail.intContractDetailId = currentSnapshot.intLineNo
	WHERE	currentSnapshot.intLineNo IS NOT NULL
			AND currentSnapshot.intInventoryShipmentItemId NOT IN (SELECT intInventoryShipmentItemId FROM #tmpLogShipmentItems)
			--AND currentSnapshot.strItemType != 'Kit'

	DECLARE loopItemsForContractScheduleQuantity CURSOR LOCAL FAST_FORWARD
	FOR 
	SELECT	intContractDetailId
			,dblQty 
			,intInventoryShipmentItemId
	FROM	@tblContractsToProcess
	WHERE	ISNULL(dblQty, 0) <> 0 

	OPEN loopItemsForContractScheduleQuantity;
		
	-- Initial fetch attempt
	FETCH NEXT FROM loopItemsForContractScheduleQuantity INTO 
		@intContractDetailId
		,@dblQty
		,@intInventoryShipmentItemId;

	-----------------------------------------------------------------------------------------------------------------------------
	-- Start of the loop for the integration sp. 
	-----------------------------------------------------------------------------------------------------------------------------
	WHILE @@FETCH_STATUS = 0
	BEGIN 		
		EXEC	uspCTUpdateScheduleQuantity
				@intContractDetailId	=	@intContractDetailId,
				@dblQuantityToUpdate	=	@dblQty,
				@intUserId				=	@UserId,
				@intExternalId			=	@intInventoryShipmentItemId,
				@strScreenName			=	'Inventory Shipment'

		-- Attempt to fetch the next row from cursor. 
		FETCH NEXT FROM loopItemsForContractScheduleQuantity INTO 
			@intContractDetailId
			,@dblQty
			,@intInventoryShipmentItemId	
	END;
	-----------------------------------------------------------------------------------------------------------------------------
	-- End of the loop
	-----------------------------------------------------------------------------------------------------------------------------

	CLOSE loopItemsForContractScheduleQuantity;
	DEALLOCATE loopItemsForContractScheduleQuantity;
END 

-- Update the Sales Order Shippped Qty
IF (
	@ShipmentType = @ShipmentType_SalesOrder
)
BEGIN 
	-- Create temporary table for processing records
	DECLARE @tblSalesOrderToProcess TABLE
	(
		intKeyId					INT IDENTITY,
		intInventoryShipmentItemId	INT,
		intSalesOrderDetailId		INT,
		intSalesOrderId				INT,
		intItemUOMId				INT,
		dblQty						NUMERIC(12,4)	
	)

	INSERT INTO @tblSalesOrderToProcess(
		intInventoryShipmentItemId
		,intSalesOrderDetailId
		,intSalesOrderId
		,intItemUOMId
		,dblQty
	)

	-- Changed Quantity/UOM
	SELECT	currentSnapshot.intInventoryShipmentItemId
			,currentSnapshot.intLineNo
			,SalesOrderDetail.intSalesOrderId
			,currentSnapshot.intItemUOMId
			,dbo.fnCalculateQtyBetweenUOM(currentSnapshot.intItemUOMId, SalesOrderDetail.intItemUOMId, (CASE WHEN @ForDelete = 1 THEN currentSnapshot.dblQuantity ELSE (currentSnapshot.dblQuantity - previousSnapshot.dblQuantity) END))
	FROM	#tmpShipmentItems currentSnapshot INNER JOIN #tmpLogShipmentItems previousSnapshot
				ON previousSnapshot.intInventoryShipmentId = currentSnapshot.intInventoryShipmentId
				AND previousSnapshot.intInventoryShipmentItemId = currentSnapshot.intInventoryShipmentItemId
			INNER JOIN tblSOSalesOrderDetail SalesOrderDetail
				ON SalesOrderDetail.intSalesOrderDetailId = currentSnapshot.intLineNo
	WHERE	currentSnapshot.intLineNo IS NOT NULL
			AND currentSnapshot.intLineNo = previousSnapshot.intLineNo
			AND currentSnapshot.intItemId = previousSnapshot.intItemId		
			AND (currentSnapshot.intItemUOMId <> previousSnapshot.intItemUOMId OR currentSnapshot.dblQuantity <> previousSnapshot.dblQuantity)

	-- New Sales Order Detail Added (via Add-Orders)
	UNION ALL 
	SELECT	currentSnapshot.intInventoryShipmentItemId
			,currentSnapshot.intLineNo
			,SalesOrderDetail.intSalesOrderId
			,currentSnapshot.intItemUOMId
			,dbo.fnCalculateQtyBetweenUOM(currentSnapshot.intItemUOMId, previousSnapshot.intItemUOMId, currentSnapshot.dblQuantity)
	FROM	#tmpShipmentItems currentSnapshot INNER JOIN #tmpLogShipmentItems previousSnapshot
				ON previousSnapshot.intInventoryShipmentId = currentSnapshot.intInventoryShipmentId
				AND previousSnapshot.intInventoryShipmentItemId = currentSnapshot.intInventoryShipmentItemId
			INNER JOIN tblSOSalesOrderDetail SalesOrderDetail
				ON SalesOrderDetail.intSalesOrderDetailId = currentSnapshot.intLineNo
	WHERE	currentSnapshot.intLineNo IS NOT NULL
			AND currentSnapshot.intLineNo <> previousSnapshot.intLineNo		
			AND currentSnapshot.intItemId = previousSnapshot.intItemId		
	

	-- Replaced the Sales Order 
	UNION ALL
	SELECT	currentSnapshot.intInventoryShipmentItemId
			,previousSnapshot.intLineNo
			,SalesOrderDetail.intSalesOrderId
			,previousSnapshot.intItemUOMId
			,dbo.fnCalculateQtyBetweenUOM(previousSnapshot.intItemUOMId, SalesOrderDetail.intItemUOMId, (-previousSnapshot.dblQuantity))
	FROM	#tmpShipmentItems currentSnapshot INNER JOIN #tmpLogShipmentItems previousSnapshot
				ON previousSnapshot.intInventoryShipmentId = currentSnapshot.intInventoryShipmentId
				AND previousSnapshot.intInventoryShipmentItemId = currentSnapshot.intInventoryShipmentItemId
			INNER JOIN tblSOSalesOrderDetail SalesOrderDetail
				ON SalesOrderDetail.intSalesOrderDetailId = currentSnapshot.intLineNo
	WHERE	currentSnapshot.intLineNo IS NOT NULL
			AND currentSnapshot.intLineNo <> previousSnapshot.intLineNo
			AND currentSnapshot.intItemId = previousSnapshot.intItemId
		
	-- Deleted Sales Order 
	UNION ALL
	SELECT	currentSnapshot.intInventoryShipmentItemId
			,previousSnapshot.intLineNo
			,SalesOrderDetail.intSalesOrderId
			,previousSnapshot.intItemUOMId
			,dbo.fnCalculateQtyBetweenUOM(previousSnapshot.intItemUOMId, SalesOrderDetail.intItemUOMId, (-previousSnapshot.dblQuantity))
	FROM	#tmpShipmentItems currentSnapshot INNER JOIN #tmpLogShipmentItems previousSnapshot
				ON previousSnapshot.intInventoryShipmentId = currentSnapshot.intInventoryShipmentId
				AND previousSnapshot.intInventoryShipmentItemId = currentSnapshot.intInventoryShipmentItemId
			INNER JOIN tblSOSalesOrderDetail SalesOrderDetail
				ON SalesOrderDetail.intSalesOrderDetailId = currentSnapshot.intLineNo
	WHERE	currentSnapshot.intLineNo IS NULL
			AND previousSnapshot.intLineNo IS NOT NULL
			
	-- Deleted Item
	UNION ALL	
	SELECT	previousSnapshot.intInventoryShipmentItemId
			,previousSnapshot.intLineNo
			,SalesOrderDetail.intSalesOrderId
			,previousSnapshot.intItemUOMId
			,dbo.fnCalculateQtyBetweenUOM(previousSnapshot.intItemUOMId, SalesOrderDetail.intItemUOMId, (-previousSnapshot.dblQuantity))
	FROM	#tmpLogShipmentItems previousSnapshot INNER JOIN tblSOSalesOrderDetail SalesOrderDetail
				ON SalesOrderDetail.intSalesOrderDetailId = previousSnapshot.intLineNo
	WHERE	previousSnapshot.intLineNo IS NOT NULL
			AND previousSnapshot.intInventoryShipmentItemId NOT IN (SELECT intInventoryShipmentItemId FROM #tmpShipmentItems)
	
	-- Added Item
	UNION ALL
	SELECT	currentSnapshot.intInventoryShipmentItemId
			,currentSnapshot.intLineNo
			,SalesOrderDetail.intSalesOrderId
			,currentSnapshot.intItemUOMId
			,dbo.fnCalculateQtyBetweenUOM(currentSnapshot.intItemUOMId, SalesOrderDetail.intItemUOMId, currentSnapshot.dblQuantity)
	FROM	#tmpShipmentItems currentSnapshot INNER JOIN tblSOSalesOrderDetail SalesOrderDetail
				ON SalesOrderDetail.intSalesOrderDetailId = currentSnapshot.intLineNo
	WHERE	currentSnapshot.intLineNo IS NOT NULL
			AND currentSnapshot.intInventoryShipmentItemId NOT IN (SELECT intInventoryShipmentItemId FROM #tmpLogShipmentItems)

	-- Iterate and process records
	DECLARE loopItemsForContractScheduleQuantity CURSOR LOCAL FAST_FORWARD
	FOR 
	SELECT	intSalesOrderDetailId
			,dblQty 
			,intInventoryShipmentItemId
	FROM	@tblSalesOrderToProcess
	WHERE	ISNULL(dblQty, 0) <> 0 

	OPEN loopItemsForContractScheduleQuantity;
		
	-- Initial fetch attempt
	FETCH NEXT FROM loopItemsForContractScheduleQuantity INTO 
		@intSalesOrderDetailId
		,@dblQty
		,@intInventoryShipmentItemId;

	-----------------------------------------------------------------------------------------------------------------------------
	-- Start of the loop for the integration sp. 
	-----------------------------------------------------------------------------------------------------------------------------
	WHILE @@FETCH_STATUS = 0
	BEGIN 		
		EXEC [dbo].[uspSOUpdateOrderShipmentStatus]
			  @intTransactionId			= NULL
			, @strTransactionType		= 'Inventory'
			, @ysnForDelete				= 0
			, @intSalesOrderDetailId	= @intSalesOrderDetailId
			, @dblQuantity				= @dblQty
			, @intItemUOMId				= NULL 

		-- Attempt to fetch the next row from cursor. 
		FETCH NEXT FROM loopItemsForContractScheduleQuantity INTO 
			@intSalesOrderDetailId
			,@dblQty
			,@intInventoryShipmentItemId	
	END;
	-----------------------------------------------------------------------------------------------------------------------------
	-- End of the loop
	-----------------------------------------------------------------------------------------------------------------------------

	CLOSE loopItemsForContractScheduleQuantity;
	DEALLOCATE loopItemsForContractScheduleQuantity;

	-----------------------------------------------------------------------------------------------------------------------------
	-- Call MFG sp to post the Pick List reservation. 
	-----------------------------------------------------------------------------------------------------------------------------
	-- Iterate and process records
	DECLARE loopForPickListReservation CURSOR LOCAL FAST_FORWARD
	FOR 
	SELECT	DISTINCT 
			intSalesOrderId
	FROM	@tblSalesOrderToProcess
	WHERE	ISNULL(dblQty, 0) <> 0 

	OPEN loopForPickListReservation;
		
	-- Initial fetch attempt
	FETCH NEXT FROM loopForPickListReservation INTO 
		@intSalesOrderId
	;

	-- Start of the loop 
	WHILE @@FETCH_STATUS = 0
	BEGIN 		
	   	-- Post the Pick/List reservation. 
		IF EXISTS (
			SELECT TOP 1 1
			FROM 
				tblICInventoryShipment s INNER JOIN tblICInventoryShipmentItem si 
					ON s.intInventoryShipmentId = si.intInventoryShipmentId
			WHERE
				s.intInventoryShipmentId = @ShipmentId
				AND s.intOrderType = @ShipmentType_SalesOrder
				AND si.intOrderId = @intSalesOrderId
				AND si.intLineNo IS NOT NULL 		
		)
		BEGIN
			
			EXEC [dbo].[uspMFUnReservePickListBySalesOrder]
				  @intSalesOrderId	= @intSalesOrderId
				, @ysnPosted = 1
		END 

		-- Unpost the Pick/List reservation because the sales order are delete from all the Shipment. 
		ELSE IF NOT EXISTS (
			SELECT TOP 1 1
			FROM 
				tblICInventoryShipment s INNER JOIN tblICInventoryShipmentItem si 
					ON s.intInventoryShipmentId = si.intInventoryShipmentId
			WHERE
				s.intOrderType = @ShipmentType_SalesOrder
				AND si.intOrderId = @intSalesOrderId
				AND si.intLineNo IS NOT NULL 
		)
		BEGIN 			
			EXEC [dbo].[uspMFUnReservePickListBySalesOrder]
				  @intSalesOrderId	= @intSalesOrderId
				, @ysnPosted = 0
		END 

		-- Attempt to fetch the next row from cursor. 
		FETCH NEXT FROM loopForPickListReservation INTO 
			@intSalesOrderId
	END;
	-- End of the loop

	CLOSE loopForPickListReservation;
	DEALLOCATE loopForPickListReservation;
END 

-- Do the stock reservation 
BEGIN
	DECLARE @tblForReservation TABLE (
		intInventoryShipmentId	INT
	)

	INSERT INTO @tblForReservation(
		intInventoryShipmentId
	)
	-- Get Previous snapshots
	SELECT	previousSnapshot.intInventoryShipmentId
	FROM	#tmpLogShipmentItems previousSnapshot

	-- Get latest snapshots
	UNION ALL 
	SELECT	currentSnapshot.intInventoryShipmentId
	FROM	#tmpShipmentItems currentSnapshot LEFT JOIN #tmpLogShipmentItems previousSnapshot
				ON currentSnapshot.intInventoryShipmentId = previousSnapshot.intInventoryShipmentId
	WHERE	previousSnapshot.intInventoryShipmentId IS NULL 
	
	DECLARE @intInventoryShipmentId	INT
	DECLARE loopForStockReservation CURSOR LOCAL FAST_FORWARD
	FOR 
	SELECT	DISTINCT intInventoryShipmentId
	FROM	@tblForReservation

	OPEN loopForStockReservation;

	-- Initial fetch attempt
	FETCH NEXT FROM loopForStockReservation INTO 
		@intInventoryShipmentId;

	-----------------------------------------------------------------------------------------------------------------------------
	-- Start of the loop for the integration sp. 
	-----------------------------------------------------------------------------------------------------------------------------
	WHILE @@FETCH_STATUS = 0
	BEGIN 		
		-- Call the stock reservation sp. 
		EXEC uspICReserveStockForInventoryShipment @intInventoryShipmentId
	
		-- Attempt to fetch the next row from cursor. 
		FETCH NEXT FROM loopForStockReservation INTO 
			@intInventoryShipmentId;	
	END;
	-----------------------------------------------------------------------------------------------------------------------------
	-- End of the loop
	-----------------------------------------------------------------------------------------------------------------------------

	CLOSE loopForStockReservation;
	DEALLOCATE loopForStockReservation;
END

-- Delete Quality Management Inspection
DECLARE @intProductTypeId AS INT = 4 -- Shipment
	,@intProductValueId AS INT = @ShipmentId -- intInventoryShipmentId

IF @ForDelete = 1
BEGIN
	EXEC uspQMInspectionDeleteResult @intProductValueId, @intProductTypeId
END
ELSE
BEGIN
	DECLARE @intControlPointId AS INT = 3
	DECLARE @QualityInspectionTable QualityInspectionTable
 
	INSERT INTO @QualityInspectionTable (intPropertyId,strPropertyName,strPropertyValue,strComment)
	SELECT iri.intQAPropertyId, iri.strPropertyName,'true / false', iri.strComment
	FROM tblICInventoryShipmentInspection iri
	WHERE iri.intInventoryShipmentId = @ShipmentId
 
	EXEC uspQMInspectionSaveResult @intControlPointId, @intProductTypeId, @intProductValueId, @UserId, @QualityInspectionTable	
END

DROP TABLE #tmpLogShipmentItems
DROP TABLE #tmpShipmentItems

DELETE	FROM tblICTransactionDetailLog 
WHERE	strTransactionType = 'Inventory Shipment' 
		AND intTransactionId = @ShipmentId

OnError_Exit: