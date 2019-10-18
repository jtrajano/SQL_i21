CREATE PROCEDURE [dbo].[uspAPConvertPaymentToPrepay]
	@paymentId INT,
	@userId INT,
	@setVouchersToPaid BIT = 1,
	@prepaidCreated INT OUTPUT
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @prepayAccount INT, @apAccount INT, @prepaymentCategory INT;
DECLARE @prepayCreated INT;
DECLARE @payment DECIMAL(18,6);
DECLARE @transCount INT;
DECLARE @voucherId INT;
DECLARE @postPrepayParam NVARCHAR(100);
DECLARE @postPrepayResult BIT;
DECLARE @batchIdUsed NVARCHAR(50);
DECLARE @paymentRecordNum NVARCHAR(50);
DECLARE @voucherBillId NVARCHAR(100)
DECLARE @prepayBillId NVARCHAR(100);
DECLARE @error NVARCHAR(1000);

BEGIN TRY

--GET PREPAY ACCOUNT TO USE IF NO AVAILALBE IN LOCATION SETUP
SELECT @prepaymentCategory = intAccountCategoryId FROM tblGLAccountCategory WHERE strAccountCategory = 'Vendor Prepayments'
SELECT TOP 1 @prepayAccount = intAccountId FROM vyuGLAccountDetail WHERE intAccountCategoryId = @prepaymentCategory
SELECT TOP 1
	@voucherId = payDetail.intBillId,
	@payment = pay.dblAmountPaid + pay.dblWithheld
FROM tblAPPayment pay
INNER JOIN tblAPPaymentDetail payDetail
	ON pay.intPaymentId = payDetail.intPaymentId
WHERE payDetail.intPaymentId = @paymentId;

SELECT TOP 1
	@prepayAccount = ISNULL(loc.intPurchaseAdvAccount,@prepayAccount)
	,@apAccount = voucher.intAccountId
	,@voucherBillId = voucher.strBillId
FROM tblSMCompanyLocation loc
INNER JOIN tblAPBill voucher
	ON voucher.intShipToId = loc.intCompanyLocationId
WHERE voucher.intBillId = @voucherId

IF @prepayAccount IS NULL
BEGIN 
	RAISERROR('No available Prepay Account.', 16, 1);
	RETURN;
END

SET @transCount = @@TRANCOUNT;
IF @transCount = 0 BEGIN TRANSACTION

--create prepayment
EXEC uspAPDuplicateBill 
		@billId = @voucherId,
		@userId = @userId,
		@reset = 1,
		@type = 2,
		@billCreatedId  = @prepayCreated OUTPUT;

SET @prepayBillId = (SELECT strBillId FROM tblAPBill WHERE intBillId = @prepayCreated)

IF @setVouchersToPaid = 1
BEGIN
	UPDATE B
	SET
		B.dblPayment = B.dblTotal,
		B.dblAmountDue = 0,
		B.dtmDatePaid = A2.dtmDatePaid,
		B.ysnPaid = 1
	FROM tblAPBill B 
	INNER JOIN tblAPPaymentDetail A
		ON A.intBillId = B.intBillId
	INNER JOIN tblAPPayment A2
		ON A.intPaymentId = A2.intPaymentId
	WHERE A.intPaymentId = @paymentId
END

--MAKE SURE PREPAID ONLY HAS 1 DETAIL
DELETE prepayDetail
FROM tblAPBillDetail prepayDetail
OUTER APPLY (
	SELECT 
		TOP 1 intBillDetailId
	FROM tblAPBillDetail detail
	WHERE detail.intBillId = @prepayCreated
) details
WHERE prepayDetail.intBillId = @prepayCreated AND prepayDetail.intBillDetailId != details.intBillDetailId

UPDATE prepayDetail
	SET prepayDetail.intPrepayTypeId = 1
	,prepayDetail.intInventoryReceiptItemId = NULL
	,prepayDetail.intScaleTicketId = NULL
	,prepayDetail.intInventoryReceiptChargeId = NULL
	,prepayDetail.intItemId = NULL
	,prepayDetail.strMiscDescription = NULL
	,prepayDetail.dblQtyReceived = 1
	,prepayDetail.dblTax = 0
	,prepayDetail.dblQtyOrdered = 1
	,prepayDetail.intAccountId = @apAccount
	,prepayDetail.dblCost = @payment
	,prepayDetail.dblTotal = @payment
FROM tblAPBill prepay
INNER JOIN tblAPBillDetail prepayDetail ON prepay.intBillId = prepayDetail.intBillId
WHERE prepay.intBillId = @prepayCreated

UPDATE prepay
	SET prepay.intAccountId = @prepayAccount
	,prepay.dblDiscount = 0
	,prepay.dblPayment = 0
	,prepay.dblTax = 0
	,prepay.dblAmountDue = @payment
	,prepay.dblTotal = @payment
	,prepay.dblSubtotal = @payment
	,prepay.ysnPaid = 0
	,prepay.dtmDatePaid = NULL
	,prepay.ysnPrepayHasPayment = 1
	,prepay.strReference = NULL
	,prepay.intTransactionReversed = NULL --if the orignal transaction is an reversed transaction, we should null this for created prepaid
FROM tblAPBill prepay
WHERE prepay.intBillId = @prepayCreated

--post the prepayment
SET @postPrepayParam = CAST(@prepayCreated AS NVARCHAR(100));
EXEC [dbo].[uspAPPostVoucherPrepay]
	@param				= @postPrepayParam,
	@post				= 1,
	@recap				= 0,
	@userId				= @userId,
	@batchId			= DEFAULT,
	@success			= @postPrepayResult OUTPUT,
	@batchIdUsed		= @batchIdUsed OUTPUT

IF @postPrepayResult = 0
BEGIN
	SET @error = ERROR_MESSAGE();
	RAISERROR(@error, 16, 1);
	RETURN;
END

--update the payment to prepayment always update prepay wether combination of bill and prepay or not.
UPDATE pay
SET 
	pay.ysnPrepay = 1
FROM tblAPPayment pay
WHERE pay.intPaymentId = @paymentId;

--update the association to the payment
UPDATE payDetail
SET 
	payDetail.intBillId = @prepayCreated, payDetail.dblTotal = @payment, payDetail.dblPayment = @payment
FROM tblAPPaymentDetail payDetail 
WHERE 
	payDetail.intPaymentId = @paymentId AND payDetail.intBillId = @voucherId

--REMOVE OTHER PAYMENT DETAIL
DELETE A
FROM tblAPPaymentDetail A
WHERE A.intPaymentId = @paymentId AND A.intBillId != @prepayCreated

--SET THE OTHER GL DETAIL OF PAYMENT TO UNPOSTED (DO NOT DELETE FOR HISTORY PURPOSES)
UPDATE gl
SET gl.ysnIsUnposted = 1
	,gl.strComments = gl.strComments + ' - ' + 'Reversed with ' + @prepayBillId
FROM tblGLDetail gl
WHERE gl.strTransactionId = @paymentRecordNum AND gl.intTransactionId = @paymentId
AND gl.strJournalLineDescription != @voucherBillId

--UPDATE THE JOURNAL LINE DESCRIPTION
UPDATE gl
	SET gl.strJournalLineDescription = @prepayBillId
	,gl.intAccountId = @apAccount
FROM tblGLDetail gl
WHERE gl.strTransactionId = @paymentRecordNum 
AND gl.intTransactionId = @paymentId
AND gl.ysnIsUnposted = 0 --filter with unposted only to make sure we only update the correct association for the prepaid
AND gl.strJournalLineDescription = @voucherBillId

SET @prepaidCreated = @prepayCreated;

IF @transCount = 0 COMMIT TRANSACTION

END TRY
BEGIN CATCH
	SET @error = ERROR_MESSAGE()
	IF @transCount = 0 AND XACT_STATE() <> 0 ROLLBACK TRANSACTION
	RAISERROR(@error, 16, 1);
END CATCH