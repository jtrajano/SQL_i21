CREATE VIEW [dbo].[vyuGRCustomerStorageNotMapped]
AS
SELECT    
 intCustomerStorageId				= CS.intCustomerStorageId
,intEntityId						= CS.intEntityId  
,strName							= E.strName  
,intStorageTypeId					= CS.intStorageTypeId  
,strStorageTypeDescription			= ST.strStorageTypeDescription
,intItemId							= CS.intItemId
,strItemNo						    = Item.strItemNo  
,intCompanyLocationId				= CS.intCompanyLocationId  
,strLocationName					= LOC.strLocationName
,intCompanyLocationSubLocationId	= ISNULL(CS.intCompanyLocationSubLocationId,0) 
,strSubLocationName					= ISNULL(SLOC.strSubLocationName,'') 
,intStorageLocationId				= ISNULL(CS.intStorageLocationId,0) 
,strStorageLocation					= ISNULL(Bin.strName,'') 
,intDiscountScheduleId				= CS.intDiscountScheduleId
,strDiscountDescription				= DS.strDiscountDescription
,intStorageScheduleId				= CS.intStorageScheduleId
,strScheduleId						= SR.strScheduleId
,intUnitMeasureId					= CS.intUnitMeasureId
,strUnitMeasure						= UOM.strUnitMeasure 
FROM tblGRCustomerStorage CS  
JOIN tblGRStorageType ST ON ST.intStorageScheduleTypeId = CS.intStorageTypeId  
JOIN tblSMCompanyLocation LOC ON LOC.intCompanyLocationId = CS.intCompanyLocationId  
JOIN tblEMEntity E ON E.intEntityId = CS.intEntityId  
JOIN tblICCommodity COM ON COM.intCommodityId = CS.intCommodityId
JOIN tblGRStorageScheduleRule SR ON SR.intStorageScheduleRuleId=CS.intStorageScheduleId
JOIN tblICItem Item ON Item.intItemId = CS.intItemId
LEFT JOIN tblICUnitMeasure UOM ON UOM.intUnitMeasureId = CS.intUnitMeasureId
JOIN tblGRDiscountSchedule DS ON DS.intDiscountScheduleId = CS.intDiscountScheduleId
LEFT JOIN tblSMCompanyLocationSubLocation SLOC ON SLOC.intCompanyLocationSubLocationId = CS.intCompanyLocationSubLocationId
LEFT JOIN tblICStorageLocation Bin ON Bin.intStorageLocationId = CS.intStorageLocationId
WHERE  ISNULL(CS.strStorageType,'') <> 'ITR'