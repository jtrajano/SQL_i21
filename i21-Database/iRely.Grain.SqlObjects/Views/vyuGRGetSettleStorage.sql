CREATE VIEW [dbo].[vyuGRGetSettleStorage]
AS     
 SELECT 
 intSettleStorageId			= SS.intSettleStorageId
,intEntityId				= SS.intEntityId
,strEntityName				= E.strName
,intCompanyLocationId		= SS.intCompanyLocationId
,strLocationName			= ISNULL(L.strLocationName, 'Multi')
,intItemId					= SS.intItemId
,strItemNo					= Item.strItemNo
,dblSpotUnits				= SS.dblSpotUnits
,dblFuturesPrice			= SS.dblFuturesPrice
,dblFuturesBasis			= SS.dblFuturesBasis
,dblCashPrice				= SS.dblCashPrice
,strStorageAdjustment		= SS.strStorageAdjustment
,dtmCalculateStorageThrough = SS.dtmCalculateStorageThrough
,dblAdjustPerUnit			= SS.dblAdjustPerUnit
,dblStorageDue				= SS.dblStorageDue
,strStorageTicket			= SS.strStorageTicket
,dblSelectedUnits			= SS.dblSelectedUnits
,dblUnpaidUnits				= SS.dblUnpaidUnits
,dblSettleUnits				= SS.dblSettleUnits
,dblDiscountsDue			= SS.dblDiscountsDue
,dblNetSettlement			= SS.dblNetSettlement
,intCreatedUserId			= SS.intCreatedUserId
,strUserName				= Entity.strUserName
,dtmCreated					= SS.dtmCreated
,ysnPosted					= SS.ysnPosted
,intBillId					= SS.intBillId
,strBillId					= ISNULL(Bill.strBillId,'')
FROM tblGRSettleStorage SS
JOIN tblEMEntity E ON E.intEntityId = SS.intEntityId
LEFT JOIN tblSMCompanyLocation L ON L.intCompanyLocationId= SS.intCompanyLocationId
JOIN tblICItem Item ON Item.intItemId = SS.intItemId
JOIN tblSMUserSecurity Entity ON Entity.intEntityId=SS.intCreatedUserId
LEFT JOIN tblAPBill Bill ON Bill.intBillId=SS.intBillId

