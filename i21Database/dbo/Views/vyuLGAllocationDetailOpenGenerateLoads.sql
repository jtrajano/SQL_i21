CREATE VIEW vyuLGGenerateLoadOpenAllocationDetails
AS
	SELECT *
		,CASE 
			WHEN (dblSAllocatedQty - dblSGeneratedScheduleQty - dblSGeneratedDeliveredQty) > 0
				THEN (dblSAllocatedQty - dblSGeneratedScheduleQty - dblSGeneratedDeliveredQty)
			ELSE 0
			END AS dblGenerateLoadOpenQuantity
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
			,AD.intPUnitMeasureId
			,UMP.strUnitMeasure AS strPUnitMeasure
			,CDP.intItemUOMId AS intPItemUOMId
			,EYP.intDefaultLocationId AS intPDefaultLocationId
			,LP.strLocationName AS strPDefaultLocationName
			,EYP.strEntityName AS strVendor
			,CHP.ysnUnlimitedQuantity AS ysnPUnlimitedQuantity
			,AD.intSContractDetailId
			,CHS.strContractNumber AS strSalesContractNumber
			,CDS.intContractSeq AS intSContractSeq
			,CHS.intEntityId AS intSEntityId
			,CDS.intCompanyLocationId AS intSCompanyLocationId
			,SCL.strLocationName AS strSCompanyLocation
			,CDS.intItemId AS intSItemId
			,CAST(CHS.strContractNumber AS VARCHAR(100)) + '/' + CAST(CDS.intContractSeq AS VARCHAR(100)) AS strSContractNumber
			,AD.intSUnitMeasureId
			,UMS.strUnitMeasure AS strSUnitMeasure
			,CDS.intItemUOMId AS intSItemUOMId
			,EYS.intDefaultLocationId AS intSDefaultLocationId
			,LS.strLocationName AS strSDefaultLocationName
			,EYS.strEntityName AS strCustomer
			,CHS.ysnUnlimitedQuantity AS ysnSUnlimitedQuantity
			,AD.dblPAllocatedQty
			,AD.dblSAllocatedQty
			,dblPCScheduleQty = IsNull(CDP.dblScheduleQty, 0)
			,dblSCScheduleQty = IsNull(CDS.dblScheduleQty, 0)
			,dblPCBalance = IsNull(CDP.dblBalance, 0)
			,dblSCBalance = IsNull(CDS.dblBalance, 0)
			,dblPCUnLoadedQuantity = IsNull(CDP.dblBalance, 0) - IsNull(CDP.dblScheduleQty, 0)
			,dblSCUnLoadedQuantity = IsNull(CDS.dblBalance, 0) - IsNull(CDS.dblScheduleQty, 0)
			,IsNull((
					SELECT SUM(LOAD.dblQuantity)
					FROM tblLGLoad LOAD
					LEFT JOIN tblLGGenerateLoad GL ON GL.intGenerateLoadId = LOAD.intGenerateLoadId
						AND IsNull(LOAD.dblDeliveredQuantity, 0) <= 0
					GROUP BY GL.intAllocationDetailId
						,LOAD.intContractDetailId
					HAVING GL.intAllocationDetailId = AD.intAllocationDetailId
						AND LOAD.intContractDetailId = AD.intPContractDetailId
					), 0) AS dblPGeneratedScheduleQty
			,IsNull((
					SELECT SUM(LOAD.dblQuantity)
					FROM tblLGLoad LOAD
					LEFT JOIN tblLGGenerateLoad GL ON GL.intGenerateLoadId = LOAD.intGenerateLoadId
						AND IsNull(LOAD.dblDeliveredQuantity, 0) <= 0
					GROUP BY GL.intAllocationDetailId
						,LOAD.intContractDetailId
					HAVING GL.intAllocationDetailId = AD.intAllocationDetailId
						AND LOAD.intContractDetailId = AD.intSContractDetailId
					), 0) AS dblSGeneratedScheduleQty
			,IsNull((
					SELECT SUM(LOAD.dblDeliveredQuantity)
					FROM tblLGLoad LOAD
					LEFT JOIN tblLGGenerateLoad GL ON GL.intGenerateLoadId = LOAD.intGenerateLoadId
						AND IsNull(LOAD.dblDeliveredQuantity, 0) > 0
					GROUP BY GL.intAllocationDetailId
						,LOAD.intContractDetailId
					HAVING GL.intAllocationDetailId = AD.intAllocationDetailId
						AND LOAD.intContractDetailId = AD.intPContractDetailId
					), 0) AS dblPGeneratedDeliveredQty
			,IsNull((
					SELECT SUM(LOAD.dblDeliveredQuantity)
					FROM tblLGLoad LOAD
					LEFT JOIN tblLGGenerateLoad GL ON GL.intGenerateLoadId = LOAD.intGenerateLoadId
						AND IsNull(LOAD.dblDeliveredQuantity, 0) > 0
					GROUP BY GL.intAllocationDetailId
						,LOAD.intContractDetailId
					HAVING GL.intAllocationDetailId = AD.intAllocationDetailId
						AND LOAD.intContractDetailId = AD.intSContractDetailId
					), 0) AS dblSGeneratedDeliveredQty
			,ITP.strItemNo AS strPItemNo
			,ITP.strDescription AS strPItemDescription
			,ITS.strItemNo AS strSItemNo
			,ITS.strDescription AS strSItemDescription

		FROM tblLGAllocationDetail AD
		JOIN tblLGAllocationHeader AH ON AH.intAllocationHeaderId = AD.intAllocationHeaderId
		JOIN tblCTContractDetail CDP ON CDP.intContractDetailId = AD.intPContractDetailId
		JOIN tblCTContractHeader CHP ON CHP.intContractHeaderId = CDP.intContractHeaderId
		JOIN tblICItem ITP ON ITP.intItemId = CDP.intItemId
		JOIN vyuCTEntity EYP ON EYP.intEntityId = CHP.intEntityId
			AND EYP.strEntityType = (
				CASE 
					WHEN CHP.intContractTypeId = 1
						THEN 'Vendor'
					ELSE 'Customer'
					END
				)
		JOIN [tblEMEntityLocation]	LP ON EYP.intEntityId =	LP.intEntityId AND LP.ysnDefaultLocation	=	1
		JOIN tblCTContractDetail CDS ON CDS.intContractDetailId = AD.intSContractDetailId
		JOIN tblCTContractHeader CHS ON CHS.intContractHeaderId = CDS.intContractHeaderId
		JOIN tblICItem ITS ON ITS.intItemId = CDP.intItemId
		JOIN vyuCTEntity EYS ON EYS.intEntityId = CHP.intEntityId
			AND EYS.strEntityType = (
				CASE 
					WHEN CHP.intContractTypeId = 1
						THEN 'Vendor'
					ELSE 'Customer'
					END
				)
		JOIN [tblEMEntityLocation]	LS ON EYS.intEntityId =	LS.intEntityId AND LS.ysnDefaultLocation	=	1
		JOIN tblICUnitMeasure UMP ON UMP.intUnitMeasureId = AD.intPUnitMeasureId
		JOIN tblICUnitMeasure UMS ON UMS.intUnitMeasureId = AD.intSUnitMeasureId
		JOIN tblSMCompanyLocation PCL ON PCL.intCompanyLocationId = CDP.intCompanyLocationId
		JOIN tblSMCompanyLocation SCL ON SCL.intCompanyLocationId = CDS.intCompanyLocationId
		WHERE AD.intPUnitMeasureId = AD.intSUnitMeasureId
	) t1