CREATE VIEW [dbo].[vyuCTContStsGoodsShipped]

AS 

	SELECT	CAST(ROW_NUMBER() OVER (ORDER BY intContractDetailId ASC) AS INT) intUniqueId,*
	FROM
	(			
			SELECT	CQ.intPContractDetailId intContractDetailId,
					SH.strLoadNumber,
					IU.intItemUOMId,
					dbo.fnCTConvertQuantityToTargetItemUOM(CQ.intItemId,IU.intUnitMeasureId,LP.intWeightUOMId,CQ.dblNet)	AS dblNetWeight,
					IM.strUnitMeasure,
					SH.intShipmentType,
					SH.intLoadId,
					'intLoadId' AS strIdColumn
			FROM	tblLGLoadDetail	CQ
			JOIN	tblLGLoad					SH	ON	SH.intLoadId			=	CQ.intLoadId 
			JOIN	tblICItemUOM				IU	ON	IU.intItemId			=	CQ.intItemId	
													AND IU.intUnitMeasureId		=	SH.intWeightUnitMeasureId
			JOIN	tblICUnitMeasure			IM	ON	IM.intUnitMeasureId		=	IU.intUnitMeasureId		CROSS	
			APPLY	tblLGCompanyPreference		LP 	

			UNION ALL

			SELECT	AD.intSContractDetailId,
					SH.strLoadNumber,
					IU.intItemUOMId,
					dbo.fnCTConvertQuantityToTargetItemUOM(CQ.intItemId,IU.intUnitMeasureId,LP.intWeightUOMId,CQ.dblNet),
					IM.strUnitMeasure,
					SH.intShipmentType,
					SH.intLoadId,
					'intLoadId' AS strIdColumn
			FROM	tblLGLoadDetail	CQ
			JOIN	tblLGLoad					SH	ON	SH.intLoadId			=	CQ.intLoadId 
			JOIN	tblLGAllocationDetail		AD	ON	AD.intPContractDetailId =	CQ.intPContractDetailId
			JOIN	tblICItemUOM				IU	ON	IU.intItemId			=	CQ.intItemId	
													AND IU.intUnitMeasureId		=	SH.intWeightUnitMeasureId
			JOIN	tblICUnitMeasure			IM	ON	IM.intUnitMeasureId		=	IU.intUnitMeasureId		CROSS	
			APPLY	tblLGCompanyPreference		LP 	
	)t
