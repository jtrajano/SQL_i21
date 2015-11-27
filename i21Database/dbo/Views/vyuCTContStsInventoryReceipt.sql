CREATE VIEW [dbo].[vyuCTContStsInventoryReceipt]

AS 

	SELECT	CAST(ROW_NUMBER() OVER (ORDER BY intContractDetailId ASC) AS INT) intUniqueId,*
	FROM
	(		
		SELECT	RI.intLineNo AS intContractDetailId,
				IR.strReceiptNumber, 
				RL.strLotNumber, 
				RL.dblQuantity,
				RL.dblGrossWeight - RL.dblTareWeight AS dblNetWeight,
				RI.intWeightUOMId intItemUOMId,
				IM.strUnitMeasure,
				SL.strSubLocationName
				
		FROM	tblICInventoryReceiptItemLot	RL
		JOIN	tblICInventoryReceiptItem		RI	ON	RI.intInventoryReceiptItemId		=	RL.intInventoryReceiptItemId
		JOIN	tblICInventoryReceipt			IR	ON	IR.intInventoryReceiptId			=	RI.intInventoryReceiptId 
													AND IR.strReceiptType					=	'Purchase Contract'
		JOIN	tblSMCompanyLocationSubLocation SL	ON	SL.intCompanyLocationSubLocationId	=	RI.intSubLocationId
		JOIN	tblICItemUOM					IU	ON	IU.intItemUOMId						=	RI.intWeightUOMId
		JOIN	tblICUnitMeasure				IM	ON	IM.intUnitMeasureId					=	IU.intUnitMeasureId

		UNION ALL

		SELECT	AD.intSContractDetailId,
				IR.strReceiptNumber, 
				RL.strLotNumber, 
				RL.dblQuantity,
				RL.dblGrossWeight - RL.dblTareWeight AS dblNetWeight,
				RI.intWeightUOMId intItemUOMId,
				IM.strUnitMeasure,
				SL.strSubLocationName
				
		FROM	tblICInventoryReceiptItemLot	RL
		JOIN	tblICInventoryReceiptItem		RI	ON	RI.intInventoryReceiptItemId		=	RL.intInventoryReceiptItemId
		JOIN	tblICInventoryReceipt			IR	ON	IR.intInventoryReceiptId			=	RI.intInventoryReceiptId 
													AND IR.strReceiptType					=	'Purchase Contract'
		JOIN	tblSMCompanyLocationSubLocation SL	ON	SL.intCompanyLocationSubLocationId	=	RI.intSubLocationId
		JOIN	tblICItemUOM					IU	ON	IU.intItemUOMId						=	RI.intWeightUOMId
		JOIN	tblICUnitMeasure				IM	ON	IM.intUnitMeasureId					=	IU.intUnitMeasureId
		JOIN	tblLGAllocationDetail			AD	ON	AD.intPContractDetailId				=	RI.intLineNo
	)t
