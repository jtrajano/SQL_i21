CREATE VIEW vyuSCTicketDirectInDistributionAllocationAndVoucher

AS

SELECT 
		TICKET.intTicketId
		, TICKET.strTicketNumber		
		, BILL_DETAIL.dblQtyReceived	
		, BILL_DETAIL.dblCost	
		, ROUND(dbo.fnMultiply(BILL_DETAIL.dblCost, BILL_DETAIL.dblQtyReceived), 2) AS dblAmount
		, strAllocationType = CASE WHEN DISTRIBUTION_ALLOCATION.intSourceType = 1 THEN 'Contract'
											  WHEN DISTRIBUTION_ALLOCATION.intSourceType = 2 THEN 'Load'
											  WHEN DISTRIBUTION_ALLOCATION.intSourceType = 3 THEN 'Storage'
											  WHEN DISTRIBUTION_ALLOCATION.intSourceType = 4 THEN 'Spot'
										 END
	FROM tblSCTicketDistributionAllocation DISTRIBUTION_ALLOCATION
		JOIN tblSCTicket TICKET 
			ON DISTRIBUTION_ALLOCATION.intTicketId = TICKET.intTicketId

		JOIN tblAPBillDetail BILL_DETAIL
			ON DISTRIBUTION_ALLOCATION.intTicketDistributionAllocationId = BILL_DETAIL.intTicketDistributionAllocationId
				AND TICKET.intItemId = BILL_DETAIL.intItemId






