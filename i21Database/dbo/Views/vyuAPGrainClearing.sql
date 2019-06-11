CREATE VIEW [dbo].[vyuAPGrainClearing]
AS 

--Settle Storage items
SELECT 
	CS.intEntityId AS intEntityVendorId
	,CS.dtmDeliveryDate
	,SS.strStorageTicket
	,SS.intSettleStorageId
	,NULL AS intBillId
    ,NULL AS strBillId
    ,NULL AS intBillDetailId
	,CS.intCustomerStorageId
	,CS.intItemId
	,0 AS dblVoucherTotal
    ,0 AS dblVoucherQty
	,SS.dblNetSettlement AS dblSettleStorageAmount
	,SS.dblSettleUnits AS dblSettleStorageQty
	,GD.intAccountId
	,AD.strDescription
	,CS.intCompanyLocationId
	,CL.strLocationName
FROM tblGRCustomerStorage CS
INNER JOIN tblICItem IM
	ON IM.intItemId = CS.intItemId
INNER JOIN tblICCommodity CO
	ON CO.intCommodityId = CS.intCommodityId
INNER JOIN tblSMCompanyLocation CL
	ON CL.intCompanyLocationId = CS.intCompanyLocationId
INNER JOIN tblGRSettleStorageTicket SST
	ON SST.intCustomerStorageId = CS.intCustomerStorageId
INNER JOIN tblGRSettleStorage SS
	ON SST.intSettleStorageId = SS.intSettleStorageId
		AND SS.intParentSettleStorageId IS NOT NULL
INNER JOIN vyuGLDetail GD
	ON GD.strTransactionId = SS.strStorageTicket
		AND GD.intTransactionId = SS.intSettleStorageId
		AND GD.strTransactionType = 'Storage Settlement'
		AND GD.ysnIsUnposted = 0
INNER JOIN vyuGLAccountDetail AD
	ON GD.intAccountId = AD.intAccountId AND AD.intAccountCategoryId = 45
UNION ALL --Charges
SELECT 
	CS.intEntityId AS intEntityVendorId
	,CS.dtmDeliveryDate
	,SS.strStorageTicket
	,SS.intSettleStorageId
	,NULL AS intBillId
    ,NULL AS strBillId
    ,NULL AS intBillDetailId
	,CS.intCustomerStorageId
	,CS.intItemId
	,0 AS dblVoucherTotal
    ,0 AS dblVoucherQty
	,0
	,0
	,CS.intCompanyLocationId
	,CL.strLocationName
	,GD.intAccountId
	,AD.strDescription
FROM tblGRCustomerStorage CS
INNER JOIN tblICCommodity CO
	ON CO.intCommodityId = CS.intCommodityId
INNER JOIN tblICItem IM
	ON IM.strType = 'Other Charge' 
		AND IM.strCostType = 'Storage Charge' 
		AND (IM.intCommodityId = CO.intCommodityId OR IM.intCommodityId IS NULL)
INNER JOIN tblSMCompanyLocation CL
	ON CL.intCompanyLocationId = CS.intCompanyLocationId
INNER JOIN tblGRSettleStorageTicket SST
	ON SST.intCustomerStorageId = CS.intCustomerStorageId
INNER JOIN tblGRSettleStorage SS
	ON SST.intSettleStorageId = SS.intSettleStorageId
		AND SS.intParentSettleStorageId IS NOT NULL
INNER JOIN vyuGLDetail GD
	ON GD.strTransactionId = SS.strStorageTicket
		AND GD.intTransactionId = SS.intSettleStorageId
		AND GD.strCode = 'STR'
		AND GD.strDescription LIKE '%Charges from ' + IM.strItemNo
		AND GD.ysnIsUnposted = 0
INNER JOIN vyuGLAccountDetail AD
	ON GD.intAccountId = AD.intAccountId AND AD.intAccountCategoryId = 45
UNION ALL --DISCOUNTS
SELECT 
	CS.intEntityId AS intEntityVendorId
	,CS.dtmDeliveryDate
	,SS.strStorageTicket
	,SS.intSettleStorageId
	,NULL AS intBillId
    ,NULL AS strBillId
    ,NULL AS intBillDetailId
	,CS.intCustomerStorageId
	,CS.intItemId
	,0 AS dblVoucherTotal
    ,0 AS dblVoucherQty
	,0
	,0
	,CS.intCompanyLocationId
	,CL.strLocationName
	,GD.intAccountId
	,AD.strDescription
FROM tblQMTicketDiscount QM
INNER JOIN tblGRDiscountScheduleCode DSC
	ON DSC.intDiscountScheduleCodeId = QM.intDiscountScheduleCodeId
INNER JOIN tblGRCustomerStorage CS
	ON CS.intCustomerStorageId = QM.intTicketFileId
INNER JOIN tblICItem IM
	ON DSC.intItemId = IM.intItemId
INNER JOIN tblGRDiscountSchedule DS
	ON DS.intDiscountScheduleId = DSC.intDiscountScheduleId
INNER JOIN tblICCommodity CO
	ON CO.intCommodityId = DS.intCommodityId
INNER JOIN tblSMCompanyLocation CL
	ON CL.intCompanyLocationId = CS.intCompanyLocationId
INNER JOIN tblGRSettleStorageTicket SST
	ON SST.intCustomerStorageId = CS.intCustomerStorageId
INNER JOIN tblGRSettleStorage SS
	ON SST.intSettleStorageId = SS.intSettleStorageId
		AND SS.intParentSettleStorageId IS NOT NULL
INNER JOIN vyuGLDetail GD
	ON GD.strTransactionId = SS.strStorageTicket
		AND GD.intTransactionId = SS.intSettleStorageId
		AND GD.strCode = 'STR'
		AND GD.strDescription LIKE '%Charges from ' + IM.strItemNo
		AND GD.ysnIsUnposted = 0
INNER JOIN vyuGLAccountDetail AD
	ON GD.intAccountId = AD.intAccountId AND AD.intAccountCategoryId = 45
WHERE QM.strSourceType = 'Storage' 
	AND QM.dblDiscountDue <> 0
