CREATE PROCEDURE uspQMGetSampleHeaderData @intProductTypeId INT
	,@intProductValueId INT
AS
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @intInventoryReceiptId INT
DECLARE @intWorkOrderId INT
DECLARE @strReceiptNumber NVARCHAR(50)
DECLARE @strLotNumber NVARCHAR(50)
DECLARE @strContainerNumber NVARCHAR(100)
DECLARE @strWorkOrderNo NVARCHAR(50)

IF @intProductTypeId = 2 -- Item  
BEGIN
	SELECT @intProductTypeId AS intProductTypeId
		,@intProductValueId AS intProductValueId
		,I.intItemId
		,I.strItemNo
		,I.strDescription
		,I.intOriginId AS intCountryId
		,CA.strDescription AS strCountry
	FROM tblICItem I
	LEFT JOIN tblICCommodityAttribute CA ON CA.intCommodityAttributeId = I.intOriginId
	WHERE I.strStatus = 'Active'
		AND I.intItemId = @intProductValueId
END
ELSE IF @intProductTypeId = 8 -- Contract Line Item  
BEGIN
	SELECT @intProductTypeId AS intProductTypeId
		,@intProductValueId AS intProductValueId
		,C.intContractDetailId
		,C.strSequenceNumber
		,C.intItemContractId
		,C.strContractItemName
		,CAST(CASE 
				WHEN I.strType = 'Bundle'
					THEN NULL
				ELSE C.intItemId
				END AS INT) AS intItemId
		,(
			CASE 
				WHEN I.strType = 'Bundle'
					THEN NULL
				ELSE C.strItemNo
				END
			) AS strItemNo
		,(
			CASE 
				WHEN I.strType = 'Bundle'
					THEN NULL
				ELSE C.strItemDescription
				END
			) AS strDescription
		,CAST(CASE 
				WHEN I.strType = 'Bundle'
					THEN C.intItemId
				ELSE NULL
				END AS INT) AS intItemBundleId
		,(
			CASE 
				WHEN I.strType = 'Bundle'
					THEN C.strItemNo
				ELSE NULL
				END
			) AS strBundleItemNo
		,C.dblDetailQuantity AS dblRepresentingQty
		,C.intUnitMeasureId AS intRepresentingUOMId
		,C.strItemUOM AS strRepresentingUOM
		,C.intEntityId
		,C.strEntityName AS strPartyName
		,ISNULL(C.intItemContractOriginId, C.intOriginCountryId) AS intCountryId
		,ISNULL(C.strItemContractOrigin, C.strItemOriginCountry) AS strCountry
		,C.intContractTypeId
		,C.strItemSpecification
		,(
			CASE 
				WHEN C.ysnBrokerage = 1
					THEN C.strCPContract
				ELSE NULL
				END
			) AS strSampleNote
		,(
			CASE 
				WHEN C.ysnBrokerage = 1
					THEN C.strCounterPartyName
				ELSE NULL
				END
			) AS strRefNo
		,C.intBookId
		,C.strBook
		,C.intSubBookId
		,C.strSubBook
	FROM vyuCTContractDetailView C
	JOIN tblICItem I ON I.intItemId = C.intItemId
	WHERE C.intContractDetailId = @intProductValueId
END
ELSE IF @intProductTypeId = 9 -- Container Line Item  
BEGIN
	SELECT @intProductTypeId AS intProductTypeId
		,@intProductValueId AS intProductValueId
		,S.intLoadId
		,S.intLoadDetailId
		,S.intLoadContainerId
		,S.intLoadDetailContainerLinkId
		,S.strLoadNumber
		,S.strContainerNumber
		,S.dblQuantity AS dblRepresentingQty
		,C.intContractDetailId
		,C.strSequenceNumber
		,C.intItemContractId
		,C.strContractItemName
		,S.intItemId
		,S.strItemNo
		,S.strItemDescription AS strDescription
		,C.intUnitMeasureId AS intRepresentingUOMId
		,C.strItemUOM AS strRepresentingUOM
		,C.intEntityId
		,C.strEntityName AS strPartyName
		,ISNULL(C.intItemContractOriginId, C.intOriginCountryId) AS intCountryId
		,ISNULL(C.strItemContractOrigin, C.strItemOriginCountry) AS strCountry
		,S.strMarks
		,S.intPSubLocationId AS intCompanyLocationSubLocationId
		,S.strSubLocationName
		,C.intContractTypeId
		,C.strItemSpecification
		,(
			CASE 
				WHEN C.ysnBrokerage = 1
					THEN C.strCPContract
				ELSE NULL
				END
			) AS strSampleNote
		,(
			CASE 
				WHEN C.ysnBrokerage = 1
					THEN C.strCounterPartyName
				ELSE NULL
				END
			) AS strRefNo
		,C.intBookId
		,C.strBook
		,C.intSubBookId
		,C.strSubBook
	FROM vyuLGLoadContainerReceiptContracts S
	JOIN vyuCTContractDetailView C ON C.intContractDetailId = S.intPContractDetailId
		AND S.strType = 'Inbound'
	WHERE S.intLoadDetailContainerLinkId = @intProductValueId
END
ELSE IF @intProductTypeId = 10 -- Shipment Line Item  
BEGIN
	SELECT @intProductTypeId AS intProductTypeId
		,@intProductValueId AS intProductValueId
		,S.intLoadId
		,S.intLoadDetailId
		,S.strLoadNumber
		,S.dblQuantity AS dblRepresentingQty
		,C.intContractDetailId
		,C.strSequenceNumber
		,C.intItemContractId
		,C.strContractItemName
		,S.intItemId
		,S.strItemNo
		,S.strItemDescription AS strDescription
		,C.intUnitMeasureId AS intRepresentingUOMId
		,C.strItemUOM AS strRepresentingUOM
		,C.intEntityId
		,C.strEntityName AS strPartyName
		,ISNULL(C.intItemContractOriginId, C.intOriginCountryId) AS intCountryId
		,ISNULL(C.strItemContractOrigin, C.strItemOriginCountry) AS strCountry
		,S.strMarks
		,C.intContractTypeId
		,C.strItemSpecification
		,(
			CASE 
				WHEN C.ysnBrokerage = 1
					THEN C.strCPContract
				ELSE NULL
				END
			) AS strSampleNote
		,(
			CASE 
				WHEN C.ysnBrokerage = 1
					THEN C.strCounterPartyName
				ELSE NULL
				END
			) AS strRefNo
		,C.intBookId
		,C.strBook
		,C.intSubBookId
		,C.strSubBook
	FROM vyuLGLoadContainerReceiptContracts S
	JOIN vyuCTContractDetailView C ON C.intContractDetailId = S.intPContractDetailId
		AND S.strType = 'Inbound'
	WHERE S.intLoadDetailId = @intProductValueId
END
ELSE IF @intProductTypeId = 6 -- Lot  
BEGIN
	SELECT TOP 1 @strLotNumber = strLotNumber
	FROM tblICLot
	WHERE intLotId = @intProductValueId

	-- Inventory Receipt / Work Order No
	SELECT TOP 1 @intInventoryReceiptId = RI.intInventoryReceiptId
		,@strReceiptNumber = R.strReceiptNumber
		,@strContainerNumber = RIL.strContainerNo
	FROM tblICInventoryReceiptItemLot RIL
	JOIN tblICInventoryReceiptItem RI ON RI.intInventoryReceiptItemId = RIL.intInventoryReceiptItemId
	JOIN tblICInventoryReceipt R ON R.intInventoryReceiptId = RI.intInventoryReceiptId
	JOIN tblICLot L ON L.intLotId = RIL.intLotId
		AND L.strLotNumber = @strLotNumber
	ORDER BY RI.intInventoryReceiptId DESC

	IF ISNULL(@intInventoryReceiptId, 0) = 0
	BEGIN
		SELECT TOP 1 @intWorkOrderId = WPL.intWorkOrderId
			,@strWorkOrderNo = W.strWorkOrderNo
		FROM tblMFWorkOrderProducedLot WPL
		JOIN tblMFWorkOrder W ON W.intWorkOrderId = WPL.intWorkOrderId
		JOIN tblICLot L ON L.intLotId = WPL.intLotId
			AND L.strLotNumber = @strLotNumber
		ORDER BY WPL.intWorkOrderId DESC
	END

	SELECT @intProductTypeId AS intProductTypeId
		,@intProductValueId AS intProductValueId
		,L.intLotStatusId
		,LS.strSecondaryStatus AS strLotStatus
		,L.strLotNumber
		,L.intItemId
		,I.strItemNo
		,I.strDescription
		,(
			CASE 
				WHEN IU.intItemUOMId = L.intWeightUOMId
					THEN ISNULL(L.dblWeight, L.dblQty)
				ELSE L.dblQty
				END
			) AS dblRepresentingQty
		,IU.intUnitMeasureId AS intRepresentingUOMId
		,UOM.strUnitMeasure AS strRepresentingUOM
		,I.intOriginId AS intCountryId
		,CA.strDescription AS strCountry
		,@intInventoryReceiptId AS intInventoryReceiptId
		,@intWorkOrderId AS intWorkOrderId
		,@strWorkOrderNo AS strWorkOrderNo
		,@strReceiptNumber AS strReceiptNumber
		,@strContainerNumber AS strContainerNumber
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
		,S.strMarks
		,C.intContractTypeId
		,C.strItemSpecification
	FROM tblICLot L
	JOIN tblICLotStatus LS ON LS.intLotStatusId = L.intLotStatusId
		AND L.intLotId = @intProductValueId
	JOIN tblICItem I ON I.intItemId = L.intItemId
	JOIN tblICItemUOM IU ON IU.intItemId = I.intItemId
		AND IU.ysnStockUnit = 1
	JOIN tblICUnitMeasure UOM ON UOM.intUnitMeasureId = IU.intUnitMeasureId
	JOIN tblICStorageLocation SL ON SL.intStorageLocationId = L.intStorageLocationId
	JOIN tblSMCompanyLocationSubLocation CL ON CL.intCompanyLocationSubLocationId = L.intSubLocationId
	LEFT JOIN tblICCommodityAttribute CA ON CA.intCommodityAttributeId = I.intOriginId
	LEFT JOIN tblICInventoryReceiptItemLot RIL ON RIL.intLotId = L.intLotId
		AND L.strLotNumber = @strLotNumber
	LEFT JOIN tblICInventoryReceiptItem RI ON RI.intInventoryReceiptItemId = RIL.intInventoryReceiptItemId
	LEFT JOIN tblICInventoryReceipt R ON R.intInventoryReceiptId = RI.intInventoryReceiptId
	LEFT JOIN vyuCTContractDetailView C ON C.intContractDetailId = RI.intContractDetailId
	LEFT JOIN vyuLGLoadContainerReceiptContracts S ON S.intPContractDetailId = C.intContractDetailId
	LEFT JOIN tblEMEntity E ON E.intEntityId = R.intEntityVendorId
	WHERE L.intLotId = @intProductValueId
END
ELSE IF @intProductTypeId = 11 -- Parent Lot  
BEGIN
	DECLARE @dblRepresentingQty NUMERIC(18, 6)
	DECLARE @intRepresentingUOMId INT
	DECLARE @strRepresentingUOM NVARCHAR(50)

	SELECT @dblRepresentingQty = SUM(CASE 
				WHEN IU.intItemUOMId = L.intWeightUOMId
					THEN ISNULL(L.dblWeight, L.dblQty)
				ELSE L.dblQty
				END)
		,@intRepresentingUOMId = MAX(IU.intUnitMeasureId)
		,@strRepresentingUOM = MAX(UOM.strUnitMeasure)
	FROM tblICLot L
	JOIN tblICItemUOM IU ON IU.intItemId = L.intItemId
		AND IU.ysnStockUnit = 1
	JOIN tblICUnitMeasure UOM ON UOM.intUnitMeasureId = IU.intUnitMeasureId
	WHERE L.intParentLotId = @intProductValueId

	-- Inventory Receipt / Work Order No
	SELECT TOP 1 @intInventoryReceiptId = RI.intInventoryReceiptId
		,@strReceiptNumber = R.strReceiptNumber
		,@strContainerNumber = RIL.strContainerNo
	FROM tblICInventoryReceiptItemLot RIL
	JOIN tblICInventoryReceiptItem RI ON RI.intInventoryReceiptItemId = RIL.intInventoryReceiptItemId
	JOIN tblICInventoryReceipt R ON R.intInventoryReceiptId = RI.intInventoryReceiptId
	JOIN tblICLot L ON L.intLotId = RIL.intLotId
		AND L.intParentLotId = @intProductValueId
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
		,PL.intItemId
		,I.strItemNo
		,I.strDescription
		,@dblRepresentingQty AS dblRepresentingQty
		,@intRepresentingUOMId AS intRepresentingUOMId
		,@strRepresentingUOM AS strRepresentingUOM
		,I.intOriginId AS intCountryId
		,CA.strDescription AS strCountry
		,@intInventoryReceiptId AS intInventoryReceiptId
		,@intWorkOrderId AS intWorkOrderId
		,@strWorkOrderNo AS strWorkOrderNo
		,@strReceiptNumber AS strReceiptNumber
		,@strContainerNumber AS strContainerNumber
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
		,S.strMarks
		,C.intContractTypeId
		,C.strItemSpecification
	FROM tblICParentLot PL
	JOIN tblICLotStatus LS ON LS.intLotStatusId = PL.intLotStatusId
	JOIN tblICItem I ON I.intItemId = PL.intItemId
	LEFT JOIN tblICCommodityAttribute CA ON CA.intCommodityAttributeId = I.intOriginId
	LEFT JOIN tblICLot L ON L.intParentLotId = PL.intParentLotId
		AND L.intParentLotId = @intProductValueId
	LEFT JOIN tblICInventoryReceiptItemLot RIL ON RIL.intLotId = L.intLotId
	LEFT JOIN tblICInventoryReceiptItem RI ON RI.intInventoryReceiptItemId = RIL.intInventoryReceiptItemId
	LEFT JOIN tblICInventoryReceipt R ON R.intInventoryReceiptId = RI.intInventoryReceiptId
	LEFT JOIN vyuCTContractDetailView C ON C.intContractDetailId = RI.intContractDetailId
	LEFT JOIN vyuLGLoadContainerReceiptContracts S ON S.intPContractDetailId = C.intContractDetailId
	LEFT JOIN tblEMEntity E ON E.intEntityId = R.intEntityVendorId
	WHERE PL.intParentLotId = @intProductValueId
END
ELSE IF @intProductTypeId = 12 -- Work Order
BEGIN
	SELECT @intProductTypeId AS intProductTypeId
		,@intProductValueId AS intProductValueId
		,WO.intWorkOrderId
		,WO.strWorkOrderNo
		,I.intItemId
		,I.strItemNo
		,I.strDescription
		,I.intOriginId AS intCountryId
		,CA.strDescription AS strCountry
	FROM tblMFWorkOrder WO
	JOIN tblICItem I ON I.intItemId = WO.intItemId
	LEFT JOIN tblICCommodityAttribute CA ON CA.intCommodityAttributeId = I.intOriginId
	WHERE WO.intWorkOrderId = @intProductValueId
END
