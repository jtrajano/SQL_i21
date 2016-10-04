CREATE VIEW [dbo].[vyuGRGetAllStorageType]
AS 
SELECT 
 intStorageScheduleTypeId
,strStorageTypeDescription
,strStorageTypeCode
,ysnReceiptedStorage
,intConcurrencyId
,strOwnedPhysicalStock
,ysnDPOwnedType
,ysnGrainBankType
,ysnActive
,ysnCustomerStorage FROM tblGRStorageType 
