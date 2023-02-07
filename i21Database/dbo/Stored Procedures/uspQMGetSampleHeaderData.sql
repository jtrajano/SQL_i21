CREATE PROCEDURE [dbo].[uspQMGetSampleHeaderData] 
	@intProductTypeId	INT
  , @intProductValueId	INT
  , @intLotId			INT = 0
AS

--SET QUOTED_IDENTIFIER OFF
--SET ANSI_NULLS ON
--SET NOCOUNT ON
--SET XACT_ABORT ON
--SET ANSI_WARNINGS OFF

DECLARE @intInventoryReceiptId	INT
	  , @intWorkOrderId			INT
	  , @strReceiptNumber		NVARCHAR(50)
	  , @strContainerNumber		NVARCHAR(100)
	  , @strWorkOrderNo			NVARCHAR(50)
	  , @strProductValue		NVARCHAR(MAX)

/* Item Product Type */
IF @intProductTypeId = 2 
	BEGIN
		SELECT @intProductTypeId	AS intProductTypeId
			 , @intProductValueId	AS intProductValueId
			 , Item.intItemId
			 , Item.strItemNo
			 , Item.strDescription
			 , Item.intOriginId		AS intCountryId
			 , CA.strDescription	AS strCountry
			 , Item.strDescription  AS strItemSpecification
		FROM tblICItem AS Item
		LEFT JOIN tblICCommodityAttribute AS CA ON CA.intCommodityAttributeId = Item.intOriginId
		WHERE Item.strStatus = 'Active' AND Item.intItemId = @intProductValueId
	END

/* Lot Product Type */
ELSE IF @intProductTypeId = 6
	BEGIN
		SELECT TOP 1 @strProductValue = strLotNumber
		FROM tblICLot
		WHERE intLotId = @intProductValueId

		/* Get Inventory Receipt Info. */
		SELECT TOP 1 @intInventoryReceiptId = ReceiptItem.intInventoryReceiptId
				   , @strReceiptNumber		= Receipt.strReceiptNumber
				   , @strContainerNumber	= ReceiptItemLot.strContainerNo
		FROM tblICInventoryReceiptItemLot AS ReceiptItemLot
		JOIN tblICInventoryReceiptItem AS ReceiptItem ON ReceiptItem.intInventoryReceiptItemId = ReceiptItemLot.intInventoryReceiptItemId
		JOIN tblICInventoryReceipt AS Receipt ON Receipt.intInventoryReceiptId = ReceiptItem.intInventoryReceiptId
		JOIN tblICLot AS Lot ON Lot.intLotId = ReceiptItemLot.intLotId AND Lot.intLotId = @intLotId
		ORDER BY ReceiptItem.intInventoryReceiptId DESC

		/* Get Work Order if no Inventory Receipt Info found. */
		IF ISNULL(@intInventoryReceiptId, 0) = 0
			BEGIN
				SELECT TOP 1 @intWorkOrderId = WorkOrderProduceLot.intWorkOrderId
						   , @strWorkOrderNo = WorkOrder.strWorkOrderNo
				FROM tblMFWorkOrderProducedLot AS WorkOrderProduceLot
				JOIN tblMFWorkOrder AS WorkOrder ON WorkOrder.intWorkOrderId = WorkOrderProduceLot.intWorkOrderId
				JOIN tblICLot AS Lot ON Lot.intLotId = WorkOrderProduceLot.intLotId AND Lot.strLotNumber = @strProductValue
				ORDER BY WorkOrderProduceLot.intWorkOrderId DESC
			END

		SELECT @intProductTypeId	 AS intProductTypeId
			 , @intProductValueId	 AS intProductValueId
			 , Lot.intLotStatusId
			 , LotStatus.strSecondaryStatus AS strLotStatus
			 , Lot.strLotNumber
			 , Lot.intItemId
			 , Item.strItemNo
			 , Item.strDescription
			 , CD.intItemBundleId
			 , IB.strItemNo AS strBundleItemNo
			 , (CASE WHEN ItemUOM.intItemUOMId = Lot.intWeightUOMId THEN ISNULL(Lot.dblWeight, Lot.dblQty) ELSE Lot.dblQty END) AS dblRepresentingQty
			 , ItemUOM.intUnitMeasureId AS intRepresentingUOMId
			 , UnitOfMeasure.strUnitMeasure AS strRepresentingUOM
			 , ISNULL(C.intItemContractOriginId, Item.intOriginId) AS intCountryId
			 , ISNULL(C.strItemContractOrigin, CA.strDescription) AS strCountry
			 , @intInventoryReceiptId AS intInventoryReceiptId
			 , @intWorkOrderId AS intWorkOrderId
			 , @strWorkOrderNo AS strWorkOrderNo
			 , @strReceiptNumber AS strReceiptNumber
			 , ISNULL(@strContainerNumber, Lot.strContainerNo) AS strContainerNumber
			 , Lot.intStorageLocationId
			 , SL.strName AS strStorageLocationName
			 , CL.intCompanyLocationSubLocationId
			 , CL.strSubLocationName		
			 , S.intLoadId
			 , S.intLoadDetailId
			 , S.intLoadContainerId
			 , S.intLoadDetailContainerLinkId
			 , S.strLoadNumber
			 , C.intContractDetailId
			 , C.strSequenceNumber
			 , C.intItemContractId
			 , C.strContractItemName
			 , ISNULL(C.intEntityId, R.intEntityVendorId) AS intEntityId
			 , ISNULL(C.strEntityName, E.strName) AS strPartyName
			 , ISNULL(S.strMarks, Lot.strMarkings) AS strMarks
			 , C.intContractTypeId
			 , C.strItemSpecification
			 , C.intContractHeaderId
			 , C.dblHeaderQuantity
			 , C.strHeaderUnitMeasure
		FROM tblICLot AS Lot
		JOIN tblICLotStatus AS LotStatus ON LotStatus.intLotStatusId = Lot.intLotStatusId AND Lot.intLotId = @intProductValueId
		JOIN tblICItem AS Item ON Item.intItemId = Lot.intItemId 
		JOIN tblICItemUOM AS ItemUOM ON ItemUOM.intItemId = Item.intItemId AND ItemUOM.ysnStockUnit = 1
		JOIN tblICUnitMeasure AS UnitOfMeasure ON UnitOfMeasure.intUnitMeasureId = ItemUOM.intUnitMeasureId
		JOIN tblICStorageLocation SL ON SL.intStorageLocationId = Lot.intStorageLocationId
		JOIN tblSMCompanyLocationSubLocation CL ON CL.intCompanyLocationSubLocationId = Lot.intSubLocationId
		LEFT JOIN tblICCommodityAttribute CA ON CA.intCommodityAttributeId = Item.intOriginId
		LEFT JOIN tblICInventoryReceiptItemLot RIL ON RIL.intLotId = Lot.intLotId AND Lot.strLotNumber = @strProductValue
		LEFT JOIN tblICInventoryReceiptItem RI ON RI.intInventoryReceiptItemId = RIL.intInventoryReceiptItemId
		LEFT JOIN tblICInventoryReceipt R ON R.intInventoryReceiptId = RI.intInventoryReceiptId
		LEFT JOIN vyuCTContractDetailView C ON C.intContractDetailId = RI.intContractDetailId
		LEFT JOIN tblCTContractDetail CD ON CD.intContractDetailId = C.intContractDetailId
		LEFT JOIN tblICItem IB ON IB.intItemId = CD.intItemBundleId
		LEFT JOIN vyuLGLoadContainerReceiptContracts S ON S.intPContractDetailId = C.intContractDetailId AND S.intLoadContainerId <> -1
		LEFT JOIN tblEMEntity E ON E.intEntityId = R.intEntityVendorId
		WHERE Lot.intLotId = @intProductValueId
	END

/* Contract Line Item Product Type */
ELSE IF @intProductTypeId = 8 
	BEGIN
		SELECT @intProductTypeId	AS intProductTypeId
			 , @intProductValueId	AS intProductValueId
			 , ContractDetail.intContractDetailId
			 , ContractDetail.strSequenceNumber
			 , ContractDetail.intItemContractId
			 , ContractDetail.strContractItemName
			 , ContractDetail.intItemId
			 , ContractDetail.strItemNo
			 , ContractDetail.strItemDescription	AS strDescription
			 , ContractDetailBundle.intItemBundleId
			 , ItemBundle.strItemNo					AS strBundleItemNo
			 , ContractDetail.dblDetailQuantity		AS dblRepresentingQty
			 , ContractDetail.intUnitMeasureId		AS intRepresentingUOMId
			 , ContractDetail.strItemUOM			AS strRepresentingUOM
			 , ContractDetail.intEntityId
			 , ContractDetail.strEntityName AS strPartyName
			 , ISNULL(ContractDetail.intItemContractOriginId, ContractDetail.intOriginCountryId) AS intCountryId
			 , ISNULL(ContractDetail.strItemContractOrigin, ContractDetail.strItemOriginCountry) AS strCountry
			 , ContractDetail.intContractTypeId
			 , ContractDetail.strItemSpecification
			 , (CASE WHEN ContractDetail.ysnBrokerage = 1 THEN ContractDetail.strCPContract ELSE NULL END)		 AS strSampleNote
			 , (CASE WHEN ContractDetail.ysnBrokerage = 1 THEN ContractDetail.strCounterPartyName ELSE NULL END) AS strRefNo
			 , ContractDetail.intBookId
			 , ContractDetail.strBook
			 , ContractDetail.intSubBookId
			 , ContractDetail.strSubBook
			 , ContractDetail.intContractHeaderId
			 , ContractDetail.dblHeaderQuantity
			 , ContractDetail.strHeaderUnitMeasure
		FROM vyuCTContractDetailView AS ContractDetail
		JOIN tblICItem AS Item ON Item.intItemId = ContractDetail.intItemId
		JOIN tblCTContractDetail AS ContractDetailBundle ON ContractDetailBundle.intContractDetailId = ContractDetail.intContractDetailId
		LEFT JOIN tblICItem AS ItemBundle ON ItemBundle.intItemId = ContractDetailBundle.intItemBundleId
		WHERE ContractDetail.intContractDetailId = @intProductValueId
	END

/* Contract Line Item Product Type */
ELSE IF @intProductTypeId = 9 -- Container Line Item  
	BEGIN
		SELECT @intProductTypeId	AS intProductTypeId
			 , @intProductValueId	AS intProductValueId
			 , LoadContractReceipt.intLoadId
			 , LoadContractReceipt.intLoadDetailId
			 , LoadContractReceipt.intLoadContainerId
			 , LoadContractReceipt.intLoadDetailContainerLinkId
			 , LoadContractReceipt.strLoadNumber
			 , LoadContractReceipt.strContainerNumber
			 , LoadContractReceipt.dblQuantity		  AS dblRepresentingQty
			 , ContractDetail.intContractDetailId
			 , ContractDetail.strSequenceNumber
			 , ContractDetail.intItemContractId
			 , ContractDetail.strContractItemName
			 , LoadContractReceipt.intItemId
			 , LoadContractReceipt.strItemNo
			 , LoadContractReceipt.strItemDescription AS strDescription
			 , ContractDetailBundle.intItemBundleId
			 , ItemBundle.strItemNo					  AS strBundleItemNo
			 , ContractDetail.intUnitMeasureId		  AS intRepresentingUOMId
			 , ContractDetail.strItemUOM			  AS strRepresentingUOM
			 , ContractDetail.intEntityId
			 , ContractDetail.strEntityName			  AS strPartyName
			 , ISNULL(ContractDetail.intItemContractOriginId, ContractDetail.intOriginCountryId) AS intCountryId
			 , ISNULL(ContractDetail.strItemContractOrigin, ContractDetail.strItemOriginCountry) AS strCountry
			 , LoadContractReceipt.strMarks
			 , LoadContractReceipt.intPSubLocationId	AS intCompanyLocationSubLocationId
			 , CompanySubLocation.strSubLocationName
			 , ContractDetail.intContractTypeId
			 , ContractDetail.strItemSpecification
			 , (CASE WHEN ContractDetail.ysnBrokerage = 1 THEN ContractDetail.strCPContract ELSE NULL END)		 AS strSampleNote
			 , (CASE WHEN ContractDetail.ysnBrokerage = 1 THEN ContractDetail.strCounterPartyName ELSE NULL END) AS strRefNo
			 , ContractDetail.intBookId
			 , ContractDetail.strBook
			 , ContractDetail.intSubBookId
			 , ContractDetail.strSubBook
			 , ContractDetail.intContractHeaderId
			 , ContractDetail.dblHeaderQuantity
			 , ContractDetail.strHeaderUnitMeasure
		FROM vyuLGLoadContainerReceiptContracts AS LoadContractReceipt
		JOIN vyuCTContractDetailView AS ContractDetail ON ContractDetail.intContractDetailId = LoadContractReceipt.intPContractDetailId AND LoadContractReceipt.strType = 'Inbound'
		JOIN tblCTContractDetail AS ContractDetailBundle ON ContractDetailBundle.intContractDetailId = ContractDetail.intContractDetailId
		LEFT JOIN tblICItem AS ItemBundle ON ItemBundle.intItemId = ContractDetailBundle.intItemBundleId
		LEFT JOIN tblSMCompanyLocationSubLocation AS CompanySubLocation ON CompanySubLocation.intCompanyLocationSubLocationId = LoadContractReceipt.intPSubLocationId
		WHERE LoadContractReceipt.intLoadDetailContainerLinkId = @intProductValueId
	END

/* Shipment Line Item Product Type */
ELSE IF @intProductTypeId = 10 
	BEGIN
		SELECT @intProductTypeId	AS intProductTypeId
			 , @intProductValueId	AS intProductValueId
			 , LoadContractReceipt.intLoadId
			 , LoadContractReceipt.intLoadDetailId
			 , LoadContractReceipt.strLoadNumber
			 , LoadContractReceipt.dblQuantity		  AS dblRepresentingQty
			 , ContractDetail.intContractDetailId
			 , ContractDetail.strSequenceNumber
			 , ContractDetail.intItemContractId
			 , ContractDetail.strContractItemName
			 , LoadContractReceipt.intItemId
			 , LoadContractReceipt.strItemNo
			 , LoadContractReceipt.strItemDescription AS strDescription
			 , ContractDetailBundle.intItemBundleId
			 , ItemBundle.strItemNo					  AS strBundleItemNo
			 , ContractDetail.intUnitMeasureId		  AS intRepresentingUOMId
			 , ContractDetail.strItemUOM			  AS strRepresentingUOM
			 , ContractDetail.intEntityId
			 , ContractDetail.strEntityName			  AS strPartyName
			 , ISNULL(ContractDetail.intItemContractOriginId, ContractDetail.intOriginCountryId) AS intCountryId
			 , ISNULL(ContractDetail.strItemContractOrigin, ContractDetail.strItemOriginCountry) AS strCountry
			 , LoadContractReceipt.strMarks
			 , ContractDetail.intContractTypeId
			 , ContractDetail.strItemSpecification
			 , (CASE WHEN ContractDetail.ysnBrokerage = 1 THEN ContractDetail.strCPContract ELSE NULL END) AS strSampleNote
			 , (CASE WHEN ContractDetail.ysnBrokerage = 1 THEN ContractDetail.strCounterPartyName ELSE NULL END) AS strRefNo
			 , ContractDetail.intBookId
			 , ContractDetail.strBook
			 , ContractDetail.intSubBookId
			 , ContractDetail.strSubBook
			 , ContractDetail.intContractHeaderId
			 , ContractDetail.dblHeaderQuantity
			 , ContractDetail.strHeaderUnitMeasure
		FROM vyuLGLoadContainerReceiptContracts AS LoadContractReceipt
		JOIN vyuCTContractDetailView AS ContractDetail ON ContractDetail.intContractDetailId = LoadContractReceipt.intPContractDetailId AND LoadContractReceipt.strType = 'Inbound'
		JOIN tblCTContractDetail AS ContractDetailBundle ON ContractDetailBundle.intContractDetailId = ContractDetail.intContractDetailId
		LEFT JOIN tblICItem AS ItemBundle ON ItemBundle.intItemId = ContractDetailBundle.intItemBundleId
		WHERE LoadContractReceipt.intLoadDetailId = @intProductValueId
	END

ELSE IF @intProductTypeId = 11 -- Parent Lot  
BEGIN
	DECLARE @dblRepresentingQty NUMERIC(18, 6)
	DECLARE @intRepresentingUOMId INT
	DECLARE @strRepresentingUOM NVARCHAR(50)

	SELECT @dblRepresentingQty = SUM(CASE 
				WHEN IU.intItemUOMId = L.intWeightUOMId
					THEN ISNULL(L.dblWeight, 0)
				WHEN IU.intItemUOMId = L.intItemUOMId
					THEN ISNULL(L.dblQty, 0)
				ELSE dbo.fnMFConvertQuantityToTargetItemUOM(L.intItemUOMId, IU.intItemUOMId, L.dblQty)
				END)
		,@intRepresentingUOMId = MAX(IU.intUnitMeasureId)
		,@strRepresentingUOM = MAX(UOM.strUnitMeasure)
	FROM tblICLot L
	JOIN tblICItemUOM IU ON IU.intItemId = L.intItemId AND IU.ysnStockUnit = 1
	JOIN tblICUnitMeasure UOM ON UOM.intUnitMeasureId = IU.intUnitMeasureId
	WHERE L.intParentLotId = @intProductValueId

	-- Inventory Receipt / Work Order No
	SELECT TOP 1 @intInventoryReceiptId = RI.intInventoryReceiptId
			   , @strReceiptNumber		= R.strReceiptNumber
			   , @strContainerNumber	= RIL.strContainerNo
	FROM tblICInventoryReceiptItemLot RIL
	JOIN tblICInventoryReceiptItem RI ON RI.intInventoryReceiptItemId = RIL.intInventoryReceiptItemId
	JOIN tblICInventoryReceipt R ON R.intInventoryReceiptId = RI.intInventoryReceiptId
	JOIN tblICLot L ON L.intLotId = RIL.intLotId AND L.intParentLotId = @intProductValueId AND L.intLotId = (CASE WHEN ISNULL(@intLotId, 0) > 0 THEN @intLotId
																						ELSE L.intLotId 
																				   END)
	ORDER BY RI.intInventoryReceiptId DESC

	IF ISNULL(@intInventoryReceiptId, 0) = 0
	BEGIN
		SELECT TOP 1 @intWorkOrderId = WPL.intWorkOrderId
			,@strWorkOrderNo = W.strWorkOrderNo
		FROM tblMFWorkOrderProducedLot WPL
		JOIN tblMFWorkOrder W ON W.intWorkOrderId = WPL.intWorkOrderId
		JOIN tblICLot L ON L.intLotId = WPL.intLotId
			AND L.intParentLotId = @intProductValueId
		ORDER BY WPL.intWorkOrderId DESC
	END

	SELECT @intProductTypeId AS intProductTypeId
		,@intProductValueId AS intProductValueId
		,PL.intLotStatusId
		,LS.strSecondaryStatus AS strLotStatus
		,PL.strParentLotNumber AS strLotNumber
		,I.intItemId
		,I.strItemNo
		,I.strDescription
		,CD.intItemBundleId
		,IB.strItemNo AS strBundleItemNo
		,@dblRepresentingQty AS dblRepresentingQty
		,@intRepresentingUOMId AS intRepresentingUOMId
		,@strRepresentingUOM AS strRepresentingUOM
		,ISNULL(C.intItemContractOriginId, I.intOriginId) AS intCountryId
		,ISNULL(C.strItemContractOrigin, CA.strDescription) AS strCountry
		,@intInventoryReceiptId AS intInventoryReceiptId
		,@intWorkOrderId AS intWorkOrderId
		,@strWorkOrderNo AS strWorkOrderNo
		,@strReceiptNumber AS strReceiptNumber
		,ISNULL(@strContainerNumber, L.strContainerNo) AS strContainerNumber
		,L.intStorageLocationId
		,SL.strName AS strStorageLocationName
		,CL.intCompanyLocationSubLocationId
		,CL.strSubLocationName
		,S.intLoadId
		,S.intLoadDetailId
		,S.intLoadContainerId
		,S.intLoadDetailContainerLinkId
		,S.strLoadNumber
		,C.intContractDetailId
		,C.strSequenceNumber
		,C.intItemContractId
		,C.strContractItemName
		,ISNULL(C.intEntityId, R.intEntityVendorId) AS intEntityId
		,ISNULL(C.strEntityName, E.strName) AS strPartyName
		,ISNULL(S.strMarks, L.strMarkings) AS strMarks
		,C.intContractTypeId
		,C.strItemSpecification
		,C.intContractHeaderId
		,C.dblHeaderQuantity
		,C.strHeaderUnitMeasure
	FROM tblICParentLot PL
	JOIN tblICLotStatus LS ON LS.intLotStatusId = PL.intLotStatusId
	LEFT JOIN tblICLot L ON L.intParentLotId = PL.intParentLotId AND L.intLotId = (CASE WHEN ISNULL(@intLotId, 0) > 0 THEN @intLotId
																						ELSE L.intLotId 
																				   END)
	JOIN tblICItem I ON I.intItemId = L.intItemId
	LEFT JOIN tblICCommodityAttribute CA ON CA.intCommodityAttributeId = I.intOriginId
	LEFT JOIN tblICStorageLocation SL ON SL.intStorageLocationId = L.intStorageLocationId
	LEFT JOIN tblSMCompanyLocationSubLocation CL ON CL.intCompanyLocationSubLocationId = L.intSubLocationId
	LEFT JOIN tblICInventoryReceiptItemLot RIL ON RIL.intLotId = L.intLotId
	LEFT JOIN tblICInventoryReceiptItem RI ON RI.intInventoryReceiptItemId = RIL.intInventoryReceiptItemId
	LEFT JOIN tblICInventoryReceipt R ON R.intInventoryReceiptId = RI.intInventoryReceiptId
	LEFT JOIN vyuCTContractDetailView C ON C.intContractDetailId = RI.intContractDetailId
	LEFT JOIN tblCTContractDetail CD ON CD.intContractDetailId = C.intContractDetailId
	LEFT JOIN tblICItem IB ON IB.intItemId = CD.intItemBundleId
	LEFT JOIN vyuLGLoadContainerReceiptContracts S ON S.intPContractDetailId = C.intContractDetailId
		AND S.intLoadContainerId <> -1
	LEFT JOIN tblEMEntity E ON E.intEntityId = R.intEntityVendorId
	WHERE PL.intParentLotId = @intProductValueId
END

/* Work Order Product Type */
ELSE IF @intProductTypeId = 12 
	BEGIN
		SELECT @intProductTypeId AS intProductTypeId
			 , @intProductValueId AS intProductValueId
			 , WorkOrder.intWorkOrderId
			 , WorkOrder.strWorkOrderNo
			 , Item.intItemId
			 , Item.strItemNo
			 , Item.strDescription
			 , Item.intOriginId AS intCountryId
			 , CommodityAttribute.strDescription AS strCountry
		FROM tblMFWorkOrder AS WorkOrder
		JOIN tblICItem AS Item ON Item.intItemId = WorkOrder.intItemId
		LEFT JOIN tblICCommodityAttribute AS CommodityAttribute ON CommodityAttribute.intCommodityAttributeId = Item.intOriginId
		WHERE WorkOrder.intWorkOrderId = @intProductValueId
	END

/* Batch Product Type */
ELSE IF @intProductTypeId = 13 
BEGIN

	SELECT @intProductTypeId						    AS intProductTypeId
		 , @intProductValueId						    AS intProductValueId
		 , strBatchId								    
		 , intTealingoItemId						    AS intItemId
		 , Item.strItemNo							    
		 , Batch.dblTotalQuantity					    AS dblRepresentingQty
		 , Item.intOriginId							    AS intCountry
		 , CommodityAttribute.strDescription		    AS strCountry
		 , Item.strDescription						    AS strItemSpecification
		 , UnitOfMeasure.strUnitMeasure				    AS strRepresentingUOM
		 , ItemUOM.intUnitMeasureId					    AS intRepresentingUOMId
		 , CAST(Batch.intSales AS NVARCHAR(50))		    AS strSaleNumber
		 , Batch.dtmSalesDate							AS dtmSaleDate
		 , SaleYear.strSaleYear							
		 , SaleYear.intSaleYearId						AS intSaleYearId
		 , Lot.strLotNumber							    AS strBatchNo
		 , GardenMark.strGardenMark					    
		 , Batch.intGardenMarkId					    
		 , Batch.strLeafStyle						    
		 , Color.intCommodityAttributeId			    AS intSeasonId 
		 , Color.strDescription						    AS strSeason
		 , BatchBroker.strName						    AS strBroker
		 , BatchBroker.intEntityId					    AS intBrokerId
		 , Batch.strTeaGardenChopInvoiceNumber		    AS strChopNumber
		 , Batch.strLeafCategory					    
		 , LeafCategory.intCommodityAttributeId2	    AS intLeafCategoryId
		 , LeafSize.intBrandId						    
		 , LeafSize.strBrandCode					    
		 , Batch.intCurrencyId						    
		 , Currency.strCurrency						    
		 , ProductLine.strDescription				    AS strProductLine
		 , ProductLine.intCommodityProductLineId	    AS intProductLineId
		 , LeafType.intCommodityAttributeId			    AS intManufacturingLeafTypeId
		 , LeafType.strDescription					    AS strManufacturingLeafType
		 , Grade.strDescription						    AS strGrade
		 , Grade.intCommodityAttributeId			    AS intGradeId
		 , Batch.strTeaGardenChopInvoiceNumber		    AS strChopNumber
		 , CAST(Batch.dblTareWeight AS NUMERIC(18, 2))  AS dblTareWeight
		 , CAST(Batch.dblGrossWeight AS NUMERIC(18, 2)) AS dblGrossWeight
		 , Batch.str3PLStatus
		 , Batch.strERPPONumber							AS strERPRefNo
		 , Batch.strSupplierReference					AS strAdditionalSupplierReference
	FROM tblMFBatch AS Batch
	LEFT JOIN tblICItem AS Item ON Batch.intTealingoItemId = Item.intItemId
	LEFT JOIN tblICCommodityAttribute AS CommodityAttribute ON Item.intOriginId = CommodityAttribute.intCommodityAttributeId
	LEFT JOIN tblICItemUOM AS ItemUOM ON Item.intItemId = ItemUOM.intItemId AND ItemUOM.ysnStockUnit = 1
	LEFT JOIN tblICUnitMeasure AS UnitOfMeasure ON ItemUOM.intUnitMeasureId = UnitOfMeasure.intUnitMeasureId
	LEFT JOIN tblMFLotInventory AS LotInventory ON Batch.intBatchId = LotInventory.intBatchId
	LEFT JOIN tblICLot AS Lot ON LotInventory.intLotId = Lot.intLotId
	LEFT JOIN tblQMGardenMark AS GardenMark ON Batch.intGardenMarkId = GardenMark.intGardenMarkId
	OUTER APPLY (SELECT intCommodityAttributeId
					  , strDescription
				 FROM vyuQMSearchCommodityAttributeAuction
				 WHERE strDescription = Batch.strTeaColour AND strType = 'Season') AS Color
	OUTER APPLY (SELECT intEntityId
					  , strName
				 FROM vyuEMSearchEntityBroker
				 WHERE intEntityId = Batch.intBrokerId) AS BatchBroker
	OUTER APPLY (SELECT intCommodityAttributeId2
					  , strAttribute2
				 FROM vyuQMSearchCommodityAttribute2
				 WHERE strAttribute2 = Batch.strLeafCategory) AS LeafCategory
	OUTER APPLY (SELECT intBrandId
					  , strBrandCode
				 FROM vyuQMSearchBrand
				 WHERE strBrandCode = Batch.strLeafSize) AS LeafSize
	OUTER APPLY (SELECT intCurrencyId
					  , strCurrency
				 FROM tblSMCurrency
				 WHERE intCurrencyId = Batch.intCurrencyId) AS Currency
	OUTER APPLY (SELECT intCommodityProductLineId
					  , strDescription
				 FROM vyuQMSearchCommodityProductLine
				 WHERE strDescription = Batch.strSustainability) AS ProductLine /* Product Type / Sustainability. */
	OUTER APPLY (SELECT intCommodityAttributeId
					  , strDescription
				 FROM vyuQMSearchCommodityAttributeAuction
				 WHERE strDescription = Batch.strLeafManufacturingType AND strType = 'Product Type') AS LeafType 
	OUTER APPLY (SELECT intCommodityAttributeId
					  , strDescription
				 FROM vyuQMSearchCommodityAttributeAuction
				 WHERE strDescription = Batch.strLeafGrade AND strType = 'Grade') AS Grade
	OUTER APPLY (SELECT intSaleYearId
					  , strSaleYear
				 FROM tblQMSaleYear
				 WHERE strSaleYear = CAST(Batch.intSalesYear AS NVARCHAR(50))) AS SaleYear
	WHERE Batch.intBatchId = @intProductValueId
END
