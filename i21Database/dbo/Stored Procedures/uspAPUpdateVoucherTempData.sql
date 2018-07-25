CREATE PROCEDURE [dbo].[uspAPUpdateVoucherTempData](
	@voucherIds NVARCHAR(MAX)
	,@datePaid DATETIME = GETDATE
	,@tempDiscount DECIMAL(18,6) = 0
	,@tempInterest DECIMAL(18,6) = 0
	,@tempPayment DECIMAL(18,6) = 0
	,@tempWithheld DECIMAL(18,6) = 0
	,@readyForPayment BIT = 0
	,@haveNegativePayment BIT = 0
	,@tempPaymentInfo NVARCHAR(MAX) = NULL
	,@newPayment DECIMAL(18,2) = 0 OUTPUT
	,@newWithheld DECIMAL(18,2) = 0 OUTPUT
	,@newPaymentInfo NVARCHAR(MAX) = NULL OUTPUT
	,@paymentVoucherIds NVARCHAR(MAX) = NULL OUTPUT
)
AS

BEGIN

	SET QUOTED_IDENTIFIER OFF
	SET ANSI_NULLS ON
	SET NOCOUNT ON
	SET XACT_ABORT ON
	SET ANSI_WARNINGS OFF

	DECLARE @recordsToUpdate INT;
	DECLARE @recordsUpdated INT;
	DECLARE @updatedPaymentAmt DECIMAL(18,2) = 0;
	DECLARE @updatedWithheld DECIMAL(18,2) = 0;
	DECLARE @amountDue DECIMAL(18,2);
	DECLARE @ids AS Id;
	DECLARE @vouchersForPaymentTran NVARCHAR(MAX);

	INSERT INTO @ids
	SELECT [intID] FROM [dbo].fnGetRowsFromDelimitedValues(@voucherIds)

	--REMOVE INVALID VOUCHERS
	DELETE A
	FROM @ids A
	INNER JOIN tblAPBill B ON A.intId = B.intBillId
	WHERE (B.ysnPosted = 0 
	OR B.ysnPaid = 1
	OR B.dblTotal = 0
	OR B.dblAmountDue > B.dblTotal) 

	SET @recordsToUpdate = (SELECT COUNT(*) FROM @ids);

	BEGIN TRY

	DECLARE @transCount INT = @@TRANCOUNT;
	IF @transCount = 0 BEGIN TRANSACTION
	
	IF (SELECT COUNT(*) FROM @ids) > 1
	BEGIN
		--MULTIPLE UPDATE
		UPDATE voucher
			SET	@updatedPaymentAmt = voucher.dblAmountDue - voucher.dblTempDiscount + voucher.dblTempInterest
				,@amountDue = voucher.dblAmountDue
				,@updatedWithheld = CASE WHEN vendor.ysnWithholding = 1 THEN
												CAST(@updatedPaymentAmt * (loc.dblWithholdPercent / 100) AS DECIMAL(18,2))
											ELSE 0 END
				,voucher.dblTempPayment = CASE WHEN NOT @updatedPaymentAmt > @amountDue THEN @updatedPaymentAmt - @updatedWithheld ELSE @amountDue END
				,voucher.dblTempWithheld = @updatedWithheld
				,voucher.ysnReadyForPayment = 1
		FROM tblAPBill voucher
		INNER JOIN @ids ids ON voucher.intBillId = ids.intId
		INNER JOIN tblAPVendor vendor ON voucher.intEntityVendorId = vendor.intEntityId
		INNER JOIN tblSMCompanyLocation loc ON voucher.intShipToId = loc.intCompanyLocationId
		WHERE voucher.ysnPosted = 1
		AND voucher.ysnPaid = 0
		AND voucher.dblTotal != 0

		SET @recordsUpdated = @@ROWCOUNT;
	END
	ELSE
		BEGIN
		--Validate
		IF @tempDiscount != 0
		BEGIN
			--DO NOT ALLOW NEGATIVE DISCOUNT
			IF @tempDiscount < 0 
			BEGIN
				RAISERROR('PAYVOUCHERNEGATIVEDISCOUNT', 16, 1);
				RETURN;
			END

			--DO NOT ALLOW NEGATIVE INTEREST
			IF @tempInterest < 0 
			BEGIN
				RAISERROR('PAYVOUCHERNEGATIVEINTEREST', 16, 1);
				RETURN;
			END
		END

		UPDATE voucher
			SET	@updatedPaymentAmt = CASE WHEN @tempPayment != voucher.dblTempPayment --Payment have been edited
					THEN @tempPayment
					ELSE voucher.dblAmountDue - @tempDiscount + @tempInterest
					END
				,@amountDue = voucher.dblAmountDue
				,@updatedWithheld = CASE WHEN vendor.ysnWithholding = 1 THEN
												CAST(@updatedPaymentAmt * (loc.dblWithholdPercent / 100) AS DECIMAL(18,2))
											ELSE 0 END
				,voucher.dblTempDiscount = @tempDiscount
				,voucher.dblTempInterest = @tempInterest
				,voucher.dblTempPayment = CASE WHEN @readyForPayment = 1 THEN @updatedPaymentAmt ELSE 0 END --when not ready for payment, set the payment to 0
				,voucher.dblTempWithheld = CASE WHEN @readyForPayment = 1 THEN @updatedWithheld ELSE 0 END
				,voucher.strTempPaymentInfo = CASE WHEN @readyForPayment = 1 THEN @tempPaymentInfo ELSE NULL END
				,voucher.ysnReadyForPayment = @readyForPayment
		FROM tblAPBill voucher
		INNER JOIN @ids ids ON voucher.intBillId = ids.intId
		INNER JOIN tblAPVendor vendor ON voucher.intEntityVendorId = vendor.intEntityId
		INNER JOIN tblSMCompanyLocation loc ON voucher.intShipToId = loc.intCompanyLocationId
		WHERE voucher.ysnPosted = 1
		AND voucher.ysnPaid = 0
		AND voucher.dblTotal != 0

		SET @recordsUpdated = @@ROWCOUNT;
		SET @newPaymentInfo = CASE WHEN @readyForPayment = 1 THEN @tempPaymentInfo ELSE NULL END; 
		--return the new payment if ready for payment only
		SET @newPayment = CASE WHEN @readyForPayment = 1 THEN @updatedPaymentAmt ELSE 0 END; 
		SET @newWithheld = CASE WHEN @readyForPayment = 1 THEN @updatedWithheld ELSE 0 END;

		--DO NOT ALLOW OVER PAY
		IF @readyForPayment = 1 AND @newPayment > (@amountDue + @tempInterest - @tempDiscount)
		BEGIN
			RAISERROR('PAYVOUCHEROVERPAY', 16, 1);
			RETURN;
		END
	END

	IF @recordsToUpdate != @recordsUpdated
	BEGIN
		RAISERROR('PAYVOUCHERINVALIDROWSAFFECTED', 16, 1);
		RETURN;
	END

	--CHECK IF THERE ARE NEGATIVE PAYMENT
	IF EXISTS(
		SELECT 
			TOP 1 1
		FROM dbo.fnAPPartitonPaymentOfVouchers(@ids) payVouchers
		WHERE dblAmountPaid < 0)
	BEGIN
		SET @haveNegativePayment = 0;
	END

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
		IF @transCount = 0 AND XACT_STATE() <> 0 ROLLBACK TRANSACTION
		RAISERROR (@ErrorMessage , @ErrorSeverity, @ErrorState, @ErrorNumber)
	END CATCH
END