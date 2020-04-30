CREATE VIEW dbo.vyuGRCustomerStorage
AS
SELECT 
	CS.intCustomerStorageId
	,CS.intEntityId
	,CS.intTicketId
	,CS.strStorageTicketNumber
	,CS.intStorageTypeId
	,CS.intCommodityId
	,CS.intCompanyLocationId
	,CS.intStorageScheduleId
	,CS.strDPARecieptNumber
	,CS.strCustomerReference
	,dblOriginalBalance					= ISNULL(CS.dblOriginalBalance,0)
	,dblOpenBalance						= ISNULL(CS.dblOpenBalance,0)
	,CS.dtmDeliveryDate
	,CS.strDiscountComment
	,dblInsuranceRate					= ISNULL(CS.dblInsuranceRate,0)
	,dblStorageDue						= ISNULL(CS.dblStorageDue,0)
	,dblStoragePaid						= ISNULL(CS.dblStoragePaid,0)
	,dblFeesDue							= ISNULL(CS.dblFeesDue,0)
	,dblFeesPaid						= ISNULL(CS.dblFeesPaid,0)
	,dblDiscountsDue					= ISNULL(CS.dblDiscountsDue,0)
	,dblDiscountsPaid					= ISNULL(CS.dblDiscountsPaid,0)
	,CS.intDiscountScheduleId
	,CS.intCurrencyId
	,CS.intItemId
	,CS.intCompanyLocationSubLocationId
	,CS.intStorageLocationId
	,dblTotalPriceShrink				= ISNULL(CS.dblTotalPriceShrink,0)
	,dblTotalWeightShrink				= ISNULL(CS.dblTotalWeightShrink,0)
	,CS.dtmZeroBalanceDate
	,CS.dtmLastStorageAccrueDate
	,CS.strOriginState
	,CS.strInsuranceState
	,dblFreightDueRate					= ISNULL(CS.dblFreightDueRate,0)
	,CS.intUnitMeasureId
	,CS.intItemUOMId
	,CS.ysnPrinted
	,dblCurrencyRate					= ISNULL(CS.dblCurrencyRate,0)
	,CS.intConcurrencyId
	,EM.strName
	,ST.strStorageTypeDescription
	,ICI.strItemNo
	,CL.strLocationName
	,CLSL.strSubLocationName
	,DS.strDiscountDescription
	,SSR.strScheduleId
	,UOM.strUnitMeasure
	,SL.strName strStorageLocation
	,CS.strStorageType
	,ysnDeliverySheetPosted = ISNULL(DeliverySheet.ysnPost,1)
	,CS.dblBasis
	,CS.dblSettlementPrice
FROM tblGRCustomerStorage CS
INNER JOIN tblSMCompanyLocation CL
	ON CS.intCompanyLocationId = CL.intCompanyLocationId
LEFT JOIN tblGRStorageScheduleRule SSR
	ON CS.intStorageScheduleId = SSR.intStorageScheduleRuleId
LEFT JOIN tblICStorageLocation SL
	ON CS.intStorageLocationId = SL.intStorageLocationId
LEFT JOIN tblICUnitMeasure UOM
	ON CS.intUnitMeasureId = UOM.intUnitMeasureId
LEFT JOIN tblEMEntity EM
	ON CS.intEntityId = EM.intEntityId
LEFT JOIN tblGRStorageType ST
	ON CS.intStorageTypeId = ST.intStorageScheduleTypeId
LEFT JOIN tblICItem ICI
	ON CS.intItemId = ICI.intItemId
LEFT JOIN tblSMCompanyLocationSubLocation CLSL
	ON CS.intCompanyLocationSubLocationId = CLSL.intCompanyLocationSubLocationId
LEFT JOIN tblGRDiscountSchedule DS
	ON CS.intDiscountScheduleId = DS.intDiscountScheduleId
LEFT JOIN tblSCDeliverySheet DeliverySheet
	ON DeliverySheet.intDeliverySheetId = CS.intDeliverySheetId
LEFT JOIN tblGRTransferStorageReference TSR
	ON TSR.intToCustomerStorageId = CS.intCustomerStorageId