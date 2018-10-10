CREATE VIEW [dbo].[vyuGRTransferStorageSearchView]
AS
SELECT
	intTransferStorageId		= TS.intTransferStorageId
	,strTransferStorageTicket	= TS.strTransferStorageTicket
	,dtmTransferStorageDate		= TS.dtmTransferStorageDate
	,intEntityId				= TS.intEntityId
	,strEntityName				= EMSource.strName
	,intCompanyLocationId		= TS.intCompanyLocationId
	,strLocationName			= CLSource.strLocationName
	,intCommodityId				= CSSource.intCommodityId
	,strCommodityCode			= Commodity.strCommodityCode
	,intItemId					= TS.intItemId
	,strItemNo					= Item.strItemNo
	,intStorageTypeId			= TSource.intStorageTypeId
	,strStorageTypeDescription	= STSource.strStorageTypeDescription
	,intStorageScheduleId		= TSource.intStorageScheduleId
	,strScheduleId				= SRSource.strScheduleId
	,intCustomerStorageId		= TSource.intSourceCustomerStorageId
	,strStorageTicketNumber		= CSSource.strStorageTicketNumber
	,dblOriginalUnits			= TSource.dblOriginalUnits
	,dblDeductedUnits			= TSource.dblDeductedUnits
	,dblSplitPercent			= TSource.dblSplitPercent
	,dblOpenBalance				= CSSource.dblOpenBalance
	,intContractNumer			= CD.intContractHeaderId
	,strContractNumber			= CH.strContractNumber
	,ysnPosted					= 1 --TS.ysnPosted
	,intUserId					= TS.intUserId
	,strUserName				= US.strUserName
FROM tblGRTransferStorageSourceSplit TSource
INNER JOIN tblGRTransferStorage TS	
	ON TS.intTransferStorageId = TSource.intTransferStorageId
INNER JOIN tblEMEntity EMSource
	ON EMSource.intEntityId = TS.intEntityId
INNER JOIN tblSMCompanyLocation CLSource
	ON CLSource.intCompanyLocationId = TS.intCompanyLocationId
INNER JOIN tblICItem Item
	ON Item.intItemId = TS.intItemId
INNER JOIN tblGRStorageType STSource
	ON STSource.intStorageScheduleTypeId = TSource.intStorageTypeId
INNER JOIN tblGRStorageScheduleRule SRSource
	ON SRSource.intStorageScheduleRuleId = TSource.intStorageScheduleId
INNER JOIN tblGRCustomerStorage CSSource
	ON CSSource.intCustomerStorageId = TSource.intSourceCustomerStorageId
INNER JOIN tblICCommodity Commodity
	ON Commodity.intCommodityId = CSSource.intCommodityId
LEFT JOIN (
			tblCTContractDetail CD
			INNER JOIN tblCTContractHeader CH
				ON CH.intContractHeaderId = CD.intContractHeaderId
		) ON CD.intContractDetailId = TSource.intContractDetailId
INNER JOIN tblSMUserSecurity US
	ON US.intEntityId = TS.intUserId

UNION ALL

SELECT
	intTransferStorageId		= TS.intTransferStorageId
	,strTransferStorageTicket	= TS.strTransferStorageTicket
	,dtmTransferStorageDate		= TS.dtmTransferStorageDate
	,intEntityId				= TS.intEntityId
	,strEntityName				= EMSplit.strName
	,intCompanyLocationId		= TS.intCompanyLocationId
	,strLocationName			= CLSplit.strLocationName
	,intCommodityId				= CSSplit.intCommodityId
	,strCommodityCode			= Commodity.strCommodityCode
	,intItemId					= TS.intItemId
	,strItemNo					= Item.strItemNo
	,intStorageTypeId			= TSplit.intStorageTypeId
	,strStorageTypeDescription	= STSplit.strStorageTypeDescription
	,intStorageScheduleId		= TSplit.intStorageScheduleId
	,strScheduleId				= SRSplit.strScheduleId
	,intCustomerStorageId		= TSplit.intTransferToCustomerStorageId
	,strStorageTicketNumber		= CSSplit.strStorageTicketNumber
	,dblOriginalUnits			= TSplit.dblUnits
	,dblDeductedUnits			= 0
	,dblSplitPercent			= TSplit.dblSplitPercent
	,dblOpenBalance				= CSSplit.dblOpenBalance
	,intContractNumer			= CD.intContractHeaderId
	,strContractNumber			= CH.strContractNumber
	,ysnPosted					= 1 --TS.ysnPosted
	,intUserId					= TS.intUserId
	,strUserName				= USSplit.strUserName
FROM tblGRTransferStorageSplit TSplit
INNER JOIN tblGRTransferStorage TS
	ON TS.intTransferStorageId = TSplit.intTransferStorageId
INNER JOIN tblEMEntity EMSplit
	ON EMSplit.intEntityId = TSplit.intEntityId
INNER JOIN tblSMCompanyLocation CLSplit
	ON CLSplit.intCompanyLocationId = TSplit.intCompanyLocationId
INNER JOIN tblICItem Item
	ON Item.intItemId = TS.intItemId
INNER JOIN tblGRStorageType STSplit
	ON STSplit.intStorageScheduleTypeId = TSplit.intStorageTypeId
INNER JOIN tblGRStorageScheduleRule SRSplit
	ON SRSplit.intStorageScheduleRuleId = TSplit.intStorageScheduleId
INNER JOIN tblGRCustomerStorage CSSplit
	ON CSSplit.intCustomerStorageId = TSplit.intTransferToCustomerStorageId
INNER JOIN tblICCommodity Commodity
	ON Commodity.intCommodityId = CSSplit.intCommodityId
LEFT JOIN (
			tblCTContractDetail CD
			INNER JOIN tblCTContractHeader CH
				ON CH.intContractHeaderId = CD.intContractHeaderId
		) ON CD.intContractDetailId = TSplit.intContractDetailId
INNER JOIN tblSMUserSecurity USSplit
	ON USSplit.intEntityId = TS.intUserId