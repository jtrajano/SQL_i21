CREATE VIEW [dbo].[vyuGROffSiteSearchView]
AS        
SELECT TOP 100 PERCENT  
 intCustomerStorageId		    = CS.intCustomerStorageId
,strName					    = E.strName  
,strStorageTicketNumber		    = CS.strStorageTicketNumber
,intCompanyLocationId			= CS.intCompanyLocationId
,strLocationName		        = LOC.strLocationName
,intCompanyLocationSubLocationId = ISNULL(CS.intCompanyLocationSubLocationId,0) 
,strSubLocationName				 = ISNULL(SLOC.strSubLocationName,'') 
,intStorageTypeId				= CS.intStorageTypeId
,strStorageTypeDescription		= ST.strStorageTypeDescription
,intStorageScheduleId			= CS.intStorageScheduleId
,strScheduleId					= SR.strScheduleId  
,dtmDeliveryDate			    = CS.dtmDeliveryDate  
,strItemNo						= Item.strItemNo  
,strCustomerReference           = ISNULL(CS.strCustomerReference,'')  
,dblOpenBalance					= dbo.fnCTConvertQuantityToTargetItemUOM(CS.intItemId,CS.intUnitMeasureId,CU.intUnitMeasureId,CS.dblOpenBalance)
,dblDiscountUnPaid				= ISNULL(CS.dblDiscountsDue,0)-ISNULL(CS.dblDiscountsPaid,0)
,dblStorageUnPaid				= ISNULL(CS.dblStorageDue,0)-ISNULL(CS.dblStoragePaid,0)
,intContractHeaderId		    = SH.intContractHeaderId
,strContractNumber				= CH.strContractNumber
FROM tblGRCustomerStorage CS  
JOIN tblSMCompanyLocation LOC ON LOC.intCompanyLocationId=CS.intCompanyLocationId
JOIN tblICItem Item on Item.intItemId=CS.intItemId  
JOIN tblEMEntity E ON E.intEntityId = CS.intEntityId
JOIN tblGRStorageType ST ON ST.intStorageScheduleTypeId=CS.intStorageTypeId
JOIN tblGRStorageScheduleRule SR ON SR.intStorageScheduleRuleId=CS.intStorageScheduleId  
JOIN tblICCommodityUnitMeasure CU ON CU.intCommodityId=CS.intCommodityId AND CU.ysnStockUnit=1
JOIN tblSMCompanyLocationSubLocation SLOC ON SLOC.intCompanyLocationSubLocationId=CS.intCompanyLocationSubLocationId 
LEFT JOIN tblGRStorageHistory SH ON SH.intCustomerStorageId=CS.intCustomerStorageId
LEFT JOIN tblCTContractHeader CH ON CH.intContractHeaderId=SH.intContractHeaderId 
WHERE ISNULL(CS.strStorageType,'') <> 'ITR' AND ST.ysnCustomerStorage=1 AND SH.strType IN('From Scale','From Transfer') 
ORDER BY CS.intCustomerStorageId 