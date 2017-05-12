CREATE PROCEDURE [dbo].[uspICProcessToInventoryShipment]
	@intSourceTransactionId AS INT
	,@strSourceType AS NVARCHAR(100) 
	,@intEntityUserSecurityId AS INT 
	,@InventoryShipmentId AS INT OUTPUT 
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @ErrorMessage NVARCHAR(4000);
DECLARE @ErrorSeverity INT;
DECLARE @ErrorState INT;

DECLARE @ItemsForItemShipment AS ItemCostingTableType 

DECLARE @SALES_CONTRACT AS NVARCHAR(50) = 'Sales Contract'
		,@SALES_ORDER AS NVARCHAR(50) = 'Sales Order'
		,@TRANSFER_ORDER AS NVARCHAR(50) = 'Transfer Order'
		,@SALES_ORDER_TYPE AS INT = 2

BEGIN TRY
	-- Get the items to process
	DECLARE @Items ShipmentStagingTable
	DECLARE @Charges ShipmentChargeStagingTable
	DECLARE @ItemLots ShipmentItemLotStagingTable

	INSERT INTO @Items(
		intOrderType, intSourceType, intEntityCustomerId, dtmShipDate, intShipFromLocationId, intShipToLocationId, intFreightTermId
		, strSourceScreenName, strReferenceNumber, dtmRequestedArrivalDate, intShipToCompanyLocationId, strBOLNumber, intShipViaId
		, strVessel, strProNumber, strDriverId, strSealNumber, strDeliveryInstruction, dtmAppointmentTime, dtmDepartureTime
		, dtmArrivalTime, dtmDeliveredDate, dtmFreeTime, strFreeTime, strReceivedBy, strComment, intItemId, intOwnershipType, dblQuantity
		, intItemUOMId, intItemLotGroup, intOrderId, intSourceId, intLineNo, intSubLocationId, intStorageLocationId, intCurrencyId
		, intWeightUOMId, dblUnitPrice, intDockDoorId, strNotes, intGradeId, intDiscountSchedule, intStorageScheduleTypeId
		, intForexRateTypeId, dblForexRate	
	)
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
		, intStorageLocationId			= ISNULL(SODetail.intStorageLocationId, ItemLocation.intStorageLocationId)
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
		FROM dbo.tblSOSalesOrder SO
			INNER JOIN dbo.tblSOSalesOrderDetail SODetail ON SO.intSalesOrderId = SODetail.intSalesOrderId
			INNER JOIN dbo.tblICItemUOM ItemUOM ON SODetail.intItemId = ItemUOM.intItemId
				AND SODetail.intItemUOMId = ItemUOM.intItemUOMId
			INNER JOIN dbo.tblICItemLocation ItemLocation ON SODetail.intItemId = ItemLocation.intItemId
				AND SO.intCompanyLocationId = ItemLocation.intLocationId
			LEFT JOIN dbo.tblICStorageLocation StorageLocation ON StorageLocation.intStorageLocationId = SODetail.intStorageLocationId
			LEFT JOIN dbo.tblICItemPricing ItemPricing ON ItemPricing.intItemId = SODetail.intItemId
				AND ItemPricing.intItemLocationId = ItemLocation.intItemLocationId
			LEFT OUTER JOIN (
				SELECT intSalesOrderDetailId, SUM(dblQtyShipped) AS dblQtyShipped
				FROM tblARInvoiceDetail ID
				GROUP BY ID.intSalesOrderDetailId) AS InvoiceDetail ON InvoiceDetail.intSalesOrderDetailId = SODetail.intSalesOrderDetailId
		WHERE SODetail.intSalesOrderId = @intSourceTransactionId
			AND dbo.fnIsStockTrackingItem(SODetail.intItemId) = 1
			AND (SODetail.dblQtyOrdered - ISNULL(InvoiceDetail.dblQtyShipped, SODetail.dblQtyShipped)) > 0	

		--EXEC dbo.uspICGetItemsForInventoryShipment @intSourceTransactionId, @strSourceType

	-- Validate the items to shipment 
	EXEC dbo.uspICValidateProcessToInventoryShipment @ItemsForItemShipment; 

	-- Create the temp table if it does not exists. 
	IF NOT EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#tmpAddItemShipmentResult')) 
	BEGIN 
		CREATE TABLE #tmpAddItemShipmentResult (
			intInventoryShipmentId INT
		)
	END

	IF @strSourceType = @SALES_ORDER
	BEGIN 

		EXEC dbo.uspICAddItemShipment @Items, @Charges, @ItemLots, @intEntityUserSecurityId

		DECLARE cur CURSOR LOCAL FAST_FORWARD
		FOR SELECT intInventoryShipmentId FROM #tmpAddItemShipmentResult

		OPEN cur

		FETCH NEXT FROM cur INTO @InventoryShipmentId

		WHILE @@FETCH_STATUS = 0
		BEGIN
			-- Increase Stock Reservation
			EXEC dbo.uspICReserveStockForInventoryShipment @intTransactionId = @InventoryShipmentId

			FETCH NEXT FROM cur INTO @InventoryShipmentId	
		END

		CLOSE cur
		DEALLOCATE cur
	END

	DELETE FROM #tmpAddItemShipmentResult
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