CREATE VIEW [dbo].[vyuGRGetSettleStorage]
AS     
 SELECT 
 SS.intSettleStorageId
,SS.intEntityId
,E.strName AS strEntityName 
,SS.intCompanyLocationId
,L.strLocationName
,SS.intItemId
,Item.strItemNo
,dblSpotUnits
,dblFuturesPrice
,dblFuturesBasis
,dblCashPrice
,strStorageAdjustment
,dtmCalculateStorageThrough
,dblAdjustPerUnit
,dblStorageDue
,strStorageTicket
,dblSelectedUnits
,SS.dblUnpaidUnits
,SS.dblSettleUnits
,dblDiscountsDue
,dblNetSettlement
,SS.intCreatedUserId
,Entity.strUserName
,SS.dtmCreated
,SS.ysnPosted
,SS.intBillId
,Bill.strBillId
FROM tblGRSettleStorage SS
JOIN tblEMEntity E ON E.intEntityId = SS.intEntityId
JOIN tblSMCompanyLocation L ON L.intCompanyLocationId= SS.intCompanyLocationId  
JOIN tblICItem Item ON Item.intItemId = SS.intItemId
JOIN tblSMUserSecurity Entity ON Entity.intEntityId=SS.intCreatedUserId
JOIN tblAPBill Bill ON Bill.intBillId=SS.intBillId
