CREATE VIEW [dbo].[vyuGRGetStorageOffSiteDetail]
AS
SELECT DISTINCT
 a.intCustomerStorageId
	 ,a.intCompanyLocationId	
	,sl.strSubLocationName [Loc]
	,a.dtmDeliveryDate [Delivery Date]
	,a.strStorageTicketNumber [Ticket]
	,a.intEntityId
	,E.strName [Customer]
	,a.strDPARecieptNumber [Receipt]
	,a.dblDiscountsDue [Disc Due]
	,a.dblStorageDue   [Storage Due]
	,a.dblOpenBalance  [Balance]
	,a.intStorageTypeId
	,b.strStorageTypeDescription [Storage Type]
	,a.intCommodityId
	,CM.strCommodityCode [Commodity Code]
	,CM.strDescription   [Commodity Description]
	,b.strOwnedPhysicalStock
	,b.ysnReceiptedStorage
	,b.ysnDPOwnedType
	,b.ysnGrainBankType
	,b.ysnActive ysnCustomerStorage 
	,a.strCustomerReference  
 	,a.dtmLastStorageAccrueDate  
 	,c1.strScheduleId,
 	isnull(ysnExternal,0) as ysnExternal,
	i.intItemId  	  
FROM tblICInventoryReceipt r
JOIN tblICInventoryReceiptItem ri ON r.intInventoryReceiptId = ri.intInventoryReceiptId
JOIN tblSCTicket sc on sc.intTicketId = ri.intSourceId
LEFT JOIN tblSMCompanyLocationSubLocation sl on sl.intCompanyLocationSubLocationId =sc.intSubLocationId and sl.intCompanyLocationId=sc.intProcessingLocationId 
join tblICItem i on i.intItemId=sc.intItemId
join tblGRStorageHistory sh on sh.intTicketId= sc.intTicketId 
join tblGRCustomerStorage a on a.intCustomerStorageId=sh.intCustomerStorageId
JOIN tblGRStorageType b ON b.intStorageScheduleTypeId = a.intStorageTypeId 
JOIN tblICCommodity CM ON CM.intCommodityId=a.intCommodityId
JOIN tblEMEntity E ON E.intEntityId=a.intEntityId
LEFT JOIN tblGRStorageScheduleRule c1 on c1.intStorageScheduleRuleId=a.intStorageScheduleId
