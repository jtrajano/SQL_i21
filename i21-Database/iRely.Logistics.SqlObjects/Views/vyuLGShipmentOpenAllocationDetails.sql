CREATE VIEW vyuLGShipmentOpenAllocationDetails
AS
SELECT *
FROM (
	SELECT AH.[strAllocationNumber]
		,AH.intAllocationHeaderId
		,AD.intAllocationDetailId
		,AD.intPContractDetailId
		,CHP.strContractNumber AS strPurchaseContractNumber
		,CDP.intContractSeq AS intPContractSeq
		,CHP.intEntityId AS intPEntityId
		,CDP.intCompanyLocationId AS intPCompanyLocationId
		,PCL.strLocationName AS strPCompanyLocation
		,CDP.intItemId AS intPItemId
		,CAST(CHP.strContractNumber AS VARCHAR(100)) + '/' + CAST(CDP.intContractSeq AS VARCHAR(100)) AS strPContractNumber
		,AD.dblPAllocatedQty
		,AD.dblPAllocatedQty - IsNull(LD.dblPShippedQuantity, 0) - IsNull(PL.dblLotPickedQty, 0) AS dblPUnAllocatedQty
		,AD.intPUnitMeasureId
		,UP.strUnitMeasure AS strPUnitMeasure
		,ENP.strName AS strVendor
		,ITP.strDescription AS strPItemDescription
		,CDP.dtmStartDate AS dtmPStartDate
		,CDP.dtmEndDate AS dtmPEndDate
		,PP.strPosition AS strPPosition
		,CP.strCountry AS strPOrigin
		,CHP.intCommodityId AS intPCommodityId
		,CDP.intItemUOMId AS intPItemUOMId
		,CP.intCountryID AS intPOriginId
		,UP.strUnitType AS strPUnitType
		,AD.intSContractDetailId
		,CHS.strContractNumber AS strSalesContractNumber
		,CDS.intContractSeq AS intSContractSeq
		,CHS.intEntityId AS intSEntityId
		,CDS.intCompanyLocationId AS intSCompanyLocationId
		,SCL.strLocationName AS strSCompanyLocation
		,CDS.intItemId AS intSItemId
		,CAST(CHS.strContractNumber AS VARCHAR(100)) + '/' + CAST(CDS.intContractSeq AS VARCHAR(100)) AS strSContractNumber
		,AD.dblSAllocatedQty
		,AD.dblSAllocatedQty - IsNull(LD.dblSShippedQuantity, 0) - IsNull(PLS.dblSalePickedQty, 0) AS dblSUnAllocatedQty
		,AD.intSUnitMeasureId
		,US.strUnitMeasure AS strSUnitMeasure
		,ENS.strName AS strCustomer
		,ITS.strDescription AS strSItemDescription
		,CDS.dtmStartDate AS dtmSStartDate
		,CDS.dtmEndDate AS dtmSEndDate
		,PS.strPosition AS strSPosition
		,CS.strCountry AS strSOrigin
		,CHS.intCommodityId AS intSCommodityId
		,CDS.intItemUOMId AS intSItemUOMId
		,CS.intCountryID AS intSOriginId
		,US.strUnitType AS strSUnitType
		,ITP.strType AS strPItemType
		,ITP.strType AS strSItemType
		,strPriceCurrency = SCurrency.strCurrency
		,dblSalesPrice = CDS.dblCashPrice
		,strPriceUOM = SUOM.strUnitMeasure
		,intPriceUnitMeasureId = SItemUOM.intUnitMeasureId
		,SCurrency.ysnSubCurrency
		,(ISNULL(AD.dblPAllocatedQty, 0) - ISNULL(LD.dblPShippedQuantity, 0)) AS dblAvailableAllocationQty
		,dbo.fnLGGetItemUnitConversion(CDP.intItemId,CDP.intItemUOMId,CDS.intUnitMeasureId) dblQtyConversionFactor
		,(ISNULL(CDP.dblQuantity,0)-ISNULL(CDP.dblScheduleQty,0)) dblAvailableContractQty
		,AH.intBookId
		,BO.strBook
		,AH.intSubBookId
		,SB.strSubBook
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
	LEFT JOIN tblCTBook BO ON BO.intBookId = AH.intBookId
	LEFT JOIN tblCTSubBook SB ON SB.intSubBookId = AH.intSubBookId
	WHERE ((AD.dblPAllocatedQty - IsNull(LD.dblPShippedQuantity, 0) + IsNull(PL.dblLotPickedQty, 0)) > 0)
		AND ((AD.dblSAllocatedQty - IsNull(LD.dblSShippedQuantity, 0) - IsNull(PLS.dblSalePickedQty, 0)) > 0)
	  ) tbl 
	WHERE dblAvailableAllocationQty > 0
