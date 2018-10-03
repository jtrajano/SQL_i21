CREATE VIEW [dbo].[vyuGRTransferStorageSplit]
AS
SELECT 
	TSS.intTransferStorageSplitId
    , TSS.intTransferStorageId
    , TSS.intTransferToCustomerStorageId
    , TSS.intEntityId
    , TSS.intLocationId
    , TSS.intStorageTypeId
    , TSS.intStorageScheduleId
    , TSS.intContractDetailId
    , TSS.dblSplitPercent
    , TSS.dblUnits
    , EM.strName
    , CL.strLocationName
    , ST.strStorageTypeDescription
    , SR.strScheduleDescription
FROM tblGRTransferStorageSplit TSS
INNER JOIN tblGRTransferStorage TS
	ON TS.intTransferStorageId = TSS.intTransferStorageId
INNER JOIN tblEMEntity EM
	ON EM.intEntityId = TSS.intEntityId
INNER JOIN tblSMCompanyLocation CL
	ON CL.intCompanyLocationId = TSS.intLocationId
INNER JOIN tblGRStorageType ST
	ON ST.intStorageScheduleTypeId = TSS.intStorageTypeId
INNER JOIN tblGRStorageScheduleRule SR
	ON SR.intStorageScheduleRuleId = TSS.intStorageScheduleId
