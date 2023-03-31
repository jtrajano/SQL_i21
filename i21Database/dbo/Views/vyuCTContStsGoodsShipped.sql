CREATE VIEW [dbo].[vyuCTContStsGoodsShipped]

AS 

	SELECT	CAST(ROW_NUMBER() OVER (ORDER BY intContractDetailId ASC) AS INT) intUniqueId,*
	FROM
	(			
			SELECT	intContractDetailId = CASE WHEN (SH.intPurchaseSale = 2) THEN CQ.intSContractDetailId ELSE CQ.intPContractDetailId END,
					SH.strLoadNumber,
					ISNULL(IU.intItemUOMId,ISNULL(CQ.intItemUOMId, LP.intWeightUOMId) ) AS intItemUOMId,
					ISNULL(dbo.fnCTConvertQuantityToTargetItemUOM(CQ.intItemId,IU.intUnitMeasureId,LP.intWeightUOMId,CQ.dblNet),0)	AS dblNetWeight,
					ISNULL(IM.strUnitMeasure,LPM.strUnitMeasure) AS strUnitMeasure,
					SH.intShipmentType,
					SH.intLoadId,
					'intLoadId' COLLATE Latin1_General_CI_AS AS strIdColumn
			FROM	tblLGLoadDetail	CQ
			LEFT JOIN	tblLGLoad					SH	ON	SH.intLoadId			=	CQ.intLoadId 
			LEFT JOIN	tblICItemUOM				IU	ON	IU.intItemId			=	CQ.intItemId	
													AND IU.intUnitMeasureId		=	ISNULL(SH.intWeightUnitMeasureId, CQ.intItemUOMId)
			LEFT JOIN	tblICUnitMeasure			IM	ON	IM.intUnitMeasureId		=	IU.intUnitMeasureId		CROSS	
			APPLY	tblLGCompanyPreference		LP 	
			INNER JOIN tblICUnitMeasure LPM ON  LPM.intUnitMeasureId = LP.intWeightUOMId

			UNION ALL

			SELECT	AD.intSContractDetailId,
					SH.strLoadNumber,
					IU.intItemUOMId,
					dbo.fnCTConvertQuantityToTargetItemUOM(CQ.intItemId,IU.intUnitMeasureId,LP.intWeightUOMId,CQ.dblNet),
					IM.strUnitMeasure,
					SH.intShipmentType,
					SH.intLoadId,
					'intLoadId' COLLATE Latin1_General_CI_AS AS strIdColumn
			FROM	tblLGLoadDetail	CQ
			JOIN	tblLGLoad					SH	ON	SH.intLoadId			=	CQ.intLoadId 
			JOIN	tblLGAllocationDetail		AD	ON	AD.intSContractDetailId =	CQ.intSContractDetailId
			JOIN	tblICItemUOM				IU	ON	IU.intItemId			=	CQ.intItemId	
													AND IU.intUnitMeasureId		=	SH.intWeightUnitMeasureId
			JOIN	tblICUnitMeasure			IM	ON	IM.intUnitMeasureId		=	IU.intUnitMeasureId		CROSS	
			APPLY	tblLGCompanyPreference		LP 	
	)t

