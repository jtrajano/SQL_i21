CREATE VIEW [dbo].[vyuGRTransferStorage]
AS
SELECT 
	 intTransferStorageId 		= TS.intTransferStorageId
    ,strTransferStorageTicket 	= TS.strTransferStorageTicket
    ,intEntityId 				= TS.intEntityId
    ,intCompanyLocationId 		= TS.intCompanyLocationId
    ,intStorageScheduleTypeId 	= TS.intStorageScheduleTypeId
    ,intItemId 					= TS.intItemId
    ,intItemUOMId 				= TS.intItemUOMId
	,intTransferLocationId 		= TS.intTransferLocationId
    ,dblTotalUnits 				= TS.dblTotalUnits
    ,dtmTransferStorageDate 	= TS.dtmTransferStorageDate
    ,intConcurrencyId 			= TS.intConcurrencyId
    ,intUserId 					= TS.intUserId
	,strEntityName 				= EM.strName
	,strLocationName 			= CL.strLocationName
	,strStorageTypeDescription	= ST.strStorageTypeDescription
	,strItemNo 					= Item.strItemNo
	,strUnitMeasure 			= UOM.strUnitMeasure
	,strTransferLocationName 	= (SELECT strLocationName FROM tblSMCompanyLocation WHERE intCompanyLocationId = TS.intTransferLocationId)
	,ysnReversed				= TS.ysnReversed
FROM tblGRTransferStorage TS
INNER JOIN tblEMEntity EM
	ON EM.intEntityId = TS.intEntityId
INNER JOIN tblSMCompanyLocation CL
	ON CL.intCompanyLocationId = TS.intCompanyLocationId
INNER JOIN tblGRStorageType ST
	ON ST.intStorageScheduleTypeId = TS.intStorageScheduleTypeId
INNER JOIN tblSMUserSecurity US
	ON US.intEntityId = TS.intUserId
INNER JOIN tblICItem Item
	ON Item.intItemId = TS.intItemId
INNER JOIN tblICItemUOM ItemUOM
	ON ItemUOM.intItemId = TS.intItemId
		AND ItemUOM.intItemUOMId = TS.intItemUOMId
INNER JOIN tblICUnitMeasure UOM
	ON UOM.intUnitMeasureId = ItemUOM.intUnitMeasureId
