CREATE PROCEDURE [dbo].[uspAPUpdateVoucherTempData](
	@voucherId INT
	,@datePaid DATETIME = GETDATE
	,@tempDiscount DECIMAL(18,6) = 0
	,@tempInterest DECIMAL(18,6) = 0
	,@tempPayment DECIMAL(18,6) = 0
	,@tempWithheld DECIMAL(18,6) = 0
	,@readyForPayment BIT = 0
	,@tempPaymentInfo NVARCHAR(MAX) = NULL
	,@newPayment DECIMAL(18,2) = 0 OUTPUT
	,@paymentVoucherIds NVARCHAR(MAX) = NULL OUTPUT
)
AS

BEGIN

	SET QUOTED_IDENTIFIER OFF
	SET ANSI_NULLS ON
	SET NOCOUNT ON
	SET XACT_ABORT ON
	SET ANSI_WARNINGS OFF

	DECLARE @updatedPaymentAmt DECIMAL(18,2);

	BEGIN TRY

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

	DECLARE @transCount INT = @@TRANCOUNT;
	IF @transCount = 0 BEGIN TRANSACTION
	BEGIN
		UPDATE voucher
			SET	@updatedPaymentAmt = CASE WHEN @tempPayment != voucher.dblTempPayment --Payment have been edited
					THEN @tempPayment
					ELSE voucher.dblAmountDue - @tempDiscount + @tempInterest
					END
				,voucher.dblTempDiscount = @tempDiscount
				,voucher.dblTempInterest = @tempInterest
				,voucher.dblTempPayment = CASE WHEN @readyForPayment = 1 THEN @updatedPaymentAmt ELSE 0 END
				,voucher.dblTempWithheld = @tempWithheld
				,voucher.strTempPaymentInfo = @tempPaymentInfo
				,voucher.ysnReadyForPayment = @readyForPayment
		FROM tblAPBill voucher
		WHERE voucher.intBillId = @voucherId

		SET @newPayment = CASE WHEN @readyForPayment = 1 THEN @updatedPaymentAmt ELSE 0 END;
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