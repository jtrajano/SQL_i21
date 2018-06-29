CREATE VIEW [dbo].[vyuGRSettleStorageTicketNotMapped]
AS
SELECT    
  S.intSettleStorageId
 ,T.intSettleStorageTicketId
 ,T.intCustomerStorageId
 ,T.dblUnits AS dblUnits
 ,V.dblOpenBalance
 ,V.strStorageTicketNumber
 ,V.intCompanyLocationId
 ,V.strLocationName
 ,V.intStorageTypeId
 ,V.strStorageTypeDescription
 ,V.intStorageScheduleId
 ,V.strScheduleId
 ,V.intContractHeaderId
 ,V.strContractNumber
 ,V.dblDiscountUnPaid
 ,V.dblStorageUnPaid 
FROM tblGRSettleStorage S
JOIN tblGRSettleStorageTicket T ON T.intSettleStorageId=S.intSettleStorageId
JOIN vyuGRStorageSearchView V ON V.intCustomerStorageId=T.intCustomerStorageId  