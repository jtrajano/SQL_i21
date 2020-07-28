CREATE PROCEDURE [dbo].[uspAPUpdateVoucherPayment]
	@paymentIds	AS VARCHAR(MAX),
	@post		AS BIT = NULL	-- NULL = UPDATE, 0 = DELETE, 1 = ADD
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT OFF
SET ANSI_WARNINGS OFF

BEGIN TRY
	DECLARE @dblPaymentTemp DECIMAL(18,2) = 0;
	DECLARE @ysnInPayment BIT = 0;
	DECLARE @nullCheck BIT = 0;
	DECLARE @tempCheck DECIMAL(18,2) = 0;
	DECLARE @totalCheck DECIMAL(18,2) = 0;
	DECLARE @billCheck VARCHAR(10) = '';
	DECLARE @ids Id;
	DECLARE @transCount INT = @@TRANCOUNT;
	IF @transCount = 0 BEGIN TRANSACTION

	INSERT INTO @ids
	--USE DISTINCT TO REMOVE DUPLICATE BILL ID FOR SCHEDULE PAYMENT
	SELECT DISTINCT [intID] FROM [dbo].fnGetRowsFromDelimitedValues(@paymentIds)

	--UPDATE NEW PAYMENTS
	IF @post = 1
	BEGIN
		UPDATE P
		SET P.ysnNewFlag = 1
		FROM tblAPPayment P
		WHERE P.intPaymentId IN (SELECT intId FROM @ids)
	END

	IF @post IS NULL OR @post = 1
	BEGIN
		UPDATE tblAPBill 
		SET
			@dblPaymentTemp =	(
									ISNULL(paySchedDetails.dblPayment, ISNULL(payDetails.dblPayment, 0)) +
									ISNULL(paySchedDetails.dblDiscount, ISNULL(payDetails.dblDiscount, 0))
								),
			@ysnInPayment = CASE WHEN B.dblAmountDue = @dblPaymentTemp
							THEN 1
							ELSE
								CASE WHEN @dblPaymentTemp < 0 OR @dblPaymentTemp > B.dblAmountDue
								THEN NULL
								ELSE 0
								END
							END,
			tblAPBill.dblPaymentTemp = @dblPaymentTemp,
			tblAPBill.ysnInPayment = @ysnInPayment
		FROM tblAPPayment P
		INNER JOIN tblAPPaymentDetail PD ON PD.intPaymentId = P.intPaymentId
		INNER JOIN tblAPBill B ON B.intBillId = PD.intBillId
		OUTER APPLY 
		(
			SELECT
				PD.intBillId,
				SUM(PD.dblPayment) dblPayment,
				SUM(PD.dblDiscount) dblDiscount
			FROM tblAPPaymentDetail PD
			WHERE 
				PD.intPayScheduleId IS NULL AND PD.intBillId = B.intBillId AND P.ysnNewFlag = 1
			GROUP BY PD.intBillId
		) payDetails 
		OUTER APPLY (
			SELECT 
				PD.intBillId,
				SUM(PD.dblPayment) dblPayment,
				SUM(PD.dblDiscount) dblDiscount
			FROM tblAPPaymentDetail PD
			WHERE 
				PD.intPayScheduleId > 0 AND PD.intBillId = B.intBillId AND P.ysnNewFlag = 1
			GROUP BY PD.intBillId
		) paySchedDetails
		WHERE P.intPaymentId IN (SELECT intId FROM @ids)
	END
	ELSE IF @post = 0
	BEGIN
		UPDATE tblAPBill 
		SET
			@dblPaymentTemp =	(
									ISNULL(paySchedDetails.dblPayment, ISNULL(payDetails.dblPayment, 0)) +
									ISNULL(paySchedDetails.dblDiscount, ISNULL(payDetails.dblDiscount, 0))
								),
			@ysnInPayment = CASE WHEN B.dblAmountDue = @dblPaymentTemp
							THEN 1
							ELSE
								CASE WHEN @dblPaymentTemp < 0 OR @dblPaymentTemp > B.dblAmountDue
								THEN NULL
								ELSE 0
								END
							END,
			tblAPBill.dblPaymentTemp = @dblPaymentTemp,
			tblAPBill.ysnInPayment = @ysnInPayment
		FROM tblAPPayment P
		INNER JOIN tblAPPaymentDetail PD ON PD.intPaymentId = P.intPaymentId
		INNER JOIN tblAPBill B ON B.intBillId = PD.intBillId
		OUTER APPLY 
		(
			SELECT
				PD.intBillId,
				SUM(PD.dblPayment) dblPayment,
				SUM(PD.dblDiscount) dblDiscount
			FROM tblAPPaymentDetail PD
			WHERE 
				PD.intPaymentId <> P.intPaymentId AND PD.intPayScheduleId IS NULL AND PD.intBillId = B.intBillId AND P.ysnNewFlag = 1
			GROUP BY PD.intBillId
		) payDetails 
		OUTER APPLY (
			SELECT 
				PD.intBillId,
				SUM(PD.dblPayment) dblPayment,
				SUM(PD.dblDiscount) dblDiscount
			FROM tblAPPaymentDetail PD
			WHERE 
				PD.intPaymentId <> P.intPaymentId AND PD.intPayScheduleId > 0 AND PD.intBillId = B.intBillId AND P.ysnNewFlag = 1
			GROUP BY PD.intBillId
		) paySchedDetails
		WHERE P.intPaymentId IN (SELECT intId FROM @ids)
	END

	--SELECT NULLED BILLS
	SELECT TOP 1 
		@nullCheck = B.ysnInPayment,
		@tempCheck = B.dblPaymentTemp,
		@totalCheck = B.dblAmountDue,
		@billCheck = B.strBillId
	FROM tblAPPayment P
	INNER JOIN tblAPPaymentDetail PD ON PD.intPaymentId = P.intPaymentId
	INNER JOIN tblAPBill B ON B.intBillId = PD.intBillId
	WHERE P.intPaymentId IN (SELECT intId FROM @ids) AND B.ysnInPayment IS NULL

	--VALIDATIONS
	IF @nullCheck IS NULL AND @tempCheck > @totalCheck
	BEGIN
		RAISERROR('%s will be overpaid.', 11, 1, @billCheck);
	END

	IF @nullCheck IS NULL AND @tempCheck < 0
	BEGIN
		RAISERROR('$s will be underpaid.', 11, 1, @billCheck);
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
