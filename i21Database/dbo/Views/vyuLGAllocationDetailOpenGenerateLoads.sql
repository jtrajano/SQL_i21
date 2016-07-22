CREATE VIEW vyuLGGenerateLoadOpenAllocationDetails
AS
	SELECT *,
			CASE WHEN (dblSAllocatedQty - dblSGeneratedScheduleQty - dblSGeneratedDeliveredQty) > 0
				THEN (dblSAllocatedQty - dblSGeneratedScheduleQty - dblSGeneratedDeliveredQty)
				ELSE 0
				END as dblGenerateLoadOpenQuantity
	FROM 
	(SELECT	AH.[strAllocationNumber],
			AH.intAllocationHeaderId,

			AD.intAllocationDetailId,

			AD.intPContractDetailId,
			CDP.strContractNumber as strPurchaseContractNumber,
			CDP.intContractSeq as intPContractSeq,
			CDP.intEntityId AS intPEntityId,
			CDP.intCompanyLocationId AS intPCompanyLocationId,
			CDP.intItemId AS intPItemId,
			CAST (CDP.strContractNumber AS VARCHAR(100)) +  '/' + CAST(CDP.intContractSeq AS VARCHAR(100)) AS strPContractNumber, 
			AD.intPUnitMeasureId,
			CDP.intItemUOMId AS intPItemUOMId,
			CDP.intDefaultLocationId as intPDefaultLocationId,
			CDP.strEntityName as strVendor,
			CDP.ysnUnlimitedQuantity as ysnPUnlimitedQuantity,

			AD.intSContractDetailId,
			CDS.strContractNumber as strSalesContractNumber,
			CDS.intContractSeq as intSContractSeq,
			CDS.intEntityId AS intSEntityId,
			CDS.intCompanyLocationId AS intSCompanyLocationId,
			CDS.intItemId AS intSItemId,
			CAST (CDS.strContractNumber AS VARCHAR(100)) +  '/' + CAST(CDS.intContractSeq AS VARCHAR(100)) AS strSContractNumber, 
			AD.intSUnitMeasureId,
			CDS.intItemUOMId AS intSItemUOMId,
			CDS.intDefaultLocationId as intSDefaultLocationId,
			CDS.strEntityName as strCustomer,
			CDS.ysnUnlimitedQuantity as ysnSUnlimitedQuantity,

			AD.dblPAllocatedQty,
			AD.dblSAllocatedQty,
			dblPCScheduleQty = IsNull(CDP.dblScheduleQty, 0),
			dblSCScheduleQty = IsNull(CDS.dblScheduleQty, 0),

			dblPCBalance = IsNull(CDP.dblBalance, 0),
			dblSCBalance = IsNull(CDS.dblBalance, 0),

			dblPCUnLoadedQuantity = IsNull(CDP.dblBalance, 0) - IsNull(CDP.dblScheduleQty, 0),
			dblSCUnLoadedQuantity = IsNull(CDS.dblBalance, 0) - IsNull(CDS.dblScheduleQty, 0),

			IsNull((SELECT SUM(Load.dblQuantity) FROM tblLGLoad Load LEFT JOIN tblLGGenerateLoad GL ON GL.intGenerateLoadId = Load.intGenerateLoadId AND IsNull(Load.dblDeliveredQuantity, 0) <= 0 Group By GL.intAllocationDetailId, Load.intContractDetailId Having GL.intAllocationDetailId = AD.intAllocationDetailId AND Load.intContractDetailId = AD.intPContractDetailId), 0) as dblPGeneratedScheduleQty,
			IsNull((SELECT SUM(Load.dblQuantity) FROM tblLGLoad Load LEFT JOIN tblLGGenerateLoad GL ON GL.intGenerateLoadId = Load.intGenerateLoadId AND IsNull(Load.dblDeliveredQuantity, 0) <= 0 Group By GL.intAllocationDetailId, Load.intContractDetailId Having GL.intAllocationDetailId = AD.intAllocationDetailId AND Load.intContractDetailId = AD.intSContractDetailId), 0) as dblSGeneratedScheduleQty,
			IsNull((SELECT SUM(Load.dblDeliveredQuantity) FROM tblLGLoad Load LEFT JOIN tblLGGenerateLoad GL ON GL.intGenerateLoadId = Load.intGenerateLoadId AND IsNull(Load.dblDeliveredQuantity, 0) > 0 Group By GL.intAllocationDetailId, Load.intContractDetailId Having GL.intAllocationDetailId = AD.intAllocationDetailId AND Load.intContractDetailId = AD.intPContractDetailId), 0) as dblPGeneratedDeliveredQty,
			IsNull((SELECT SUM(Load.dblDeliveredQuantity) FROM tblLGLoad Load LEFT JOIN tblLGGenerateLoad GL ON GL.intGenerateLoadId = Load.intGenerateLoadId AND IsNull(Load.dblDeliveredQuantity, 0) > 0 Group By GL.intAllocationDetailId, Load.intContractDetailId Having GL.intAllocationDetailId = AD.intAllocationDetailId AND Load.intContractDetailId = AD.intSContractDetailId), 0) as dblSGeneratedDeliveredQty

	FROM 	tblLGAllocationDetail AD	
	JOIN	tblLGAllocationHeader	AH	ON AH.intAllocationHeaderId = AD.intAllocationHeaderId
	JOIN	vyuCTContractDetailView 	CDP	ON CDP.intContractDetailId = AD.intPContractDetailId
	JOIN	vyuCTContractDetailView 	CDS	ON CDS.intContractDetailId = AD.intSContractDetailId
	WHERE	AD.intPUnitMeasureId = AD.intSUnitMeasureId
	) t1
