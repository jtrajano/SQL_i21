CREATE PROCEDURE [dbo].[uspAPUpdateTaxForTexasLoadingFee]
	@billIds AS Id READONLY
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

BEGIN TRY

DECLARE @transCount INT = @@TRANCOUNT;

IF @transCount = 0 BEGIN TRANSACTION

	IF (SELECT TOP 1 ysnPosted FROM tblAPBill A
				WHERE intBillId IN (SELECT intId FROM @billIds)) = 1
	BEGIN
		RAISERROR('Voucher was already posted.', 16, 1);
	END

	UPDATE A
	SET
		A.dblTax = ISNULL(details.dblTotalTax,0)
	FROM tblAPBillDetail A
	OUTER APPLY (
		SELECT 
			SUM(dblAdjustedTax) AS dblTotalTax
		FROM tblAPBillDetailTax B
		WHERE
			A.intBillDetailId = B.intBillDetailId
		AND B.strCalculationMethod != 'Using Texas Fee Matrix'
	) details
	WHERE A.intBillId IN (SELECT intId FROM @billIds)

	UPDATE A
	SET
		A.dblTax = ISNULL(details.dblTotalTax,0)
	FROM tblAPBill A
	INNER JOIN tblAPBillDetail A2 ON A.intBillId = A2.intBillId
	OUTER APPLY (
		SELECT SUM(dblDetailTax) AS dblTotalTax
		FROM (
			SELECT 
				SUM(dblAdjustedTax) AS dblDetailTax
			FROM tblAPBillDetailTax B
			WHERE
				A2.intBillDetailId = B.intBillDetailId
			AND B.strCalculationMethod != 'Using Texas Fee Matrix'
			UNION ALL
			SELECT 
				TOP 1 dblAdjustedTax
			FROM tblAPBillDetailTax B
			WHERE
				A2.intBillDetailId = B.intBillDetailId
			AND B.strCalculationMethod = 'Using Texas Fee Matrix'
		) tmpDetails
	) details
	WHERE A.intBillId IN (SELECT intId FROM @billIds)

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