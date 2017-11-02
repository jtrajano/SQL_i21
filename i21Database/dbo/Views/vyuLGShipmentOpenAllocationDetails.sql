CREATE VIEW vyuLGShipmentOpenAllocationDetails
AS
		SELECT	AH.[strAllocationNumber],
			AH.intAllocationHeaderId,
			AD.intAllocationDetailId,
			AD.intPContractDetailId,
			CHP.strContractNumber as strPurchaseContractNumber,
			CDP.intContractSeq as intPContractSeq,
			CHP.intEntityId AS intPEntityId,
			CDP.intCompanyLocationId AS intPCompanyLocationId,
			PCL.strLocationName AS strPCompanyLocation,
			CDP.intItemId AS intPItemId,
			CAST (CHP.strContractNumber AS VARCHAR(100)) +  '/' + CAST(CDP.intContractSeq AS VARCHAR(100)) AS strPContractNumber, 
			AD.dblPAllocatedQty,
			AD.dblPAllocatedQty - IsNull(LD.dblPShippedQuantity, 0) - IsNull(PL.dblLotPickedQty, 0) AS dblPUnAllocatedQty,
			AD.intPUnitMeasureId,
			UP.strUnitMeasure as strPUnitMeasure,
			ENP.strName AS strVendor,
			ITP.strDescription as strPItemDescription,
			CDP.dtmStartDate as dtmPStartDate,
			CDP.dtmEndDate as dtmPEndDate,
			PP.strPosition as strPPosition,	
			CP.strCountry as strPOrigin,
			CHP.intCommodityId AS intPCommodityId,
			CDP.intItemUOMId AS intPItemUOMId,
			ITP.intOriginId as intPOriginId,
			UP.strUnitType as strPUnitType,

			AD.intSContractDetailId,
			CHS.strContractNumber as strSalesContractNumber,
			CDS.intContractSeq as intSContractSeq,
			CHS.intEntityId AS intSEntityId,
			CDS.intCompanyLocationId AS intSCompanyLocationId,
			SCL.strLocationName AS strSCompanyLocation,
			CDS.intItemId AS intSItemId,
			CAST (CHS.strContractNumber AS VARCHAR(100)) +  '/' + CAST(CDS.intContractSeq AS VARCHAR(100)) AS strSContractNumber, 
			AD.dblSAllocatedQty,
			AD.dblSAllocatedQty - IsNull(LD.dblSShippedQuantity, 0) - IsNull(PLS.dblSalePickedQty, 0)  AS dblSUnAllocatedQty,
			AD.intSUnitMeasureId,
			US.strUnitMeasure as strSUnitMeasure,
			ENS.strName AS strCustomer,
			ITS.strDescription as strSItemDescription,
			CDS.dtmStartDate as dtmSStartDate,
			CDS.dtmEndDate as dtmSEndDate,
			PS.strPosition as strSPosition,
			CS.strCountry as strSOrigin,
			CHS.intCommodityId AS intSCommodityId,
			CDS.intItemUOMId AS intSItemUOMId,
			ITS.intOriginId as intSOriginId,
			US.strUnitType as strSUnitType,
			ITP.strType AS strPItemType,
			ITP.strType AS strSItemType,
			strPriceCurrency = SCurrency.strCurrency,
			dblSalesPrice = CDS.dblCashPrice,
			strPriceUOM = SUOM.strUnitMeasure,
			intPriceUnitMeasureId = SItemUOM.intUnitMeasureId,
			SCurrency.ysnSubCurrency

	FROM 	tblLGAllocationDetail AD
	JOIN	tblLGAllocationHeader	AH	ON AH.intAllocationHeaderId = AD.intAllocationHeaderId
	LEFT JOIN (SELECT SP.intAllocationDetailId, SUM (SP.dblQuantity) dblPShippedQuantity, SUM (SP.dblDeliveredQuantity) dblSShippedQuantity
					FROM tblLGLoadDetail SP 
					JOIN tblLGLoad L ON L.intLoadId = SP.intLoadId AND L.intPurchaseSale=3 AND L.ysnPosted=1
				GROUP BY SP.intAllocationDetailId) 
				LD ON AD.intAllocationDetailId = LD.intAllocationDetailId AND AD.intPContractDetailId = AD.intSContractDetailId
	LEFT JOIN (SELECT PL.intAllocationDetailId, SUM (PL.dblSalePickedQty) dblSalePickedQty 
				FROM tblLGPickLotDetail PL GROUP BY PL.intAllocationDetailId
			) PLS ON AD.intAllocationDetailId = PLS.intAllocationDetailId
	LEFT JOIN (SELECT PL.intAllocationDetailId, SUM (PL.dblLotPickedQty) dblLotPickedQty 
				FROM tblLGPickLotDetail PL GROUP BY PL.intAllocationDetailId
			) PL ON AD.intAllocationDetailId = PL.intAllocationDetailId
	JOIN	tblCTContractDetail 	CDP	ON CDP.intContractDetailId = AD.intPContractDetailId
	JOIN	tblCTContractHeader		CHP	ON	CHP.intContractHeaderId		=	CDP.intContractHeaderId
	JOIN	tblCTContractDetail 	CDS	ON CDS.intContractDetailId = AD.intSContractDetailId
	JOIN	tblCTContractHeader		CHS	ON	CHS.intContractHeaderId		=	CDS.intContractHeaderId
	JOIN	tblEMEntity				ENP	ON	ENP.intEntityId				=	CHP.intEntityId
	JOIN	tblEMEntity				ENS	ON	ENS.intEntityId				=	CHS.intEntityId
	JOIN	tblICUnitMeasure		UP	ON	UP.intUnitMeasureId				=	AD.intPUnitMeasureId
	JOIN	tblICUnitMeasure		US	ON	US.intUnitMeasureId				=	AD.intSUnitMeasureId
	JOIN	tblICItem				ITP	ON	ITP.intItemId				= CDP.intItemId
	JOIN	tblICItem				ITS	ON	ITS.intItemId				= CDS.intItemId
	JOIN	tblSMCurrency			SCurrency ON SCurrency.intCurrencyID = CDS.intCurrencyId
	JOIN	tblICItemUOM			SItemUOM ON SItemUOM.intItemUOMId = CDS.intPriceItemUOMId
	JOIN	tblICUnitMeasure		SUOM ON SUOM.intUnitMeasureId = SItemUOM.intUnitMeasureId
	LEFT JOIN tblSMCompanyLocation	PCL ON PCL.intCompanyLocationId = CDP.intCompanyLocationId
	LEFT JOIN tblSMCompanyLocation	SCL ON SCL.intCompanyLocationId = CDS.intCompanyLocationId
	LEFT JOIN	tblCTPosition			PP	ON	PP.intPositionId			= CHP.intPositionId
	LEFT JOIN	tblCTPosition			PS	ON	PS.intPositionId			= CHS.intPositionId
	LEFT JOIN	tblSMCountry			CP	ON	CP.intCountryID				= ITP.intOriginId
	LEFT JOIN	tblSMCountry			CS	ON	CS.intCountryID				= ITS.intOriginId
	WHERE ((AD.dblPAllocatedQty - IsNull(LD.dblPShippedQuantity, 0) + IsNull(PL.dblLotPickedQty, 0)) > 0)
	  AND ((AD.dblSAllocatedQty - IsNull(LD.dblSShippedQuantity, 0) - IsNull(PLS.dblSalePickedQty, 0)) > 0)
	  AND AD.intAllocationDetailId NOT IN (SELECT ISNULL(intAllocationDetailId, 0) FROM tblLGLoadDetail)