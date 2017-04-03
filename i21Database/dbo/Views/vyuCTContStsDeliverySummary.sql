CREATE VIEW [dbo].[vyuCTContStsDeliverySummary]

AS 

	SELECT	CAST(ROW_NUMBER() OVER (ORDER BY UP.intContractDetailId ASC) AS INT) intUniqueId,
			UP.intContractDetailId,
			UP.strName,
			UP.strValue
	FROM	(
				SELECT	AD.intPContractDetailId intContractDetailId,
						dbo.fnRemoveTrailingZeroes(CAST(dbo.fnCTConvertQuantityToTargetItemUOM(ISNULL(MAX(SI.intItemId),MAX(LD.intItemId)),ISNULL(MAX(WU.intUnitMeasureId),MAX(LO.intWeightUnitMeasureId)),LP.intWeightUOMId,SUM(ISNULL(SI.dblQuantity,LD.dblQuantity)))AS NUMERIC(18, 6))) Delivered,
						dbo.fnRemoveTrailingZeroes(CAST(dbo.fnCTConvertQuantityToTargetItemUOM(ISNULL(MAX(SI.intItemId),MAX(LD.intItemId)),ISNULL(MAX(WU.intUnitMeasureId),MAX(LO.intWeightUnitMeasureId)),LP.intWeightUOMId,MAX(CD.dblQuantity) - SUM(ISNULL(SI.dblQuantity,LD.dblQuantity))) AS NUMERIC(18, 6))) AS [To be Delivered]
				FROM	tblLGPickLotDetail			PL
				JOIN	tblLGPickLotHeader			LH	ON	LH.intPickLotHeaderId		=	PL.intPickLotHeaderId
				JOIN	tblLGAllocationDetail		AD	ON	AD.intAllocationDetailId	=	PL.intAllocationDetailId	
				JOIN	tblCTContractDetail			CD	ON	CD.intContractDetailId		=	AD.intPContractDetailId		LEFT
				JOIN	tblLGLoadDetail				LD	ON	LD.intPickLotDetailId		=	PL.intPickLotDetailId		LEFT
				JOIN	tblLGLoad					LO	ON	LO.intLoadId				=	LD.intLoadId				LEFT
				JOIN	tblICInventoryShipmentItem	SI	ON	SI.intSourceId				=	PL.intPickLotHeaderId		LEFT
				JOIN	tblICInventoryShipment		SH	ON	SH.intInventoryShipmentId	=	SI.intInventoryShipmentId 
														AND SH.intOrderType				=	1 
														AND SH.intSourceType			=	3							LEFT
				
				JOIN	tblICItemUOM				WU	ON	WU.intItemUOMId				=	SI.intItemUOMId	CROSS	
				APPLY	tblLGCompanyPreference		LP 	
				GROUP BY AD.intPContractDetailId,
						 LP.intWeightUOMId
				
				UNION ALL
				
				SELECT	AD.intSContractDetailId,
						dbo.fnRemoveTrailingZeroes(CAST(dbo.fnCTConvertQuantityToTargetItemUOM(ISNULL(MAX(SI.intItemId),MAX(LD.intItemId)),ISNULL(MAX(WU.intUnitMeasureId),MAX(LO.intWeightUnitMeasureId)),LP.intWeightUOMId,SUM(ISNULL(SI.dblQuantity,LD.dblQuantity)))AS NUMERIC(18, 6))) Delivered,
						dbo.fnRemoveTrailingZeroes(CAST(dbo.fnCTConvertQuantityToTargetItemUOM(ISNULL(MAX(SI.intItemId),MAX(LD.intItemId)),ISNULL(MAX(WU.intUnitMeasureId),MAX(LO.intWeightUnitMeasureId)),LP.intWeightUOMId,MAX(CD.dblQuantity) - SUM(ISNULL(SI.dblQuantity,LD.dblQuantity))) AS NUMERIC(18, 6))) AS [To be Delivered]
				FROM	tblLGPickLotDetail			PL
				JOIN	tblLGPickLotHeader			LH	ON	LH.intPickLotHeaderId		=	PL.intPickLotHeaderId
				JOIN	tblLGAllocationDetail		AD	ON	AD.intAllocationDetailId	=	PL.intAllocationDetailId
				
				JOIN	tblCTContractDetail			CD	ON	CD.intContractDetailId		=	AD.intSContractDetailId		LEFT
				JOIN	tblLGLoadDetail				LD	ON	LD.intPickLotDetailId		=	PL.intPickLotDetailId		LEFT
				JOIN	tblLGLoad					LO	ON	LO.intLoadId				=	LD.intLoadId				LEFT
				JOIN	tblICInventoryShipmentItem	SI	ON	SI.intSourceId				=	PL.intPickLotHeaderId		LEFT
				JOIN	tblICInventoryShipment		SH	ON	SH.intInventoryShipmentId	=	SI.intInventoryShipmentId 
														AND SH.intOrderType				=	1 
														AND SH.intSourceType			=	3							LEFT		
				JOIN	tblICItemUOM				WU	ON	WU.intItemUOMId				=	SI.intItemUOMId	CROSS	
				APPLY	tblLGCompanyPreference		LP 	
				GROUP BY AD.intSContractDetailId,
						 LP.intWeightUOMId
			) s
			UNPIVOT	(strValue FOR strName IN 
						(
							Delivered,
							[To be Delivered] 
						)
			) UP

