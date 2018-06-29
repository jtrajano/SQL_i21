CREATE VIEW [dbo].[vyuSCGetScaleDistribution]
AS SELECT 
IRI.intInventoryReceiptItemId
,SC.intTicketId
,(
	CASE 
		WHEN CTD.intContractDetailId > 0 AND CTD.intPricingTypeId != 5 THEN -2
		WHEN ISNULL(CTD.intContractDetailId,0) = 0 AND IRI.intOwnershipType = 1 THEN -3
		WHEN ISNULL(SC.intLoadId,0) > 0 THEN -6
		ELSE GRT.intStorageScheduleTypeId 
	END
) AS intStorageScheduleTypeId
,(
	CASE 
		WHEN CTD.intContractDetailId > 0 AND CTD.intPricingTypeId != 5 THEN 'CNT'
		WHEN ISNULL(CTD.intContractDetailId,0) = 0 AND IRI.intOwnershipType = 1 THEN 'SPT'
		WHEN ISNULL(SC.intLoadId,0) > 0 THEN 'LOD'
		ELSE GRT.strStorageTypeCode 
	END
) AS strDistributionCode
,(
	CASE 
		WHEN CTD.intContractDetailId > 0 AND CTD.intPricingTypeId != 5 THEN 'Contract'
		WHEN ISNULL(CTD.intContractDetailId,0) = 0 AND IRI.intOwnershipType = 1 THEN 'Spot Sale'
		WHEN ISNULL(SC.intLoadId,0) > 0 THEN 'Load'
		ELSE GRT.strStorageTypeDescription 
	END
) AS strDistributionType
,CTD.intContractDetailId
,CTD.intPricingTypeId 
,GRS.intCustomerStorageId
from tblICInventoryReceiptItem IRI 
LEFT JOIN tblICInventoryReceipt IR ON IR.intInventoryReceiptId = IRI.intInventoryReceiptId
LEFT JOIN tblSCTicket SC ON SC.intTicketId = IRI.intSourceId
LEFT JOIN tblCTContractDetail CTD ON CTD.intContractDetailId = IRI.intLineNo
LEFT JOIN tblGRCustomerStorage GRS ON GRS.intTicketId = IRI.intSourceId
LEFT JOIN tblGRStorageType GRT ON GRT.intStorageScheduleTypeId = GRS.intStorageTypeId
WHERE IR.intSourceType = 1