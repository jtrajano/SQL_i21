CREATE PROCEDURE [dbo].[uspICInventoryShipmentAfterSave]
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
INTO	#tmpShipmentItems
FROM	tblICInventoryShipmentItem ShipmentItem LEFT JOIN tblICInventoryShipment Shipment 
			ON Shipment.intInventoryShipmentId = ShipmentItem.intInventoryShipmentId
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
		dblQty						NUMERIC(12,4)	
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
			,dbo.fnCalculateQtyBetweenUOM(currentSnapshot.intItemUOMId, ContractDetail.intItemUOMId, (CASE WHEN @ForDelete = 1 THEN currentSnapshot.dblQuantity ELSE (currentSnapshot.dblQuantity - previousSnapshot.dblQuantity) END))
	FROM	#tmpShipmentItems currentSnapshot INNER JOIN #tmpLogShipmentItems previousSnapshot
				ON previousSnapshot.intInventoryShipmentId = currentSnapshot.intInventoryShipmentId
				AND previousSnapshot.intInventoryShipmentItemId = currentSnapshot.intInventoryShipmentItemId
			INNER JOIN tblCTContractDetail ContractDetail
				ON ContractDetail.intContractDetailId = currentSnapshot.intLineNo
	WHERE	currentSnapshot.intLineNo IS NOT NULL
			AND currentSnapshot.intLineNo = previousSnapshot.intLineNo
			AND currentSnapshot.intItemId = previousSnapshot.intItemId		
			AND (currentSnapshot.intItemUOMId <> previousSnapshot.intItemUOMId OR currentSnapshot.dblQuantity <> previousSnapshot.dblQuantity)

	--New Contract Selected
	UNION ALL 
	SELECT	currentSnapshot.intInventoryShipmentItemId
			,currentSnapshot.intLineNo
			,currentSnapshot.intItemUOMId
			,dbo.fnCalculateQtyBetweenUOM(currentSnapshot.intItemUOMId, previousSnapshot.intItemUOMId, currentSnapshot.dblQuantity)
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
			,dbo.fnCalculateQtyBetweenUOM(previousSnapshot.intItemUOMId, ContractDetail.intItemUOMId, (-previousSnapshot.dblQuantity))
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
			,dbo.fnCalculateQtyBetweenUOM(previousSnapshot.intItemUOMId, ContractDetail.intItemUOMId, (-previousSnapshot.dblQuantity))
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
			,dbo.fnCalculateQtyBetweenUOM(previousSnapshot.intItemUOMId, ContractDetail.intItemUOMId, (-previousSnapshot.dblQuantity))
	FROM	#tmpLogShipmentItems previousSnapshot INNER JOIN tblCTContractDetail ContractDetail
				ON ContractDetail.intContractDetailId = previousSnapshot.intLineNo
	WHERE	previousSnapshot.intLineNo IS NOT NULL
			AND previousSnapshot.intInventoryShipmentItemId NOT IN (SELECT intInventoryShipmentItemId FROM #tmpShipmentItems)
		
	
	--Added Item
	UNION ALL
	SELECT	currentSnapshot.intInventoryShipmentItemId
			,currentSnapshot.intLineNo
			,currentSnapshot.intItemUOMId
			,dbo.fnCalculateQtyBetweenUOM(currentSnapshot.intItemUOMId, ContractDetail.intItemUOMId, currentSnapshot.dblQuantity)
	FROM	#tmpShipmentItems currentSnapshot INNER JOIN tblCTContractDetail ContractDetail
				ON ContractDetail.intContractDetailId = currentSnapshot.intLineNo
	WHERE	currentSnapshot.intLineNo IS NOT NULL
			AND currentSnapshot.intInventoryShipmentItemId NOT IN (SELECT intInventoryShipmentItemId FROM #tmpLogShipmentItems)

	-- Iterate and process records
	DECLARE @Id INT = NULL,
			@intInventoryShipmentItemId	INT = NULL,
			@intContractDetailId		INT = NULL,
			@intFromItemUOMId			INT = NULL,
			@intToItemUOMId				INT = NULL,
			@dblQty				NUMERIC(12,4) = 0

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

DROP TABLE #tmpLogShipmentItems
DROP TABLE #tmpShipmentItems

DELETE	FROM tblICTransactionDetailLog 
WHERE	strTransactionType = 'Inventory Shipment' 
		AND intTransactionId = @ShipmentId

OnError_Exit: