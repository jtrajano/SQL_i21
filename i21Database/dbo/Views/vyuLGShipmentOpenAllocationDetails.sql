CREATE VIEW vyuLGShipmentOpenAllocationDetails
AS
	SELECT	AH.intRefernceNumber,
			AH.intAllocationHeaderId,

			AD.intAllocationDetailId,

			AD.intPContractDetailId,
			CHP.intContractNumber as intPContractNumber,
			CDP.intContractSeq as intPContractSeq,
			CHP.intEntityId AS intPEntityId,
			CDP.intCompanyLocationId AS intPCompanyLocationId,
			CDP.intItemId AS intPItemId,
			CAST (CHP.intContractNumber AS VARCHAR(100)) +  '/' + CAST(CDP.intContractSeq AS VARCHAR(100)) AS strPContractNumber, 
			AD.dblPAllocatedQty,
			AD.dblPAllocatedQty - IsNull((SELECT SUM (SP.dblPAllocatedQty) from tblLGShipmentPurchaseSalesContract SP Group By SP.intAllocationDetailId Having AD.intAllocationDetailId = SP.intAllocationDetailId), 0) AS dblPUnAllocatedQty,
			AD.intPUnitMeasureId,
			UP.strUnitMeasure as strPUnitMeasure,
			ENP.strName AS strVendor,

			AD.intSContractDetailId,
			CHS.intContractNumber as intSContractNumber,
			CDS.intContractSeq as intSContractSeq,
			CHS.intEntityId AS intSEntityId,
			CDS.intCompanyLocationId AS intSCompanyLocationId,
			CDS.intItemId AS intSItemId,
			CAST (CHS.intContractNumber AS VARCHAR(100)) +  '/' + CAST(CDS.intContractSeq AS VARCHAR(100)) AS strSContractNumber, 
			AD.dblSAllocatedQty,
			AD.dblSAllocatedQty - IsNull((SELECT SUM (SP.dblSAllocatedQty) from tblLGShipmentPurchaseSalesContract SP Group By SP.intAllocationDetailId Having AD.intAllocationDetailId = SP.intAllocationDetailId), 0) AS dblSUnAllocatedQty,
			AD.intSUnitMeasureId,
			US.strUnitMeasure as strSUnitMeasure,
			ENS.strName AS strCustomer

	FROM 	tblLGAllocationDetail AD
	JOIN	tblLGAllocationHeader	AH	ON AH.intAllocationHeaderId = AD.intAllocationHeaderId
	JOIN	tblCTContractDetail 	CDP	ON CDP.intContractDetailId = AD.intPContractDetailId
	JOIN	tblCTContractHeader		CHP	ON	CHP.intContractHeaderId		=	CDP.intContractHeaderId
	JOIN	tblCTContractDetail 	CDS	ON CDS.intContractDetailId = AD.intSContractDetailId
	JOIN	tblCTContractHeader		CHS	ON	CHS.intContractHeaderId		=	CDS.intContractHeaderId
	JOIN	tblEntity				ENP	ON	ENP.intEntityId				=	CHP.intEntityId
	JOIN	tblEntity				ENS	ON	ENS.intEntityId				=	CHS.intEntityId
	JOIN	tblICUnitMeasure		UP	ON	UP.intUnitMeasureId				=	AD.intPUnitMeasureId
	JOIN	tblICUnitMeasure		US	ON	US.intUnitMeasureId				=	AD.intSUnitMeasureId
	WHERE	(AD.dblPAllocatedQty - IsNull((SELECT SUM (SP.dblPAllocatedQty) from tblLGShipmentPurchaseSalesContract SP Group By SP.intAllocationDetailId Having AD.intAllocationDetailId = SP.intAllocationDetailId), 0) > 0 AND
			AD.dblSAllocatedQty - IsNull((SELECT SUM (SP.dblSAllocatedQty) from tblLGShipmentPurchaseSalesContract SP Group By SP.intAllocationDetailId Having AD.intAllocationDetailId = SP.intAllocationDetailId), 0) > 0
			)
			