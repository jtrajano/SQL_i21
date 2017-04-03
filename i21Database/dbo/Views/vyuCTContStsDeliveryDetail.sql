CREATE VIEW [dbo].[vyuCTContStsDeliveryDetail]

AS 

	SELECT	CAST(ROW_NUMBER() OVER (ORDER BY intContractDetailId ASC) AS INT) intUniqueId,*
	FROM(
			SELECT	AD.intPContractDetailId AS intContractDetailId, 
					ISNULL(SH.strShipmentNumber,LO.strLoadNumber) AS strShipmentNumber,
					ISNULL(SH.dtmShipDate,LO.dtmScheduledDate) AS dtmShipDate,
					EY.strName	AS strCustomer,
					LTRIM(CAST(SUM(ISNULL(SI.dblQuantity,LD.dblQuantity)) AS NUMERIC(18, 6))) + ' ' + UM.strUnitMeasure AS strQuantity,
					dbo.fnCTConvertQuantityToTargetItemUOM(ISNULL(SI.intItemId,LD.intItemId),ISNULL(WU.intUnitMeasureId,LO.intWeightUnitMeasureId),LP.intWeightUOMId,ISNULL(SUM(IL.dblGrossWeight - IL.dblTareWeight),LD.dblNet)) AS dblNetWeight,
					ISNULL(SI.intWeightUOMId,LD.intWeightItemUOMId) AS intWeightUOMId

			FROM	tblLGPickLotDetail				PL
			JOIN	tblLGPickLotHeader				LH	ON	LH.intPickLotHeaderId			=	PL.intPickLotHeaderId
			JOIN	tblLGAllocationDetail			AD	ON	AD.intAllocationDetailId		=	PL.intAllocationDetailId								LEFT
			JOIN	tblLGLoadDetail					LD	ON	LD.intPickLotDetailId			=	PL.intPickLotDetailId									LEFT
			JOIN	tblLGLoad						LO	ON	LO.intLoadId					=	LD.intLoadId											LEFT
			JOIN	tblICInventoryShipmentItem		SI	ON	SI.intSourceId					=	PL.intPickLotHeaderId									LEFT
			JOIN	tblICInventoryShipment			SH	ON	SH.intInventoryShipmentId		=	SI.intInventoryShipmentId 
														AND SH.intOrderType					=	1 
														AND SH.intSourceType				=	3														LEFT
			JOIN	tblEMEntity						EY	ON	EY.intEntityId					=	ISNULL(SH.intEntityCustomerId,LD.intCustomerEntityId)	LEFT
			JOIN	tblICInventoryShipmentItemLot	IL	ON	IL.intInventoryShipmentItemId	=	SI.intInventoryShipmentItemId							LEFT
			JOIN	tblICItemUOM					IU	ON	IU.intItemUOMId					=	ISNULL(SI.intItemUOMId,LD.intItemUOMId)					LEFT
			JOIN	tblICUnitMeasure				UM	ON	UM.intUnitMeasureId				=	IU.intUnitMeasureId										LEFT
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
					LP.intWeightUOMId,
					LO.strLoadNumber,
					LO.dtmScheduledDate,
					LD.dblNet,
					LO.intWeightUnitMeasureId,
					LD.intItemId,
					LD.intWeightItemUOMId

			UNION ALL
				
			SELECT	AD.intSContractDetailId AS intContractDetailId, 
					ISNULL(SH.strShipmentNumber,LO.strLoadNumber) AS strShipmentNumber,
					ISNULL(SH.dtmShipDate,LO.dtmScheduledDate) AS dtmShipDate,
					EY.strName	AS strCustomer,
					LTRIM(CAST(SUM(ISNULL(SI.dblQuantity,LD.dblQuantity)) AS NUMERIC(18, 6))) + ' ' + UM.strUnitMeasure AS strQuantity,
					dbo.fnCTConvertQuantityToTargetItemUOM(ISNULL(SI.intItemId,LD.intItemId),ISNULL(WU.intUnitMeasureId,LO.intWeightUnitMeasureId),LP.intWeightUOMId,ISNULL(SUM(IL.dblGrossWeight - IL.dblTareWeight),LD.dblNet)) AS dblNetWeight,
					ISNULL(SI.intWeightUOMId,LD.intWeightItemUOMId) AS intWeightUOMId

			FROM	tblLGPickLotDetail				PL
			JOIN	tblLGPickLotHeader				LH	ON	LH.intPickLotHeaderId			=	PL.intPickLotHeaderId
			JOIN	tblLGAllocationDetail			AD	ON	AD.intAllocationDetailId		=	PL.intAllocationDetailId								LEFT
			JOIN	tblLGLoadDetail					LD	ON	LD.intPickLotDetailId			=	PL.intPickLotDetailId									LEFT
			JOIN	tblLGLoad						LO	ON	LO.intLoadId					=	LD.intLoadId											LEFT
			JOIN	tblICInventoryShipmentItem		SI	ON	SI.intSourceId					=	PL.intPickLotHeaderId									LEFT
			JOIN	tblICInventoryShipment			SH	ON	SH.intInventoryShipmentId		=	SI.intInventoryShipmentId 
														AND SH.intOrderType					=	1 
														AND SH.intSourceType				=	3														LEFT
			JOIN	tblEMEntity						EY	ON	EY.intEntityId					=	ISNULL(SH.intEntityCustomerId,LD.intCustomerEntityId)	LEFT
			JOIN	tblICInventoryShipmentItemLot	IL	ON	IL.intInventoryShipmentItemId	=	SI.intInventoryShipmentItemId							LEFT
			JOIN	tblICItemUOM					IU	ON	IU.intItemUOMId					=	ISNULL(SI.intItemUOMId,LD.intItemUOMId)					LEFT
			JOIN	tblICUnitMeasure				UM	ON	UM.intUnitMeasureId				=	IU.intUnitMeasureId										LEFT
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
					LP.intWeightUOMId,
					LO.strLoadNumber,
					LO.dtmScheduledDate,
					LD.dblNet,
					LO.intWeightUnitMeasureId,
					LD.intItemId,
					LD.intWeightItemUOMId
		)t
