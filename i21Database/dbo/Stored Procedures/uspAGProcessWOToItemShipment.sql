CREATE PROCEDURE [dbo].[uspAGProcessWOToItemShipment]
@intWorkOrderId INT,
@intUserId INT,
@intInventoryShipmentId INT OUTPUT

AS
BEGIN
	SET QUOTED_IDENTIFIER OFF  
	SET ANSI_NULLS ON  
	SET NOCOUNT ON  
	SET XACT_ABORT OFF  
	SET ANSI_WARNINGS OFF  

	--VALIDATE IF AGWO IS FINALIZED
	IF EXISTS (SELECT 1 FROM tblAGWorkOrder WHERE [intWorkOrderId] = @intWorkOrderId AND [strStatus] = 'Closed')
	BEGIN
		RAISERROR('AG Work Order is already closed.', 16, 1)
		RETURN;
	END
	
	--VALIDATE IF AGWO HAS (0) TOTAL
	IF EXISTS (SELECT 1 FROM tblAGWorkOrder WHERE [intWorkOrderId] = @intWorkOrderId AND [dblWorkOrderTotal] = 0 )
	BEGIN
		RAISERROR('Cannot Process AGWO with (0) amount.', 16, 1)
		RETURN;
	END

	-- UNSHIP if AGWO is already has an IS -- todo

	
	--VALIDATE IF THERE ARE STOCK TO SHIP
	IF(OBJECT_ID('tempdb..#ICITEMSTOSHIP') IS NOT NULL)  
	BEGIN  
		DROP TABLE #ICITEMSTOSHIP  
	END  

	SELECT 
		WOD.intItemId
		,IC.strBundleType
		,IC.strType
	INTO #ICITEMSTOSHIP
	FROM tblAGWorkOrderDetail WOD
	INNER JOIN tblICItem IC ON IC.intItemId = WOD.intItemId
	WHERE WOD.intWorkOrderId = @intWorkOrderId
	AND (dbo.fnIsStockTrackingItem(WOD.intItemId) = 1 OR (dbo.fnIsStockTrackingItem(WOD.intItemId) = 0 AND (IC.strType = 'Bundle' AND ISNULL(IC.strBundleType, 'Kit') = 'Kit')))  
	AND (dblQtyOrdered - dblQtyShipped > 0)  

	IF NOT EXISTS (SELECT TOP 1 1 FROM #ICITEMSTOSHIP)
		BEGIN
			RAISERROR('Creation of item shipment failed. There is no shippable item on this AG work order.', 16, 1);  
			RETURN
		END
	ELSE
		BEGIN
			DECLARE @Items ShipmentStagingTable
				,@Charges ShipmentChargeStagingTable  
				,@Lots ShipmentItemLotStagingTable
				,@AGWORK_ORDER NVARCHAR(50) = N'AG Work Order'
				,@AGWORK_ORDER_TYPE INT = 6
				,@intReturn INT


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
		  SELECT intOrderType	 = @AGWORK_ORDER_TYPE --create jira for ic on order type
		  ,intSourceType		 = 0
		  ,intEntityCustomerId	 = WO.intEntityCustomerId
		  ,dtmShipDate			 = GETDATE()
		  ,intShipFromLocationId = WO.intCompanyLocationId
		  ,intShipToLocationId   = WO.intCompanyLocationId
		  ,intFreightTermId		 = FREIGHTTERMS.intFreightTermId
		  ,strSourceScreenName   = @AGWORK_ORDER
		  ,strReferenceNumber	 = WO.strOrderNumber
		  ,dtmRequestedArrivalDate = NULL
		  ,intShipToCompanyLocationId = NULL
		  ,strBOLNumber			 =	''
		  ,intShipViaId			 = NULL
		  ,strVessel			 = NULL  
		  ,strProNumber		 = NULL  
		  ,strDriverId			= NULL  
		  ,strSealNumber		 = NULL  
		  ,strDeliveryInstruction  = NULL  
		  ,dtmAppointmentTime   = NULL  
		  ,dtmDepartureTime    = NULL  
		  ,dtmArrivalTime    = NULL  
		  ,dtmDeliveredDate    = NULL  
		  ,dtmFreeTime     = NULL  
		  ,strFreeTime     = NULL  
		  ,strReceivedBy     = NULL  
		  ,strComment		= WO.strComments
		  ,intItemId		= WOD.intItemId
		  ,intOwnershipType	= CASE WHEN WOD.intStorageScheduleTypeId IS NULL THEN 1 ELSE 2 END 
		  ,dblQuantity		= (ISNULL(WOD.dblQtyOrdered,0) - ISNULL(WOD.dblQtyShipped,0))
		  ,intItemUOMId		= ITEMUOM.intItemUOMId
		  ,intPriceUOMId    = WOD.intItemUOMId
		  ,intItemLotGroup  = NULL
		  ,intOrderId     = WOD.intWorkOrderId  
		  ,intSourceId     = NULL  
		  ,intLineNo		= WOD.intWorkOrderDetailId
		  ,intSubLocationId  = COALESCE(WOD.intSubLocationId, STORAGELOCATION.intSubLocationId, ITEMLOCATION.intSubLocationId)
		  ,intStorageLocationId   = COALESCE(WOD.intStorageLocationId, ITEMLOCATION.intStorageLocationId)
		  ,intCurrencyId     = NULL --to check if need to add field on AGWO screen  
		  ,intWeightUOMId    = NULL  
		  ,dblUnitPrice     = WOD.dblPrice  
		  ,intDockDoorId     = NULL  
		  ,strNotes      = WOD.strComments  
		  ,intGradeId     = NULL  
		  ,intDiscountSchedule   = NULL  
		  ,intStorageScheduleTypeId  = WOD.intStorageScheduleTypeId  
		  ,intForexRateTypeId   = WOD.intCurrencyExchangeRateTypeId  
		  ,dblForexRate     = WOD.dblCurrencyExchangeRate

		  FROM tblAGWorkOrder WO
		  INNER JOIN tblAGWorkOrderDetail WOD 
				ON WOD.intWorkOrderId = WO.intWorkOrderId
		  INNER JOIN tblICItem ITEM
				ON ITEM.intItemId = WOD.intItemId
				AND ((ITEM.strType <> 'Bundle' AND dbo.fnIsStockTrackingItem(WOD.intItemId) = 1)   
				OR (ITEM.strType = 'Bundle' AND ISNULL(ITEM.strBundleType, 'Kit') = 'Kit'))  
				AND  CASE WHEN (ITEM.strType = 'Bundle') THEN   
				CASE WHEN ISNULL(ITEM.ysnListBundleSeparately, 0) = 0 THEN 1 ELSE 0 END  
				ELSE 1 END = 1 
		  INNER JOIN tblICItemUOM ITEMUOM
				ON ITEMUOM.intItemId = WOD.intItemId
				AND ITEMUOM.intItemUOMId = WOD.intItemUOMId
		 INNER JOIN dbo.tblICItemLocation ITEMLOCATION 
				ON ITEMLOCATION.intItemId = WOD.intItemId
				AND WO.intCompanyLocationId = ITEMLOCATION.intLocationId 
		 LEFT JOIN tblSMCompanyLocationSubLocation SUBLOCATION  
			   ON SUBLOCATION.intCompanyLocationId = ITEMLOCATION.intLocationId  
			   AND SUBLOCATION.intCompanyLocationSubLocationId = WOD.intSubLocationId
		 LEFT JOIN dbo.tblICStorageLocation STORAGELOCATION   
			   ON STORAGELOCATION.intLocationId = ITEMLOCATION.intLocationId  
			   AND STORAGELOCATION.intSubLocationId = SUBLOCATION.intCompanyLocationSubLocationId  
			   AND STORAGELOCATION.intStorageLocationId = WOD.intStorageLocationId
		OUTER APPLY(
			SELECT TOP 1 FTERMS.intFreightTermId
				FROM tblEMEntityLocation EL
				INNER JOIN tblSMFreightTerms FTERMS 
					ON FTERMS.intFreightTermId = EL.intFreightTermId
				WHERE EL.intEntityId = WO.intEntityCustomerId AND EL.ysnDefaultLocation = 1
		) FREIGHTTERMS
		WHERE WO.intWorkOrderId = @intWorkOrderId
		
		INSERT INTO @Charges(  
			intOrderType  
		   ,intSourceType  
		   ,intEntityCustomerId  
		   ,dtmShipDate  
		   ,intShipFromLocationId  
		   ,intShipToLocationId  
		   ,intFreightTermId  
		   ,intContractId  
		   ,intContractDetailId  
		   ,intChargeId  
		   ,strCostMethod  
		   ,dblRate  
		   ,intCostUOMId  
		   ,intCurrency  
		   ,dblAmount  
		   ,ysnAccrue  
		   ,intEntityVendorId  
		   ,ysnPrice  
		   ,intForexRateTypeId  
		   ,dblForexRate  
		   ,strChargesLink  
		   ,strAllocatePriceBy  
		  )  	  
		 SELECT intOrderType = @AGWORK_ORDER_TYPE
		 ,intSourceType      = 0
		 ,intEntityCustomerId = WO.intEntityCustomerId
		 ,dtmShipDate		  = WO.dtmCreatedDate
		 ,intShipFromLocationId = WO.intCompanyLocationId
		 ,intShipToLocationId   = NULL
		 ,intFreightTermId		= NULL
		 ,intContractId			= Header.intContractHeaderId
		 ,intContractDetailId	= Detail.intContractDetailId
		 ,intChargeId			= Cost.intItemId
		 ,strCostMethod   = Cost.strCostMethod  
		 ,dblRate    = Cost.dblRate  
		 ,intCostUOMId   = Cost.intItemUOMId  
		 ,intCurrency   = Cost.intCurrencyId  
		 ,dblAmount    = NULL  
		 ,ysnAccrue    = Cost.ysnAccrue  
		 ,intEntityVendorId  = NULL  
		 ,ysnPrice    = Cost.ysnPrice  
		 ,intForexRateTypeId = WOD.intCurrencyExchangeRateTypeId  
		 ,dblForexRate   = WOD.dblCurrencyExchangeRate  
		 ,strChargesLink  = NULL  
		 ,strAllocatePriceBy = NULL 
		 FROM tblAGWorkOrder WO
		  INNER JOIN dbo.tblAGWorkOrderDetail WOD   
			ON WOD.intWorkOrderId = WO.intWorkOrderId  
		  INNER JOIN tblCTContractHeader Header  
		   ON Header.intContractHeaderId = WOD.intContractHeaderId  
		  INNER JOIN tblCTContractDetail Detail  
		   ON Detail.intContractHeaderId = Header.intContractHeaderId  
		  INNER JOIN tblCTContractCost Cost  
		   ON Detail.intContractDetailId = Cost.intContractDetailId  
		  WHERE WO.intWorkOrderId = @intWorkOrderId  
		END

		 --POST RESERVATION FOR PICK LIST   - not sure

		  IF NOT EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#tmpAddItemShipmentResult'))   
		  BEGIN   
			   CREATE TABLE #tmpAddItemShipmentResult (  
				intInventoryShipmentId INT  
			   )  
		  END  

		 --PROCESS TO INVENTORY SHIPMENT
		   EXEC @intReturn = dbo.uspICAddItemShipment @Items  = @Items  
             , @Charges  = @Charges  
             , @Lots  = @Lots  
             , @intUserId = @intUserId
			 
		 IF @intReturn <> 0   
			RETURN @intReturn     

			  SELECT TOP 1   
				@intInventoryShipmentId = intInventoryShipmentId   
			  FROM #tmpAddItemShipmentResult  

		--to adjust when invoice process comes to place
		-- UPDATE tblAGWorkOrder
		-- SET dtmProcessDate = GETDATE()
		-- 	,ysnFinalized = 1
		-- 	,ysnShipped = 1
		-- 	,strStatus = 'Closed'
		-- WHERE intWorkOrderId = @intWorkOrderId


END



