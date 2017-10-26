CREATE VIEW [dbo].[vyuGRSellOffsiteTicketNotMapped]
AS
SELECT    
  intSellOffsiteId			  = SO.intSellOffsiteId
 ,intSellOffsiteTicketId	  = SOT.intSellOffsiteTicketId
 ,intCustomerStorageId		  = SOT.intCustomerStorageId
 ,dblUnits					  = SOT.dblUnits
 ,dblOpenBalance			  = V.dblOpenBalance
 ,strStorageTicketNumber	  = V.strStorageTicketNumber
 ,intCompanyLocationId		  = V.intCompanyLocationId
 ,strLocationName			  = V.strLocationName
 ,intStorageTypeId			  = V.intStorageTypeId		
 ,strStorageTypeDescription	  = V.strStorageTypeDescription
 ,intStorageScheduleId		  = V.intStorageScheduleId
 ,strScheduleId				  = V.strScheduleId
 ,intContractHeaderId		  = V.intContractHeaderId
 ,strContractNumber			  = V.strContractNumber
 ,dblDiscountUnPaid			  = V.dblDiscountUnPaid
 ,dblStorageUnPaid			  = V.dblStorageUnPaid 
FROM tblGRSellOffsite SO
JOIN tblGRSellOffsiteTicket SOT ON SOT.intSellOffsiteId=SO.intSellOffsiteId
JOIN vyuGROffSiteSearchView V ON V.intCustomerStorageId=SOT.intCustomerStorageId