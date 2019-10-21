CREATE VIEW [dbo].[vyuCTContStsInventoryReceipt]

AS 

		SELECT	CAST(ROW_NUMBER() OVER (ORDER BY intContractDetailId ASC) AS INT) intUniqueId,*
		FROM
		(		
			SELECT	RI.intLineNo AS intContractDetailId,
					IR.strReceiptNumber, 
					RL.strLotNumber, 
					CASE	WHEN IR.strReceiptType = 'Inventory Return' 
								THEN -1*ISNULL(RL.dblQuantity,RI.dblNetReturned)
								ELSE	ISNULL(RL.dblQuantity,ISNULL(RI.dblNet,RI.dblReceived))
					END AS dblQuantity,
					dbo.fnCTConvertQuantityToTargetItemUOM(RI.intItemId,IU.intUnitMeasureId,LP.intWeightUOMId,
						CASE	WHEN IR.strReceiptType = 'Inventory Return' 
								THEN -1*ISNULL((RL.dblGrossWeight - RL.dblTareWeight),RI.dblNet) 
								ELSE	ISNULL((RL.dblGrossWeight - RL.dblTareWeight),ISNULL(RI.dblNet,RI.dblReceived))
						END
					) AS dblNetWeight,
					ISNULL(RI.intWeightUOMId,RI.intUnitMeasureId) intItemUOMId,
					IM.strUnitMeasure,
					SL.strSubLocationName,
					IR.intInventoryReceiptId
				
			FROM	tblICInventoryReceiptItem		RI	
			JOIN	tblICInventoryReceipt			IR	ON	IR.intInventoryReceiptId			=	RI.intInventoryReceiptId 
														AND IR.strReceiptType					IN	('Purchase Contract','Inventory Return')
			JOIN	tblICItemUOM					IU	ON	IU.intItemUOMId						=	ISNULL(RI.intWeightUOMId,RI.intUnitMeasureId)
			JOIN	tblICUnitMeasure				IM	ON	IM.intUnitMeasureId					=	IU.intUnitMeasureId		
	LEFT	JOIN	tblSMCompanyLocationSubLocation SL	ON	SL.intCompanyLocationSubLocationId	=	RI.intSubLocationId
	LEFT	JOIN	tblICInventoryReceiptItemLot	RL	ON	RI.intInventoryReceiptItemId		=	RL.intInventoryReceiptItemId	CROSS	
			APPLY	tblLGCompanyPreference			LP 	

			UNION ALL

			SELECT	AD.intSContractDetailId,
					IR.strReceiptNumber, 
					RL.strLotNumber, 
					CASE	WHEN IR.strReceiptType = 'Inventory Return' 
								THEN -1*RL.dblQuantity
								ELSE	RL.dblQuantity
					END AS dblQuantity,
					dbo.fnCTConvertQuantityToTargetItemUOM(RI.intItemId,IU.intUnitMeasureId,LP.intWeightUOMId,
						CASE	WHEN IR.strReceiptType = 'Inventory Return' 
								THEN -1*(RL.dblGrossWeight - RL.dblTareWeight) 
								ELSE	(RL.dblGrossWeight - RL.dblTareWeight) 
						END
					) AS dblNetWeight,
					ISNULL(RI.intWeightUOMId,RI.intUnitMeasureId) intItemUOMId,
					IM.strUnitMeasure,
					SL.strSubLocationName,
					IR.intInventoryReceiptId

			FROM	tblICInventoryReceiptItemLot	RL
			JOIN	tblICInventoryReceiptItem		RI	ON	RI.intInventoryReceiptItemId		=	RL.intInventoryReceiptItemId
			JOIN	tblICInventoryReceipt			IR	ON	IR.intInventoryReceiptId			=	RI.intInventoryReceiptId 
														AND IR.strReceiptType					=	'Purchase Contract'
			JOIN	tblICItemUOM					IU	ON	IU.intItemUOMId						=	ISNULL(RI.intWeightUOMId,RI.intUnitMeasureId)
			JOIN	tblICUnitMeasure				IM	ON	IM.intUnitMeasureId					=	IU.intUnitMeasureId
			JOIN	tblLGAllocationDetail			AD	ON	AD.intPContractDetailId				=	RI.intLineNo		
	LEFT	JOIN	tblSMCompanyLocationSubLocation SL	ON	SL.intCompanyLocationSubLocationId	=	RI.intSubLocationId	CROSS	
			APPLY	tblLGCompanyPreference			LP 	
		)t
