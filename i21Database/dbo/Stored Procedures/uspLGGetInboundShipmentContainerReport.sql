CREATE PROCEDURE [dbo].[uspLGGetInboundShipmentContainerReport] 
	@xmlParam NVARCHAR(MAX) = NULL
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

	IF (@ysnLoadNumber = 1)
	BEGIN
		SELECT DISTINCT 
			strContainerNumber = CASE WHEN (LV.intPurchaseSale = 2) THEN ICL.strLotNumber ELSE LC.strContainerNumber END
			,LV.strBLNumber
			,strMarks = CASE WHEN (LV.intPurchaseSale = 2) THEN ICL.strMarkings ELSE LC.strMarks END 
			,LDV.dblDeliveredGross
			,LDV.dblDeliveredNet
			,LDV.dblDeliveredQuantity
			,LDV.dblDeliveredTare
			,LDV.dblGross
			,LDV.dblInboundAdjustment
			,LDV.dblItemUOMCF
			,LDV.dblNet
			,LDV.dblOutboundAdjustment
			,LDV.dblPCashPrice
			,LDV.dblPCostUOMCF
			,LDV.dblPFranchise
			,LDV.dblPMainCashPrice
			,LDV.dblPQuantityPerLoad
			,LDV.dblPStockUOMCF
			,LDV.dblQuantity
			,LDV.dblSCashPrice
			,LDV.dblSCostUOMCF
			,LDV.dblSFranchise
			,LDV.dblSMainCashPrice
			,LDV.dblSQuantityPerLoad
			,LDV.dblSStockUOMCF
			,LDV.dblTare
			,LDV.dtmCancelDispatchMailSent
			,LDV.dtmDeliveredDate
			,LDV.dtmDispatchedDate
			,LDV.dtmDispatchMailSent
			,LDV.dtmScheduledDate
			,LDV.strComments
			,LDV.strCustomer
			,LDV.strCustomerContract
			,LDV.strCustomerEmail
			,LDV.strCustomerFax
			,LDV.strCustomerMobile
			,LDV.strCustomerNo
			,LDV.strCustomerPhone
			,LDV.strCustomerReference
			,LDV.strDispatcher
			,LDV.strDriver
			,LDV.strEquipmentType
			,LDV.strExternalLoadNumber
			,LDV.strHauler
			,LDV.strInboundIndexType
			,LDV.strInboundPricingType
			,LDV.strInboundTaxGroup
			,strItemDescription = CASE 
				WHEN ISNULL(ITM.strContractItemName, '') = ''
					THEN LDV.strItemDescription
				ELSE ITM.strContractItemName
				END
			,LDV.strItemNo
			,LDV.strItemUOM
			,LDV.strLoadDirectionMsg
			,LDV.strLoadNumber
			,LDV.strLotTracking
			,LDV.strOutboundIndexType
			,LDV.strOutboundPricingType
			,LDV.strOutboundTaxGroup
			,LDV.strPContractNumber
			,LDV.strPCostUOM
			,LDV.strPCurrency
			,LDV.strPLifeTimeType
			,LDV.strPLocationAddress
			,LDV.strPLocationCity
			,LDV.strPLocationCountry
			,LDV.strPLocationFax
			,LDV.strPLocationMail
			,LDV.strPLocationName
			,LDV.strPLocationPhone
			,LDV.strPLocationState
			,LDV.strPLocationZipCode
			,LDV.strPMainCurrency
			,LDV.strPStockUOM
			,LDV.strPStockUOMType
			,LDV.strPSubLocationName
			,LDV.strScaleTicketNo
			,LDV.strScheduleInfoMsg
			,LDV.strSContractNumber
			,LDV.strSCostUOM
			,LDV.strSCurrency
			,LDV.strShipFrom
			,LDV.strShipFromAddress
			,LDV.strShipFromCity
			,LDV.strShipFromCountry
			,LDV.strShipFromState
			,LDV.strShipFromZipCode
			,LDV.strShipTo
			,LDV.strShipToAddress
			,LDV.strShipToCity
			,LDV.strShipToCountry
			,LDV.strShipToState
			,LDV.strShipToZipCode
			,LDV.strSLifeTimeType
			,LDV.strSLocationAddress
			,LDV.strSLocationCity
			,LDV.strSLocationCountry
			,LDV.strSLocationFax
			,LDV.strSLocationMail
			,LDV.strSLocationName
			,LDV.strSLocationPhone
			,LDV.strSLocationState
			,LDV.strSLocationZipCode
			,LDV.strSMainCurrency
			,LDV.strSStockUOM
			,LDV.strSStockUOMType
			,LDV.strSSubLocationName
			,LDV.strTrailerNo1
			,LDV.strTrailerNo2
			,LDV.strTrailerNo3
			,LDV.strCarNumber
			,LDV.strEmbargoNo
			,LDV.strEmbargoPermitNo
			,LDV.strTransUsedBy
			,LDV.strTruckNo
			,LDV.strType
			,LDV.strVendor
			,LDV.strVendorContract
			,LDV.strVendorEmail
			,LDV.strVendorFax
			,LDV.strVendorMobile
			,LDV.strVendorNo
			,LDV.strVendorPhone
			,LDV.strWeightItemUOM
			,LDV.strZipCode
			,dblContainerContractQty = CASE WHEN (LV.intPurchaseSale = 2) THEN LDL.dblLotQuantity ELSE LC.dblQuantity END
			,CH.strCustomerContract AS strCustomerContractNo
			,CH.dtmContractDate
			,strContractNumberDashSeq = CASE WHEN  (LV.intPurchaseSale = 1) 
											THEN LDV.strPContractNumber + '-' + CONVERT(NVARCHAR, LDV.intPContractSeq)
											ELSE LDV.strSContractNumber + '-' + CONVERT(NVARCHAR, LDV.intSContractSeq) END
			,CB.strContractBasis
			,strContractBasisDescription = CB.strFreightTerm
			,AB.strApprovalBasis
			,dblContainerGrossWt = CASE WHEN (LV.intPurchaseSale = 2) THEN LDL.dblGross ELSE LC.dblGrossWt END
			,dblContainerNetWt = CASE WHEN (LV.intPurchaseSale = 2) THEN LDL.dblNet ELSE LC.dblNetWt END
			,dblContainerTareWt = CASE WHEN (LV.intPurchaseSale = 2) THEN LDL.dblTare ELSE LC.dblTareWt END
			,strContractNumberWithSeq = LDV.strPContractNumber + '/' + CONVERT(NVARCHAR, LDV.intPContractSeq)
			,strSContractNumberWithSeq = LDV.strSContractNumber + '/' + CONVERT(NVARCHAR, LDV.intSContractSeq)
			,IC.strCommodityCode
			,LDCL.dblQuantity AS dblContainerLinkQty
			,LDCL.dblLinkGrossWt AS dblContainerLinkGrossWt
			,LDCL.dblLinkNetWt AS dblContainerLinkNetWt
			,LV.intPurchaseSale
			,LW.dtmDeliveryDate
			,SMC.strCountry 
			,CH.strContractNumber
			,CD.dtmEndDate AS  dtmEndDate
		FROM vyuLGLoadDetailView LDV
		JOIN vyuLGLoadView LV ON LV.intLoadId = LDV.intLoadId
		LEFT JOIN tblLGLoadDetailContainerLink LDCL ON LDCL.intLoadDetailId = LDV.intLoadDetailId
		LEFT JOIN tblLGLoadContainer LC ON LC.intLoadContainerId = LDCL.intLoadContainerId
		OUTER APPLY (SELECT TOP 1 intPickLotDetailId FROM tblLGPickLotDetail WHERE intContainerId = LC.intLoadContainerId) PL
		LEFT JOIN tblLGLoadWarehouseContainer LWC ON LWC.intLoadContainerId = LC.intLoadContainerId
		LEFT JOIN tblLGLoadWarehouse LW ON LW.intLoadWarehouseId = LWC.intLoadWarehouseId
		LEFT JOIN tblCTContractDetail CD ON CD.intContractDetailId = LDV.intPContractDetailId
		LEFT JOIN tblCTContractHeader CH ON CD.intContractHeaderId = CH.intContractHeaderId
		LEFT JOIN tblCTApprovalBasis AB ON AB.intApprovalBasisId = CH.intApprovalBasisId
		LEFT JOIN tblSMFreightTerms CB ON CB.intFreightTermId = CH.intFreightTermId
		LEFT JOIN tblICCommodity IC ON IC.intCommodityId = CH.intCommodityId
		LEFT JOIN tblICItemContract ITM ON ITM.intItemContractId = CD.intItemContractId
		LEFT JOIN tblLGLoadDetailLot LDL ON LDL.intLoadDetailId = LDV.intLoadDetailId AND LV.intPurchaseSale = 2
		LEFT JOIN tblICLot ICL ON ICL.intLotId = LDL.intLotId
		LEFT JOIN tblSMCountry SMC ON ITM.intCountryId = SMC.intCountryID
		WHERE LDV.strLoadNumber = @xmlParam
			AND (@ysnHasPickContainer = 0
				 OR (@ysnHasPickContainer = 1 AND LC.intLoadContainerId IN 
						(SELECT intContainerId FROM tblLGPickLotDetail PLD 
						LEFT JOIN tblLGPickLotHeader PLH ON PLD.intPickLotHeaderId = PLH.intPickLotHeaderId
						WHERE PLH.intType = 2)))
	END
	ELSE
	BEGIN
		SELECT L.strBLNumber
			,LC.strContainerNumber
			,LDV.strItemNo
			,CASE WHEN ISNULL(ITM.strContractItemName,'') = '' THEN LDV.strItemDescription ELSE ITM.strContractItemName END AS strItemDescription
			,CB.strContractBasis
			,CH.strContractNumber
			,CH.strContractNumber + '-' + CONVERT(NVARCHAR, LDV.intPContractSeq) AS strContractNumberDashSeq
			,CH.strCustomerContract
			,LC.dblQuantity AS tractQty
			,LC.strMarks
			,LDV.strItemUOM
			,LDV.strWeightItemUOM
			,LDCL.dblQuantity AS dblContainerContractQty
			,CH.strCustomerContract AS strCustomerContractNo
			,CH.dtmContractDate
			,strContractBasis = CB.strContractBasis
			,CB.strDescription strContractBasisDescription
			,AB.strApprovalBasis
			,(
				LC.dblGrossWt / CASE 
					WHEN ISNULL(LC.dblQuantity, 0) = 0
						THEN 1
					ELSE LC.dblQuantity
					END
				) * LDCL.dblQuantity AS dblContainerGrossWt
			,(
				LC.dblNetWt / CASE 
					WHEN ISNULL(LC.dblQuantity, 0) = 0
						THEN 1
					ELSE LC.dblQuantity
					END
				) * LDCL.dblQuantity AS dblContainerNetWt
			,(
				LC.dblTareWt / CASE 
					WHEN ISNULL(LC.dblQuantity, 0) = 0
						THEN 1
					ELSE LC.dblQuantity
					END
				) * LDCL.dblQuantity AS dblContainerTareWt
			,LDV.strPContractNumber + '/' + CONVERT(NVARCHAR, LDV.intPContractSeq) AS strContractNumberWithSeq
			,LDV.strSContractNumber + '/' + CONVERT(NVARCHAR, LDV.intSContractSeq) AS strSContractNumberWithSeq
			,IC.strCommodityCode
			,LW.dtmDeliveryDate
			,SMC.strCountry
			,LDV.strVendor
		FROM tblLGLoad L
		JOIN tblLGLoadWarehouse LW ON LW.intLoadId = L.intLoadId
		JOIN tblLGLoadWarehouseContainer WC ON WC.intLoadWarehouseId = LW.intLoadWarehouseId
		JOIN tblLGLoadContainer LC ON LC.intLoadContainerId = WC.intLoadContainerId
		JOIN tblLGLoadDetailContainerLink LDCL ON LDCL.intLoadContainerId = LC.intLoadContainerId
		JOIN vyuLGLoadDetailViewSearch LDV ON LDV.intLoadDetailId = LDCL.intLoadDetailId
		JOIN tblCTContractDetail CD ON CD.intContractDetailId = LDV.intPContractDetailId
		JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
		LEFT JOIN tblSMFreightTerms CB ON CB.intFreightTermId = CH.intFreightTermId
		LEFT JOIN tblCTApprovalBasis AB ON AB.intApprovalBasisId = CH.intApprovalBasisId
		LEFT JOIN tblICCommodity IC ON IC.intCommodityId = CH.intCommodityId
		LEFT JOIN tblICItemContract ITM ON ITM.intItemContractId = CD.intItemContractId
		LEFT JOIN tblSMCountry SMC ON ITM.intCountryId = SMC.intCountryID
		WHERE LW.intLoadWarehouseId = @xmlParam
	END
END