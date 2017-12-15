﻿CREATE VIEW [dbo].[vyuGRStorageSearchView]
AS    
SELECT TOP 100 PERCENT  
 intCustomerStorageId		  = CS.intCustomerStorageId
,intTicketId				  = CS.intTicketId
,intDeliverySheetId			  = CS.intDeliverySheetId
,intEntityId				  = CS.intEntityId
,strName					  = E.strName  
,strStorageTicketNumber		  = CS.strStorageTicketNumber
,intStorageTypeId			  = CS.intStorageTypeId
,strStorageTypeDescription	  = ST.strStorageTypeDescription 
,intItemId					  = CS.intItemId  
,strItemNo					  = Item.strItemNo   
,intCompanyLocationId		  = CS.intCompanyLocationId
,strLocationName			  = LOC.strLocationName
,intStorageScheduleId		  = CS.intStorageScheduleId
,strScheduleId				  = SR.strScheduleId
,strDPARecieptNumber		  = CS.strDPARecieptNumber
,strCustomerReference		  = ISNULL(CS.strCustomerReference,'')  
,dblOriginalBalance			  = dbo.fnCTConvertQuantityToTargetItemUOM(CS.intItemId,CS.intUnitMeasureId,CU.intUnitMeasureId,CS.dblOriginalBalance) 
,dblOpenBalance				  = dbo.fnCTConvertQuantityToTargetItemUOM(CS.intItemId,CS.intUnitMeasureId,CU.intUnitMeasureId,CS.dblOpenBalance) 
,dtmDeliveryDate			  = CS.dtmDeliveryDate
,strDiscountComment			  = CS.strDiscountComment
,dblInsuranceRate			  = CS.dblInsuranceRate
,dblStorageDue				  = CS.dblStorageDue
,dblStoragePaid				  = CS.dblStoragePaid
,dblFeesDue					  = CS.dblFeesDue
,dblFeesPaid				  = CS.dblFeesPaid
,dblDiscountsDue			  = CS.dblDiscountsDue
,dblDiscountsPaid			  = CS.dblDiscountsPaid
,intDiscountScheduleId		  = CS.intDiscountScheduleId
,strDiscountDescription		  = DS.strDiscountDescription
,dblDiscountUnPaid			  = ISNULL(CS.dblDiscountsDue,0)-ISNULL(CS.dblDiscountsPaid,0)
,dblStorageUnPaid			  = ISNULL(CS.dblStorageDue,0)-ISNULL(CS.dblStoragePaid,0)
,strSplitNumber				  = EMSplit.strSplitNumber
,intContractHeaderId		  = SH.intContractHeaderId
,strContractNumber			  = CH.strContractNumber
,strDeliverySheetNumber		  = DeliverySheet.strDeliverySheetNumber
,dtmLastStorageAccrueDate	  = CS.dtmLastStorageAccrueDate
FROM tblGRCustomerStorage       CS  
JOIN tblSMCompanyLocation       LOC				ON LOC.intCompanyLocationId			= CS.intCompanyLocationId  
JOIN tblGRStorageType	        ST				ON ST.intStorageScheduleTypeId		= CS.intStorageTypeId  
JOIN tblICItem			        Item			ON Item.intItemId					= CS.intItemId
JOIN tblICCommodityUnitMeasure  CU				ON CU.intCommodityId				= CS.intCommodityId AND CU.ysnStockUnit=1  
JOIN tblEMEntity				E			    ON E.intEntityId					= CS.intEntityId
JOIN tblGRStorageScheduleRule   SR				ON SR.intStorageScheduleRuleId		= CS.intStorageScheduleId
JOIN tblGRDiscountSchedule		DS		        ON DS.intDiscountScheduleId			= CS.intDiscountScheduleId
LEFT JOIN tblGRStorageHistory   SH				ON SH.intCustomerStorageId			= CS.intCustomerStorageId
LEFT JOIN tblCTContractHeader   CH				ON CH.intContractHeaderId			= SH.intContractHeaderId
LEFT JOIN tblSCDeliverySheet    DeliverySheet   ON DeliverySheet.intDeliverySheetId = CS.intDeliverySheetId  
LEFT JOIN tblSCTicket		    SC				ON SC.intTicketId					= CS.intTicketId
LEFT JOIN tblSCTicketSplit	    SCTicketSplit	ON SCTicketSplit.intTicketId		= CS.intTicketId AND SCTicketSplit.intCustomerId = CS.intEntityId AND SCTicketSplit.intStorageScheduleTypeId=CS.intStorageTypeId
LEFT JOIN tblEMEntitySplit		EMSplit		    ON EMSplit.intSplitId				= SC.intSplitId
Where ISNULL(CS.strStorageType,'') <> 'ITR' AND ST.ysnCustomerStorage=0 AND SH.strType IN('From Scale','From Transfer','From Delivery Sheet')
ORDER BY CS.intCustomerStorageId