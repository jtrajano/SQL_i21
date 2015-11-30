CREATE VIEW [dbo].[vyuCTContStsAllocationSummary]

AS 

	SELECT	CAST(ROW_NUMBER() OVER (ORDER BY UP.intContractDetailId ASC) AS INT) intUniqueId,
			UP.intContractDetailId,
			UP.strName,
			UP.strValue
	FROM	(
				SELECT	CD.intContractDetailId,
						CAST(ISNULL(RV.dblReservedQuantity,0) AS NVARCHAR(100)) collate Latin1_General_CI_AS [Reserved],				
						--ISNULL(CD.dblQuantity,0) - ISNULL(RV.dblReservedQuantity,0) AS dblUnReservedQuantity,
						CAST(ISNULL(PA.dblAllocatedQty,0) + ISNULL(SA.dblAllocatedQty,0) AS NVARCHAR(100)) collate Latin1_General_CI_AS  AS [Allocated],
						CAST(CAST(ISNULL(CD.dblQuantity,0) AS NUMERIC(18,2)) - ISNULL(PA.dblAllocatedQty,0) + ISNULL(SA.dblAllocatedQty,0) AS NVARCHAR(100)) collate Latin1_General_CI_AS AS [Unallocated],
						CAST(ISNULL(PL.dblPickedQty,0) AS NVARCHAR(100)) collate Latin1_General_CI_AS [Picked Qty],
						CAST(ISNULL(PA.dblAllocatedQty,0) + ISNULL(SA.dblAllocatedQty,0) - PL.dblPickedQty AS NVARCHAR(100)) collate Latin1_General_CI_AS AS [To be Picked]
				FROM	tblCTContractDetail CD LEFT
				JOIN	(
							SELECT		intContractDetailId,CAST(ISNULL(SUM(dblReservedQuantity),0) AS NUMERIC(18,2)) AS dblReservedQuantity 
							FROM		tblLGReservation 
							Group By	intContractDetailId
						)	RV	  ON	RV.intContractDetailId		=	CD.intContractDetailId		LEFT	
				JOIN	(
							SELECT		intPContractDetailId,CAST(ISNULL(SUM(dblPAllocatedQty),0) AS NUMERIC(18,2))  AS dblAllocatedQty
							FROM		tblLGAllocationDetail 
							Group By	intPContractDetailId
						)	PA	  ON	PA.intPContractDetailId		=	CD.intContractDetailId		LEFT	
				JOIN	(
							SELECT		intSContractDetailId,CAST(ISNULL(SUM(dblSAllocatedQty),0) AS NUMERIC(18,2))  AS dblAllocatedQty
							FROM		tblLGAllocationDetail 
							Group By	intSContractDetailId
						)	SA	  ON	SA.intSContractDetailId		=	CD.intContractDetailId		LEFT
				JOIN	(
							SELECT		intContractDetailId,CAST(ISNULL(SUM(dblPickedQty),0) AS NUMERIC(18,2))  AS dblPickedQty
							FROM		vyuCTContStsPickedLot 
							Group By	intContractDetailId
						)	PL	  ON	PL.intContractDetailId		=	CD.intContractDetailId		
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
