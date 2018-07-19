CREATE PROCEDURE [dbo].[uspAPUpdateVoucherTempData](
	@voucherIds NVARCHAR(MAX)
	,@datePaid DATETIME = GETDATE
	,@tempDiscount DECIMAL(18,6) = 0
	,@tempInterest DECIMAL(18,6) = 0
	,@tempPayment DECIMAL(18,6) = 0
	,@tempWithheld DECIMAL(18,6) = 0
	,@readyForPayment BIT = 0
	,@tempPaymentInfo NVARCHAR(MAX) = NULL
	,@newPayment DECIMAL(18,2) = 0 OUTPUT
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
	DECLARE @updatedPaymentAmt DECIMAL(18,2);
	DECLARE @amountDue DECIMAL(18,2);
	DECLARE @ids AS Id;
	DECLARE @vouchersForPaymentTran NVARCHAR(MAX);

	INSERT INTO @ids
	SELECT [intID] FROM [dbo].fnGetRowsFromDelimitedValues(@voucherIds)

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
				,voucher.dblTempPayment = CASE WHEN NOT @updatedPaymentAmt > @amountDue THEN @updatedPaymentAmt ELSE @amountDue END
				,voucher.ysnReadyForPayment = 1
		FROM tblAPBill voucher
		INNER JOIN @ids ids ON voucher.intBillId = ids.intId
		AND voucher.ysnPosted = 1
		AND voucher.ysnPaid = 0

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
				,voucher.dblTempDiscount = @tempDiscount
				,voucher.dblTempInterest = @tempInterest
				,voucher.dblTempPayment = CASE WHEN @readyForPayment = 1 THEN @updatedPaymentAmt ELSE 0 END --when not ready for payment, set the payment to 0
				,voucher.dblTempWithheld = @tempWithheld
				,voucher.strTempPaymentInfo = @tempPaymentInfo
				,voucher.ysnReadyForPayment = @readyForPayment
		FROM tblAPBill voucher
		INNER JOIN @ids ids ON voucher.intBillId = ids.intId

		SET @recordsUpdated = @@ROWCOUNT;

		--return the new payment if ready for payment only
		SET @newPayment = CASE WHEN @readyForPayment = 1 THEN @updatedPaymentAmt ELSE 0 END; 

		--START UPDATING OF PAYMENT INFO
		-- BEGIN
		-- 	--GET ALL ASSOCIATED VOUCHERS WHEN PAYMENT WILL BE CREATED
		-- 	DECLARE @voucherId INT = (SELECT TOP 1 intId FROM @ids); --get the voucher being update
		-- 	DECLARE @tableVoucherForPaymentDetails TABLE(intBillId INT);
		-- 	INSERT INTO @tableVoucherForPaymentDetails
		-- 	SELECT
		-- 		intBillId
		-- 	FROM dbo.fnAPGetVoucherPaymentDetails(@voucherId) vouchersId
			
		-- 	SELECT
		-- 		@vouchersForPaymentTran = COALESCE(@vouchersForPaymentTran + ',', '') +  CONVERT(VARCHAR(12),intBillId)
		-- 	FROM @tableVoucherForPaymentDetails vouchersId
		-- 	ORDER BY intBillId

		-- 	SET @paymentVoucherIds = @vouchersForPaymentTran

		-- 	--IF temp payment info is empty, check to see if other vouchers already have temp payment info
		-- 	IF NULLIF(@tempPaymentInfo,'') IS NULL
		-- 	BEGIN
		-- 		SELECT TOP 1
		-- 			@newPaymentInfo = voucher.strTempPaymentInfo
		-- 		FROM tblAPBill voucher
		-- 		INNER JOIN @tableVoucherForPaymentDetails B ON voucher.intBillId = B.intBillId
		-- 		WHERE voucher.strTempPaymentInfo IS NOT NULL
		-- 	END
		-- END
		--END UPDATING OF PAYMENT INFO

		--DO NOT ALLOW OVER PAY
		IF @readyForPayment = 1 AND @newPayment > @amountDue
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