CREATE PROCEDURE [dbo].[uspQMGetSampleHeaderData]
     @intProductTypeId INT
	,@intProductValueId INT
AS
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

IF @intProductTypeId = 2 -- Item  
BEGIN
	SELECT @intProductTypeId AS intProductTypeId
		,@intProductValueId AS intProductValueId
		,I.intItemId
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
		--,C.intContractHeaderId
		,C.intContractDetailId
		,C.intItemContractId
		--,C.intItemId
		--,C.strItemDescription AS strDescription
		,CAST(CASE 
				WHEN I.strType = 'Bundle'
					THEN NULL
				ELSE C.intItemId
				END AS INT) AS intItemId
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
		,C.dblDetailQuantity AS dblRepresentingQty
		,C.intUnitMeasureId AS intRepresentingUOMId
		,C.intEntityId
		,ISNULL(C.intItemContractOriginId, C.intOriginId) AS intCountryId
		,ISNULL(C.strItemContractOrigin, C.strItemOrigin) AS strCountry
	FROM vyuCTContractDetailView C
	JOIN tblICItem I ON I.intItemId = C.intItemId
	WHERE C.intContractDetailId = @intProductValueId
END
ELSE IF @intProductTypeId = 9 -- Container Line Item  
BEGIN
	SELECT @intProductTypeId AS intProductTypeId
		,@intProductValueId AS intProductValueId
		--,S.intShipmentId
		--,S.intShipmentContractQtyId
		--,S.intShipmentBLContainerId
		--,S.intShipmentBLContainerContractId
		,S.intLoadId
		,S.intLoadDetailId
		,S.intLoadContainerId
		,S.intLoadDetailContainerLinkId
		,S.strContainerNumber
		,S.dblQuantity AS dblRepresentingQty
		--,C.intContractHeaderId
		,C.intContractDetailId
		,C.intItemContractId
		--,C.intItemId
		--,C.strItemDescription AS strDescription
		,S.intItemId
		,S.strItemDescription AS strDescription
		,C.intUnitMeasureId AS intRepresentingUOMId
		,C.intEntityId
		,ISNULL(C.intItemContractOriginId, C.intOriginId) AS intCountryId
		,ISNULL(C.strItemContractOrigin, C.strItemOrigin) AS strCountry
		,S.strMarks
		,S.intPSubLocationId AS intCompanyLocationSubLocationId
	--FROM vyuLGShipmentContainerReceiptContracts S
	--JOIN vyuCTContractDetailView C ON C.intContractDetailId = S.intContractDetailId
	--WHERE S.intShipmentBLContainerContractId = @intProductValueId
	FROM vyuLGLoadContainerReceiptContracts S
	JOIN vyuCTContractDetailView C ON C.intContractDetailId = S.intPContractDetailId
		AND S.strType = 'Inbound'
	WHERE S.intLoadDetailContainerLinkId = @intProductValueId
END
ELSE IF @intProductTypeId = 10 -- Shipment Line Item  
BEGIN
	SELECT @intProductTypeId AS intProductTypeId
		,@intProductValueId AS intProductValueId
		--,S.intShipmentId
		--,S.intShipmentContractQtyId
		,S.intLoadId
		,S.intLoadDetailId
		,S.dblQuantity AS dblRepresentingQty
		--,C.intContractHeaderId
		,C.intContractDetailId
		,C.intItemContractId
		--,C.intItemId
		--,C.strItemDescription AS strDescription
		,S.intItemId
		,S.strItemDescription AS strDescription
		,C.intUnitMeasureId AS intRepresentingUOMId
		,C.intEntityId
		,ISNULL(C.intItemContractOriginId, C.intOriginId) AS intCountryId
		,ISNULL(C.strItemContractOrigin, C.strItemOrigin) AS strCountry
		,S.strMarks
	--FROM vyuLGShipmentContainerReceiptContracts S
	--JOIN vyuCTContractDetailView C ON C.intContractDetailId = S.intContractDetailId
	--WHERE S.intShipmentContractQtyId = @intProductValueId
	FROM vyuLGLoadContainerReceiptContracts S
	JOIN vyuCTContractDetailView C ON C.intContractDetailId = S.intPContractDetailId
		AND S.strType = 'Inbound'
	WHERE S.intLoadDetailId = @intProductValueId
END
ELSE IF @intProductTypeId = 6 -- Lot  
BEGIN
	SELECT @intProductTypeId AS intProductTypeId
		,@intProductValueId AS intProductValueId
		,L.intLotStatusId
		,L.strLotNumber
		,L.intItemId
		,I.strDescription
		,(
			CASE 
				WHEN IU.intItemUOMId = L.intWeightUOMId
					THEN ISNULL(L.dblWeight, L.dblQty)
				ELSE L.dblQty
				END
			) AS dblRepresentingQty
		,IU.intUnitMeasureId AS intRepresentingUOMId
		,I.intOriginId AS intCountryId
		,CA.strDescription AS strCountry
	FROM tblICLot L
	JOIN tblICItem I ON I.intItemId = L.intItemId
	JOIN tblICItemUOM IU ON IU.intItemId = I.intItemId
		AND IU.ysnStockUnit = 1
	LEFT JOIN tblICCommodityAttribute CA ON CA.intCommodityAttributeId = I.intOriginId
	WHERE L.intLotId = @intProductValueId
END
ELSE IF @intProductTypeId = 11 -- Parent Lot  
BEGIN
	DECLARE @dblRepresentingQty NUMERIC(18, 6)
	DECLARE @intRepresentingUOMId INT

	SELECT @dblRepresentingQty = SUM(CASE 
				WHEN IU.intItemUOMId = L.intWeightUOMId
					THEN ISNULL(L.dblWeight, L.dblQty)
				ELSE L.dblQty
				END)
		,@intRepresentingUOMId = MAX(IU.intUnitMeasureId)
	FROM tblICLot L
	JOIN tblICItemUOM IU ON IU.intItemId = L.intItemId
		AND IU.ysnStockUnit = 1
	WHERE L.intParentLotId = @intProductValueId

	SELECT @intProductTypeId AS intProductTypeId
		,@intProductValueId AS intProductValueId
		,PL.intLotStatusId
		,PL.strParentLotNumber AS strLotNumber
		,PL.intItemId
		,I.strDescription
		,@dblRepresentingQty AS dblRepresentingQty
		,@intRepresentingUOMId AS intRepresentingUOMId
		,I.intOriginId AS intCountryId
		,CA.strDescription AS strCountry
	FROM tblICParentLot PL
	JOIN tblICItem I ON I.intItemId = PL.intItemId
	LEFT JOIN tblICCommodityAttribute CA ON CA.intCommodityAttributeId = I.intOriginId
	WHERE PL.intParentLotId = @intProductValueId
END
