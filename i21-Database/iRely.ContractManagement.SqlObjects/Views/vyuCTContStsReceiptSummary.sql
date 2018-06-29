CREATE VIEW [dbo].[vyuCTContStsReceiptSummary]

AS 

	SELECT	CAST(ROW_NUMBER() OVER (ORDER BY UP.intContractDetailId ASC) AS INT) intUniqueId,
			UP.intContractDetailId,
			UP.strName,
			UP.strValue
	FROM	(
				SELECT	CD.intContractDetailId,
						CAST(dbo.fnRemoveTrailingZeroes(GS.dblNetWeight) AS NVARCHAR(100)) collate Latin1_General_CI_AS						[Shipped],
						CAST(dbo.fnRemoveTrailingZeroes(dbo.fnCTConvertQtyToTargetItemUOM(CD.intItemUOMId,GS.intItemUOMId, CD.dblQuantity)) - GS.dblNetWeight AS NVARCHAR(100)) collate Latin1_General_CI_AS		[To be Shipped],
						CAST(dbo.fnRemoveTrailingZeroes(CR.dblShippedWeight) AS NVARCHAR(100)) collate Latin1_General_CI_AS					[Recd Wt in Wh],
						CAST(dbo.fnRemoveTrailingZeroes(dbo.fnCTConvertQtyToTargetItemUOM(CD.intItemUOMId,GS.intItemUOMId, CD.dblQuantity)) - CR.dblShippedWeight AS NVARCHAR(100)) collate Latin1_General_CI_AS	[To be Received]
				FROM	tblCTContractDetail			CD								LEFT
				JOIN	(
							SELECT	intContractDetailId,
									CAST(SUM(dblNetWeight) AS NUMERIC(18, 6)) dblNetWeight,
									MIN(intItemUOMId) intItemUOMId
							FROM	vyuCTContStsGoodsShipped
							WHERE	intShipmentType <> 2
							GROUP
							BY		intContractDetailId		
						)GS	ON	GS.intContractDetailId	=	CD.intContractDetailId	LEFT
				JOIN	(
							SELECT	intContractDetailId,
									CAST(SUM(dblNetWeight) AS NUMERIC(18, 6)) dblShippedWeight,
									MIN(intItemUOMId) intItemUOMId 
							FROM	vyuCTContStsInventoryReceipt	
							GROUP
							BY		intContractDetailId	
						)CR	ON	CR.intContractDetailId	=	CD.intContractDetailId	
			) s
	UNPIVOT	(strValue FOR strName IN 
				(
					[Shipped],
					[To be Shipped],
					[Recd Wt in Wh],
					[To be Received]
				)
			) UP
