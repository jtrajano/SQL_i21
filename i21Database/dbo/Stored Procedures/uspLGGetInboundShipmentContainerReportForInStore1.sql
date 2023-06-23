/** This is a new SP for the In-Store Template 1 that is based from uspLGGetInboundShipmentContainerReport **/

CREATE PROCEDURE [dbo].[uspLGGetInboundShipmentContainerReportForInStore1]
	@xmlParam NVARCHAR(MAX) = NULL,
	@xmlParam2 INT = NULL,
	@xmlParam3 INT = NULL
AS
BEGIN
	DECLARE @ysnLoadNumber BIT
	DECLARE @ysnHasPickContainer BIT = 0

	IF EXISTS (SELECT 1 FROM tblLGLoad WHERE strLoadNumber = @xmlParam)
	BEGIN
		SET @ysnLoadNumber = 1
		IF EXISTS (SELECT TOP 1 1 FROM tblLGPickLotDetail PLD 
					INNER JOIN tblLGPickLotHeader PLH ON PLD.intPickLotHeaderId = PLH.intPickLotHeaderId 
					INNER JOIN tblLGLoadContainer LC ON LC.intLoadContainerId = PLD.intContainerId
					INNER JOIN tblLGLoad L ON L.intLoadId = LC.intLoadId
					WHERE L.strLoadNumber = @xmlParam AND L.intPurchaseSale = 1 AND PLH.intType = 2)
		BEGIN
			SET @ysnHasPickContainer = 1
		END
	END
	ELSE
	BEGIN
		SET @ysnLoadNumber = 0
	END

	SELECT DISTINCT 
		strContainerNumber = CASE WHEN (LV.intPurchaseSale = 2) THEN ICL.strLotNumber ELSE LC.strContainerNumber END
		,strItemDescription = CASE 
		WHEN ISNULL(ITM.strContractItemName, '') = ''
			THEN LDV.strItemDescription
		ELSE ITM.strContractItemName
		END
		,strContractNumberWithSeq = LDV.strPContractNumber + '/' + CONVERT(NVARCHAR, LDV.intPContractSeq)


		,strMarks = CASE WHEN (LV.intPurchaseSale = 2) THEN ICL.strMarkings ELSE LC.strMarks END 
		,LDV.strItemUOM
		,dblContainerContractQty = CASE WHEN (LV.intPurchaseSale = 2) THEN LDL.dblLotQuantity ELSE LDCL.dblQuantity END
		,dblContainerGrossWt = CASE WHEN (LV.intPurchaseSale = 2) THEN LDL.dblGross ELSE LC.dblGrossWt END
		,LDV.strWeightItemUOM
		,dblContainerTareWt = CASE WHEN (LV.intPurchaseSale = 2) THEN LDL.dblTare ELSE LC.dblTareWt END
		,dblContainerNetWt = CASE WHEN (LV.intPurchaseSale = 2) THEN LDL.dblNet ELSE LC.dblNetWt END
		,LC.intLoadContainerId
		,LV.strLoadNumber
	FROM vyuLGLoadDetailView LDV
	JOIN vyuLGLoadView LV ON LV.intLoadId = LDV.intLoadId
	LEFT JOIN tblLGLoadDetailContainerLink LDCL ON LDCL.intLoadDetailId = LDV.intLoadDetailId
	LEFT JOIN tblLGLoadContainer LC ON LC.intLoadContainerId = LDCL.intLoadContainerId
	OUTER APPLY (SELECT TOP 1 intPickLotDetailId FROM tblLGPickLotDetail WHERE intContainerId = LC.intLoadContainerId) PL
	LEFT JOIN tblLGLoadWarehouseContainer LWC ON LWC.intLoadContainerId = LC.intLoadContainerId
	LEFT JOIN tblLGLoadWarehouse LW ON LW.intLoadWarehouseId = LWC.intLoadWarehouseId
	LEFT JOIN tblCTContractDetail CD ON CD.intContractDetailId = CASE WHEN(LV.intPurchaseSale = 2) THEN LDV.intSContractDetailId ELSE LDV.intPContractDetailId END
	LEFT JOIN tblCTContractHeader CH ON CD.intContractHeaderId = CH.intContractHeaderId
	LEFT JOIN tblCTApprovalBasis AB ON AB.intApprovalBasisId = CH.intApprovalBasisId
	LEFT JOIN tblSMFreightTerms CB ON CB.intFreightTermId = CH.intFreightTermId
	LEFT JOIN tblICCommodity IC ON IC.intCommodityId = CH.intCommodityId
	LEFT JOIN tblICItemContract ITM ON ITM.intItemContractId = CD.intItemContractId
	LEFT JOIN tblLGLoadDetailLot LDL ON LDL.intLoadDetailId = LDV.intLoadDetailId AND LV.intPurchaseSale = 2
	LEFT JOIN tblICLot ICL ON ICL.intLotId = LDL.intLotId
	LEFT JOIN tblSMCountry SMC ON ITM.intCountryId = SMC.intCountryID
	WHERE LDV.strLoadNumber = @xmlParam
		AND (ISNULL(@xmlParam2, 0) = 0 
			OR (ISNULL(@xmlParam2, 0) > 0 AND @xmlParam2 = LDV.intCustomerEntityId)
			OR (ISNULL(@xmlParam2, 0) < 0 AND LDV.intCustomerEntityId IS NULL))
		AND (@ysnHasPickContainer = 0
				OR (@ysnHasPickContainer = 1 AND LC.intLoadContainerId IN 
					(SELECT intContainerId FROM tblLGPickLotDetail PLD 
					LEFT JOIN tblLGPickLotHeader PLH ON PLD.intPickLotHeaderId = PLH.intPickLotHeaderId
					WHERE PLH.intType = 2)))
		AND ISNULL(@xmlParam3, 0) = LW.intLoadWarehouseId
END