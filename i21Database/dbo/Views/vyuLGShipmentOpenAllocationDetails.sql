CREATE VIEW vyuLGShipmentOpenAllocationDetails
AS
SELECT *
FROM (
	SELECT AH.[strAllocationNumber]
		,AD.strAllocationDetailRefNo
		,AH.intAllocationHeaderId
		,AD.intAllocationDetailId
		,AD.intPContractDetailId
		,intPurchaseContractHeaderId = CHP.intContractHeaderId
		,strPurchaseContractNumber = CHP.strContractNumber
		,intPContractSeq = CDP.intContractSeq
		,intPEntityId = CHP.intEntityId
		,intPCompanyLocationId = CDP.intCompanyLocationId
		,strPCompanyLocation = PCL.strLocationName
		,intPItemId = CDP.intItemId
		,strPContractNumber = CAST(CHP.strContractNumber AS VARCHAR(100)) + '/' + CAST(CDP.intContractSeq AS VARCHAR(100))
		,AD.dblPAllocatedQty
		,dblPUnAllocatedQty = AD.dblPAllocatedQty - IsNull(LD.dblPShippedQuantity, 0) - IsNull(PL.dblLotPickedQty, 0)
		,AD.intPUnitMeasureId
		,strPUnitMeasure = UP.strUnitMeasure
		,strVendor = ENP.strName
		,strVendorContract = CHP.strCustomerContract
		,strPItemDescription = ITP.strDescription
		,dtmPStartDate = CDP.dtmStartDate
		,dtmPEndDate = CDP.dtmEndDate
		,strPPosition = PP.strPosition
		,strPOrigin = CP.strCountry
		,intPCommodityId = CHP.intCommodityId
		,intPItemUOMId = CDP.intItemUOMId
		,intPOriginId = CP.intCountryID
		,strPUnitType = UP.strUnitType

		,AD.intSContractDetailId
		,intSalesContractHeaderId = CHS.intContractHeaderId
		,strSalesContractNumber = CHS.strContractNumber
		,intSContractSeq = CDS.intContractSeq
		,intSEntityId = CHS.intEntityId
		,intSCompanyLocationId = CDS.intCompanyLocationId
		,strSCompanyLocation = SCL.strLocationName
		,intSItemId = CDS.intItemId
		,strSContractNumber = CAST(CHS.strContractNumber AS VARCHAR(100)) + '/' + CAST(CDS.intContractSeq AS VARCHAR(100))
		,AD.dblSAllocatedQty
		,dblSUnAllocatedQty = AD.dblSAllocatedQty - IsNull(LD.dblSShippedQuantity, 0) - IsNull(PLS.dblSalePickedQty, 0)
		,AD.intSUnitMeasureId
		,strSUnitMeasure = US.strUnitMeasure
		,strCustomer = ENS.strName
		,strCustomerContract = CHS.strCustomerContract
		,strSItemDescription = ITS.strDescription
		,dtmSStartDate = CDS.dtmStartDate
		,dtmSEndDate = CDS.dtmEndDate
		,strSPosition = PS.strPosition
		,strSOrigin = CS.strCountry
		,intSCommodityId = CHS.intCommodityId
		,intSItemUOMId = CDS.intItemUOMId
		,intSOriginId = CS.intCountryID
		,strSUnitType = US.strUnitType

		,strPItemType = ITP.strType
		,strSItemType = ITP.strType
		,strPriceCurrency = SCurrency.strCurrency
		,dblSalesPrice = CDS.dblCashPrice
		,strPriceUOM = SUOM.strUnitMeasure
		,intPriceUnitMeasureId = SItemUOM.intUnitMeasureId
		,SCurrency.ysnSubCurrency
		,dblAvailableAllocationQty = (ISNULL(AD.dblPAllocatedQty, 0) - ISNULL(LD.dblPShippedQuantity, 0))
		,dblQtyConversionFactor = dbo.fnLGGetItemUnitConversion(CDP.intItemId,CDP.intItemUOMId,CDS.intUnitMeasureId)
		,dblAvailableContractQty = (ISNULL(CDP.dblQuantity,0)-ISNULL(CDP.dblScheduleQty,0))
		,AH.intBookId
		,BO.strBook
		,AH.intSubBookId
		,SB.strSubBook
		,strOriginPort = ISNULL(SLP.strCity, PLP.strCity)
		,strDestinationPort = ISNULL(SDP.strCity, PDP.strCity)
		,strDestinationCity = ISNULL(SDC.strCity, PDC.strCity)
		,intShippingLineEntityId = ISNULL(CDP.intShippingLineId, CDS.intShippingLineId)
		,strShippingLine = ISNULL(ESLP.strName, ESLS.strName)
		,intShipmentType = 1
	FROM tblLGAllocationDetail AD
	JOIN tblLGAllocationHeader AH ON AH.intAllocationHeaderId = AD.intAllocationHeaderId
	JOIN tblCTContractDetail CDP ON CDP.intContractDetailId = AD.intPContractDetailId
	JOIN tblCTContractHeader CHP ON CHP.intContractHeaderId = CDP.intContractHeaderId
	JOIN tblCTContractDetail CDS ON CDS.intContractDetailId = AD.intSContractDetailId
	JOIN tblCTContractHeader CHS ON CHS.intContractHeaderId = CDS.intContractHeaderId
	JOIN tblEMEntity ENP ON ENP.intEntityId = CHP.intEntityId
	JOIN tblEMEntity ENS ON ENS.intEntityId = CHS.intEntityId
	JOIN tblICUnitMeasure UP ON UP.intUnitMeasureId = AD.intPUnitMeasureId
	JOIN tblICUnitMeasure US ON US.intUnitMeasureId = AD.intSUnitMeasureId
	JOIN tblICItem ITP ON ITP.intItemId = CDP.intItemId
	JOIN tblICItem ITS ON ITS.intItemId = CDS.intItemId
	JOIN tblSMCurrency SCurrency ON SCurrency.intCurrencyID = CDS.intCurrencyId
	JOIN tblICItemUOM SItemUOM ON SItemUOM.intItemUOMId = CDS.intPriceItemUOMId
	JOIN tblICUnitMeasure SUOM ON SUOM.intUnitMeasureId = SItemUOM.intUnitMeasureId
	LEFT JOIN (
		SELECT SP.intAllocationDetailId
			,SUM(SP.dblQuantity) dblPShippedQuantity
			,SUM(SP.dblDeliveredQuantity) dblSShippedQuantity
		FROM tblLGLoadDetail SP
		JOIN tblLGLoad L ON L.intLoadId = SP.intLoadId
			AND L.intPurchaseSale = 3
			AND L.intShipmentType = 1
			AND ISNULL(L.ysnCancelled, 0) = 0
		GROUP BY SP.intAllocationDetailId
		) LD ON AD.intAllocationDetailId = LD.intAllocationDetailId
	LEFT JOIN (
		SELECT PL.intAllocationDetailId
			,SUM(PL.dblSalePickedQty) dblSalePickedQty
		FROM tblLGPickLotDetail PL
		GROUP BY PL.intAllocationDetailId
		) PLS ON AD.intAllocationDetailId = PLS.intAllocationDetailId
	LEFT JOIN (
		SELECT PL.intAllocationDetailId
			,SUM(PL.dblLotPickedQty) dblLotPickedQty
		FROM tblLGPickLotDetail PL
		GROUP BY PL.intAllocationDetailId
		) PL ON AD.intAllocationDetailId = PL.intAllocationDetailId
	LEFT JOIN tblSMCompanyLocation PCL ON PCL.intCompanyLocationId = CDP.intCompanyLocationId
	LEFT JOIN tblSMCompanyLocation SCL ON SCL.intCompanyLocationId = CDS.intCompanyLocationId
	LEFT JOIN tblCTPosition PP ON PP.intPositionId = CHP.intPositionId
	LEFT JOIN tblCTPosition PS ON PS.intPositionId = CHS.intPositionId
	LEFT JOIN tblICCommodityAttribute CAP ON CAP.intCommodityAttributeId = ITP.intOriginId
	LEFT JOIN tblSMCountry CP ON CP.intCountryID = CAP.intCountryID
	LEFT JOIN tblICCommodityAttribute CAS ON CAS.intCommodityAttributeId = ITS.intOriginId
	LEFT JOIN tblSMCountry CS ON CS.intCountryID = CAS.intCountryID
	LEFT JOIN tblSMCity PLP ON PLP.intCityId = CDP.intLoadingPortId
	LEFT JOIN tblSMCity PDP ON PDP.intCityId = CDP.intDestinationPortId
	LEFT JOIN tblSMCity PDC ON PDC.intCityId = CDP.intDestinationCityId
	LEFT JOIN tblSMCity SLP ON SLP.intCityId = CDS.intLoadingPortId
	LEFT JOIN tblSMCity SDP ON SDP.intCityId = CDS.intDestinationPortId
	LEFT JOIN tblSMCity SDC ON SDC.intCityId = CDS.intDestinationCityId
	LEFT JOIN tblEMEntity ESLP ON ESLP.intEntityId = CDP.intShippingLineId
	LEFT JOIN tblEMEntity ESLS ON ESLS.intEntityId = CDS.intShippingLineId
	LEFT JOIN tblCTBook BO ON BO.intBookId = AH.intBookId
	LEFT JOIN tblCTSubBook SB ON SB.intSubBookId = AH.intSubBookId
	OUTER APPLY (SELECT TOP 1 ysnUnapproved = CAST(1 AS BIT)
					FROM tblSMTransaction TRN INNER JOIN tblSMScreen SCR 
					ON TRN.intScreenId = SCR.intScreenId AND SCR.strNamespace IN ('ContractManagement.view.Contract','ContractManagement.view.Amendments' )
					WHERE intRecordId IN (CDP.intContractHeaderId, CDS.intContractHeaderId)
					AND strApprovalStatus NOT IN ('Approved', 'No Need for Approval', 'Approved with Modifications', '')
				) APRV
	WHERE ((AD.dblPAllocatedQty - IsNull(LD.dblPShippedQuantity, 0) + IsNull(PL.dblLotPickedQty, 0)) > 0)
		AND ((AD.dblSAllocatedQty - IsNull(LD.dblSShippedQuantity, 0) - IsNull(PLS.dblSalePickedQty, 0)) > 0)
		AND ISNULL(APRV.ysnUnapproved, 0) = 0

	UNION ALL

	SELECT AH.[strAllocationNumber]
		,AD.strAllocationDetailRefNo
		,AH.intAllocationHeaderId
		,AD.intAllocationDetailId
		,AD.intPContractDetailId
		,intPurchaseContractHeaderId = CHP.intContractHeaderId
		,strPurchaseContractNumber = CHP.strContractNumber
		,intPContractSeq = CDP.intContractSeq
		,intPEntityId = CHP.intEntityId
		,intPCompanyLocationId = CDP.intCompanyLocationId
		,strPCompanyLocation = PCL.strLocationName
		,intPItemId = CDP.intItemId
		,strPContractNumber = CAST(CHP.strContractNumber AS VARCHAR(100)) + '/' + CAST(CDP.intContractSeq AS VARCHAR(100))
		,AD.dblPAllocatedQty
		,dblPUnAllocatedQty = AD.dblPAllocatedQty - IsNull(LD.dblPShippedQuantity, 0) - IsNull(PL.dblLotPickedQty, 0)
		,AD.intPUnitMeasureId
		,strPUnitMeasure = UP.strUnitMeasure
		,strVendor = ENP.strName
		,strVendorContract = CHP.strCustomerContract
		,strPItemDescription = ITP.strDescription
		,dtmPStartDate = CDP.dtmStartDate
		,dtmPEndDate = CDP.dtmEndDate
		,strPPosition = PP.strPosition
		,strPOrigin = CP.strCountry
		,intPCommodityId = CHP.intCommodityId
		,intPItemUOMId = CDP.intItemUOMId
		,intPOriginId = CP.intCountryID
		,strPUnitType = UP.strUnitType

		,AD.intSContractDetailId
		,intSalesContractHeaderId = CHS.intContractHeaderId
		,strSalesContractNumber = CHS.strContractNumber
		,intSContractSeq = CDS.intContractSeq
		,intSEntityId = CHS.intEntityId
		,intSCompanyLocationId = CDS.intCompanyLocationId
		,strSCompanyLocation = SCL.strLocationName
		,intSItemId = CDS.intItemId
		,strSContractNumber = CAST(CHS.strContractNumber AS VARCHAR(100)) + '/' + CAST(CDS.intContractSeq AS VARCHAR(100))
		,AD.dblSAllocatedQty
		,dblSUnAllocatedQty = AD.dblSAllocatedQty - IsNull(LD.dblSShippedQuantity, 0) - IsNull(PLS.dblSalePickedQty, 0)
		,AD.intSUnitMeasureId
		,strSUnitMeasure = US.strUnitMeasure
		,strCustomer = ENS.strName
		,strCustomerContract = CHS.strCustomerContract
		,strSItemDescription = ITS.strDescription
		,dtmSStartDate = CDS.dtmStartDate
		,dtmSEndDate = CDS.dtmEndDate
		,strSPosition = PS.strPosition
		,strSOrigin = CS.strCountry
		,intSCommodityId = CHS.intCommodityId
		,intSItemUOMId = CDS.intItemUOMId
		,intSOriginId = CS.intCountryID
		,strSUnitType = US.strUnitType

		,strPItemType = ITP.strType
		,strSItemType = ITP.strType
		,strPriceCurrency = SCurrency.strCurrency
		,dblSalesPrice = CDS.dblCashPrice
		,strPriceUOM = SUOM.strUnitMeasure
		,intPriceUnitMeasureId = SItemUOM.intUnitMeasureId
		,SCurrency.ysnSubCurrency
		,dblAvailableAllocationQty = ISNULL(AD.dblPAllocatedQty, 0) 
			- (CASE WHEN ((CASE WHEN ISNULL(LDS.dblPShippedQuantity, 0) > ISNULL(LD.dblPShippedQuantity,0) 
						THEN ISNULL(LDS.dblPShippedQuantity, 0) 
						ELSE ISNULL(LD.dblPShippedQuantity, 0) END <=0)) THEN 0 
					ELSE 
						CASE WHEN (ISNULL(LDS.dblPShippedQuantity, 0) > ISNULL(LD.dblPShippedQuantity,0))
						THEN ISNULL(LDS.dblPShippedQuantity, 0) 
						ELSE ISNULL(LD.dblPShippedQuantity, 0) 
						END 
				END)
		,dblQtyConversionFactor = dbo.fnLGGetItemUnitConversion(CDP.intItemId,CDP.intItemUOMId,CDS.intUnitMeasureId)
		,dblAvailableContractQty = ISNULL(CDP.dblQuantity,0) 
			- (CASE WHEN ((CASE WHEN ISNULL(CDP.dblScheduleQty, 0) > ISNULL(CDP.dblShippingInstructionQty,0) 
						THEN ISNULL(CDP.dblScheduleQty, 0) 
						ELSE ISNULL(CDP.dblShippingInstructionQty, 0) END <=0)) THEN 0 
					ELSE 
						CASE WHEN (ISNULL(CDP.dblScheduleQty, 0) > ISNULL(CDP.dblShippingInstructionQty,0))
						THEN ISNULL(CDP.dblScheduleQty, 0) 
						ELSE ISNULL(CDP.dblShippingInstructionQty, 0) 
						END 
				END)
		,AH.intBookId
		,BO.strBook
		,AH.intSubBookId
		,SB.strSubBook
		,strOriginPort = ISNULL(SLP.strCity, PLP.strCity)
		,strDestinationPort = ISNULL(SDP.strCity, PDP.strCity)
		,strDestinationCity = ISNULL(SDC.strCity, PDC.strCity)
		,intShippingLineEntityId = ISNULL(CDP.intShippingLineId, CDS.intShippingLineId)
		,strShippingLine = ISNULL(ESLP.strName, ESLS.strName)
		,intShipmentType = 2
	FROM tblLGAllocationDetail AD
	JOIN tblLGAllocationHeader AH ON AH.intAllocationHeaderId = AD.intAllocationHeaderId
	JOIN tblCTContractDetail CDP ON CDP.intContractDetailId = AD.intPContractDetailId
	JOIN tblCTContractHeader CHP ON CHP.intContractHeaderId = CDP.intContractHeaderId
	JOIN tblCTContractDetail CDS ON CDS.intContractDetailId = AD.intSContractDetailId
	JOIN tblCTContractHeader CHS ON CHS.intContractHeaderId = CDS.intContractHeaderId
	JOIN tblEMEntity ENP ON ENP.intEntityId = CHP.intEntityId
	JOIN tblEMEntity ENS ON ENS.intEntityId = CHS.intEntityId
	JOIN tblICUnitMeasure UP ON UP.intUnitMeasureId = AD.intPUnitMeasureId
	JOIN tblICUnitMeasure US ON US.intUnitMeasureId = AD.intSUnitMeasureId
	JOIN tblICItem ITP ON ITP.intItemId = CDP.intItemId
	JOIN tblICItem ITS ON ITS.intItemId = CDS.intItemId
	JOIN tblSMCurrency SCurrency ON SCurrency.intCurrencyID = CDS.intCurrencyId
	JOIN tblICItemUOM SItemUOM ON SItemUOM.intItemUOMId = CDS.intPriceItemUOMId
	JOIN tblICUnitMeasure SUOM ON SUOM.intUnitMeasureId = SItemUOM.intUnitMeasureId
	LEFT JOIN (
		SELECT SP.intAllocationDetailId
			,SUM(SP.dblQuantity) dblPShippedQuantity
			,SUM(SP.dblDeliveredQuantity) dblSShippedQuantity
		FROM tblLGLoadDetail SP
		JOIN tblLGLoad L ON L.intLoadId = SP.intLoadId
			AND L.intPurchaseSale = 3
			AND L.intShipmentType = 2
			AND ISNULL(L.ysnCancelled, 0) = 0
		GROUP BY SP.intAllocationDetailId
		) LD ON AD.intAllocationDetailId = LD.intAllocationDetailId
	LEFT JOIN (
		SELECT SP.intAllocationDetailId
			,SUM(SP.dblQuantity) dblPShippedQuantity
			,SUM(SP.dblDeliveredQuantity) dblSShippedQuantity
		FROM tblLGLoadDetail SP
		JOIN tblLGLoad L ON L.intLoadId = SP.intLoadId
			AND L.intPurchaseSale = 3
			AND L.intShipmentType = 1
			AND ISNULL(L.ysnCancelled, 0) = 0
		GROUP BY SP.intAllocationDetailId
		) LDS ON AD.intAllocationDetailId = LDS.intAllocationDetailId
	LEFT JOIN (
		SELECT PL.intAllocationDetailId
			,SUM(PL.dblSalePickedQty) dblSalePickedQty
		FROM tblLGPickLotDetail PL
		GROUP BY PL.intAllocationDetailId
		) PLS ON AD.intAllocationDetailId = PLS.intAllocationDetailId
	LEFT JOIN (
		SELECT PL.intAllocationDetailId
			,SUM(PL.dblLotPickedQty) dblLotPickedQty
		FROM tblLGPickLotDetail PL
		GROUP BY PL.intAllocationDetailId
		) PL ON AD.intAllocationDetailId = PL.intAllocationDetailId
	LEFT JOIN tblSMCompanyLocation PCL ON PCL.intCompanyLocationId = CDP.intCompanyLocationId
	LEFT JOIN tblSMCompanyLocation SCL ON SCL.intCompanyLocationId = CDS.intCompanyLocationId
	LEFT JOIN tblCTPosition PP ON PP.intPositionId = CHP.intPositionId
	LEFT JOIN tblCTPosition PS ON PS.intPositionId = CHS.intPositionId
	LEFT JOIN tblICCommodityAttribute CAP ON CAP.intCommodityAttributeId = ITP.intOriginId
	LEFT JOIN tblSMCountry CP ON CP.intCountryID = CAP.intCountryID
	LEFT JOIN tblICCommodityAttribute CAS ON CAS.intCommodityAttributeId = ITS.intOriginId
	LEFT JOIN tblSMCountry CS ON CS.intCountryID = CAS.intCountryID
	LEFT JOIN tblSMCity PLP ON PLP.intCityId = CDP.intLoadingPortId
	LEFT JOIN tblSMCity PDP ON PDP.intCityId = CDP.intDestinationPortId
	LEFT JOIN tblSMCity PDC ON PDC.intCityId = CDP.intDestinationCityId
	LEFT JOIN tblSMCity SLP ON SLP.intCityId = CDS.intLoadingPortId
	LEFT JOIN tblSMCity SDP ON SDP.intCityId = CDS.intDestinationPortId
	LEFT JOIN tblSMCity SDC ON SDC.intCityId = CDS.intDestinationCityId
	LEFT JOIN tblEMEntity ESLP ON ESLP.intEntityId = CDP.intShippingLineId
	LEFT JOIN tblEMEntity ESLS ON ESLS.intEntityId = CDS.intShippingLineId
	LEFT JOIN tblCTBook BO ON BO.intBookId = AH.intBookId
	LEFT JOIN tblCTSubBook SB ON SB.intSubBookId = AH.intSubBookId
	OUTER APPLY (SELECT TOP 1 ysnUnapproved = CAST(1 AS BIT)
					FROM tblSMTransaction TRN INNER JOIN tblSMScreen SCR 
					ON TRN.intScreenId = SCR.intScreenId AND SCR.strNamespace IN ('ContractManagement.view.Contract','ContractManagement.view.Amendments' )
					WHERE intRecordId IN (CDP.intContractHeaderId, CDS.intContractHeaderId)
					AND strApprovalStatus NOT IN ('Approved', 'No Need for Approval', 'Approved with Modifications', '')
				) APRV
	WHERE ((AD.dblPAllocatedQty - IsNull(LD.dblPShippedQuantity, 0) + IsNull(PL.dblLotPickedQty, 0)) > 0)
		AND ((AD.dblSAllocatedQty - IsNull(LD.dblSShippedQuantity, 0) - IsNull(PLS.dblSalePickedQty, 0)) > 0)
		AND ISNULL(APRV.ysnUnapproved, 0) = 0
	  ) tbl 
	WHERE dblAvailableAllocationQty > 0
