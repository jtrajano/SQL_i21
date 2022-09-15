CREATE VIEW [dbo].[vyuLGAllocationStatus]
AS
	SELECT 
		intAllocationHeaderId,
		strAllocationStatus = CASE 
								WHEN dblPContractAllocatedQty = dblPDetailQuantity THEN 'Allocated'
								WHEN dblPContractAllocatedQty < dblPDetailQuantity THEN 'Partially Allocated' END,
		strAllocationNumber,
		dblAllocatedQuantity = dblPContractAllocatedQty,
		strPurchaseContractNumber,
		strSalesContractNumber
	FROM vyuLGAllocatedContracts

	UNION ALL

	SELECT 
		intAllocationHeaderId = NULL,
		strAllocationStatus = 'Unallocated',
		strAllocationNumber = NULL,
		dblAllocatedQuantity,
		strPurchaseContractNumber = CASE WHEN intPurchaseSale = 1 THEN strContractNumber ELSE NULL END,
		strSalesContractNumber = CASE WHEN intPurchaseSale = 2 THEN strContractNumber ELSE NULL END 
	FROM vyuLGAllocationOpenContracts WHERE dblAllocatedQuantity = 0

	UNION ALL

	SELECT
		intAllocationHeaderId = NULL,
		strAllocationStatus = 'Reserved',
		strAllocationNumber = NULL,
		dblAllocatedQuantity = 0,
		strPurchaseContractNumber = CASE WHEN intPurchaseSale = 1 THEN strContractNumber ELSE NULL END,
		strSalesContractNumber = CASE WHEN intPurchaseSale = 2 THEN strContractNumber ELSE NULL END 
	FROM tblLGReservation R
	LEFT JOIN tblCTContractDetail CD ON R.intContractDetailId = CD.intContractDetailId
	LEFT JOIN tblCTContractHeader CH ON CD.intContractHeaderId = CH.intContractHeaderId