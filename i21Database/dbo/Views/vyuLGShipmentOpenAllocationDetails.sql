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
			AD.dblPAllocatedQty - IsNull((SELECT SUM (SP.dblQuantity) from tblLGLoadDetail SP
										  JOIN tblLGLoad L ON L.intLoadId = SP.intLoadId
											  AND ISNULL(L.ysnCancelled, 0) = 0
										  GROUP BY SP.intAllocationDetailId Having AD.intAllocationDetailId = SP.intAllocationDetailId), 0) 
								- IsNull((SELECT SUM (PL.dblLotPickedQty) from tblLGPickLotDetail PL Group By PL.intAllocationDetailId Having AD.intAllocationDetailId = PL.intAllocationDetailId), 0) AS dblPUnAllocatedQty,
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
			AD.dblSAllocatedQty - IsNull((SELECT SUM (SP.dblQuantity) from tblLGLoadDetail SP
										  JOIN tblLGLoad L ON L.intLoadId = SP.intLoadId
											  AND ISNULL(L.ysnCancelled, 0) = 0
										  GROUP BY SP.intAllocationDetailId Having AD.intAllocationDetailId = SP.intAllocationDetailId), 0) 
								- IsNull((SELECT SUM (PL.dblSalePickedQty) from tblLGPickLotDetail PL Group By PL.intAllocationDetailId Having AD.intAllocationDetailId = PL.intAllocationDetailId), 0)  AS dblSUnAllocatedQty,
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
			ITP.strType AS strSItemType

	FROM 	tblLGAllocationDetail AD
	JOIN	tblLGAllocationHeader	AH	ON AH.intAllocationHeaderId = AD.intAllocationHeaderId
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
	LEFT JOIN tblSMCompanyLocation	PCL ON PCL.intCompanyLocationId = CDP.intCompanyLocationId
	LEFT JOIN tblSMCompanyLocation	SCL ON SCL.intCompanyLocationId = CDS.intCompanyLocationId
	LEFT JOIN	tblCTPosition			PP	ON	PP.intPositionId			= CHP.intPositionId
	LEFT JOIN	tblCTPosition			PS	ON	PS.intPositionId			= CHS.intPositionId
	LEFT JOIN	tblSMCountry			CP	ON	CP.intCountryID				= ITP.intOriginId
	LEFT JOIN	tblSMCountry			CS	ON	CS.intCountryID				= ITS.intOriginId
	WHERE (
			AD.dblPAllocatedQty - IsNull((
					SELECT SUM(SP.dblQuantity)
					FROM tblLGLoadDetail SP
					JOIN tblLGLoad L ON L.intLoadId = SP.intLoadId
						AND ISNULL(L.ysnCancelled, 0) = 0
					GROUP BY SP.intAllocationDetailId
					HAVING AD.intAllocationDetailId = SP.intAllocationDetailId
					), 0) - IsNull((
					SELECT SUM(PL.dblLotPickedQty)
					FROM tblLGPickLotDetail PL
					GROUP BY PL.intAllocationDetailId
					HAVING AD.intAllocationDetailId = PL.intAllocationDetailId
					), 0) > 0
			AND AD.dblSAllocatedQty - IsNull((
					SELECT SUM(SP.dblQuantity)
					FROM tblLGLoadDetail SP
					JOIN tblLGLoad L ON L.intLoadId = SP.intLoadId
						AND ISNULL(L.ysnCancelled, 0) = 0
					GROUP BY SP.intAllocationDetailId
					HAVING AD.intAllocationDetailId = SP.intAllocationDetailId
					), 0) - IsNull((
					SELECT SUM(PL.dblSalePickedQty)
					FROM tblLGPickLotDetail PL
					GROUP BY PL.intAllocationDetailId
					HAVING AD.intAllocationDetailId = PL.intAllocationDetailId
					), 0) > 0
			)