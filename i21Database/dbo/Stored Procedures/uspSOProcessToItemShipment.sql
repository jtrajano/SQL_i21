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
SET XACT_ABORT OFF
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

--VALIDATE IF SO HAS BUNDLE-OPTION ITEM
IF EXISTS(SELECT NULL FROM tblSOSalesOrderDetail SOD INNER JOIN tblICItem I ON SOD.intItemId = I.intItemId WHERE intSalesOrderId = @SalesOrderId AND I.strType = 'Bundle' AND I.strBundleType = 'Option')
	BEGIN
		RAISERROR('Option bundle cannot be processed directly to invoice/shipment', 16, 1)
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
					DECLARE @strSalesOrderNumber    NVARCHAR(100) = NULL

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
						EXEC dbo.uspSOUpdateReservedStock @SalesOrderId, 0
						EXEC dbo.uspICUnshipInventoryItem @intInventoryShipmentId, @UserId
						EXEC dbo.uspSOUpdateOrderShipmentStatus @intInventoryShipmentId, 'Inventory', 1

						FETCH NEXT FROM c INTO @intInventoryShipmentId
					END
					CLOSE c;
					DEALLOCATE c;
				END
			
				UPDATE tblSOSalesOrder 
                SET ysnShipped              = CASE WHEN ISNULL(@PostedShipmentNos, '') <> '' THEN CAST(1 AS BIT) ELSE CAST(0 AS BIT) END 
                  , @strSalesOrderNumber    = strSalesOrderNumber
                WHERE intSalesOrderId = @SalesOrderId

                --DELETE FROM INVENTORY LINK
                EXEC dbo.[uspICDeleteTransactionLinks] @SalesOrderId, @strSalesOrderNumber, 'Sales Order', 'Accounts Receivable'

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
		--AUTO-BLEND ITEMS
		DECLARE @strErrorMessage	NVARCHAR(MAX)

		BEGIN TRY
			EXEC dbo.uspARAutoBlendSalesOrderItems @intSalesOrderId = @SalesOrderId, @intUserId = @UserId
		END TRY
		BEGIN CATCH
			SET @strErrorMessage	= ERROR_MESSAGE()
				
			RAISERROR(@strErrorMessage, 11, 1)
			RETURN
		END CATCH
		 
		DECLARE @Items				ShipmentStagingTable
			  , @Charges			ShipmentChargeStagingTable
			  , @Lots				ShipmentItemLotStagingTable	
			  , @LotsOnly			ShipmentItemLotsOnlyStagingTable
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
			, intItemId						= SOD.intItemId
			, intOwnershipType				= CASE WHEN SOD.intStorageScheduleTypeId IS NULL THEN 1 ELSE 2 END
			, dblQuantity					= SOD.dblQtyOrdered - ISNULL(INVOICEDETAIL.dblQtyShipped, SOD.dblQtyShipped)
			, intItemUOMId					= ITEMUOM.intItemUOMId
			, intPriceUOMId					= SOD.intItemUOMId
			, intItemLotGroup				= NULL
			, intOrderId					= SOD.intSalesOrderId
			, intSourceId					= NULL
			, intLineNo						= SOD.intSalesOrderDetailId
			, intSubLocationId				= COALESCE(SOD.intSubLocationId, SL.intSubLocationId, IL.intSubLocationId)
			, intStorageLocationId			= COALESCE(SOD.intStorageLocationId, IL.intStorageLocationId)
			, intCurrencyId					= SO.intCurrencyId
			, intWeightUOMId				= NULL
			, dblUnitPrice					= SOD.dblPrice
			, intDockDoorId					= NULL
			, strNotes						= SOD.strComments
			, intGradeId					= NULL
			, intDiscountSchedule			= NULL
			, intStorageScheduleTypeId		= SOD.intStorageScheduleTypeId
			, intForexRateTypeId			= SOD.intCurrencyExchangeRateTypeId
			, dblForexRate					= SOD.dblCurrencyExchangeRate
		FROM dbo.tblSOSalesOrder SO	
		INNER JOIN dbo.tblSOSalesOrderDetail SOD ON SO.intSalesOrderId = SOD.intSalesOrderId
		INNER JOIN tblICItem ITEM ON ITEM.intItemId = SOD.intItemId 
			AND ((ITEM.strType <> 'Bundle' AND ITEM.strType = 'Inventory') 
			  OR (ITEM.strType = 'Bundle' AND ISNULL(ITEM.strBundleType, 'Kit') = 'Kit'))
			AND CASE WHEN (ITEM.strType = 'Bundle') THEN 
				CASE WHEN ISNULL(ITEM.ysnListBundleSeparately, 0) = 0 THEN 1 ELSE 0 END
			 ELSE 1 END = 1
		INNER JOIN dbo.tblICItemUOM ITEMUOM ON ITEMUOM.intItemId = SOD.intItemId AND ITEMUOM.intItemUOMId = SOD.intItemUOMId 
		INNER JOIN dbo.tblICItemLocation IL ON IL.intItemId = SOD.intItemId AND SO.intCompanyLocationId = IL.intLocationId
		LEFT JOIN tblSMCompanyLocationSubLocation SUBL ON SUBL.intCompanyLocationId = IL.intLocationId AND SUBL.intCompanyLocationSubLocationId = SOD.intSubLocationId				
		LEFT JOIN dbo.tblICStorageLocation SL ON SL.intLocationId = IL.intLocationId AND SL.intSubLocationId = SUBL.intCompanyLocationSubLocationId AND SL.intStorageLocationId = SOD.intStorageLocationId	
		OUTER APPLY (
			SELECT intSalesOrderDetailId
					, dblQtyShipped = SUM(dblQtyShipped)
			FROM dbo.tblARInvoiceDetail ID
			WHERE ID.intSalesOrderDetailId = SOD.intSalesOrderDetailId
			GROUP BY ID.intSalesOrderDetailId
		) INVOICEDETAIL
		WHERE SO.intSalesOrderId = @SalesOrderId
		  AND (SOD.dblQtyOrdered - ISNULL(INVOICEDETAIL.dblQtyShipped, SOD.dblQtyShipped)) > 0

		INSERT INTO @Charges (
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
		INNER JOIN dbo.tblSOSalesOrderDetail SODETAIL ON SO.intSalesOrderId = SODETAIL.intSalesOrderId
		INNER JOIN tblCTContractHeader Header ON Header.intContractHeaderId = SODETAIL.intContractHeaderId
		INNER JOIN tblCTContractDetail Detail ON Detail.intContractHeaderId = Header.intContractHeaderId
		INNER JOIN tblCTContractCost Cost ON Detail.intContractDetailId = Cost.intContractDetailId
		WHERE SO.intSalesOrderId = @SalesOrderId

		UNION ALL

		SELECT intOrderType			= @SALES_ORDER_TYPE
			, intSourceType			= 0
			, intEntityCustomerId	= SO.intEntityCustomerId
			, dtmShipDate			= SO.dtmDate
			, intShipFromLocationId	= SO.intCompanyLocationId
			, intShipToLocationId	= SO.intShipToLocationId
			, intFreightTermId		= SO.intFreightTermId
			, intContractId			= NULL
			, intContractDetailId	= NULL
			, intChargeId			= SOD.intItemId
			, strCostMethod			= 'Amount'
			, dblRate				= NULL
			, intCostUOMId			= SOD.intItemUOMId
			, intCurrency			= SO.intCurrencyId
			, dblAmount				= SOD.dblQtyOrdered * SOD.dblPrice
			, ysnAccrue				= 0
			, intEntityVendorId		= NULL
			, ysnPrice				= 1
			, intForexRateTypeId	= SOD.intCurrencyExchangeRateTypeId
			, dblForexRate			= SOD.dblCurrencyExchangeRate
			, strChargesLink		= NULL
			, strAllocatePriceBy	= NULL
		FROM dbo.tblSOSalesOrder SO	
		INNER JOIN dbo.tblSOSalesOrderDetail SOD ON SO.intSalesOrderId = SOD.intSalesOrderId
		INNER JOIN tblICItem ITEM ON SOD.intItemId = ITEM.intItemId
		WHERE SO.intSalesOrderId = @SalesOrderId
		  AND ITEM.strType = 'Other Charge'

		IF NOT EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#tmpAddItemShipmentResult')) 
		BEGIN 
			CREATE TABLE #tmpAddItemShipmentResult (
				intInventoryShipmentId INT
			)
		END

		--POST RESERVATION FOR PICK LIST
		EXEC dbo.uspSOUpdateReservedStock @SalesOrderId, 1

		--PROCESS TO INVENTORY SHIPMENT
		BEGIN TRY
			EXEC  dbo.uspICAddItemShipment @Items		= @Items
												     , @Charges		= @Charges
												     , @Lots		= @Lots
												     , @LotsOnly	= @LotsOnly
												     , @intUserId	= @UserId	
		END TRY
		BEGIN CATCH
			SET @strErrorMessage	= ERROR_MESSAGE()
				
			RAISERROR(@strErrorMessage, 11, 1)
			RETURN
		END CATCH		
				
		IF @intReturn <> 0 
			RETURN @intReturn

		SELECT	TOP 1 
				@InventoryShipmentId = intInventoryShipmentId 
		FROM	#tmpAddItemShipmentResult

		EXEC dbo.uspSOUpdateOrderShipmentStatus @InventoryShipmentId, 'Inventory', 0

		UPDATE SOD
		SET dblQtyShipped = SOD.dblQtyOrdered
		FROM tblSOSalesOrderDetail SOD
		INNER JOIN tblSOSalesOrder SO ON SOD.intSalesOrderId = SO.intSalesOrderId
		INNER JOIN tblICItem ITEM ON SOD.intItemId = ITEM.intItemId		
		WHERE SOD.intSalesOrderId = @SalesOrderId
		  AND ITEM.strType = 'Other Charge'

		UPDATE tblSOSalesOrder
		SET dtmProcessDate = GETDATE()
		  , ysnProcessed   = 1
		  , ysnShipped     = 1
		  , strOrderStatus	= 'Closed'
		WHERE intSalesOrderId = @SalesOrderId

		        --INSERT TO TRANSACTION LINKS
        DECLARE @tblTransactionLinks    udtICTransactionLinks

        INSERT INTO @tblTransactionLinks (
              intSrcId
            , strSrcTransactionNo
            , strSrcTransactionType
            , strSrcModuleName
            , intDestId
            , strDestTransactionNo
            , strDestTransactionType
            , strDestModuleName
            , strOperation
        )
        SELECT intSrcId                    = SO.intSalesOrderId
            , strSrcTransactionNo       = SO.strSalesOrderNumber
            , strSrcTransactionType     = 'Sales Order'
            , strSrcModuleName          = 'Accounts Receivable'
            , intDestId                 = SHIPMENT.intInventoryShipmentId
            , strDestTransactionNo      = SHIPMENT.strShipmentNumber
            , strDestTransactionType    = 'Inventory Shipment'
            , strDestModuleName         = 'Inventory'
            , strOperation              = 'Process'
        FROM tblSOSalesOrder SO
        INNER JOIN (
            SELECT DISTINCT SHIPD.intOrderId
                 , SHIP.strShipmentNumber 
                 , SHIP.intInventoryShipmentId
            FROM tblICInventoryShipmentItem SHIPD
            INNER JOIN tblICInventoryShipment SHIP ON SHIPD.intInventoryShipmentId = SHIP.intInventoryShipmentId
            WHERE SHIP.intOrderType = 2
        ) SHIPMENT ON SO.intSalesOrderId = SHIPMENT.intOrderId
        WHERE SO.intSalesOrderId = @SalesOrderId
          AND SO.strTransactionType = 'Order'

        EXEC dbo.uspICAddTransactionLinks @tblTransactionLinks

		RETURN 1
	END 
END