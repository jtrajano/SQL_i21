CREATE VIEW [dbo].[vyuGRGetTransferStorageType]
AS
SELECT DISTINCT ST.intStorageScheduleTypeId  
 ,ST.strStorageTypeDescription
 ,SR.intCurrencyID
 ,ST.ysnDPOwnedType  
FROM tblGRStorageType ST  
JOIN tblGRStorageScheduleRule SR ON SR.intStorageType = ST.intStorageScheduleTypeId  
WHERE ST.ysnActive=1 AND ST.ysnCustomerStorage=0 
AND dbo.fnRemoveTimeOnDate(GETDATE())
BETWEEN ISNULL(dbo.fnRemoveTimeOnDate(SR.dtmEffectiveDate), dbo.fnRemoveTimeOnDate(GETDATE()))  
AND ISNULL(dbo.fnRemoveTimeOnDate(SR.dtmTerminationDate), dbo.fnRemoveTimeOnDate(GETDATE()))