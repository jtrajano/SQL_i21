CREATE VIEW [dbo].[vyuGRTransferStorageSearchView]
AS
SELECT
	intTransferStorageId			= SourceTransfer.intTransferStorageId
	,strTransferStorageTicket		= SourceTransfer.strTransferStorageTicket
	,intFromCustomerStorageId		= SourceTransfer.intCustomerStorageId
	,strFromStorageTicketNumber		= SourceTransfer.strStorageTicketNumber
	,dtmTransferStorageDate			= SourceTransfer.dtmTransferStorageDate
	,intFromEntityId				= SourceTransfer.intEntityId
	,strFromEntityName				= SourceTransfer.strEntityName
	,intToEntityId					= SplitTransfer.intEntityId
	,strToEntityName				= SplitTransfer.strEntityName
	,intFromCompanyLocationId		= SourceTransfer.intCompanyLocationId
	,strFromLocationName			= SourceTransfer.strLocationName
	,intToCompanyLocationId			= SplitTransfer.intCompanyLocationId
	,strToLocationName				= SplitTransfer.strLocationName
	,intCommodityId					= SourceTransfer.intCommodityId
	,strCommodityCode				= SourceTransfer.strCommodityCode
	,intItemId						= SourceTransfer.intItemId
	,strItemNo						= SourceTransfer.strItemNo
	,intFromStorageTypeId			= SourceTransfer.intStorageTypeId
	,strFromStorageTypeDescription	= SourceTransfer.strStorageTypeDescription
	,intToStorageTypeId				= SplitTransfer.intStorageTypeId
	,strToStorageTypeDescription	= SplitTransfer.strStorageTypeDescription
	,dblOriginalUnits				= SourceTransfer.dblOriginalUnits
	,dblSplitPercent				= SplitTransfer.dblSplitPercent
	,dblDeductedUnits				= SplitTransfer.dblOriginalUnits
	,dblOpenBalance					= SplitTransfer.dblOriginalUnits
	,ysnPosted						= SourceTransfer.ysnPosted
	,intUserId						= SourceTransfer.intUserId
	,strUserName					= SourceTransfer.strUserName
	,intSourceCustomerStorageId
FROM (
		SELECT
			 TS.intTransferStorageId
			,TS.strTransferStorageTicket
			,TS.dtmTransferStorageDate
			,TS.intEntityId
			,strEntityName				= EMSource.strName
			,TS.intCompanyLocationId
			,CLSource.strLocationName
			,CSSource.intCommodityId
			,Commodity.strCommodityCode
			,TS.intItemId
			,Item.strItemNo
			,TSource.intStorageTypeId
			,STSource.strStorageTypeDescription
			,intCustomerStorageId		= TSource.intSourceCustomerStorageId
			,CSSource.strStorageTicketNumber
			,TSource.dblOriginalUnits
			,TSource.dblDeductedUnits
			,TSource.dblSplitPercent
			,CSSource.dblOpenBalance
			,ysnPosted					= CAST(1 AS BIT) --TS.ysnPosted
			,TS.intUserId
			,US.strUserName
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
		INNER JOIN tblGRCustomerStorage CSSource
			ON CSSource.intCustomerStorageId = TSource.intSourceCustomerStorageId
		INNER JOIN tblICCommodity Commodity
			ON Commodity.intCommodityId = CSSource.intCommodityId
		INNER JOIN tblSMUserSecurity US
			ON US.intEntityId = TS.intUserId
		
	) SourceTransfer
INNER JOIN (
		SELECT
			TSplit.intTransferStorageId
			,TSplit.intEntityId
			,strEntityName				= EMSplit.strName
			,TSplit.intCompanyLocationId
			,CLSplit.strLocationName
			,TSplit.intStorageTypeId
			,STSplit.strStorageTypeDescription
			,dblOriginalUnits			= ISNULL(TSR.dblUnitQty,TSplit.dblUnits)
			,dblSplitPercent			= TSplit.dblSplitPercent
			,intSourceCustomerStorageId
		FROM tblGRTransferStorageSplit TSplit
		INNER JOIN tblEMEntity EMSplit
			ON EMSplit.intEntityId = TSplit.intEntityId
		INNER JOIN tblSMCompanyLocation CLSplit
			ON CLSplit.intCompanyLocationId = TSplit.intCompanyLocationId
		INNER JOIN tblGRStorageType STSplit
			ON STSplit.intStorageScheduleTypeId = TSplit.intStorageTypeId
		LEFT JOIN tblGRTransferStorageReference TSR
			ON TSR.intTransferStorageSplitId  = TSplit.intTransferStorageSplitId 
	) SplitTransfer 
		ON SourceTransfer.intTransferStorageId = SplitTransfer.intTransferStorageId AND CASE WHEN (SplitTransfer.intSourceCustomerStorageId IS NOT NULL) THEN CASE WHEN SplitTransfer.intSourceCustomerStorageId = SourceTransfer.intCustomerStorageId THEN 1 ELSE 0 END ELSE  1 END = 1