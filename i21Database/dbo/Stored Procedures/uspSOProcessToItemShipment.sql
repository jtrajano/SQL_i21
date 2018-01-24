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

--IF UNSHIP
IF @Unship = 1
	BEGIN
		--VALIDATE IF SO HAS POSTED SHIPMENT RECORDS
		DECLARE @shipmentNos NVARCHAR(MAX) = NULL

		SELECT @shipmentNos = COALESCE(@shipmentNos + ', ' ,'') + ISH.strShipmentNumber 
		FROM tblICInventoryShipmentItem ISHI INNER JOIN tblICInventoryShipment ISH ON ISHI.intInventoryShipmentId = ISH.intInventoryShipmentId
			WHERE ISHI.intOrderId = @SalesOrderId 
			  AND ISH.ysnPosted = 1

		IF ISNULL(@shipmentNos, '') <> ''
			BEGIN				
				RAISERROR('Failed to unship Sales Order. Unpost this Shipment Record first: %s', 16, 1, @shipmentNos)
				RETURN
			END
		ELSE
			BEGIN
				-- Delete shipment and decrease Item Stock Reservation
				BEGIN
					DECLARE @intInventoryShipmentId INT
					SELECT DISTINCT TOP 1 @intInventoryShipmentId = ISH.intInventoryShipmentId
					FROM tblICInventoryShipmentItem ISHI
						INNER JOIN tblICInventoryShipment ISH ON ISHI.intInventoryShipmentId = ISH.intInventoryShipmentId
					WHERE intOrderId = @SalesOrderId
					
					EXEC dbo.uspICUnshipInventoryItem @intInventoryShipmentId, @UserId
					EXEC dbo.uspSOUpdateOrderShipmentStatus @intInventoryShipmentId, 'Inventory', 1
				END
			
				UPDATE tblSOSalesOrder SET ysnShipped = 0 WHERE intSalesOrderId = @SalesOrderId
				RETURN 1
			END
	END

--VALIDATE IF THERE ARE STOCK ITEMS TO SHIP
IF NOT EXISTS(SELECT 1 FROM tblSOSalesOrderDetail SOD
				LEFT JOIN tblICItem IC ON SOD.intItemId = IC.intItemId 
		WHERE intSalesOrderId = @SalesOrderId 
		AND (dbo.fnIsStockTrackingItem(SOD.intItemId) = 1 OR (dbo.fnIsStockTrackingItem(SOD.intItemId) = 0 AND IC.strType = 'Bundle')) 
		AND (dblQtyOrdered - dblQtyShipped > 0)
		AND SOD.[intSalesOrderDetailId] NOT IN (SELECT ISNULL(tblARInvoiceDetail.[intSalesOrderDetailId],0) 
				FROM tblARInvoiceDetail INNER JOIN tblARInvoice ON tblARInvoiceDetail.intInvoiceId = tblARInvoice.intInvoiceId 
				WHERE SOD.dblQtyOrdered <= tblARInvoiceDetail.dblQtyShipped))
	BEGIN
		RAISERROR('Shipping Failed. There is no shippable item on this sales order.', 16, 1);
        RETURN
	END
ELSE
	--BEGIN
	--	EXEC dbo.uspICProcessToInventoryShipment
	--			 @intSourceTransactionId = @SalesOrderId
	--			,@strSourceType = 'Sales Order'
	--			,@intEntityUserSecurityId = @UserId
	--			,@InventoryShipmentId = @ShipmentId OUTPUT
		
	--	SET @InventoryShipmentId = @ShipmentId

	--	IF @@ERROR > 0 
	--		RETURN 0;

	--	EXEC dbo.uspSOUpdateOrderShipmentStatus @InventoryShipmentId, 'Inventory', 0

	--	UPDATE tblSOSalesOrder
	--	SET dtmProcessDate = GETDATE()
	--	  , ysnProcessed   = 1
	--	  , ysnShipped     = 1
	--	WHERE intSalesOrderId = @SalesOrderId
	
	--	RETURN 1
	--END
	BEGIN 
		DECLARE @Items ShipmentStagingTable
				,@Charges ShipmentChargeStagingTable
				,@Lots ShipmentItemLotStagingTable
				,@intReturn AS INT 

		DECLARE @SALES_CONTRACT AS NVARCHAR(50) = 'Sales Contract'
				,@SALES_ORDER AS NVARCHAR(50) = 'Sales Order'
				,@TRANSFER_ORDER AS NVARCHAR(50) = 'Transfer Order'
				,@SALES_ORDER_TYPE AS INT = 2

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
		SELECT
			intOrderType					= @SALES_ORDER_TYPE
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
			, intItemId						= SODetail.intItemId
			, intOwnershipType				= CASE WHEN SODetail.intStorageScheduleTypeId IS NULL THEN 1 ELSE 2 END
			, dblQuantity					= SODetail.dblQtyOrdered - ISNULL(InvoiceDetail.dblQtyShipped, SODetail.dblQtyShipped)
			, intItemUOMId					= ItemUOM.intItemUOMId
			, intItemLotGroup				= NULL
			, intOrderId					= SODetail.intSalesOrderId
			, intSourceId					= NULL
			, intLineNo						= SODetail.intSalesOrderDetailId
			, intSubLocationId				= COALESCE(SODetail.intSubLocationId, StorageLocation.intSubLocationId, ItemLocation.intSubLocationId)
			, intStorageLocationId			= COALESCE(SODetail.intStorageLocationId, ItemLocation.intStorageLocationId)
			, intCurrencyId					= SO.[intCurrencyId] 
			, intWeightUOMId				= NULL
			, dblUnitPrice					= SODetail.dblPrice
			, intDockDoorId					= NULL
			, strNotes						= SODetail.strComments
			, intGradeId					= NULL
			, intDiscountSchedule			= NULL
			, intStorageScheduleTypeId		= SODetail.intStorageScheduleTypeId
			, intForexRateTypeId			= SODetail.intCurrencyExchangeRateTypeId
			, dblForexRate					= SODetail.dblCurrencyExchangeRate
			FROM 
				dbo.tblSOSalesOrder SO	INNER JOIN dbo.tblSOSalesOrderDetail SODetail 
					ON SO.intSalesOrderId = SODetail.intSalesOrderId

				INNER JOIN tblICItem i 
					ON i.intItemId = SODetail.intItemId 

				INNER JOIN dbo.tblICItemUOM ItemUOM 
					ON ItemUOM.intItemId = SODetail.intItemId 
					AND ItemUOM.intItemUOMId = SODetail.intItemUOMId 

				INNER JOIN dbo.tblICItemLocation ItemLocation 
					ON ItemLocation.intItemId = SODetail.intItemId 
					AND SO.intCompanyLocationId = ItemLocation.intLocationId

				LEFT JOIN tblSMCompanyLocationSubLocation SubLocation
					ON SubLocation.intCompanyLocationId = ItemLocation.intLocationId
					AND SubLocation.intCompanyLocationSubLocationId = SODetail.intSubLocationId				

				LEFT JOIN dbo.tblICStorageLocation StorageLocation 
					ON StorageLocation.intLocationId = ItemLocation.intLocationId
					AND StorageLocation.intSubLocationId = SubLocation.intCompanyLocationSubLocationId
					AND StorageLocation.intStorageLocationId = SODetail.intStorageLocationId	

				OUTER APPLY (
					SELECT	intSalesOrderDetailId, SUM(dblQtyShipped) AS dblQtyShipped
					FROM	tblARInvoiceDetail ID
					WHERE	ID.intSalesOrderDetailId = SODetail.intSalesOrderDetailId
					GROUP BY ID.intSalesOrderDetailId
				) InvoiceDetail 
					
			WHERE	
				SODetail.intSalesOrderId = @SalesOrderId
				AND dbo.fnIsStockTrackingItem(SODetail.intItemId) = 1
				AND (SODetail.dblQtyOrdered - ISNULL(InvoiceDetail.dblQtyShipped, SODetail.dblQtyShipped)) > 0			
				AND ISNULL(i.strBundleType, '') <> 'Kit'

		-- Insert all the components of the Kit item. 
		UNION ALL 
		SELECT
			intOrderType					= @SALES_ORDER_TYPE
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
			, intItemId						= BundleItems.intItemId
			, intOwnershipType				= CASE WHEN SODetail.intStorageScheduleTypeId IS NULL THEN 1 ELSE 2 END
			, dblQuantity					= dbo.fnMultiply(SODetail.dblQtyOrdered, BundleItems.dblQty)  --SODetail.dblQtyOrdered - ISNULL(InvoiceDetail.dblQtyShipped, SODetail.dblQtyShipped)
			, intItemUOMId					= BundleItems.intItemUOMId
			, intItemLotGroup				= NULL
			, intOrderId					= SODetail.intSalesOrderId
			, intSourceId					= NULL
			, intLineNo						= SODetail.intSalesOrderDetailId
			, intSubLocationId				= COALESCE(SubLocation.intCompanyLocationSubLocationId, StorageLocation.intSubLocationId, ItemLocation.intSubLocationId)
			, intStorageLocationId			= COALESCE(StorageLocation.intStorageLocationId, ItemLocation.intStorageLocationId)
			, intCurrencyId					= SO.[intCurrencyId] 
			, intWeightUOMId				= NULL
			, dblUnitPrice					= SODetail.dblPrice
			, intDockDoorId					= NULL
			, strNotes						= SODetail.strComments
			, intGradeId					= NULL
			, intDiscountSchedule			= NULL
			, intStorageScheduleTypeId		= SODetail.intStorageScheduleTypeId
			, intForexRateTypeId			= SODetail.intCurrencyExchangeRateTypeId
			, dblForexRate					= SODetail.dblCurrencyExchangeRate
			FROM 
				dbo.tblSOSalesOrder SO	INNER JOIN dbo.tblSOSalesOrderDetail SODetail 
					ON SO.intSalesOrderId = SODetail.intSalesOrderId

				INNER JOIN tblICItem Kit
					ON Kit.intItemId = SODetail.intItemId 

				INNER JOIN dbo.tblICItemUOM KitUOM 
					ON KitUOM.intItemId = Kit.intItemId 
					AND KitUOM.intItemUOMId = SODetail.intItemUOMId  

				CROSS APPLY (				
					SELECT	intItemId = Bundle.intBundleItemId 
							,dblQty = dbo.fnMultiply(Bundle.dblQuantity, KitUOM.dblUnitQty) 
							,intItemUOMId = Bundle.intItemUnitMeasureId 
					FROM	tblICItemBundle Bundle 
					WHERE	Bundle.intItemId = Kit.intItemId
				) BundleItems 

				LEFT JOIN dbo.tblICItemLocation ItemLocation 
					ON ItemLocation.intItemId = BundleItems.intItemId 
					AND SO.intCompanyLocationId = ItemLocation.intLocationId

				LEFT JOIN tblSMCompanyLocationSubLocation SubLocation
					ON SubLocation.intCompanyLocationId = ItemLocation.intLocationId
					AND SubLocation.intCompanyLocationSubLocationId = SODetail.intSubLocationId				

				LEFT JOIN dbo.tblICStorageLocation StorageLocation 
					ON StorageLocation.intLocationId = ItemLocation.intLocationId
					AND StorageLocation.intSubLocationId = SubLocation.intCompanyLocationSubLocationId
					AND StorageLocation.intStorageLocationId = SODetail.intStorageLocationId				
					
			WHERE	
				SODetail.intSalesOrderId = @SalesOrderId
				AND dbo.fnIsStockTrackingItem(BundleItems.intItemId) = 1
				--AND (SODetail.dblQtyOrdered - ISNULL(InvoiceDetail.dblQtyShipped, SODetail.dblQtyShipped)) > 0
				AND ISNULL(Kit.ysnListBundleSeparately, 0) = 1
				AND Kit.strBundleType = 'Kit'
				AND KitUOM.ysnAllowSale = 1 

		IF NOT EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#tmpAddItemShipmentResult')) 
		BEGIN 
			CREATE TABLE #tmpAddItemShipmentResult (
				intInventoryShipmentId INT

			)
		END 

		EXEC @intReturn = dbo.uspICAddItemShipment 
				@Items
				, @Charges
				, @Lots
				, @UserId	
				
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