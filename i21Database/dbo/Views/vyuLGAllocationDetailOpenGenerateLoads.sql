CREATE VIEW vyuLGGenerateLoadOpenAllocationDetails
AS
	SELECT	AH.intReferenceNumber,
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
			AD.intPUnitMeasureId,
			ENP.strName AS strVendor,
			IsNull(CDP.dblBalance, 0) - IsNull(CDP.dblScheduleQty, 0)		AS dblPUnLoadedQuantity,

			AD.intSContractDetailId,
			CHS.intContractNumber as intSContractNumber,
			CDS.intContractSeq as intSContractSeq,
			CHS.intEntityId AS intSEntityId,
			CDS.intCompanyLocationId AS intSCompanyLocationId,
			CDS.intItemId AS intSItemId,
			CAST (CHS.intContractNumber AS VARCHAR(100)) +  '/' + CAST(CDS.intContractSeq AS VARCHAR(100)) AS strSContractNumber, 
			AD.dblSAllocatedQty,
			AD.intSUnitMeasureId,
			ENS.strName AS strCustomer,
			IsNull(CDS.dblBalance, 0) - IsNull(CDS.dblScheduleQty, 0)		AS dblSUnLoadedQuantity

	FROM 	tblLGAllocationDetail AD
	JOIN	tblLGAllocationHeader	AH	ON AH.intAllocationHeaderId = AD.intAllocationHeaderId
	JOIN	tblCTContractDetail 	CDP	ON CDP.intContractDetailId = AD.intPContractDetailId
	JOIN	tblCTContractHeader		CHP	ON	CHP.intContractHeaderId		=	CDP.intContractHeaderId
	JOIN	tblCTContractDetail 	CDS	ON CDS.intContractDetailId = AD.intSContractDetailId
	JOIN	tblCTContractHeader		CHS	ON	CHS.intContractHeaderId		=	CDS.intContractHeaderId
	JOIN	tblEntity				ENP	ON	ENP.intEntityId				=	CHP.intEntityId
	JOIN	tblEntity				ENS	ON	ENS.intEntityId				=	CHS.intEntityId
	WHERE	AD.intAllocationDetailId NOT IN (SELECT intAllocationDetailId FROM tblLGGenerateLoad WHERE intAllocationDetailId IS NOT NULL) 
	AND 
	AD.intPUnitMeasureId = AD.intSUnitMeasureId