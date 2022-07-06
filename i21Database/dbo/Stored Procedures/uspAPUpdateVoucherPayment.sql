﻿CREATE PROCEDURE [dbo].[uspAPUpdateVoucherPayment]
	@paymentIds	AS VARCHAR(MAX),
	@post		AS BIT = NULL	-- NULL = UPDATE, 0 = DELETE, 1 = ADD
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT OFF
SET ANSI_WARNINGS OFF

BEGIN TRY
	DECLARE @emptyBillPayFromBankAccount VARCHAR(1000) = '';
	DECLARE @emptyBillPayToBankAccount VARCHAR(1000) = '';
	DECLARE @billPayBankAccountCount INT = 1;

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
		--VALIDATE EMPTY PAY FROM BANK ACCOUNT
		SELECT @emptyBillPayFromBankAccount = COALESCE(@emptyBillPayFromBankAccount + ', ', '') + B.strBillId
		FROM tblAPPayment P
		INNER JOIN tblAPPaymentDetail PD ON PD.intPaymentId = P.intPaymentId
		INNER JOIN tblAPBill B ON B.intBillId = PD.intBillId
		WHERE P.intPaymentId IN (SELECT intId FROM @ids) AND P.intPaymentMethodId = 2 AND PD.dblPayment != 0 AND B.intPayFromBankAccountId IS NULL

		IF @emptyBillPayFromBankAccount <> ''
		BEGIN
			SET	@emptyBillPayFromBankAccount = RIGHT(@emptyBillPayFromBankAccount, LEN(@emptyBillPayFromBankAccount) - 2);
			RAISERROR('%s have empty pay from bank account.', 11, 1, @emptyBillPayFromBankAccount);
		END

		--VALIDATE EMPTY PAY TO BANK ACCOUNT
		SELECT @emptyBillPayToBankAccount = COALESCE(@emptyBillPayToBankAccount + ', ', '') + B.strBillId
		FROM tblAPPayment P
		INNER JOIN tblAPPaymentDetail PD ON PD.intPaymentId = P.intPaymentId
		INNER JOIN tblAPBill B ON B.intBillId = PD.intBillId
		WHERE P.intPaymentId IN (SELECT intId FROM @ids) AND P.intPaymentMethodId = 2 AND PD.dblPayment != 0 AND B.intPayToBankAccountId IS NULL

		IF @emptyBillPayToBankAccount <> ''
		BEGIN
			SET @emptyBillPayToBankAccount = RIGHT(@emptyBillPayToBankAccount, LEN(@emptyBillPayToBankAccount) - 2);
			RAISERROR('%s have empty pay to bank account.', 11, 1, @emptyBillPayToBankAccount);
		END

		-- --VALIDATE MULTIPLE PAY BANK ACCOUNT COMBINATIONS
		-- SELECT @billPayBankAccountCount = COUNT(*) FROM @ids
		-- IF @billPayBankAccountCount = 1
		-- BEGIN
		-- 	SELECT @billPayBankAccountCount = COUNT(intGroupCount)
		-- 	FROM (
		-- 		SELECT COUNT(*) intGroupCount
		-- 		FROM tblAPPayment P
		-- 		INNER JOIN tblAPPaymentDetail PD ON PD.intPaymentId = P.intPaymentId
		-- 		INNER JOIN tblAPBill B ON B.intBillId = PD.intBillId
		-- 		WHERE P.intPaymentId IN (SELECT intId FROM @ids) AND PD.dblPayment != 0 AND P.intPaymentMethodId = 2
		-- 		GROUP BY B.intPayFromBankAccountId, B.intPayToBankAccountId
		-- 	) A

		-- 	IF @billPayBankAccountCount > 1
		-- 	BEGIN
		-- 		RAISERROR('Multiple sets of pay from and to bank account is not allowed.', 11, 1);
		-- 	END
		-- END

		--UPDATE PAYMENT SCHEDULE
		UPDATE PS
		SET PS.ysnInPayment = CASE WHEN ISNULL(paySched.dblPayment, 0) <> 0 THEN 1 ELSE 0 END
		FROM tblAPPayment P
		INNER JOIN tblAPPaymentDetail PD ON PD.intPaymentId = P.intPaymentId
		INNER JOIN tblAPBill B ON B.intBillId = PD.intBillId
		INNER JOIN tblAPVoucherPaymentSchedule PS ON PS.intBillId = B.intBillId
		OUTER APPLY (
			SELECT SUM(PD2.dblPayment) dblPayment
			FROM tblAPPaymentDetail PD2
			INNER JOIN tblAPPayment P2 ON P2.intPaymentId = PD2.intPaymentId
			WHERE PD2.intPayScheduleId = PS.intId AND P2.ysnNewFlag = 1
		) paySched
		WHERE PD.intPaymentId IN (SELECT intId FROM @ids)

		UPDATE tblAPBill 
		SET
			@dblPaymentTemp =	(
									ISNULL(paySchedDetails.dblPayment, ISNULL(ABS(payDetails.dblPayment), 0)) +
									ISNULL(paySchedDetails.dblDiscount, ISNULL(payDetails.dblDiscount, 0)) -
									ISNULL(payDetails.dblInterest, 0)
								),
			@ysnInPayment = CASE WHEN (B.dblTotal - ISNULL(appliedPrepays.dblPayment, 0)) = @dblPaymentTemp
							THEN 1
							ELSE
								CASE WHEN @dblPaymentTemp < 0 OR @dblPaymentTemp > (B.dblTotal - ISNULL(appliedPrepays.dblPayment, 0))
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
				intBillId,
				SUM(dblPayment) dblPayment,
				SUM(dblDiscount) dblDiscount,
				SUM(dblInterest) dblInterest
			FROM
			(
				SELECT
					PD.dblPayment,
					CASE WHEN PD.dblPayment + PD.dblDiscount - PD.dblInterest = PD.dblAmountDue THEN PD.dblDiscount 
					--WHEN B.ysnDiscountOverride = 1 THEN PD.dblDiscount 
					ELSE 0 END
					AS dblDiscount,
					CASE WHEN PD.dblPayment + PD.dblDiscount - PD.dblInterest = PD.dblAmountDue THEN PD.dblInterest 
					ELSE 0 END
					AS dblInterest,
					PD.intBillId
				FROM tblAPPaymentDetail PD
				INNER JOIN tblAPPayment P2 ON P2.intPaymentId = PD.intPaymentId
				WHERE 
					PD.intPayScheduleId IS NULL AND PD.intBillId = B.intBillId AND P2.ysnNewFlag = 1
			) tmpPayDetails
			GROUP BY intBillId
		) payDetails 
		OUTER APPLY (
			SELECT 
				PD.intBillId,
				SUM(PD.dblPayment) dblPayment,
				SUM(PD.dblDiscount) dblDiscount
			FROM tblAPPaymentDetail PD
			INNER JOIN tblAPPayment P2 ON P2.intPaymentId = PD.intPaymentId
			WHERE 
				PD.intPayScheduleId > 0 AND PD.intBillId = B.intBillId AND P2.ysnNewFlag = 1
			GROUP BY PD.intBillId
		) paySchedDetails
		OUTER APPLY (
			SELECT SUM(APD.dblAmountApplied) AS dblPayment
			FROM tblAPAppliedPrepaidAndDebit APD
			WHERE APD.intBillId = B.intBillId AND APD.ysnApplied = 1
		) appliedPrepays
		WHERE P.intPaymentId IN (SELECT intId FROM @ids) AND (B.ysnPrepayHasPayment = 0 OR B.intTransactionType NOT IN (2, 13))
	END
	ELSE IF @post = 0
	BEGIN
		--UPDATE PAYMENT SCHEDULE
		UPDATE PS
		SET PS.ysnInPayment = CASE WHEN ISNULL(paySched.dblPayment, 0) <> 0 THEN 1 ELSE 0 END
		FROM tblAPPayment P
		INNER JOIN tblAPPaymentDetail PD ON PD.intPaymentId = P.intPaymentId
		INNER JOIN tblAPBill B ON B.intBillId = PD.intBillId
		INNER JOIN tblAPVoucherPaymentSchedule PS ON PS.intBillId = B.intBillId
		OUTER APPLY (
			SELECT SUM(PD2.dblPayment) dblPayment
			FROM tblAPPaymentDetail PD2
			INNER JOIN tblAPPayment P2 ON P2.intPaymentId = PD2.intPaymentId
			WHERE PD2.intPayScheduleId = PS.intId AND P2.ysnNewFlag = 1 AND P2.intPaymentId <> PD.intPaymentId
		) paySched
		WHERE PD.intPaymentId IN (SELECT intId FROM @ids)

		UPDATE tblAPBill 
		SET
			@dblPaymentTemp =	(
									ISNULL(paySchedDetails.dblPayment, ISNULL(ABS(payDetails.dblPayment), 0)) +
									ISNULL(paySchedDetails.dblDiscount, ISNULL(payDetails.dblDiscount, 0)) -
									ISNULL(payDetails.dblInterest, 0)
								),
			@ysnInPayment = CASE WHEN (B.dblTotal - ISNULL(appliedPrepays.dblPayment, 0)) = @dblPaymentTemp
							THEN 1
							ELSE
								CASE WHEN @dblPaymentTemp < 0 OR @dblPaymentTemp > (B.dblTotal - ISNULL(appliedPrepays.dblPayment, 0))
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
				intBillId,
				SUM(dblPayment) dblPayment,
				SUM(dblDiscount) dblDiscount,
				SUM(dblInterest) dblInterest
			FROM
			(
				SELECT
					PD.dblPayment,
					CASE WHEN PD.dblPayment + PD.dblDiscount - PD.dblInterest = PD.dblAmountDue THEN PD.dblDiscount 
					--WHEN B.ysnDiscountOverride = 1 THEN PD.dblDiscount 
					ELSE 0 END
					AS dblDiscount,
					CASE WHEN PD.dblPayment + PD.dblDiscount - PD.dblInterest = PD.dblAmountDue THEN PD.dblInterest 
					ELSE 0 END
					AS dblInterest,
					PD.intBillId
				FROM tblAPPaymentDetail PD
				INNER JOIN tblAPPayment P2 ON P2.intPaymentId = PD.intPaymentId
				WHERE 
					PD.intPaymentId <> P.intPaymentId AND PD.intPayScheduleId IS NULL AND PD.intBillId = B.intBillId AND P2.ysnNewFlag = 1
			) tmpPayDetails
			GROUP BY intBillId
		) payDetails 
		OUTER APPLY (
			SELECT 
				PD.intBillId,
				SUM(PD.dblPayment) dblPayment,
				SUM(PD.dblDiscount) dblDiscount
			FROM tblAPPaymentDetail PD
			INNER JOIN tblAPPayment P2 ON P2.intPaymentId = PD.intPaymentId
			WHERE 
				PD.intPaymentId <> P.intPaymentId AND PD.intPayScheduleId > 0 AND PD.intBillId = B.intBillId AND P2.ysnNewFlag = 1
			GROUP BY PD.intBillId
		) paySchedDetails
		OUTER APPLY (
			SELECT SUM(APD.dblAmountApplied) AS dblPayment
			FROM tblAPAppliedPrepaidAndDebit APD
			WHERE APD.intBillId = B.intBillId AND APD.ysnApplied = 1
		) appliedPrepays
		WHERE P.intPaymentId IN (SELECT intId FROM @ids) AND (B.ysnPrepayHasPayment = 0 OR B.intTransactionType NOT IN (2, 13))
	END

	--SELECT NULLED BILLS
	SELECT TOP 1 
		@nullCheck = B.ysnInPayment,
		@tempCheck = B.dblPaymentTemp,
		@totalCheck = (B.dblTotal - ISNULL(appliedPrepays.dblPayment, 0)),
		@billCheck = B.strBillId
	FROM tblAPPayment P
	INNER JOIN tblAPPaymentDetail PD ON PD.intPaymentId = P.intPaymentId
	INNER JOIN tblAPBill B ON B.intBillId = PD.intBillId
	OUTER APPLY (
					SELECT SUM(APD.dblAmountApplied) AS dblPayment
					FROM tblAPAppliedPrepaidAndDebit APD
					WHERE APD.intBillId = B.intBillId AND APD.ysnApplied = 1
	) appliedPrepays
	WHERE P.intPaymentId IN (SELECT intId FROM @ids) AND B.ysnInPayment IS NULL AND B.dblPaymentTemp <> 0

	--VALIDATIONS
	IF @nullCheck IS NULL AND @tempCheck > @totalCheck
	BEGIN
		RAISERROR('%s will be overpaid.', 11, 1, @billCheck);
	END

	IF @nullCheck IS NULL AND @tempCheck < 0
	BEGIN
		RAISERROR('%s will be underpaid.', 11, 1, @billCheck);
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
