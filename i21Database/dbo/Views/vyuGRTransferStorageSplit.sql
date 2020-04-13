CREATE VIEW [dbo].[vyuGRTransferStorageSplit]
AS
SELECT 
	intTransferStorageSplitId		= TSS.intTransferStorageSplitId
    , intTransferStorageId			= TSS.intTransferStorageId
    , intTransferToCustomerStorageId= TSS.intTransferToCustomerStorageId
    , intEntityId					= TSS.intEntityId
    , intCompanyLocationId			= TSS.intCompanyLocationId
    , intStorageTypeId				= TSS.intStorageTypeId
    , intStorageScheduleId			= TSS.intStorageScheduleId
    , intContractDetailId			= TSS.intContractDetailId
    , dblSplitPercent				= TSS.dblSplitPercent
    , dblUnits						= TSS.dblUnits
    , strEntityName					= EM.strName
    , strLocationName				= CL.strLocationName
    , strStorageTypeDescription		= ST.strStorageTypeDescription
    , strScheduleDescription		= SR.strScheduleDescription
	, strContractNumber				= CH.strContractNumber
    , CS.strStorageTicketNumber
    , TS.ysnReversed
FROM tblGRTransferStorageSplit TSS
INNER JOIN tblGRTransferStorage TS
	ON TS.intTransferStorageId = TSS.intTransferStorageId
INNER JOIN tblEMEntity EM
	ON EM.intEntityId = TSS.intEntityId
INNER JOIN tblSMCompanyLocation CL
	ON CL.intCompanyLocationId = TSS.intCompanyLocationId
INNER JOIN tblGRStorageType ST
	ON ST.intStorageScheduleTypeId = TSS.intStorageTypeId
INNER JOIN tblGRStorageScheduleRule SR
	ON SR.intStorageScheduleRuleId = TSS.intStorageScheduleId
INNER JOIN tblGRCustomerStorage CS
    ON CS.intCustomerStorageId = TSS.intTransferToCustomerStorageId
LEFT JOIN (
			tblCTContractDetail CD
			INNER JOIN tblCTContractHeader CH
				ON CH.intContractHeaderId = CD.intContractHeaderId
		) ON CD.intContractDetailId = TSS.intContractDetailId
