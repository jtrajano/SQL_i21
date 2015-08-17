CREATE VIEW [dbo].[vyuGRGetTransferStorageType]
AS
SELECT DISTINCT a.intStorageScheduleTypeId
	,a.strStorageTypeDescription
FROM tblGRStorageType a
JOIN tblGRStorageScheduleRule b ON b.intStorageType = a.intStorageScheduleTypeId
JOIN tblGRCustomerStorage c ON c.intCurrencyId = b.intCurrencyID
WHERE CONVERT(NVARCHAR, GETDATE(), 106) BETWEEN ISNULL(CONVERT(NVARCHAR, b.dtmEffectiveDate, 106), CONVERT(NVARCHAR, GETDATE(), 106))
		AND ISNULL(CONVERT(NVARCHAR, b.dtmTerminationDate, 106), CONVERT(NVARCHAR, GETDATE(), 106))