CREATE VIEW [dbo].[vyuGRGetStorageTakeOut]
AS
SELECT 
 intStorageTypeId
,strStorageTypeDescription
,intEntityId
,strName
,intItemId
,strItemNo
,SUM(dblOpenBalance) dblOpenBalance
FROM vyuGRGetStorageTransferTicket
WHERE ysnCustomerStorage=0 AND ysnDPOwnedType=0  
GROUP BY 
intStorageTypeId
,strStorageTypeDescription
,intEntityId
,strName
,intItemId
,strItemNo