CREATE VIEW [dbo].[vyuCTContStsDeliveryDetail]

AS 

	SELECT	CAST(ROW_NUMBER() OVER (ORDER BY intContractDetailId ASC) AS INT) intUniqueId,*
	FROM(
			SELECT		AD.intPContractDetailId intContractDetailId,
						SH.strShipmentNumber,
						SH.dtmShipDate,
						EY.strName	AS strCustomer,
						LTRIM(CAST(SUM(SI.dblQuantity) AS NUMERIC(18,2))) + ' ' + UM.strUnitMeasure AS strQuantity,
						dbo.fnCTConvertQuantityToTargetItemUOM(SI.intItemId,WU.intUnitMeasureId,LP.intWeightUOMId,SUM(IL.dblGrossWeight - IL.dblTareWeight)) dblNetWeight,
						SI.intWeightUOMId
				FROM	tblLGPickLotDetail				PL
				JOIN	tblLGPickLotHeader				LH	ON	LH.intPickLotHeaderId			=	PL.intPickLotHeaderId
				JOIN	tblLGAllocationDetail			AD	ON	AD.intAllocationDetailId		=	PL.intAllocationDetailId
				JOIN	tblICInventoryShipmentItem		SI	ON	SI.intLineNo					=	PL.intPickLotDetailId
				JOIN	tblICInventoryShipment			SH	ON	SH.intInventoryShipmentId		=	SI.intInventoryShipmentId AND SH.intOrderType = 1 AND intSourceType = 3
				JOIN	tblEntity						EY	ON	EY.intEntityId					=	SH.intEntityCustomerId
				JOIN	tblICInventoryShipmentItemLot	IL	ON	IL.intInventoryShipmentItemId	=	SI.intInventoryShipmentItemId
				JOIN	tblICItemUOM					IU	ON	IU.intItemUOMId					=	SI.intItemUOMId
				JOIN	tblICUnitMeasure				UM	ON	UM.intUnitMeasureId				=	IU.intUnitMeasureId		
				JOIN	tblICItemUOM					WU	ON	WU.intItemUOMId					=	SI.intWeightUOMId		CROSS	
				APPLY	tblLGCompanyPreference			LP 	
				GROUP 
				BY		AD.intPContractDetailId,
						SH.strShipmentNumber,
						SH.dtmShipDate,
						EY.strName,
						SI.intWeightUOMId,
						UM.strUnitMeasure,
						SI.intItemId,
						WU.intUnitMeasureId,
						LP.intWeightUOMId
			UNION ALL
				
			SELECT		AD.intSContractDetailId intContractDetailId,
						SH.strShipmentNumber,
						SH.dtmShipDate,
						EY.strName	AS strCustomer,
						LTRIM(CAST(SUM(SI.dblQuantity) AS NUMERIC(18,2))) + ' ' + UM.strUnitMeasure AS strQuantity,
						dbo.fnCTConvertQuantityToTargetItemUOM(SI.intItemId,WU.intUnitMeasureId,LP.intWeightUOMId,SUM(IL.dblGrossWeight - IL.dblTareWeight)) dblNetWeight,
						SI.intWeightUOMId
				FROM	tblLGPickLotDetail				PL
				JOIN	tblLGPickLotHeader				LH	ON	LH.intPickLotHeaderId			=	PL.intPickLotHeaderId
				JOIN	tblLGAllocationDetail			AD	ON	AD.intAllocationDetailId		=	PL.intAllocationDetailId
				JOIN	tblICInventoryShipmentItem		SI	ON	SI.intLineNo					=	PL.intPickLotDetailId
				JOIN	tblICInventoryShipment			SH	ON	SH.intInventoryShipmentId		=	SI.intInventoryShipmentId AND SH.intOrderType = 1 AND intSourceType = 3
				JOIN	tblEntity						EY	ON	EY.intEntityId					=	SH.intEntityCustomerId
				JOIN	tblICInventoryShipmentItemLot	IL	ON	IL.intInventoryShipmentItemId	=	SI.intInventoryShipmentItemId
				JOIN	tblICItemUOM					IU	ON	IU.intItemUOMId					=	SI.intItemUOMId
				JOIN	tblICUnitMeasure				UM	ON	UM.intUnitMeasureId				=	IU.intUnitMeasureId		
				JOIN	tblICItemUOM					WU	ON	WU.intItemUOMId					=	SI.intWeightUOMId		CROSS	
				APPLY	tblLGCompanyPreference			LP 	
				GROUP 
				BY		AD.intSContractDetailId,
						SH.strShipmentNumber,
						SH.dtmShipDate,
						EY.strName,
						SI.intWeightUOMId,
						UM.strUnitMeasure,
						SI.intItemId,
						WU.intUnitMeasureId,
						LP.intWeightUOMId
		)t
