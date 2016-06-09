CREATE VIEW [dbo].[vyuCTContStsContainer]
	
AS 
	SELECT	CAST(ROW_NUMBER() OVER (ORDER BY intContractDetailId ASC) AS INT) intUniqueId,*
	FROM
	(	
			SELECT	CQ.intSContractDetailId intContractDetailId,
					SH.strBLNumber,
					BC.strContainerNumber,
					dbo.fnCTConvertQuantityToTargetItemUOM(CQ.intItemId,BC.intWeightUnitMeasureId,LP.intWeightUOMId,BC.dblNetWt) dblShippedWeight,
					IU.intItemUOMId,
					IM.strUnitMeasure,
					CAST(CASE WHEN  SH.intPurchaseSale = 3 THEN 1 ELSE 0 END AS BIT) ysnDirectShipment
					
			FROM	tblLGLoadDetailContainerLink		CC  
			JOIN	tblLGLoadDetail						CQ	ON	CQ.intLoadDetailId				=	CC.intLoadDetailId  
			JOIN	tblLGLoad							SH	ON	SH.intLoadId					=	CC.intLoadId  
			JOIN	tblICItemUOM						IU	ON	IU.intItemId					=	CQ.intItemId	 
															AND	IU.intUnitMeasureId				=	SH.intWeightUnitMeasureId 
			JOIN	tblICUnitMeasure					IM	ON	IM.intUnitMeasureId				=	IU.intUnitMeasureId				LEFT
			JOIN	tblLGLoadContainer					BC	ON	BC.intLoadContainerId			=	CC.intLoadContainerId		CROSS	
			APPLY	tblLGCompanyPreference	LP 	

			UNION ALL

			SELECT	AD.intSContractDetailId,
					SH.strBLNumber,
					BC.strContainerNumber,
					dbo.fnCTConvertQuantityToTargetItemUOM(CQ.intItemId,BC.intWeightUnitMeasureId,LP.intWeightUOMId,BC.dblNetWt) dblShippedWeight,
					IU.intItemUOMId,
					IM.strUnitMeasure,
					CAST(CASE WHEN  SH.intPurchaseSale = 3 THEN 1 ELSE 0 END AS BIT) ysnDirectShipment
					
			FROM	tblLGLoadDetailContainerLink		CC  
			JOIN	tblLGLoadDetail						CQ	ON	CQ.intLoadDetailId				=	CC.intLoadDetailId 
			JOIN	tblLGAllocationDetail				AD	ON	AD.intPContractDetailId			=	CQ.intPContractDetailId 
			JOIN	tblLGLoad							SH	ON	SH.intLoadId					=	CC.intLoadId  
			JOIN	tblICItemUOM						IU	ON	IU.intItemId					=	CQ.intItemId	 
															AND	IU.intUnitMeasureId				=	SH.intWeightUnitMeasureId 
			JOIN	tblICUnitMeasure					IM	ON	IM.intUnitMeasureId				=	IU.intUnitMeasureId				LEFT
			JOIN	tblLGLoadContainer					BC	ON	BC.intLoadContainerId			=	CC.intLoadContainerId		CROSS	
			APPLY	tblLGCompanyPreference	LP 	  
	)t
