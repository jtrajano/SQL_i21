CREATE PROCEDURE [dbo].[uspGRSaveVoidedPayments]
(
	@billList Id READONLY
	,@dtmClientPostDate DATETIME
)
AS
BEGIN TRY
	DECLARE @ErrMsg NVARCHAR(MAX)

	INSERT INTO tblGRReversedSettlementsWithVoidedPayments
	(
		strSettleStorageTicket
		,strBillId
		,dblUnits
		,strPaymentRecordNo
		,intItemId
		,intCommodityId
		,intCommodityStockUOMId
		,intCompanyLocationId
		,dtmVoucherCreated
		,dtmPaymentDate
		,dtmVoidPaymentDate
		,dtmReversalDate
	)
	SELECT 
		SS.strStorageTicket
		,AP.strBillId
		,BD.dblQtyReceived
		,P_VOID.strPaymentRecordNum
		,IC.intItemId
		,IC.intCommodityId
		,SS.intCommodityStockUomId
		,AP.intShipToId
		,AP.dtmDateCreated
		,P.dtmDatePaid
		,P_VOID.dtmDatePaid	
		,@dtmClientPostDate
	FROM @billList B
	INNER JOIN tblAPBill AP
		ON AP.intBillId = B.intId
	INNER JOIN tblAPBillDetail BD
		ON BD.intBillId = AP.intBillId
	INNER JOIN tblICItem IC
		ON IC.intItemId = BD.intItemId
			AND IC.strType = 'Inventory'
	INNER JOIN tblAPPaymentDetail PD_VOID
		ON PD_VOID.intOrigBillId = AP.intBillId
	INNER JOIN tblAPPayment P_VOID
		ON P_VOID.intPaymentId = PD_VOID.intPaymentId
			AND P_VOID.strPaymentRecordNum LIKE '%V'	
	INNER JOIN tblAPPayment P
		ON P.strPaymentRecordNum = LEFT(P_VOID.strPaymentRecordNum,LEN(P_VOID.strPaymentRecordNum)-1)
	INNER JOIN tblGRSettleStorageBillDetail SBD
		ON SBD.intBillId = AP.intBillId
	INNER JOIN tblGRSettleStorage SS
		ON SS.intSettleStorageId = SBD.intSettleStorageId
END TRY

BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()
	RAISERROR (@ErrMsg,16,1,'WITH NOWAIT')
END CATCH