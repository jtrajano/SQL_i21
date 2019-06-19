CREATE VIEW [dbo].[vyuAPGrainClearing]
AS 
SELECT 
	CS.intEntityId
	,CS.dtmDeliveryDate
	,dtmSettlementDate = SS.dtmCreated
	,SS.strStorageTicket
	,SS.intSettleStorageId
	,NULL AS intBillId
    ,NULL AS strBillId
    ,NULL AS intBillDetailId
	,CS.intCustomerStorageId
	,CS.intItemId
	,0 AS dblVoucherTotal
    ,0 AS dblVoucherQty
	,CAST(SS.dblNetSettlement AS DECIMAL(18,2)) AS dblSettleStorageAmount
	,SS.dblSettleUnits AS dblSettleStorageQty
	,GD.intAccountId
	,AD.strDescription
	,GD.strDescription
FROM vyuGLDetail GD
INNER JOIN vyuGLAccountDetail AD
	ON AD.intAccountId = GD.intAccountId
INNER JOIN tblGRSettleStorage SS
	ON SS.intSettleStorageId = GD.intTransactionId
		AND SS.strStorageTicket = GD.strTransactionId
INNER JOIN tblGRSettleStorageTicket SST
	ON SST.intSettleStorageId = SS.intSettleStorageId
INNER JOIN tblGRCustomerStorage CS
	ON CS.intCustomerStorageId = SST.intCustomerStorageId
WHERE GD.strTransactionId LIKE 'STR-%'
	AND SS.intBillId IS NULL
	AND GD.strCode IN ('STR','IC')