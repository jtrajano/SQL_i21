CREATE VIEW [dbo].[vyuCTContStsGoodsShipped]

AS 

	SELECT	CAST(ROW_NUMBER() OVER (ORDER BY intContractDetailId ASC) AS INT) intUniqueId,*
	FROM
	(			
			SELECT	CQ.intContractDetailId,
					SH.intTrackingNumber,
					IU.intItemUOMId,
					CQ.dblNetWt	AS dblNetWeight,
					IM.strUnitMeasure
			FROM	tblLGShipmentContractQty	CQ
			JOIN	tblLGShipment				SH	ON	SH.intShipmentId		=	CQ.intShipmentId 
			JOIN	tblICItemUOM				IU	ON	IU.intItemId			=	CQ.intItemId	
													AND IU.intUnitMeasureId		=	SH.intWeightUnitMeasureId
			JOIN	tblICUnitMeasure			IM	ON	IM.intUnitMeasureId		=	IU.intUnitMeasureId

			UNION ALL

			SELECT	AD.intSContractDetailId,
					SH.intTrackingNumber,
					IU.intItemUOMId,
					CQ.dblNetWt,
					IM.strUnitMeasure
			FROM	tblLGShipmentContractQty	CQ
			JOIN	tblLGShipment				SH	ON	SH.intShipmentId		=	CQ.intShipmentId 
			JOIN	tblLGAllocationDetail		AD	ON	AD.intPContractDetailId =	CQ.intContractDetailId
			JOIN	tblICItemUOM				IU	ON	IU.intItemId			=	CQ.intItemId	
													AND IU.intUnitMeasureId		=	SH.intWeightUnitMeasureId
			JOIN	tblICUnitMeasure			IM	ON	IM.intUnitMeasureId		=	IU.intUnitMeasureId
	)t
