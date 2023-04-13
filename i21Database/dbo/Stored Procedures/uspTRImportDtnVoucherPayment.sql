CREATE PROCEDURE [dbo].[uspTRImportDtnVoucherPayment]
	@intBillId INT,
	@intImportLoadId INT,
	@intImportDtnDetailId INT,
	@strErrMsg NVARCHAR(MAX) OUT

AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS OFF
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

BEGIN

	
	DECLARE @ErrorMessage NVARCHAR(4000)
	DECLARE @ErrorSeverity INT
	DECLARE @ErrorState INT

	BEGIN TRY
			
		DECLARE @intTermId INT = NULL
		DECLARE @dtmDueDate DATETIME = NULL
		DECLARE @dblAmountDue NUMERIC(18,6) = NULL
		DECLARE @dblTotalDeferredAmt NUMERIC(18,6) = NULL
		DECLARE @dblDeferredAmt NUMERIC(18,6) = NULL		
		DECLARE @dblDeferredAmt1 NUMERIC(18,6) = NULL
		DECLARE @dtmDeferredDate1 DATETIME = NULL
		DECLARE @dblDeferredAmt2 NUMERIC(18,6) = NULL
		DECLARE @dtmDeferredDate2 DATETIME = NULL
		DECLARE @dblDeferredAmt3 NUMERIC(18,6) = NULL
		DECLARE @dtmDeferredDate3 DATETIME = NULL
		DECLARE @dblDeferredAmt4 NUMERIC(18,6) = NULL
		DECLARE @dtmDeferredDate4 DATETIME = NULL
		DECLARE @dblDeferredAmt5 NUMERIC(18,6) = NULL
		DECLARE @dtmDeferredDate5 DATETIME = NULL
		DECLARE @dblDeferredAmt6 NUMERIC(18,6) = NULL
		DECLARE @dtmDeferredDate6 DATETIME = NULL
		DECLARE @dblDeferredAmt7 NUMERIC(18,6) = NULL
		DECLARE @dtmDeferredDate7 DATETIME = NULL
		DECLARE @dblDeferredAmt8 NUMERIC(18,6) = NULL
		DECLARE @dtmDeferredDate8 DATETIME = NULL
		DECLARE @dblDeferredAmt9 NUMERIC(18,6) = NULL
		DECLARE @dtmDeferredDate9 DATETIME = NULL
		DECLARE @dblDeferredAmt10 NUMERIC(18,6) = NULL
		DECLARE @dtmDeferredDate10 DATETIME = NULL
		DECLARE @strDeferredInvoiceNo1 NVARCHAR(50) = NULL
			, @strDeferredInvoiceNo2 NVARCHAR(50) = NULL
			, @strDeferredInvoiceNo3 NVARCHAR(50) = NULL
			, @strDeferredInvoiceNo4 NVARCHAR(50) = NULL
			, @strDeferredInvoiceNo5 NVARCHAR(50) = NULL
			, @strDeferredInvoiceNo6 NVARCHAR(50) = NULL
			, @strDeferredInvoiceNo7 NVARCHAR(50) = NULL
			, @strDeferredInvoiceNo8 NVARCHAR(50) = NULL
			, @strDeferredInvoiceNo9 NVARCHAR(50) = NULL
			, @strDeferredInvoiceNo10 NVARCHAR(50) = NULL
			, @strInvoiceNo NVARCHAR(50) = NULL

		SELECT @dblDeferredAmt1 = dblDeferredAmt1
			,@dtmDeferredDate1 = dtmDeferredDate1
			,@dblDeferredAmt2 = dblDeferredAmt2
			,@dtmDeferredDate2 = dtmDeferredDate2
			,@dblDeferredAmt3 = dblDeferredAmt3
			,@dtmDeferredDate3 = dtmDeferredDate3
			,@dblDeferredAmt4 = dblDeferredAmt4
			,@dtmDeferredDate4 = dtmDeferredDate4
			,@dblDeferredAmt5 = dblDeferredAmt5
			,@dtmDeferredDate5 = dtmDeferredDate5
			,@dblDeferredAmt6 = dblDeferredAmt6
			,@dtmDeferredDate6 = dtmDeferredDate6
			,@dblDeferredAmt7 = dblDeferredAmt7
			,@dtmDeferredDate7 = dtmDeferredDate7
			,@dblDeferredAmt8 = dblDeferredAmt8
			,@dtmDeferredDate8 = dtmDeferredDate8
			,@dblDeferredAmt9 = dblDeferredAmt9
			,@dtmDeferredDate9 = dtmDeferredDate9
			,@dblDeferredAmt10 = dblDeferredAmt10
			,@dtmDeferredDate10 = dtmDeferredDate10
			,@dtmDueDate = dtmDueDate
			,@strDeferredInvoiceNo1 = strDeferredInvoiceNo1
			,@strDeferredInvoiceNo2 = strDeferredInvoiceNo2
			,@strDeferredInvoiceNo3 = strDeferredInvoiceNo3
			,@strDeferredInvoiceNo4 = strDeferredInvoiceNo4
			,@strDeferredInvoiceNo5 = strDeferredInvoiceNo5
			,@strDeferredInvoiceNo6 = strDeferredInvoiceNo6
			,@strDeferredInvoiceNo7 = strDeferredInvoiceNo7
			,@strDeferredInvoiceNo8 = strDeferredInvoiceNo8
			,@strDeferredInvoiceNo9 = strDeferredInvoiceNo9
			,@strDeferredInvoiceNo10 = strDeferredInvoiceNo10
			,@strInvoiceNo = strInvoiceNo
		FROM tblTRImportDtnDetail DD WHERE DD.intImportDtnDetailId = @intImportDtnDetailId
						
		SELECT @intTermId = intTermsId, @dblAmountDue = dblAmountDue FROM tblAPBill B WHERE B.intBillId = @intBillId

		SET @dblDeferredAmt = @dblAmountDue - (ISNULL(@dblDeferredAmt1, 0) 
			+ ISNULL(@dblDeferredAmt2, 0) 
			+ ISNULL(@dblDeferredAmt3, 0) 
			+ ISNULL(@dblDeferredAmt4, 0)
			+ ISNULL(@dblDeferredAmt5, 0)
			+ ISNULL(@dblDeferredAmt6, 0)
			+ ISNULL(@dblDeferredAmt7, 0)
			+ ISNULL(@dblDeferredAmt8, 0)
			+ ISNULL(@dblDeferredAmt9, 0)
			+ ISNULL(@dblDeferredAmt10, 0))

		DECLARE @PaymentSchedule PaymentSchedule
		DECLARE @PaymentScheduleDetail PaymentSchedule
						
		INSERT INTO @PaymentSchedule ([intBillId],
			[intTermsId],
			[dtmDueDate],
			[dblPayment],
			[ysnPaid],
			[ysnScheduleDiscountOverride],
			[dblDiscount],
			strPaymentScheduleNumber)
		SELECT intBillId = @intBillId,
			intTermsId = @intTermId,
			dtmDueDate = @dtmDueDate,
			dblPayment = @dblDeferredAmt,
			ysnPaid = 0,
			ysnScheduleDiscountOverride = 0,
			dblDiscount = 0,
			strPaymentScheduleNumber = @strInvoiceNo

		IF(ISNULL(@dblDeferredAmt1, 0) <> 0)
		BEGIN
			INSERT INTO @PaymentScheduleDetail ([intBillId],
				[intTermsId],
				[dtmDueDate],
				[dblPayment],
				[ysnPaid],
				[ysnScheduleDiscountOverride],
				[dblDiscount],
				strPaymentScheduleNumber)
			SELECT intBillId = @intBillId,
				intTermsId = @intTermId,
				dtmDueDate = ISNULL(@dtmDeferredDate1, @dtmDueDate),
				dblPayment = @dblDeferredAmt1,
				ysnPaid = 0,
				ysnScheduleDiscountOverride = 0,
				dblDiscount = 0,
				strPaymentScheduleNumber = ISNULL(@strDeferredInvoiceNo1, @strInvoiceNo)
		END

		IF(ISNULL(@dblDeferredAmt2, 0) <> 0)
		BEGIN
			INSERT INTO @PaymentScheduleDetail ([intBillId],
				[intTermsId],
				[dtmDueDate],
				[dblPayment],
				[ysnPaid],
				[ysnScheduleDiscountOverride],
				[dblDiscount],
				strPaymentScheduleNumber)
			SELECT intBillId = @intBillId,
				intTermsId = @intTermId,
				dtmDueDate = ISNULL(@dtmDeferredDate2, @dtmDueDate),
				dblPayment = @dblDeferredAmt2,
				ysnPaid = 0,
				ysnScheduleDiscountOverride = 0,
				dblDiscount = 0,
				strPaymentScheduleNumber = ISNULL(@strDeferredInvoiceNo2, @strInvoiceNo)
		END
			
		IF(ISNULL(@dblDeferredAmt2, 0) <> 0 AND ISNULL(@dblDeferredAmt3, 0) <> 0)
		BEGIN
			INSERT INTO @PaymentScheduleDetail ([intBillId],
				[intTermsId],
				[dtmDueDate],
				[dblPayment],
				[ysnPaid],
				[ysnScheduleDiscountOverride],
				[dblDiscount],
				strPaymentScheduleNumber)
			SELECT intBillId = @intBillId,
				intTermsId = @intTermId,
				dtmDueDate = ISNULL(@dtmDeferredDate3, @dtmDueDate),
				dblPayment = @dblDeferredAmt3,
				ysnPaid = 0,
				ysnScheduleDiscountOverride = 0,
				dblDiscount = 0,
				strPaymentScheduleNumber = ISNULL(@strDeferredInvoiceNo3, @strInvoiceNo)
		END
			
		IF(ISNULL(@dblDeferredAmt2, 0) <> 0 AND ISNULL(@dblDeferredAmt3, 0) <> 0 AND ISNULL(@dblDeferredAmt4, 0) <> 0)
		BEGIN
			INSERT INTO @PaymentScheduleDetail ([intBillId],
				[intTermsId],
				[dtmDueDate],
				[dblPayment],
				[ysnPaid],
				[ysnScheduleDiscountOverride],
				[dblDiscount],
				strPaymentScheduleNumber)
			SELECT intBillId = @intBillId,
				intTermsId = @intTermId,
				dtmDueDate = ISNULL(@dtmDeferredDate4, @dtmDueDate),
				dblPayment = @dblDeferredAmt4,
				ysnPaid = 0,
				ysnScheduleDiscountOverride = 0,
				dblDiscount = 0,
				strPaymentScheduleNumber = ISNULL(@strDeferredInvoiceNo4, @strInvoiceNo)
		END
			
		IF(ISNULL(@dblDeferredAmt2, 0) <> 0 AND ISNULL(@dblDeferredAmt3, 0) <> 0 
			AND ISNULL(@dblDeferredAmt4, 0) <> 0 AND ISNULL(@dblDeferredAmt5, 0) <> 0)
		BEGIN
			INSERT INTO @PaymentScheduleDetail ([intBillId],
				[intTermsId],
				[dtmDueDate],
				[dblPayment],
				[ysnPaid],
				[ysnScheduleDiscountOverride],
				[dblDiscount],
				strPaymentScheduleNumber)
			SELECT intBillId = @intBillId,
				intTermsId = @intTermId,
				dtmDueDate = ISNULL(@dtmDeferredDate5, @dtmDueDate),
				dblPayment = @dblDeferredAmt5,
				ysnPaid = 0,
				ysnScheduleDiscountOverride = 0,
				dblDiscount = 0,
				strPaymentScheduleNumber = ISNULL(@strDeferredInvoiceNo5, @strInvoiceNo)
		END
			
		IF(ISNULL(@dblDeferredAmt2, 0) <> 0 AND ISNULL(@dblDeferredAmt3, 0) <> 0 
			AND ISNULL(@dblDeferredAmt4, 0) <> 0 AND ISNULL(@dblDeferredAmt5, 0) <> 0 
			AND ISNULL(@dblDeferredAmt6, 0) <> 0)
		BEGIN
			INSERT INTO @PaymentScheduleDetail ([intBillId],
				[intTermsId],
				[dtmDueDate],
				[dblPayment],
				[ysnPaid],
				[ysnScheduleDiscountOverride],
				[dblDiscount],
				strPaymentScheduleNumber)
			SELECT intBillId = @intBillId,
				intTermsId = @intTermId,
				dtmDueDate = ISNULL(@dtmDeferredDate6, @dtmDueDate),
				dblPayment = @dblDeferredAmt6,
				ysnPaid = 0,
				ysnScheduleDiscountOverride = 0,
				dblDiscount = 0,
				strPaymentScheduleNumber = ISNULL(@strDeferredInvoiceNo6, @strInvoiceNo)
		END
			
		IF(ISNULL(@dblDeferredAmt2, 0) <> 0 AND ISNULL(@dblDeferredAmt3, 0) <> 0 
			AND ISNULL(@dblDeferredAmt4, 0) <> 0 AND ISNULL(@dblDeferredAmt5, 0) <> 0 
			AND ISNULL(@dblDeferredAmt6, 0) <> 0 AND ISNULL(@dblDeferredAmt7, 0) <> 0)
		BEGIN
			INSERT INTO @PaymentScheduleDetail ([intBillId],
				[intTermsId],
				[dtmDueDate],
				[dblPayment],
				[ysnPaid],
				[ysnScheduleDiscountOverride],
				[dblDiscount],
				strPaymentScheduleNumber)
			SELECT intBillId = @intBillId,
				intTermsId = @intTermId,
				dtmDueDate = ISNULL(@dtmDeferredDate7, @dtmDueDate),
				dblPayment = @dblDeferredAmt7,
				ysnPaid = 0,
				ysnScheduleDiscountOverride = 0,
				dblDiscount = 0,
				strPaymentScheduleNumber = ISNULL(@strDeferredInvoiceNo7, @strInvoiceNo)
		END
			
		IF(ISNULL(@dblDeferredAmt2, 0) <> 0 AND ISNULL(@dblDeferredAmt3, 0) <> 0 
			AND ISNULL(@dblDeferredAmt4, 0) <> 0 AND ISNULL(@dblDeferredAmt5, 0) <> 0 
			AND ISNULL(@dblDeferredAmt6, 0) <> 0 AND ISNULL(@dblDeferredAmt7, 0) <> 0
			AND ISNULL(@dblDeferredAmt8, 0) <> 0)
		BEGIN
			INSERT INTO @PaymentScheduleDetail ([intBillId],
				[intTermsId],
				[dtmDueDate],
				[dblPayment],
				[ysnPaid],
				[ysnScheduleDiscountOverride],
				[dblDiscount],
				strPaymentScheduleNumber)
			SELECT intBillId = @intBillId,
				intTermsId = @intTermId,
				dtmDueDate = ISNULL(@dtmDeferredDate8, @dtmDueDate),
				dblPayment = @dblDeferredAmt8,
				ysnPaid = 0,
				ysnScheduleDiscountOverride = 0,
				dblDiscount = 0,
				strPaymentScheduleNumber = ISNULL(@strDeferredInvoiceNo8, @strInvoiceNo)
		END
			
		IF(ISNULL(@dblDeferredAmt2, 0) <> 0 AND ISNULL(@dblDeferredAmt3, 0) <> 0 
			AND ISNULL(@dblDeferredAmt4, 0) <> 0 AND ISNULL(@dblDeferredAmt5, 0) <> 0 
			AND ISNULL(@dblDeferredAmt6, 0) <> 0 AND ISNULL(@dblDeferredAmt7, 0) <> 0
			AND ISNULL(@dblDeferredAmt8, 0) <> 0 AND ISNULL(@dblDeferredAmt9, 0) <> 0)
		BEGIN
			INSERT INTO @PaymentScheduleDetail ([intBillId],
				[intTermsId],
				[dtmDueDate],
				[dblPayment],
				[ysnPaid],
				[ysnScheduleDiscountOverride],
				[dblDiscount],
				strPaymentScheduleNumber)
			SELECT intBillId = @intBillId,
				intTermsId = @intTermId,
				dtmDueDate = ISNULL(@dtmDeferredDate9, @dtmDueDate),
				dblPayment = @dblDeferredAmt9,
				ysnPaid = 0,
				ysnScheduleDiscountOverride = 0,
				dblDiscount = 0,
				strPaymentScheduleNumber = ISNULL(@strDeferredInvoiceNo9, @strInvoiceNo)
		END
			
		IF(ISNULL(@dblDeferredAmt2, 0) <> 0 AND ISNULL(@dblDeferredAmt3, 0) <> 0 
			AND ISNULL(@dblDeferredAmt4, 0) <> 0 AND ISNULL(@dblDeferredAmt5, 0) <> 0 
			AND ISNULL(@dblDeferredAmt6, 0) <> 0 AND ISNULL(@dblDeferredAmt7, 0) <> 0
			AND ISNULL(@dblDeferredAmt8, 0) <> 0 AND ISNULL(@dblDeferredAmt9, 0) <> 0
			AND ISNULL(@dblDeferredAmt10, 0) <> 0)
		BEGIN
			INSERT INTO @PaymentScheduleDetail ([intBillId],
				[intTermsId],
				[dtmDueDate],
				[dblPayment],
				[ysnPaid],
				[ysnScheduleDiscountOverride],
				[dblDiscount],
				strPaymentScheduleNumber)
			SELECT intBillId = @intBillId,
				intTermsId = @intTermId,
				dtmDueDate = ISNULL(@dtmDeferredDate10, @dtmDueDate),
				dblPayment = @dblDeferredAmt10,
				ysnPaid = 0,
				ysnScheduleDiscountOverride = 0,
				dblDiscount = 0,
				strPaymentScheduleNumber = ISNULL(@strDeferredInvoiceNo10, @strInvoiceNo)
		END

		INSERT INTO @PaymentSchedule ([intBillId],
			[intTermsId],
			[dtmDueDate],
			[dblPayment],
			[ysnPaid],
			[ysnScheduleDiscountOverride],
			[dblDiscount],
			strPaymentScheduleNumber)
		SELECT intBillId
			, intTermsId
			, dtmDueDate
			, dblPayment = SUM(dblPayment)
			, 0
			, 0
			, 0
			, strPaymentScheduleNumber
		FROM @PaymentScheduleDetail
		GROUP BY intBillId
			, intTermsId
			, dtmDueDate
			, strPaymentScheduleNumber

		IF EXISTS(SELECT TOP 1 1 FROM @PaymentSchedule)
		BEGIN
			BEGIN TRY
				DECLARE @error NVARCHAR(MAX)
				EXEC [dbo].[uspAPAddPaymentSchedules]
					@paySchedules = @PaymentSchedule
					,@error = @error OUTPUT
				
				SET @strErrMsg = @error
			END TRY
			BEGIN CATCH
				SELECT @ErrorMessage = ERROR_MESSAGE(),
					@ErrorSeverity = ERROR_SEVERITY(),
					@ErrorState = ERROR_STATE();
				SET @strErrMsg = @ErrorMessage
			END CATCH
		END		
	END TRY
	BEGIN CATCH
		SELECT @ErrorMessage = ERROR_MESSAGE(),
			@ErrorSeverity = ERROR_SEVERITY(),
			@ErrorState = ERROR_STATE();
		SET @strErrMsg = @ErrorMessage
	END CATCH

END	