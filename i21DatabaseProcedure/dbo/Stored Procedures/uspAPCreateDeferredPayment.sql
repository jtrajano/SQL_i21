CREATE PROCEDURE [dbo].[uspAPCreateDeferredPayment] (
	@userId INT,
	@locationId INT,
	@voucherCreated NVARCHAR(MAX) OUTPUT
)
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

BEGIN TRY

DECLARE @transCount INT = @@TRANCOUNT;
DECLARE @deferredInterestAccount INT;
DECLARE @companyLocationId INT = @locationId;
DECLARE @currentUser INT = @userId;
DECLARE @voucherSelected TABLE(intBillId INT, intEntityVendorId INT, intShipToId INT, intShipFromId INT, intCurrencyId INT);
DECLARE @vouchers TABLE(intBillId INT);
DECLARE @voucherIds NVARCHAR(MAX);
DECLARE @currentVoucherId INT, @currentVendorId INT, @currentCurrency INT, @currentShipTo INT, @currentShipFrom INT;
DECLARE @voucherPayables AS VoucherPayable;
DECLARE @SavePoint NVARCHAR(32) = 'uspAPCreateDeferredPayment';

SELECT @deferredInterestAccount = intDeferredPayableInterestId FROM tblSMCompanyLocation WHERE intCompanyLocationId = @companyLocationId;


-- INSERT INTO @voucherSelected
-- SELECT
-- 	A.intBillId
-- 	,A.intEntityVendorId
-- 	,B.intShipToId
-- 	,B.intShipFromId
-- 	,B.intCurrencyId
-- FROM vyuAPDeferredPayment A
-- INNER JOIN tblAPBill B ON A.intBillId = B.intBillId
-- WHERE A.ysnSelected = 1

INSERT INTO @voucherPayables(
	intPartitionId
	,intTransactionType
	,intEntityVendorId
	,intShipToId
	,intShipFromId
	,intCurrencyId
	,intAccountId
	,intDeferredVoucherId
	,intTermId
	,strMiscDescription
	,strCheckComment
	,dblCost
	,dblQuantityToBill
	,dtmDate
	,dtmDueDate
	,dtmVoucherDate
)
SELECT
	intPartitionId				= ROW_NUMBER() OVER(ORDER BY (SELECT 1)) --1 voucher per 1 payable
	,intTransactionType			= 14
	,intEntityVendorId			= A.intEntityVendorId
	,intShipToId				= B.intShipToId
	,intShipFromId				= B.intShipFromId
	,intCurrencyId				= B.intCurrencyId
	,intAccountId				= A.intDeferredAccountId
	,intDeferredVoucherId		= B.intBillId
	,intTermId					= term.intTermID
	,strMiscDescription			= 'Deferred Interest'
	,strCheckComment			= A.strCheckComment
	,dblCost					= A.dblInterest
	,dblQuantityToBill			= 1
	,dtmDate					= deferredInterest.dtmPaymentPostDate
	,dtmDueDate					= deferredInterest.dtmPaymentDueDateOverride
	,dtmVoucherDate				= deferredInterest.dtmPaymentInvoiceDate
FROM vyuAPDeferredPayment A
INNER JOIN tblAPBill B ON A.intBillId = B.intBillId
CROSS APPLY tblAPDeferredPaymentInterest deferredInterest
INNER JOIN tblSMTerm term ON deferredInterest.strTerm = term.strTerm
WHERE A.ysnSelected = 1

IF @transCount = 0 BEGIN TRANSACTION
ELSE SAVE TRAN @SavePoint

EXEC uspAPCreateVoucher @voucherPayables = @voucherPayables, @userId = @userId, @throwError = 1, @createdVouchersId = @voucherIds OUT

INSERT INTO @vouchers SELECT [intID] FROM [dbo].fnGetRowsFromDelimitedValues(@voucherIds)

--UPDATE ORIGINAL VOUCHER dtmDeferredInterestDate, dtmInterestAccruedThru
UPDATE A
	SET A.dtmDeferredInterestDate = deferredInterest.dtmPaymentDueDateOverride,
		A.dtmInterestAccruedThru = deferredInterest.dtmCalculationDate
FROM tblAPBill A
INNER JOIN vyuAPDeferredPayment B ON A.intBillId = B.intBillId
INNER JOIN (tblAPBill deferred INNER JOIN @vouchers C ON deferred.intBillId = C.intBillId) --UPDATE ONLY THOSE WHO HAVE SUCCESSFULLY CREATED
	ON deferred.intDeferredVoucherId = B.intBillId
CROSS APPLY tblAPDeferredPaymentInterest deferredInterest
WHERE B.ysnSelected = 1

--OLD APPROACH
-- DECLARE c CURSOR LOCAL STATIC READ_ONLY FORWARD_ONLY
-- FOR
--     SELECT intBillId, intEntityVendorId, intShipToId, intShipFromId, intCurrencyId FROM @voucherSelected
-- OPEN c;
-- FETCH NEXT FROM c INTO @currentVoucherId, @currentVendorId, @currentShipTo, @currentShipFrom, @currentCurrency

-- WHILE @@FETCH_STATUS = 0 
-- BEGIN

-- 	DECLARE @voucherDetail AS VoucherDetailNonInventory;
-- 	DECLARE @voucherIdCreated INT;

-- 	INSERT INTO @voucherDetail(
-- 		intAccountId,
-- 		strMiscDescription,
-- 		dblQtyReceived,
-- 		dblCost
-- 	)
-- 	SELECT
-- 		intAccountId		=	A.intDeferredAccountId,
-- 		strMiscDescription	=	'Deferred Interest',
-- 		dblQtyReceived		=	1,
-- 		dblCost				=	A.dblInterest
-- 	FROM vyuAPDeferredPayment A
-- 	WHERE A.intBillId = @currentVoucherId
-- 	--CATCH EXCEPTION ON CREATING VOUCHER TO CONTINUE
-- 	BEGIN TRY
-- 		EXEC uspAPCreateBillData @userId = @currentUser,
-- 								@vendorId = @currentVendorId,
-- 								@type = 14,
-- 								@voucherNonInvDetails = @voucherDetail,
-- 								@shipTo = @currentShipTo,
-- 								@shipFrom = @currentShipFrom,
-- 								@currencyId = @currentCurrency,
-- 								@billId = @voucherIdCreated OUTPUT

-- 		INSERT INTO @vouchers
-- 		SELECT @voucherIdCreated

-- 		--UPDATE THE VOUCHER INTEREST DATE AND INTEREST ACCRUED THRU OF EXISTING VOUCHER
-- 		UPDATE A
-- 			SET A.dtmDate = deferredInterest.dtmPaymentPostDate,
-- 				A.dtmDueDate = deferredInterest.dtmPaymentDueDateOverride, 
-- 				A.dtmBillDate = deferredInterest.dtmPaymentInvoiceDate,
-- 				A.intTermsId = term.intTermID,
-- 				A.intDeferredVoucherId = @currentVoucherId,
-- 				A.strComment = deferredInterest.strCheckComment
-- 		FROM tblAPBill A
-- 		CROSS APPLY tblAPDeferredPaymentInterest deferredInterest
-- 		INNER JOIN tblSMTerm term ON deferredInterest.strTerm = term.strTerm
-- 		WHERE A.intBillId = @voucherIdCreated

-- 		UPDATE A
-- 			SET A.intDeferredVoucherId = @currentVoucherId
-- 		FROM tblAPBillDetail A
-- 		WHERE A.intBillId = @voucherIdCreated

-- 		UPDATE A
-- 			SET A.dtmDeferredInterestDate = deferredInterest.dtmPaymentDueDateOverride,
-- 				A.dtmInterestAccruedThru = deferredInterest.dtmCalculationDate
-- 		FROM tblAPBill A
-- 		CROSS APPLY tblAPDeferredPaymentInterest deferredInterest
-- 		INNER JOIN tblSMTerm term ON deferredInterest.strTerm = term.strTerm
-- 		WHERE A.intBillId = @currentVoucherId
		
-- 	END TRY
--     BEGIN CATCH
-- 	END CATCH

--     FETCH NEXT FROM c INTO @currentVoucherId, @currentVendorId, @currentShipTo, @currentShipFrom, @currentCurrency
-- END
-- CLOSE c; DEALLOCATE c;

DELETE A
FROM tblAPDeferredPaymentStaging A
INNER JOIN (tblAPBill deferred INNER JOIN @vouchers C ON deferred.intBillId = C.intBillId) --DELETE ONLY THOSE WHO HAVE SUCCESSFULLY CREATED
	ON deferred.intDeferredVoucherId = A.intBillId

-- SELECT @voucherIds = COALESCE(@voucherIds + ',', '') +  CONVERT(VARCHAR(12),intBillId) FROM @vouchers

SET @voucherCreated = @voucherIds;

IF @transCount = 0 COMMIT TRANSACTION
END TRY
BEGIN CATCH
	DECLARE @ErrorSeverity INT,
			@ErrorNumber   INT,
			@ErrorMessage nvarchar(4000),
			@ErrorState INT,
			@ErrorLine  INT,
			@ErrorProc nvarchar(200);
	-- Grab error information from SQL functions
	SET @ErrorSeverity = ERROR_SEVERITY()
	SET @ErrorNumber   = ERROR_NUMBER()
	SET @ErrorMessage  = ERROR_MESSAGE()
	SET @ErrorState    = ERROR_STATE()
	SET @ErrorLine     = ERROR_LINE()
	SET @ErrorProc     = ERROR_PROCEDURE()

	SET @ErrorMessage  = 'Error creating deferred payment.' + CHAR(13) + 
		'SQL Server Error Message is: ' + CAST(@ErrorNumber AS VARCHAR(10)) + 
		' in procedure: ' + @ErrorProc + ' Line: ' + CAST(@ErrorLine AS VARCHAR(10)) + ' Error text: ' + @ErrorMessage
	
	IF (XACT_STATE()) = -1
	BEGIN
		ROLLBACK TRANSACTION
	END
	ELSE IF (XACT_STATE()) = 1 AND @transCount = 0
	BEGIN
		ROLLBACK TRANSACTION
	END
	ELSE IF (XACT_STATE()) = 1 AND @transCount > 0
	BEGIN
		ROLLBACK TRANSACTION  @SavePoint
	END

	RAISERROR (@ErrorMessage , @ErrorSeverity, @ErrorState, @ErrorNumber)
END CATCH