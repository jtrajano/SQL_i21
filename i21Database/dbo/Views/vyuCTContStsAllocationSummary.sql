CREATE VIEW [dbo].[vyuCTContStsAllocationSummary]

AS 

	SELECT	CAST(ROW_NUMBER() OVER (ORDER BY UP.intContractDetailId ASC) AS INT) intUniqueId,
			UP.intContractDetailId,
			UP.strName,
			UP.strValue
			
	FROM	(
				SELECT	CD.intContractDetailId,
						dbo.fnRemoveTrailingZeroes(ISNULL(RV.dblReservedQuantity,0)) collate Latin1_General_CI_AS [Reserved],				
						--ISNULL(CD.dblQuantity,0) - ISNULL(RV.dblReservedQuantity,0) AS dblUnReservedQuantity,
						dbo.fnRemoveTrailingZeroes(ISNULL(PA.dblAllocatedQty,0) + ISNULL(SA.dblAllocatedQty,0)) collate Latin1_General_CI_AS  AS [Allocated],
						dbo.fnRemoveTrailingZeroes(CAST(dbo.fnCTConvertQuantityToTargetItemUOM(CD.intItemId,CD.intUnitMeasureId,LP.intWeightUOMId,ISNULL(CD.dblQuantity,0)) AS NUMERIC(18, 6)) - ISNULL(PA.dblAllocatedQty,0) - ISNULL(SA.dblAllocatedQty,0)) collate Latin1_General_CI_AS AS [Unallocated],
						dbo.fnRemoveTrailingZeroes(ISNULL(PL.dblPickedQty,0)) collate Latin1_General_CI_AS [Picked Qty],
						dbo.fnRemoveTrailingZeroes(ISNULL(PA.dblAllocatedQty,0) + ISNULL(SA.dblAllocatedQty,0) - PL.dblPickedQty) collate Latin1_General_CI_AS AS [To be Picked]

				FROM	tblCTContractDetail CD LEFT
				JOIN	(
							SELECT		RV.intContractDetailId,
										CAST(ISNULL(SUM(dbo.fnCTConvertQuantityToTargetItemUOM(CD.intItemId,RV.intUnitMeasureId,LP.intWeightUOMId,dblReservedQuantity)),0) AS NUMERIC(18, 6)) AS dblReservedQuantity 
							FROM		tblLGReservation		RV		
							JOIN		tblCTContractDetail		CD	ON	CD.intContractDetailId = RV.intContractDetailId	 CROSS	
							APPLY		tblLGCompanyPreference	LP
							Group By	RV.intContractDetailId,CD.intItemId,RV.intUnitMeasureId,LP.intWeightUOMId
						)	RV	  ON	RV.intContractDetailId		=	CD.intContractDetailId		LEFT	
				JOIN	(
							SELECT		RV.intPContractDetailId,
										CAST(ISNULL(SUM(dbo.fnCTConvertQuantityToTargetItemUOM(CD.intItemId,RV.intPUnitMeasureId,LP.intWeightUOMId,dblPAllocatedQty)),0) AS NUMERIC(18, 6))  AS dblAllocatedQty
							FROM		tblLGAllocationDetail	RV		
							JOIN		tblCTContractDetail		CD	ON	CD.intContractDetailId = RV.intPContractDetailId	 CROSS	
							APPLY		tblLGCompanyPreference	LP
							Group By	intPContractDetailId,CD.intItemId,RV.intPUnitMeasureId,LP.intWeightUOMId
						)	PA	  ON	PA.intPContractDetailId		=	CD.intContractDetailId		LEFT	
				JOIN	(
							SELECT		intSContractDetailId,
										CAST(ISNULL(SUM(dbo.fnCTConvertQuantityToTargetItemUOM(CD.intItemId,RV.intSUnitMeasureId,LP.intWeightUOMId,dblSAllocatedQty)),0) AS NUMERIC(18, 6))  AS dblAllocatedQty
							FROM		tblLGAllocationDetail	RV		
							JOIN		tblCTContractDetail		CD	ON	CD.intContractDetailId = RV.intPContractDetailId	 CROSS	
							APPLY		tblLGCompanyPreference	LP 
							Group By	intSContractDetailId,CD.intItemId,RV.intSUnitMeasureId,LP.intWeightUOMId
						)	SA	  ON	SA.intSContractDetailId		=	CD.intContractDetailId		LEFT
				JOIN	(
							SELECT		intContractDetailId,CAST(ISNULL(SUM(dblPickedQty),0) AS NUMERIC(18, 6))  AS dblPickedQty
							FROM		vyuCTContStsPickedLot 
							Group By	intContractDetailId
						)	PL	  ON	PL.intContractDetailId		=	CD.intContractDetailId	CROSS	
				APPLY	tblLGCompanyPreference	LP
			) s
				UNPIVOT	(strValue FOR strName IN 
							(
								[Allocated],
								[Unallocated],
								[Picked Qty],
								[To be Picked],
								[Reserved]
							)
						) UP
