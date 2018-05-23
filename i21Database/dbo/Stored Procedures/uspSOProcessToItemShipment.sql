CREATE PROCEDURE [dbo].[uspSOProcessToItemShipment]
	@SalesOrderId			INT,
	@UserId					INT,
	@Unship					BIT = 0,
	@InventoryShipmentId	INT OUTPUT 
AS
BEGIN

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF
 
DECLARE	 @ShipmentId INT
		,@InvoiceId  INT = 0	    

--VALIDATE IF SO IS ALREADY CLOSED
IF EXISTS(SELECT NULL FROM tblSOSalesOrder WHERE [intSalesOrderId] = @SalesOrderId AND [strOrderStatus] = 'Closed' AND @Unship = 0)
	BEGIN
		RAISERROR('Sales Order already closed.', 16, 1)
		RETURN;
	END

--VALIDATE IF SO HAS ZERO TOTAL AMOUNT
IF EXISTS(SELECT NULL FROM tblSOSalesOrder WHERE [intSalesOrderId] = @SalesOrderId AND [dblSalesOrderTotal]  = 0 AND @Unship = 0)
	BEGIN
		RAISERROR('Cannot process Sales Order with zero(0) amount.', 16, 1)
		RETURN;
	END

--VALIDATE IF SO IS FOR APPROVAL
IF EXISTS(SELECT NULL FROM vyuARForApprovalTransction WHERE strScreenName = 'Sales Order' AND intTransactionId = @SalesOrderId)
	BEGIN
		RAISERROR('Sales Order is still waiting for approval.', 16, 1)
		RETURN;
	END

--IF UNSHIP
IF @Unship = 1
	BEGIN
		--VALIDATE IF SO HAS POSTED SHIPMENT RECORDS
		DECLARE @PostedShipmentNos NVARCHAR(MAX) = NULL
			  , @UnpostedShipmentNos NVARCHAR(MAX) = NULL

		SELECT @PostedShipmentNos = COALESCE(@PostedShipmentNos + ', ' ,'') + ISH.strShipmentNumber 
		FROM (
			SELECT intInventoryShipmentId
			FROM dbo.tblICInventoryShipmentItem WITH (NOLOCK)
			WHERE intOrderId = @SalesOrderId
			GROUP BY intInventoryShipmentId
		) ISHI 
		INNER JOIN (
			SELECT intInventoryShipmentId
				 , strShipmentNumber
			FROM dbo.tblICInventoryShipment WITH (NOLOCK)
			WHERE ysnPosted = 1
		) ISH ON ISHI.intInventoryShipmentId = ISH.intInventoryShipmentId

		SELECT @UnpostedShipmentNos = COALESCE(@UnpostedShipmentNos + ', ' ,'') + ISH.strShipmentNumber 
		FROM (
			SELECT intInventoryShipmentId
			FROM dbo.tblICInventoryShipmentItem WITH (NOLOCK)
			WHERE intOrderId = @SalesOrderId
			GROUP BY intInventoryShipmentId
		) ISHI 
		INNER JOIN (
			SELECT intInventoryShipmentId
				 , strShipmentNumber
			FROM dbo.tblICInventoryShipment WITH (NOLOCK)
			WHERE ysnPosted = 0
		) ISH ON ISHI.intInventoryShipmentId = ISH.intInventoryShipmentId

		IF ISNULL(@PostedShipmentNos, '') <> '' AND ISNULL(@UnpostedShipmentNos, '') = ''
			BEGIN				
				RAISERROR('Failed to unship Sales Order. Unpost this Shipment Record first: %s', 16, 1, @PostedShipmentNos)
				RETURN
			END
		ELSE
			BEGIN
				-- Delete shipment and decrease Item Stock Reservation
				BEGIN
					DECLARE @InventoryShipment Id
					DECLARE @intInventoryShipmentId INT

					INSERT INTO @InventoryShipment
					SELECT DISTINCT ISH.intInventoryShipmentId
					FROM tblICInventoryShipmentItem ISHI
						INNER JOIN tblICInventoryShipment ISH ON ISHI.intInventoryShipmentId = ISH.intInventoryShipmentId
					WHERE intOrderId = @SalesOrderId
					  AND ISH.ysnPosted = 0
					
					DECLARE c CURSOR LOCAL STATIC READ_ONLY FORWARD_ONLY
					FOR
						SELECT * FROM @InventoryShipment
					OPEN c;
					FETCH NEXT FROM c INTO @intInventoryShipmentId

					WHILE @@FETCH_STATUS = 0 
					BEGIN
						EXEC dbo.uspICUnshipInventoryItem @intInventoryShipmentId, @UserId
						EXEC dbo.uspSOUpdateOrderShipmentStatus @intInventoryShipmentId, 'Inventory', 1

						FETCH NEXT FROM c INTO @intInventoryShipmentId
					END
					CLOSE c;
					DEALLOCATE c;
				END
			
				UPDATE tblSOSalesOrder 
				SET ysnShipped = CASE WHEN ISNULL(@PostedShipmentNos, '') <> '' THEN CAST(1 AS BIT) ELSE CAST(0 AS BIT) END 
				WHERE intSalesOrderId = @SalesOrderId
				RETURN 1
			END
	END

--VALIDATE IF THERE ARE STOCK ITEMS TO SHIP
IF(OBJECT_ID('tempdb..#ITEMSTOSHIP') IS NOT NULL)
BEGIN
    DROP TABLE #ITEMSTOSHIP
END

SELECT SOD.intItemId
	 , IC.strBundleType
	 , IC.strType
INTO #ITEMSTOSHIP
FROM tblSOSalesOrderDetail SOD
INNER JOIN tblICItem IC ON SOD.intItemId = IC.intItemId 
WHERE intSalesOrderId = @SalesOrderId 
AND (dbo.fnIsStockTrackingItem(SOD.intItemId) = 1 OR (dbo.fnIsStockTrackingItem(SOD.intItemId) = 0 AND (IC.strType = 'Bundle' AND ISNULL(IC.strBundleType, 'Kit') = 'Kit')))
AND (dblQtyOrdered - dblQtyShipped > 0)

IF NOT EXISTS(SELECT TOP 1 NULL FROM #ITEMSTOSHIP)
	BEGIN
		RAISERROR('Shipping Failed. There is no shippable item on this sales order.', 16, 1);
        RETURN
	END
ELSE
	BEGIN 
		DECLARE @Items				ShipmentStagingTable
			  , @Charges			ShipmentChargeStagingTable
			  , @Lots				ShipmentItemLotStagingTable			  
			  , @SALES_ORDER		NVARCHAR(50) = 'Sales Order'
			  , @SALES_ORDER_TYPE	INT = 2
			  , @intReturn			INT 

		INSERT INTO @Items (
			  intOrderType 
			, intSourceType
			, intEntityCustomerId
			, dtmShipDate
			, intShipFromLocationId
			, intShipToLocationId
			, intFreightTermId
			, strSourceScreenName
			, strReferenceNumber
			, dtmRequestedArrivalDate
			, intShipToCompanyLocationId
			, strBOLNumber
			, intShipViaId
			, strVessel
			, strProNumber
			, strDriverId
			, strSealNumber
			, strDeliveryInstruction
			, dtmAppointmentTime
			, dtmDepartureTime
			, dtmArrivalTime
			, dtmDeliveredDate
			, dtmFreeTime
			, strFreeTime
			, strReceivedBy
			, strComment
			, intItemId
			, intOwnershipType
			, dblQuantity
			, intItemUOMId
			, intPriceUOMId
			, intItemLotGroup
			, intOrderId
			, intSourceId
			, intLineNo
			, intSubLocationId
			, intStorageLocationId
			, intCurrencyId
			, intWeightUOMId
			, dblUnitPrice
			, intDockDoorId
			, strNotes
			, intGradeId
			, intDiscountSchedule
			, intStorageScheduleTypeId
			, intForexRateTypeId
			, dblForexRate	
		)
		-- Insert stock keeping items, except kit items. 
		SELECT intOrderType					= @SALES_ORDER_TYPE
			, intSourceType					= 0
			, intEntityCustomerId			= SO.intEntityCustomerId
			, dtmShipDate					= SO.dtmDate
			, intShipFromLocationId			= SO.intCompanyLocationId
			, intShipToLocationId			= SO.intShipToLocationId
			, intFreightTermId				= SO.intFreightTermId
			, strSourceScreenName			= @SALES_ORDER
			, strReferenceNumber			= SO.strSalesOrderNumber
			, dtmRequestedArrivalDate		= NULL
			, intShipToCompanyLocationId	= NULL
			, strBOLNumber					= SO.strBOLNumber
			, intShipViaId					= SO.intShipViaId
			, strVessel						= NULL
			, strProNumber					= NULL
			, strDriverId					= NULL
			, strSealNumber					= NULL
			, strDeliveryInstruction		= NULL
			, dtmAppointmentTime			= NULL
			, dtmDepartureTime				= NULL
			, dtmArrivalTime				= NULL
			, dtmDeliveredDate				= NULL
			, dtmFreeTime					= NULL
			, strFreeTime					= NULL
			, strReceivedBy					= NULL
			, strComment					= SO.strComments
			, intItemId						= SODETAIL.intItemId
			, intOwnershipType				= CASE WHEN SODETAIL.intStorageScheduleTypeId IS NULL THEN 1 ELSE 2 END
			, dblQuantity					= SODETAIL.dblQtyOrdered - ISNULL(INVOICEDETAIL.dblQtyShipped, SODETAIL.dblQtyShipped)
			, intItemUOMId					= ITEMUOM.intItemUOMId
			, intPriceUOMId					= SODETAIL.intItemUOMId
			, intItemLotGroup				= NULL
			, intOrderId					= SODETAIL.intSalesOrderId
			, intSourceId					= NULL
			, intLineNo						= SODETAIL.intSalesOrderDetailId
			, intSubLocationId				= COALESCE(SODETAIL.intSubLocationId, STORAGELOCATION.intSubLocationId, ITEMLOCATION.intSubLocationId)
			, intStorageLocationId			= COALESCE(SODETAIL.intStorageLocationId, ITEMLOCATION.intStorageLocationId)
			, intCurrencyId					= SO.intCurrencyId
			, intWeightUOMId				= NULL
			, dblUnitPrice					= SODETAIL.dblPrice
			, intDockDoorId					= NULL
			, strNotes						= SODETAIL.strComments
			, intGradeId					= NULL
			, intDiscountSchedule			= NULL
			, intStorageScheduleTypeId		= SODETAIL.intStorageScheduleTypeId
			, intForexRateTypeId			= SODETAIL.intCurrencyExchangeRateTypeId
			, dblForexRate					= SODETAIL.dblCurrencyExchangeRate
	FROM dbo.tblSOSalesOrder SO	
	INNER JOIN dbo.tblSOSalesOrderDetail SODETAIL 
		ON SO.intSalesOrderId = SODETAIL.intSalesOrderId
	INNER JOIN tblICItem ITEM
		ON ITEM.intItemId = SODETAIL.intItemId 
		AND ((ITEM.strType <> 'Bundle' AND dbo.fnIsStockTrackingItem(SODETAIL.intItemId) = 1) 
		  OR (ITEM.strType = 'Bundle' AND ISNULL(ITEM.strBundleType, 'Kit') = 'Kit'))
		AND  CASE WHEN (ITEM.strType = 'Bundle') THEN 
				CASE WHEN ISNULL(ITEM.ysnListBundleSeparately, 0) = 0 THEN 1 ELSE 0 END
			 ELSE 1 END = 1
	INNER JOIN dbo.tblICItemUOM ITEMUOM 
		ON ITEMUOM.intItemId = SODETAIL.intItemId 
		AND ITEMUOM.intItemUOMId = SODETAIL.intItemUOMId 
	INNER JOIN dbo.tblICItemLocation ITEMLOCATION 
		ON ITEMLOCATION.intItemId = SODETAIL.intItemId 
		AND SO.intCompanyLocationId = ITEMLOCATION.intLocationId
	LEFT JOIN tblSMCompanyLocationSubLocation SUBLOCATION
		ON SUBLOCATION.intCompanyLocationId = ITEMLOCATION.intLocationId
		AND SUBLOCATION.intCompanyLocationSubLocationId = SODETAIL.intSubLocationId				
	LEFT JOIN dbo.tblICStorageLocation STORAGELOCATION 
		ON STORAGELOCATION.intLocationId = ITEMLOCATION.intLocationId
		AND STORAGELOCATION.intSubLocationId = SUBLOCATION.intCompanyLocationSubLocationId
		AND STORAGELOCATION.intStorageLocationId = SODETAIL.intStorageLocationId	
	OUTER APPLY (
		SELECT intSalesOrderDetailId
				, dblQtyShipped = SUM(dblQtyShipped)
		FROM dbo.tblARInvoiceDetail ID
		WHERE ID.intSalesOrderDetailId = SODETAIL.intSalesOrderDetailId
		GROUP BY ID.intSalesOrderDetailId
	) INVOICEDETAIL
	WHERE SO.intSalesOrderId = @SalesOrderId
	  AND (SODETAIL.dblQtyOrdered - ISNULL(INVOICEDETAIL.dblQtyShipped, SODETAIL.dblQtyShipped)) > 0

		INSERT INTO @Charges(
			  intOrderType
			, intSourceType
			, intEntityCustomerId
			, dtmShipDate
			, intShipFromLocationId
			, intShipToLocationId
			, intFreightTermId
			, intContractId
			, intContractDetailId
			, intChargeId
			, strCostMethod
			, dblRate
			, intCostUOMId
			, intCurrency
			, dblAmount
			, ysnAccrue
			, intEntityVendorId
			, ysnPrice
			, intForexRateTypeId
			, dblForexRate
			, strChargesLink
			, strAllocatePriceBy
		)

		SELECT intOrderType			= @SALES_ORDER_TYPE
			, intSourceType			= 0
			, intEntityCustomerId	= SO.intEntityCustomerId
			, dtmShipDate			= SO.dtmDate
			, intShipFromLocationId	= SO.intCompanyLocationId
			, intShipToLocationId	= SO.intShipToLocationId
			, intFreightTermId		= SO.intFreightTermId
			, intContractId			= Header.intContractHeaderId
			, intContractDetailId	= Detail.intContractDetailId
			, intChargeId			= Cost.intItemId
			, strCostMethod			= Cost.strCostMethod
			, dblRate				= Cost.dblRate
			, intCostUOMId			= Cost.intItemUOMId
			, intCurrency			= Cost.intCurrencyId
			, dblAmount				= NULL
			, ysnAccrue				= Cost.ysnAccrue
			, intEntityVendorId		= NULL
			, ysnPrice				= Cost.ysnPrice
			, intForexRateTypeId	= SODETAIL.intCurrencyExchangeRateTypeId
			, dblForexRate			= SODETAIL.dblCurrencyExchangeRate
			, strChargesLink		= NULL
			, strAllocatePriceBy	= NULL
		FROM dbo.tblSOSalesOrder SO	
		INNER JOIN dbo.tblSOSalesOrderDetail SODETAIL 
				ON SO.intSalesOrderId = SODETAIL.intSalesOrderId
		INNER JOIN tblCTContractHeader Header
			ON Header.intContractHeaderId = SODETAIL.intContractHeaderId
		INNER JOIN tblCTContractDetail Detail
			ON Detail.intContractHeaderId = Header.intContractHeaderId
		INNER JOIN tblCTContractCost Cost
			ON Detail.intContractDetailId = Cost.intContractDetailId
		WHERE SO.intSalesOrderId = @SalesOrderId

		IF NOT EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#tmpAddItemShipmentResult')) 
		BEGIN 
			CREATE TABLE #tmpAddItemShipmentResult (
				intInventoryShipmentId INT
			)
		END 

		EXEC @intReturn = dbo.uspICAddItemShipment @Items		= @Items
												 , @Charges		= @Charges
												 , @Lots		= @Lots
												 , @intUserId	= @UserId	
				
		IF @intReturn <> 0 
			RETURN @intReturn

		SELECT	TOP 1 
				@InventoryShipmentId = intInventoryShipmentId 
		FROM	#tmpAddItemShipmentResult

		EXEC dbo.uspSOUpdateOrderShipmentStatus @InventoryShipmentId, 'Inventory', 0

		UPDATE tblSOSalesOrder
		SET dtmProcessDate = GETDATE()
		  , ysnProcessed   = 1
		  , ysnShipped     = 1
		WHERE intSalesOrderId = @SalesOrderId

		RETURN 1
	END 
END