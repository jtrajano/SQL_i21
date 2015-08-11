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
	FROM tblICItem I
	WHERE I.strStatus = 'Active'
		AND I.intItemId = @intProductValueId
END
ELSE IF @intProductTypeId = 8 -- Contract Line Item
BEGIN
	SELECT @intProductTypeId AS intProductTypeId
		,@intProductValueId AS intProductValueId
		,C.intContractHeaderId
		,C.intContractDetailId
		,C.intItemId
		,C.strItemDescription AS strDescription
		,C.dblDetailQuantity AS dblRepresentingQty
		,C.intUnitMeasureId AS intRepresentingUOMId
		,C.intCountryId
		,C.intEntityId
	FROM vyuCTContractDetailView C
	WHERE C.intContractDetailId = @intProductValueId
END
ELSE IF @intProductTypeId = 9 -- Container Line Item
BEGIN
	SELECT @intProductTypeId AS intProductTypeId
		,@intProductValueId AS intProductValueId
		,S.intShipmentId
		,S.intShipmentContractQtyId
		,S.intShipmentBLContainerId
		,S.intShipmentBLContainerContractId
		,C.intContractHeaderId
		,C.intContractDetailId
		,C.intItemId
		,C.strItemDescription AS strDescription
		,C.dblDetailQuantity AS dblRepresentingQty
		,C.intUnitMeasureId AS intRepresentingUOMId
		,C.intCountryId
		,C.intEntityId
	FROM vyuLGShipmentContainerReceiptContracts S
	JOIN vyuCTContractDetailView C ON C.intContractDetailId = S.intContractDetailId
	WHERE S.intShipmentBLContainerContractId = @intProductValueId
END
ELSE IF @intProductTypeId = 10 -- Shipment Line Item
BEGIN
	SELECT @intProductTypeId AS intProductTypeId
		,@intProductValueId AS intProductValueId
		,S.intShipmentId
		,S.intShipmentContractQtyId
		,C.intContractHeaderId
		,C.intContractDetailId
		,C.intItemId
		,C.strItemDescription AS strDescription
		,C.dblDetailQuantity AS dblRepresentingQty
		,C.intUnitMeasureId AS intRepresentingUOMId
		,C.intCountryId
		,C.intEntityId
	FROM vyuLGShipmentContainerReceiptContracts S
	JOIN vyuCTContractDetailView C ON C.intContractDetailId = S.intContractDetailId
	WHERE S.intShipmentContractQtyId = @intProductValueId
END
ELSE IF @intProductTypeId = 6 -- Lot
BEGIN
	SELECT @intProductTypeId AS intProductTypeId
		,@intProductValueId AS intProductValueId
		,L.intLotStatusId
		,L.strLotNumber
		,L.intItemId
		,I.strDescription
		,L.dblQty AS dblRepresentingQty
		,IU.intUnitMeasureId AS intRepresentingUOMId
	FROM tblICLot L
	JOIN tblICItem I ON I.intItemId = L.intItemId
	JOIN tblICItemUOM IU ON IU.intItemUOMId = L.intItemUOMId
	WHERE L.intLotId = @intProductValueId
END
ELSE IF @intProductTypeId = 11 -- Parent Lot
BEGIN
	SELECT @intProductTypeId AS intProductTypeId
		,@intProductValueId AS intProductValueId
		,PL.intLotStatusId
		,PL.strParentLotNumber
		,PL.intItemId
		,I.strDescription
		,PL.dblQty AS dblRepresentingQty
		,IU.intUnitMeasureId AS intRepresentingUOMId
	FROM tblICParentLot PL
	JOIN tblICItem I ON I.intItemId = PL.intItemId
	JOIN tblICItemUOM IU ON IU.intItemUOMId = PL.intItemUOMId
	WHERE PL.intParentLotId = @intProductValueId
END
