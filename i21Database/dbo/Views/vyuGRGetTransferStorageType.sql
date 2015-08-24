CREATE VIEW [dbo].[vyuGRGetTransferStorageType]
AS
SELECT DISTINCT a.intStorageScheduleTypeId  
 ,a.strStorageTypeDescription
 ,b.intCurrencyID  
FROM tblGRStorageType a  
JOIN tblGRStorageScheduleRule b ON b.intStorageType = a.intStorageScheduleTypeId  
WHERE a.ysnCustomerStorage=0 AND CONVERT(NVARCHAR, GETDATE(), 106) BETWEEN ISNULL(CONVERT(NVARCHAR, b.dtmEffectiveDate, 106), CONVERT(NVARCHAR, GETDATE(), 106))  
  AND ISNULL(CONVERT(NVARCHAR, b.dtmTerminationDate, 106), CONVERT(NVARCHAR, GETDATE(), 106))