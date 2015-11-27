CREATE VIEW [dbo].[vyuGRGetTransferStorageType]
AS
SELECT DISTINCT a.intStorageScheduleTypeId  
 ,a.strStorageTypeDescription
 ,b.intCurrencyID  
FROM tblGRStorageType a  
JOIN tblGRStorageScheduleRule b ON b.intStorageType = a.intStorageScheduleTypeId  
WHERE a.ysnActive=1 
AND dbo.fnRemoveTimeOnDate(GETDATE())
BETWEEN ISNULL(dbo.fnRemoveTimeOnDate(b.dtmEffectiveDate), dbo.fnRemoveTimeOnDate(GETDATE()))  
AND ISNULL(dbo.fnRemoveTimeOnDate(b.dtmTerminationDate), dbo.fnRemoveTimeOnDate(GETDATE()))