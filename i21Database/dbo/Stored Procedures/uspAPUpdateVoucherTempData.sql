CREATE PROCEDURE [dbo].[uspAPUpdateVoucherTempData](
	@voucherIds NVARCHAR(MAX) = NULL
	,@paySchedIds NVARCHAR(MAX) = NULL
	,@selectDue BIT = NULL
	,@datePaid DATETIME = GETDATE
	,@tempDiscount DECIMAL(18,6) = 0
	,@tempInterest DECIMAL(18,6) = 0
	,@tempPayment DECIMAL(18,6) = 0
	,@tempWithheld DECIMAL(18,6) = 0
	,@readyForPayment BIT = 0
	,@discountOverride BIT = 0
	,@tempPaymentInfo NVARCHAR(MAX) = NULL
	,@negativePayment NVARCHAR(MAX) = NULL OUTPUT
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

	DECLARE @vouchers NVARCHAR(MAX) = @voucherIds;
	DECLARE @paySched NVARCHAR(MAX) = @paySchedIds;
	DECLARE @voucherRecordsUpdated INT;
	DECLARE @paySchedRecordsUpdated INT;
	DECLARE @updatedPaymentAmt DECIMAL(18,2) = 0;
	DECLARE @updatedWithheld DECIMAL(18,2) = 0;
	DECLARE @amountDue DECIMAL(18,2);
	DECLARE @ids AS Id;
	DECLARE @schedIds AS Id;
	DECLARE @cntVoucher INT = 0;
	DECLARE @cntPaySched INT = 0;
	DECLARE @vouchersForPaymentTran NVARCHAR(MAX);

	INSERT INTO @ids
	SELECT [intID] FROM [dbo].fnGetRowsFromDelimitedValues(@vouchers) WHERE intID > 0

	--REMOVE INVALID VOUCHERS
	DELETE A
	FROM @ids A
	INNER JOIN tblAPBill B ON A.intId = B.intBillId
	WHERE 
	(
		B.ysnPosted = 0 
	OR	B.ysnPaid = 1
	OR	B.dblTotal = 0
	OR	B.dblAmountDue > B.dblTotal
	)  

	SELECT @cntVoucher = COUNT(*) FROM @ids

	IF OBJECT_ID('tempdb..#tmpNegativePayment') IS NOT NULL DROP TABLE #tmpNegativePayment
	CREATE TABLE #tmpNegativePayment(intBillId INT);

	INSERT INTO @schedIds
	SELECT [intID] FROM [dbo].fnGetRowsFromDelimitedValues(@paySched) WHERE intID > 0

	DELETE A
	FROM @schedIds A
	INNER JOIN tblAPVoucherPaymentSchedule A2 ON A.intId = A2.intId
	INNER JOIN tblAPBill B ON A2.intBillId = B.intBillId
	WHERE 
	(
		B.ysnPosted = 0 
	OR	B.ysnPaid = 1
	OR	B.dblTotal = 0
	OR	B.dblAmountDue > B.dblTotal
	OR	A2.ysnPaid = 1
	) 

	SELECT @cntPaySched = COUNT(*) FROM @schedIds

	BEGIN TRY

	DECLARE @transCount INT = @@TRANCOUNT;
	IF @transCount = 0 BEGIN TRANSACTION
	
	--VOUCHERS
	IF @cntVoucher > 0
	BEGIN
		IF (SELECT COUNT(*) FROM @ids) > 1
		BEGIN
			--MULTIPLE UPDATE
			IF @selectDue IS NULL
			BEGIN
				UPDATE voucher
					SET	@updatedPaymentAmt = voucher.dblAmountDue - voucher.dblTempDiscount + voucher.dblTempInterest
						--,@amountDue = voucher.dblAmountDue
						,@amountDue = CASE WHEN voucher.dblPaymentTemp <> 0 THEN ((voucher.dblTotal - appliedPrepays.dblPayment) - voucher.dblPaymentTemp) ELSE voucher.dblAmountDue END
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
				OUTER APPLY (
					SELECT SUM(APD.dblAmountApplied) AS dblPayment
					FROM tblAPAppliedPrepaidAndDebit APD
					WHERE APD.intBillId = voucher.intBillId AND APD.ysnApplied = 1
				) appliedPrepays
				WHERE voucher.ysnPosted = 1
				AND voucher.ysnPaid = 0
				AND voucher.dblTotal != 0
			END
			ELSE
			BEGIN
				--MARK ALL DUE VOUCHERS AS READY FOR PAYMENT
				UPDATE voucher
					SET	@updatedPaymentAmt = voucher.dblAmountDue - voucher.dblTempDiscount + voucher.dblTempInterest
						--,@amountDue = voucher.dblAmountDue
						,@amountDue = CASE WHEN voucher.dblPaymentTemp <> 0 THEN ((voucher.dblTotal - appliedPrepays.dblPayment) - voucher.dblPaymentTemp) ELSE voucher.dblAmountDue END
						,@updatedWithheld = CASE WHEN vendor.ysnWithholding = 1 THEN
														CAST(@updatedPaymentAmt * (loc.dblWithholdPercent / 100) AS DECIMAL(18,2))
													ELSE 0 END
						,voucher.dblTempPayment = CASE WHEN NOT @updatedPaymentAmt > @amountDue THEN @updatedPaymentAmt - @updatedWithheld ELSE @amountDue END
						,voucher.dblTempWithheld = @updatedWithheld
						,voucher.ysnReadyForPayment = CASE WHEN @selectDue = 1
															THEN 
																CASE WHEN @datePaid >= dbo.fnGetDueDateBasedOnTerm(voucher.dtmDate, voucher.intTermsId)
																THEN 1
																ELSE 0
																END
															ELSE 0
														END
				FROM tblAPBill voucher
				INNER JOIN @ids ids ON voucher.intBillId = ids.intId
				INNER JOIN tblAPVendor vendor ON voucher.intEntityVendorId = vendor.intEntityId
				INNER JOIN tblSMCompanyLocation loc ON voucher.intShipToId = loc.intCompanyLocationId
				OUTER APPLY (
					SELECT SUM(APD.dblAmountApplied) AS dblPayment
					FROM tblAPAppliedPrepaidAndDebit APD
					WHERE APD.intBillId = voucher.intBillId AND APD.ysnApplied = 1
				) appliedPrepays
				WHERE voucher.ysnPosted = 1
				AND voucher.ysnPaid = 0
				AND voucher.dblTotal != 0
			END

			SET @voucherRecordsUpdated = @@ROWCOUNT;
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
						ELSE ((voucher.dblTotal - appliedPrepays.dblPayment) - voucher.dblPaymentTemp) - @tempDiscount + @tempInterest
						END
					--,@amountDue = voucher.dblAmountDue
					,@amountDue = CASE WHEN voucher.dblPaymentTemp <> 0 THEN ((voucher.dblTotal - appliedPrepays.dblPayment) - voucher.dblPaymentTemp) ELSE voucher.dblAmountDue END
					,@updatedWithheld = CASE WHEN vendor.ysnWithholding = 1 THEN
													CAST(@updatedPaymentAmt * (loc.dblWithholdPercent / 100) AS DECIMAL(18,2))
												ELSE 0 END
					,voucher.dblTempDiscount = @tempDiscount
					,voucher.dblTempInterest = @tempInterest
					,voucher.dblTempPayment = CASE WHEN @readyForPayment = 1 THEN @updatedPaymentAmt ELSE 0 END --when not ready for payment, set the payment to 0
					,voucher.dblTempWithheld = CASE WHEN @readyForPayment = 1 THEN @updatedWithheld ELSE 0 END
					,voucher.strTempPaymentInfo = CASE WHEN @readyForPayment = 1 THEN @tempPaymentInfo ELSE NULL END
					,voucher.ysnReadyForPayment = @readyForPayment
					,voucher.ysnDiscountOverride = CASE WHEN @discountOverride = 1 THEN 1 ELSE voucher.ysnDiscountOverride END
					,voucher.dblDiscount = CASE WHEN @discountOverride = 1 THEN @tempDiscount ELSE voucher.dblDiscount END
			FROM tblAPBill voucher
			INNER JOIN @ids ids ON voucher.intBillId = ids.intId
			INNER JOIN tblAPVendor vendor ON voucher.intEntityVendorId = vendor.intEntityId
			INNER JOIN tblSMCompanyLocation loc ON voucher.intShipToId = loc.intCompanyLocationId
			OUTER APPLY (
				SELECT SUM(APD.dblAmountApplied) AS dblPayment
				FROM tblAPAppliedPrepaidAndDebit APD
				WHERE APD.intBillId = voucher.intBillId AND APD.ysnApplied = 1
			) appliedPrepays
			WHERE voucher.ysnPosted = 1
			AND voucher.ysnPaid = 0
			AND voucher.dblTotal != 0

			SET @voucherRecordsUpdated = @@ROWCOUNT;
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

		IF @cntVoucher != @voucherRecordsUpdated
		BEGIN
			RAISERROR('PAYVOUCHERINVALIDROWSAFFECTED', 16, 1);
			RETURN;
		END
	END
	
	IF @cntPaySched > 0
	BEGIN
		--MULTIPLE
		IF @cntPaySched > 1
		BEGIN
			IF @selectDue IS NULL
			BEGIN
				UPDATE A
					SET A.ysnReadyForPayment = @readyForPayment
				FROM tblAPVoucherPaymentSchedule A
				INNER JOIN @schedIds A2 ON A.intId = A2.intId
				INNER JOIN tblAPBill B ON A.intBillId = B.intBillId
				WHERE 
					A.ysnPaid = 0
				AND B.ysnPosted = 1
				AND B.dblAmountDue != 0
			END
			ELSE
			BEGIN
				UPDATE A
					SET A.ysnReadyForPayment = CASE WHEN @selectDue = 1
															THEN 
																CASE WHEN @datePaid >= A.dtmDueDate
																THEN 1
																ELSE 0
																END
															ELSE 0
														END
				FROM tblAPVoucherPaymentSchedule A
				INNER JOIN tblAPBill B ON A.intBillId = B.intBillId
				WHERE 
					A.ysnPaid = 0
				AND B.ysnPosted = 1
				AND B.dblAmountDue != 0
			END

			SET @paySchedRecordsUpdated = @@ROWCOUNT;
		END
		ELSE
		BEGIN
			UPDATE A
				SET A.ysnReadyForPayment = @readyForPayment
				,@updatedPaymentAmt = A.dblPayment - A.dblDiscount
				,@updatedWithheld = CASE WHEN vendor.ysnWithholding = 1 THEN
													CAST(@updatedPaymentAmt * (loc.dblWithholdPercent / 100) AS DECIMAL(18,2))
												ELSE 0 END
			FROM tblAPVoucherPaymentSchedule A
			INNER JOIN @schedIds A2 ON A.intId = A2.intId
			INNER JOIN tblAPBill B ON A.intBillId = B.intBillId
			INNER JOIN tblAPVendor vendor ON B.intEntityVendorId = vendor.intEntityId
			INNER JOIN tblSMCompanyLocation loc ON B.intShipToId = loc.intCompanyLocationId
			WHERE 
				A.ysnPaid = 0
			AND B.ysnPosted = 1
			AND B.dblAmountDue != 0

			SET @paySchedRecordsUpdated = @@ROWCOUNT;
			
			SET @newPaymentInfo = CASE WHEN @readyForPayment = 1 THEN @tempPaymentInfo ELSE NULL END; 
			SET @newPayment = CASE WHEN @readyForPayment = 1 THEN @updatedPaymentAmt ELSE 0 END; 
			SET @newWithheld = CASE WHEN @readyForPayment = 1 THEN @updatedWithheld ELSE 0 END;
		END

		IF @cntPaySched != @paySchedRecordsUpdated
		BEGIN
			RAISERROR('PAYVOUCHERINVALIDROWSAFFECTED', 16, 1);
			RETURN;
		END
	END
	--CHECK IF THERE ARE NEGATIVE PAYMENT
	-- INSERT INTO #tmpNegativePayment
	-- SELECT 
	-- 	payVouchers.intBillId
	-- FROM dbo.fnAPPartitonPaymentOfVouchers(@ids) payVouchers
	-- WHERE dblTempPayment < 0

	-- SELECT @negativePayment	=	STUFF((
	-- 									SELECT ',' + CAST(vouchers.intBillId AS NVARCHAR)
	-- 									FROM #tmpNegativePayment vouchers
	-- 									FOR XML PATH('')),1,1,''
	-- 								)


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