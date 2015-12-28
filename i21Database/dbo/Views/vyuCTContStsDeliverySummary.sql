CREATE VIEW [dbo].[vyuCTContStsDeliverySummary]

AS 

	SELECT	CAST(ROW_NUMBER() OVER (ORDER BY UP.intContractDetailId ASC) AS INT) intUniqueId,
			UP.intContractDetailId,
			UP.strName,
			UP.strValue
	FROM	(
				SELECT	AD.intPContractDetailId intContractDetailId,
						LTRIM(CAST(SUM(SI.dblQuantity)AS NUMERIC(18,2))) Delivered,
						LTRIM(CAST(CD.dblQuantity - SUM(SI.dblQuantity) AS NUMERIC(18,2))) AS [To be Delivered]
				FROM	tblLGPickLotDetail			PL
				JOIN	tblLGPickLotHeader			LH	ON	LH.intPickLotHeaderId		=	PL.intPickLotHeaderId
				JOIN	tblLGAllocationDetail		AD	ON	AD.intAllocationDetailId	=	PL.intAllocationDetailId
				JOIN	tblICInventoryShipmentItem	SI	ON	SI.intLineNo				=	PL.intPickLotDetailId
				JOIN	tblICInventoryShipment		SH	ON	SH.intInventoryShipmentId	=	SI.intInventoryShipmentId AND SH.intOrderType = 1 AND intSourceType = 3
				JOIN	tblCTContractDetail			CD	ON	CD.intContractDetailId		=	AD.intPContractDetailId
				GROUP BY AD.intPContractDetailId,CD.dblQuantity
				
				UNION ALL
				
				SELECT	AD.intSContractDetailId,
						LTRIM(CAST(SUM(SI.dblQuantity)AS NUMERIC(18,2))) Delivered,
						LTRIM(CAST(CD.dblQuantity - SUM(SI.dblQuantity) AS NUMERIC(18,2))) AS [To be Delivered]
				FROM	tblLGPickLotDetail			PL
				JOIN	tblLGPickLotHeader			LH	ON	LH.intPickLotHeaderId		=	PL.intPickLotHeaderId
				JOIN	tblLGAllocationDetail		AD	ON	AD.intAllocationDetailId	=	PL.intAllocationDetailId
				JOIN	tblICInventoryShipmentItem	SI	ON	SI.intLineNo				=	PL.intPickLotDetailId
				JOIN	tblICInventoryShipment		SH	ON	SH.intInventoryShipmentId	=	SI.intInventoryShipmentId AND SH.intOrderType = 1 AND intSourceType = 3
				JOIN	tblCTContractDetail			CD	ON	CD.intContractDetailId		=	AD.intSContractDetailId
				GROUP BY AD.intSContractDetailId,CD.dblQuantity
			) s
			UNPIVOT	(strValue FOR strName IN 
						(
							Delivered,
							[To be Delivered] 
						)
			) UP

