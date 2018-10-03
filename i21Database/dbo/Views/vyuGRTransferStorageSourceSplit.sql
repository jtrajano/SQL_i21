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
	, ST.strStorageTypeDescription
	, SR.strScheduleDescription
FROM tblGRTransferStorageSourceSplit TSS
INNER JOIN tblGRTransferStorage TS
	ON TS.intTransferStorageId = TSS.intTransferStorageId
INNER JOIN tblGRStorageType ST
	ON ST.intStorageScheduleTypeId = TSS.intStorageTypeId
INNER JOIN tblGRStorageScheduleRule SR
	ON SR.intStorageScheduleRuleId = TSS.intStorageScheduleId
