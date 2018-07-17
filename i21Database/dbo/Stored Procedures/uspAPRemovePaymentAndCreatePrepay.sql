CREATE PROCEDURE [dbo].[uspAPRemovePaymentAndCreatePrepay]
	@voucherId INT,
	@userId INT,
	@paymentId INT,
	@prepayCreatedIds NVARCHAR(MAX) OUTPUT
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @prepayCreated INT;
DECLARE @transCount INT;
CREATE TABLE #paymentInfo(intId INT, strRecordNum NVARCHAR(50), dblAmountPaid DECIMAL(18, 6));
DECLARE @paymentRecordId INT = @paymentId;
DECLARE @currentPaymentId INT;
DECLARE @payment DECIMAL(18,6);
DECLARE @paymentRecordNum NVARCHAR(50);
DECLARE @voucherKey INT = @voucherId;
DECLARE @prepayAccount INT, @apAccount INT, @prepaymentCategory INT;
DECLARE @postPrepayResult BIT;
DECLARE @postPrepayParam NVARCHAR(100);
DECLARE @voucherBillId NVARCHAR(100)
DECLARE @prepayBillId NVARCHAR(100);
DECLARE @error NVARCHAR(1000);
DECLARE @batchIdUsed NVARCHAR(50);

BEGIN TRY

--GET PREPAY ACCOUNT TO USE IF NO AVAILALBE IN LOCATION SETUP
SELECT @prepaymentCategory = intAccountCategoryId FROM tblGLAccountCategory WHERE strAccountCategory = 'Vendor Prepayments'
SELECT TOP 1 @prepayAccount = intAccountId FROM vyuGLAccountDetail WHERE intAccountCategoryId = @prepaymentCategory

SELECT
	@prepayAccount = ISNULL(loc.intPurchaseAdvAccount,@prepayAccount)
	,@apAccount = voucher.intAccountId
	,@voucherBillId = voucher.strBillId
FROM tblSMCompanyLocation loc
INNER JOIN tblAPBill voucher ON loc.intCompanyLocationId = voucher.intShipToId
WHERE voucher.intBillId = @voucherKey;

IF @prepayAccount IS NULL
BEGIN 
	RAISERROR('No available Prepay Account.', 16, 1);
	RETURN;
END

INSERT INTO #paymentInfo
SELECT
	DISTINCT pay.intPaymentId,
	pay.strPaymentRecordNum,
	payDetail.dblPayment + payDetail.dblDiscount - payDetail.dblInterest
FROM tblAPPayment pay
INNER JOIN tblAPPaymentDetail payDetail ON pay.intPaymentId = payDetail.intPaymentId
INNER JOIN tblCMBankTransaction bankTran ON pay.strPaymentRecordNum = bankTran.strTransactionId
WHERE payDetail.intBillId = @voucherKey AND pay.ysnPosted = 1 
AND bankTran.ysnCheckVoid = 0 AND (bankTran.dtmCheckPrinted IS NOT NULL OR bankTran.ysnClr = 1) 
AND pay.intPaymentId = @paymentRecordId

SET @transCount = @@TRANCOUNT;
IF @transCount = 0 BEGIN TRANSACTION

DECLARE c CURSOR LOCAL STATIC READ_ONLY FORWARD_ONLY
FOR
    SELECT intId, dblAmountPaid, strRecordNum FROM #paymentInfo
OPEN c;
FETCH NEXT FROM c INTO @currentPaymentId, @payment, @paymentRecordNum

WHILE @@FETCH_STATUS = 0 
BEGIN

	--create prepayment
	EXEC uspAPDuplicateBill 
		@billId = @voucherKey,
		@userId = @userId,
		@reset = DEFAULT,
		@type = 2,
		@billCreatedId  = @prepayCreated OUTPUT;

	SET @prepayBillId = (SELECT strBillId FROM tblAPBill WHERE intBillId = @prepayCreated)
	--MAKE SURE PREPAID ONLY HAS 1 DETAIL
	IF (SELECT COUNT(*) FROM tblAPBillDetail WHERE intBillId = @prepayCreated) > 1
	BEGIN
		DELETE prepayDetail
		FROM tblAPBillDetail prepayDetail
		OUTER APPLY (
			SELECT 
				TOP 1 intBillDetailId
			FROM tblAPBillDetail detail
			WHERE detail.intBillId = @prepayCreated
		) details
		WHERE prepayDetail.intBillId = @prepayCreated AND prepayDetail.intBillDetailId != details.intBillDetailId
	END

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
		RAISERROR('Posting prepay failed.', 16, 1);
		RETURN;
	END
	
	--CONVERT THE PAYMENT TO PREPAID
	--update original bills associated to payment to unpaid
	UPDATE origBill
		SET origBill.ysnPaid = 0
		,origBill.dblPayment = origBill.dblPayment - payDetail.dblPayment
		,origBill.dblAmountDue = origBill.dblAmountDue + payDetail.dblPayment
		,origBill.dtmDatePaid = NULL
	FROM tblAPBill origBill
	INNER JOIN tblAPPaymentDetail payDetail ON origBill.intBillId = payDetail.intBillId
	INNER JOIN tblAPPayment pay ON payDetail.intPaymentId = pay.intPaymentId
	WHERE pay.intPaymentId = @currentPaymentId
	-- WHERE origBill.intBillId = @voucherKey

	--update the payment to prepayment
	UPDATE pay
		SET pay.ysnPrepay = 1
	FROM tblAPPayment pay
	WHERE pay.intPaymentId = @currentPaymentId;

	--REMOVE OTHER BILL ASSOCIATED TO THE PAYMENT, IT SHOULD ONLY HAVE 1 BILL WHICH IS THE PREPAID CREATED
	DELETE payDetail
	FROM tblAPPaymentDetail payDetail
	WHERE payDetail.intPaymentId = @currentPaymentId AND payDetail.intBillId != @voucherKey

	--update the association to the payment
	UPDATE payDetail
		SET payDetail.intBillId = @prepayCreated
	FROM tblAPPaymentDetail payDetail 
	WHERE payDetail.intPaymentId = @currentPaymentId;

	--update the gl record of payment
	--SET THE OTHER GL DETAIL OF PAYMENT TO UNPOSTED (DO NOT DELETE FOR HISTORY PURPOSES)
	UPDATE gl
		SET gl.ysnIsUnposted = 1
			,gl.strComments = gl.strComments + ' - ' + 'Reversed with ' + @voucherBillId
	FROM tblGLDetail gl
	WHERE gl.strTransactionId = @paymentRecordNum AND gl.intTransactionId = @currentPaymentId
	AND gl.strJournalLineDescription != @voucherBillId

	--UPDATE THE JOURNAL LINE DESCRIPTION
	UPDATE gl
		SET gl.strJournalLineDescription = @prepayBillId
		,gl.intAccountId = @prepayAccount
		--to ensure correct debit/credit to update, check first if that is not equal to 0
		,gl.dblDebit = (CASE WHEN gl.dblDebit != 0 THEN @payment ELSE gl.dblDebit END)
		,gl.dblCredit = (CASE WHEN gl.dblCredit != 0 THEN @payment ELSE gl.dblCredit END)
	FROM tblGLDetail gl
	WHERE gl.strTransactionId = @paymentRecordNum AND gl.intTransactionId = @currentPaymentId
	AND gl.ysnIsUnposted = 0 --filter with unposted only to make sure we only update the correct association for the prepaid

	SET @prepayCreatedIds = CAST(@prepayCreated AS NVARCHAR) + ','
	FETCH NEXT FROM c INTO @currentPaymentId, @payment, @paymentRecordNum

END
CLOSE c; DEALLOCATE c;

IF @transCount = 0 COMMIT TRANSACTION

END TRY
BEGIN CATCH
	SET @error = ERROR_MESSAGE()
	IF @transCount = 0 AND XACT_STATE() <> 0 ROLLBACK TRANSACTION
	RAISERROR(@error, 16, 1);
END CATCH