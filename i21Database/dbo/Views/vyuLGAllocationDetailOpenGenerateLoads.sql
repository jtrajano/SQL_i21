CREATE VIEW vyuLGGenerateLoadOpenAllocationDetails
AS
	SELECT	AH.intReferenceNumber,
			AH.intAllocationHeaderId,

			AD.intAllocationDetailId,

			AD.intPContractDetailId,
			CHP.strContractNumber as strPurchaseContractNumber,
			CDP.intContractSeq as intPContractSeq,
			CHP.intEntityId AS intPEntityId,
			CDP.intCompanyLocationId AS intPCompanyLocationId,
			CDP.intItemId AS intPItemId,
			CAST (CHP.strContractNumber AS VARCHAR(100)) +  '/' + CAST(CDP.intContractSeq AS VARCHAR(100)) AS strPContractNumber, 
			AD.dblPAllocatedQty,
			AD.intPUnitMeasureId,
			ENP.strName AS strVendor,
			IsNull(CDP.dblBalance, 0) - IsNull(CDP.dblScheduleQty, 0)		AS dblPUnLoadedQuantity,
			ENP.intDefaultLocationId as intPDefaultLocationId,

			AD.intSContractDetailId,
			CHS.strContractNumber as intSalesContractNumber,
			CDS.intContractSeq as intSContractSeq,
			CHS.intEntityId AS intSEntityId,
			CDS.intCompanyLocationId AS intSCompanyLocationId,
			CDS.intItemId AS intSItemId,
			CAST (CHS.strContractNumber AS VARCHAR(100)) +  '/' + CAST(CDS.intContractSeq AS VARCHAR(100)) AS strSContractNumber, 
			AD.dblSAllocatedQty,
			AD.intSUnitMeasureId,
			ENS.strName AS strCustomer,
			IsNull(CDS.dblBalance, 0) - IsNull(CDS.dblScheduleQty, 0)		AS dblSUnLoadedQuantity,
			IsNull(AD.dblPAllocatedQty, 0) - IsNull(GL.dblQuantity, 0)		AS dblGenerateLoadOpenQuantity,
			ENS.intDefaultLocationId as intSDefaultLocationId

	FROM 	tblLGAllocationDetail AD
	LEFT JOIN	tblLGGenerateLoad		GL	ON GL.intAllocationDetailId = AD.intAllocationDetailId
	JOIN	tblLGAllocationHeader	AH	ON AH.intAllocationHeaderId = AD.intAllocationHeaderId
	JOIN	tblCTContractDetail 	CDP	ON CDP.intContractDetailId = AD.intPContractDetailId
	JOIN	tblCTContractHeader		CHP	ON	CHP.intContractHeaderId		=	CDP.intContractHeaderId
	JOIN	tblCTContractDetail 	CDS	ON CDS.intContractDetailId = AD.intSContractDetailId
	JOIN	tblCTContractHeader		CHS	ON	CHS.intContractHeaderId		=	CDS.intContractHeaderId
	LEFT JOIN	tblEntity				ENP	ON	ENP.intEntityId				=	CHP.intEntityId
	LEFT JOIN	tblEntity				ENS	ON	ENS.intEntityId				=	CHS.intEntityId
	WHERE	AD.intPUnitMeasureId = AD.intSUnitMeasureId
