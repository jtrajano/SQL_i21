CREATE VIEW [dbo].[vyuGRTransferStorageSourceSplit]
AS
SELECT 
	TSS.intTransferStorageSourceSplitId
	, TSS.intTransferStorageId
	, TSS.intSourceCustomerStorageId
	, TSS.intStorageTypeId
	, TSS.intStorageScheduleId
	, TSS.intContractDetailId
	, TSS.dblOriginalUnits
	, TSS.dblDeductedUnits
	, TSS.dblSplitPercent
	, ST.strStorageTypeDescription
	, SR.strScheduleDescription
	, CS.strStorageTicketNumber
	, CS.dtmDeliveryDate
	, CS.strDPARecieptNumber
	, CH.strContractNumber
FROM tblGRTransferStorageSourceSplit TSS
INNER JOIN tblGRTransferStorage TS
	ON TS.intTransferStorageId = TSS.intTransferStorageId
INNER JOIN tblGRCustomerStorage CS
	ON CS.intCustomerStorageId = TSS.intSourceCustomerStorageId
INNER JOIN tblGRStorageType ST
	ON ST.intStorageScheduleTypeId = TSS.intStorageTypeId
INNER JOIN tblGRStorageScheduleRule SR
	ON SR.intStorageScheduleRuleId = TSS.intStorageScheduleId
LEFT JOIN (
			tblCTContractDetail CD
			INNER JOIN tblCTContractHeader CH
				ON CH.intContractHeaderId = CD.intContractHeaderId
		) ON CD.intContractDetailId = TSS.intContractDetailId

