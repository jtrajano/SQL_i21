CREATE PROCEDURE [dbo].[uspLGGetInboundShipmentContainerReport] 
	@xmlParam NVARCHAR(MAX) = NULL
AS
BEGIN
	DECLARE @ysnLoadNumber BIT

	IF EXISTS (SELECT 1 FROM tblLGLoad WHERE strLoadNumber = @xmlParam)
	BEGIN
		SET @ysnLoadNumber = 1
	END
	ELSE
	BEGIN
		SET @ysnLoadNumber = 0
	END

	IF (@ysnLoadNumber = 1)
	BEGIN
		SELECT DISTINCT LC.strContainerNumber
			,LV.strBLNumber
			,LC.strMarks
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
			,CASE 
				WHEN ISNULL(CD.strContractItemName, '') = ''
					THEN LDV.strItemDescription
				ELSE CD.strContractItemName
				END AS strItemDescription
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
			,LC.dblQuantity AS dblContainerContractQty
			,CD.strCustomerContract AS strCustomerContractNo
			,CD.dtmContractDate
			,CD.strContractBasis
			,CD.strContractBasisDescription
			,CD.strApprovalBasis
			,LC.dblGrossWt AS dblContainerGrossWt
			,LC.dblNetWt AS dblContainerNetWt
			,LC.dblTareWt AS dblContainerTareWt
			,LDV.strPContractNumber + '/' + CONVERT(NVARCHAR, LDV.intPContractSeq) AS strContractNumberWithSeq
			,CD.strCommodityCode
		FROM vyuLGLoadDetailView LDV
		JOIN vyuLGLoadView LV ON LV.intLoadId = LDV.intLoadId
		JOIN tblLGLoadDetailContainerLink LDCL ON LDCL.intLoadDetailId = LDV.intLoadDetailId
		JOIN tblLGLoadContainer LC ON LC.intLoadContainerId = LDCL.intLoadContainerId
		LEFT JOIN tblLGLoadWarehouseContainer LWC ON LWC.intLoadContainerId = LC.intLoadContainerId
		LEFT JOIN tblLGLoadWarehouse LW ON LW.intLoadWarehouseId = LWC.intLoadWarehouseId
		LEFT JOIN vyuCTContractDetailView CD ON CD.intContractDetailId = LDV.intPContractDetailId
		WHERE LDV.strLoadNumber = @xmlParam
	END
	ELSE
	BEGIN
		SELECT L.strBLNumber
			,LC.strContainerNumber
			,LDV.strItemNo
			,LDV.strItemDescription
			,CB.strContractBasis
			,CH.strContractNumber
			,CH.strContractNumber + '/' + CONVERT(NVARCHAR, LDV.intPContractSeq) AS strContractNumberWithSeq
			,CH.strCustomerContract
			,LC.dblQuantity AS tractQty
			,LC.strMarks
			,LDV.strItemUOM
			,LDV.strWeightItemUOM
			,LDCL.dblQuantity AS dblContainerContractQty
			,CH.strCustomerContract AS strCustomerContractNo
			,CH.dtmContractDate
			,CB.strContractBasis
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
			,IC.strCommodityCode
		FROM tblLGLoad L
		JOIN tblLGLoadWarehouse LW ON LW.intLoadId = L.intLoadId
		JOIN tblLGLoadWarehouseContainer WC ON WC.intLoadWarehouseId = LW.intLoadWarehouseId
		JOIN tblLGLoadContainer LC ON LC.intLoadContainerId = WC.intLoadContainerId
		JOIN tblLGLoadDetailContainerLink LDCL ON LDCL.intLoadContainerId = LC.intLoadContainerId
		JOIN vyuLGLoadDetailViewSearch LDV ON LDV.intLoadDetailId = LDCL.intLoadDetailId
		JOIN tblCTContractDetail CD ON CD.intContractDetailId = LDV.intPContractDetailId
		JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
		LEFT JOIN tblCTContractBasis CB ON CB.intContractBasisId = CH.intContractBasisId
		LEFT JOIN tblCTApprovalBasis AB ON AB.intApprovalBasisId = CH.intApprovalBasisId
		LEFT JOIN tblICCommodity IC ON IC.intCommodityId = CH.intCommodityId
		LEFT JOIN tblICItemContract ITM ON ITM.intItemContractId = CD.intItemContractId
		WHERE LW.intLoadWarehouseId = @xmlParam
	END
END