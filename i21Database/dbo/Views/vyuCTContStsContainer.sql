CREATE VIEW [dbo].[vyuCTContStsContainer]
	
AS 
	SELECT	CAST(ROW_NUMBER() OVER (ORDER BY intContractDetailId ASC) AS INT) intUniqueId,*
	FROM
	(	
			SELECT	CQ.intContractDetailId,
					BL.strBLNumber,
					BC.strContainerNumber,
					(BC.dblNetWt / BC.dblQuantity) * CC.dblQuantity dblShippedWeight,
					IU.intItemUOMId,
					IM.strUnitMeasure,
					SH.ysnDirectShipment
					
			FROM	tblLGShipmentBLContainerContract	CC  
			JOIN	tblLGShipmentContractQty			CQ	ON	CQ.intShipmentContractQtyId		=	CC.intShipmentContractQtyId  
			JOIN	tblLGShipment						SH	ON	SH.intShipmentId				=	CC.intShipmentId  
			JOIN	tblLGShipmentBL						BL	ON	BL.intShipmentBLId				=	CC.intShipmentBLId  
			JOIN	tblICItemUOM						IU	ON	IU.intItemId					=	CQ.intItemId	 
															AND	IU.intUnitMeasureId				=	SH.intWeightUnitMeasureId 
			JOIN	tblICUnitMeasure					IM	ON	IM.intUnitMeasureId				=	IU.intUnitMeasureId			LEFT
			JOIN	tblLGShipmentBLContainer			BC	ON	BC.intShipmentBLContainerId		=	CC.intShipmentBLContainerId  

			UNION ALL

			SELECT	AD.intSContractDetailId,
					BL.strBLNumber,
					BC.strContainerNumber,
					(BC.dblNetWt / BC.dblQuantity) * CC.dblQuantity dblShippedWeight,
					IU.intItemUOMId,
					IM.strUnitMeasure,
					SH.ysnDirectShipment
					
			FROM	tblLGShipmentBLContainerContract	CC  
			JOIN	tblLGShipmentContractQty			CQ	ON	CQ.intShipmentContractQtyId		=	CC.intShipmentContractQtyId 
			JOIN	tblLGAllocationDetail				AD	ON	AD.intPContractDetailId			=	CQ.intContractDetailId 
			JOIN	tblLGShipment						SH	ON	SH.intShipmentId				=	CC.intShipmentId  
			JOIN	tblLGShipmentBL						BL	ON	BL.intShipmentBLId				=	CC.intShipmentBLId  
			JOIN	tblICItemUOM						IU	ON	IU.intItemId					=	CQ.intItemId	 
															AND	IU.intUnitMeasureId				=	SH.intWeightUnitMeasureId 
			JOIN	tblICUnitMeasure					IM	ON	IM.intUnitMeasureId				=	IU.intUnitMeasureId			LEFT
			JOIN	tblLGShipmentBLContainer			BC	ON	BC.intShipmentBLContainerId		=	CC.intShipmentBLContainerId  
	)t
