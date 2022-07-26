﻿CREATE PROCEDURE [dbo].[uspAPUpdatePayableTaxForTexasLoadingFee]
	@payableIds AS Id READONLY
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

BEGIN TRY

DECLARE @transCount INT = @@TRANCOUNT;

IF @transCount = 0 BEGIN TRANSACTION

	UPDATE A
	SET
		A.dblTax = details.dblTotalTax
	FROM tblAPVoucherPayable A
	OUTER APPLY (
		SELECT 
			SUM(dblAdjustedTax) AS dblTotalTax
		FROM tblAPVoucherPayableTaxStaging B
		WHERE
			A.intVoucherPayableId = B.intVoucherPayableId
		AND B.strCalculationMethod != 'Using Texas Fee Matrix'
	) details
	WHERE A.intVoucherPayableId IN (SELECT intId FROM @payableIds)

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