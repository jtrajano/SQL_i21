CREATE VIEW [dbo].[vyuGRGetSettleStorage]
AS     
 SELECT 
 SS.intSettleStorageId
,SS.intEntityId
,E.strName AS strEntityName 
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
,dblDiscountsDue
,dblNetSettlement
,SS.ysnPosted
,SS.intBillId
,Bill.strBillId
FROM tblGRSettleStorage SS
JOIN tblEMEntity E ON E.intEntityId = SS.intEntityId  
JOIN tblICItem Item ON Item.intItemId = SS.intItemId
JOIN tblAPBill Bill ON Bill.intBillId=SS.intBillId
