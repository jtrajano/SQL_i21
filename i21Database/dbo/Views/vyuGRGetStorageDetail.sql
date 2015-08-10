CREATE VIEW [dbo].[vyuGRGetStorageDetail]
AS
SELECT
	  a.intCustomerStorageId
	 ,a.intCompanyLocationId	
	,c.strLocationName [Loc]
	,a.dtmDeliveryDate [Delivery Date]
	,a.intStorageTicketNumber [Ticket]
	,a.intEntityId
	,E.strName [Customer]
	,a.strDPARecieptNumber [Receipt]
	,(a.dblDiscountsDue-a.dblDiscountsPaid) [Disc Due]
	,(a.dblStorageDue-a.dblStoragePaid)   [Storage Due]
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
	,b.ysnCustomerStorage 
	,a.strCustomerReference  
 	,a.dtmLastStorageAccrueDate  
 	,c1.strScheduleId
FROM tblGRCustomerStorage a
JOIN tblGRStorageType b ON b.intStorageScheduleTypeId = a.intStorageTypeId
LEFT JOIN tblGRStorageScheduleRule c1 on c1.intStorageScheduleRuleId=a.intStorageScheduleId  
JOIN tblSMCompanyLocation c ON c.intCompanyLocationId=a.intCompanyLocationId
JOIN tblEntity E ON E.intEntityId=a.intEntityId
JOIN tblICCommodity CM ON CM.intCommodityId=a.intCommodityId
Where ISNULL(a.strStorageType,'') <> 'ITR'
