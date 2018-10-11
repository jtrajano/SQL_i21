CREATE VIEW [dbo].[vyuGRTransferStorage]
AS
SELECT 
	TS.intTransferStorageId
    ,TS.strTransferStorageTicket
    ,TS.intEntityId
    ,TS.intCompanyLocationId
    ,TS.intStorageScheduleTypeId
    ,TS.intItemId
    ,TS.intItemUOMId
	,TS.intTransferLocationId
    ,TS.dblTotalUnits
    ,TS.dtmTransferStorageDate
    ,TS.intConcurrencyId
    ,TS.intUserId
	,strEntityName = EM.strName
	,CL.strLocationName
	,ST.strStorageTypeDescription
	,Item.strItemNo
	,strUnitMeasure = UOM.strUnitMeasure
	,strTransferLocationName = CLTransfer.strLocationName
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
INNER JOIN tblSMCompanyLocation CLTransfer
	ON CL.intCompanyLocationId = TS.intTransferLocationId

