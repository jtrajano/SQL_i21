CREATE VIEW [dbo].[vyuLGAllocationStatus]
AS
	SELECT 
		V.intAllocationHeaderId,
		strAllocationStatus = CASE 
								WHEN dblPContractAllocatedQty = dblPDetailQuantity THEN 'Allocated'
								WHEN dblPContractAllocatedQty < dblPDetailQuantity THEN 'Partially Allocated' END,
		V.strAllocationNumber,
		dblAllocatedQuantity = ALD.dblPAllocatedQty,
		V.strPurchaseContractNumber,
		V.intPContractDetailId AS intContractDetailId,
		V.strSalesContractNumber,
		dblReservedQuantity = NULL
	FROM vyuLGAllocatedContracts V
	LEFT JOIN tblLGAllocationDetail ALD ON ALD.intAllocationDetailId  = V.intAllocationDetailId

	UNION ALL

	SELECT 
		intAllocationHeaderId = NULL,
		strAllocationStatus = 'Unallocated',
		strAllocationNumber = NULL,
		dblAllocatedQuantity,
		strPurchaseContractNumber = CASE WHEN intPurchaseSale = 1 THEN strContractNumber ELSE NULL END,
		intContractDetailId,
		strSalesContractNumber = CASE WHEN intPurchaseSale = 2 THEN strContractNumber ELSE NULL END,
		dblReservedQuantity = NULL
	FROM vyuLGAllocationOpenContracts WHERE dblAllocatedQuantity = 0

	UNION ALL

	SELECT
		intAllocationHeaderId = NULL,
		strAllocationStatus = 'Reserved',
		strAllocationNumber = NULL,
		dblAllocatedQuantity = NULL,
		strPurchaseContractNumber = CASE WHEN intPurchaseSale = 1 THEN strContractNumber ELSE NULL END,
		R.intContractDetailId,
		strSalesContractNumber = CASE WHEN intPurchaseSale = 2 THEN strContractNumber ELSE NULL END ,
		R.dblReservedQuantity
	FROM tblLGReservation R
	LEFT JOIN tblCTContractDetail CD ON R.intContractDetailId = CD.intContractDetailId
	LEFT JOIN tblCTContractHeader CH ON CD.intContractHeaderId = CH.intContractHeaderId
GO
