CREATE VIEW [dbo].[vyuSCTicketApplyTransparency]
AS
	
	
SELECT
	'C-' + CAST(CONTRACT_ALLOCATION.intTicketApplyContractAllocationId AS NVARCHAR) AS ID
	, 1 as intType
	, CONTRACT_ALLOCATION.dblUnit	
	, TICKET.intTicketId
	, TICKET.strTicketNumber
	, TICKET.dblNetUnits
	, TICKET.intEntityId
	, TICKET_APPLY_TICKET.intTicketApplyId

	, 'CNT' AS strDistributionOption
	, CONTRACT_HEADER.strContractNumber
	, CONTRACT_DETAIL.dblFutures
	, CONTRACT_DETAIL.dblBasis
	, CONTRACT_DETAIL.intContractDetailId
	, CONTRACT_DETAIL.intContractHeaderId
	, CASE	WHEN	CONTRACT_DETAIL.intPricingTypeId = 2
		THEN	AD.dblSeqBasis
	WHEN	CONTRACT_DETAIL.intPricingTypeId = 3
		THEN	AD.dblSeqFutures
	ELSE	AD.dblSeqPrice
	END AS dblSequenceCost
	, NULL AS intStorageScheduleId
	, NULL AS intStorageScheduleTypeId
	, NULL AS ysnCustomerStorage
FROM tblSCTicketApplyContractAllocation CONTRACT_ALLOCATION
	JOIN tblSCTicketApplyTicket TICKET_APPLY_TICKET
		ON CONTRACT_ALLOCATION.intTicketApplyTicketId = TICKET_APPLY_TICKET.intTicketApplyTicketId
	JOIN tblSCTicket TICKET
		ON TICKET_APPLY_TICKET.intTicketId = TICKET.intTicketId
	JOIN tblSCTicketApplyContract TICKET_CONTRACT
		ON CONTRACT_ALLOCATION.intTicketApplyContractId = TICKET_CONTRACT.intTicketApplyContractId
	JOIN tblCTContractDetail CONTRACT_DETAIL
		ON TICKET_CONTRACT.intContractDetailId = CONTRACT_DETAIL.intContractDetailId
	JOIN tblCTContractHeader CONTRACT_HEADER
		ON CONTRACT_DETAIL.intContractHeaderId = CONTRACT_HEADER.intContractHeaderId
	CROSS APPLY	dbo.fnCTGetAdditionalColumnForDetailView(CONTRACT_DETAIL.intContractDetailId) AD


UNION ALL
SELECT
	'STR-' + CAST(STORAGE_ALLOCATION.intTicketApplyStorageAllocationId AS NVARCHAR)
	, 2 as intType
	, STORAGE_ALLOCATION.dblUnit
	, TICKET.intTicketId
	, TICKET.strTicketNumber
	, TICKET.dblNetUnits
	, TICKET.intEntityId
	, TICKET_APPLY_TICKET.intTicketApplyId
	, DISTRIBUTION_OPTION.strDistributionOption AS strDistributionOption
	, '' as strContractNumber
	, 0 as dblFutures--SPOT.dblFutures
	, 0 as dblBasis--SPOT.dblBasis
	, NULL AS intContractDetailId
	, NULL AS intContractHeaderId
	, 0 as dblSequenceCost	--SPOT.dblFutures + SPOT.dblBasis AS dblSequenceCost
	, DISTRIBUTION_OPTION.intStorageScheduleId
	, DISTRIBUTION_OPTION.intStorageScheduleTypeId
	, DISTRIBUTION_OPTION.ysnCustomerStorage
FROM tblSCTicketApplyStorageAllocation STORAGE_ALLOCATION
JOIN tblSCTicketApplyTicket TICKET_APPLY_TICKET
		ON STORAGE_ALLOCATION.intTicketApplyTicketId = TICKET_APPLY_TICKET.intTicketApplyTicketId
	JOIN tblSCTicket TICKET
		ON TICKET_APPLY_TICKET.intTicketId = TICKET.intTicketId
	JOIN tblICItem ITEM
		ON TICKET.intItemId = ITEM.intItemId	
	JOIN tblSCTicketApplyStorage STORAGE
		ON STORAGE_ALLOCATION.intTicketApplyStorageId = STORAGE.intTicketApplyStorageId
	JOIN vyuSCHoldTicketApplyAllowedStorageTypePerTicketPool DISTRIBUTION_OPTION
		ON STORAGE.intStorageScheduleId = DISTRIBUTION_OPTION.intStorageScheduleId	
			AND TICKET.intTicketPoolId = DISTRIBUTION_OPTION.intTicketPoolId
			AND TICKET.intProcessingLocationId = DISTRIBUTION_OPTION.intCompanyLocationId
			AND ITEM.intCommodityId = DISTRIBUTION_OPTION.intCommodity
WHERE STORAGE_ALLOCATION.dblUnit > 0
UNION ALL
SELECT
	'S-' + CAST(SPOT_ALLOCATION.intTicketApplySpotAllocationId AS NVARCHAR)
	, 10 as intType
	, SPOT_ALLOCATION.dblUnit
	, TICKET.intTicketId
	, TICKET.strTicketNumber
	, TICKET.dblNetUnits
	, TICKET.intEntityId
	, TICKET_APPLY_TICKET.intTicketApplyId
	, 'SPT' AS strDistributionOption
	, '' as strContractNumber
	, SPOT.dblFutures
	, SPOT.dblBasis
	, NULL AS intContractDetailId
	, NULL AS intContractHeaderId
	, SPOT.dblFutures + SPOT.dblBasis AS dblSequenceCost	
	, NULL AS intStorageScheduleId
	, NULL AS intStorageScheduleTypeId
	, NULL AS ysnCustomerStorage
FROM tblSCTicketApplySpotAllocation SPOT_ALLOCATION
JOIN tblSCTicketApplyTicket TICKET_APPLY_TICKET
		ON SPOT_ALLOCATION.intTicketApplyTicketId = TICKET_APPLY_TICKET.intTicketApplyTicketId
	JOIN tblSCTicket TICKET
		ON TICKET_APPLY_TICKET.intTicketId = TICKET.intTicketId
	JOIN tblSCTicketApplySpot SPOT
		ON SPOT_ALLOCATION.intTicketApplySpotId = SPOT.intTicketApplySpotId


GO

SELECT * FROM vyuSCTicketApplyTransparency WHERE intTicketApplyId = 35

--SELECT * FROM tblSCTicketApplyStorage WHERE intTicketApplyId = 35
--SELECT * FROM tblSCTicketApplySpot WHERE intTicketApplyId = 35
SELECT * FROM tblSCTicketApplyStorageAllocation