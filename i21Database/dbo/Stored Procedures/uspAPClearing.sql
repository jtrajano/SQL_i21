CREATE PROCEDURE [dbo].[uspAPClearing]
	@APClearing AS APClearing READONLY,
	@post AS BIT = 1
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET ANSI_WARNINGS OFF

BEGIN TRY
	INSERT INTO dbo.tblAPClearing (
		intTransactionId,
		strTransactionId,
		intTransactionType,
		strReferenceNumber,
		dtmDate,
		intEntityVendorId,
		intLocationId,
		intTransactionDetailId,
		intAccountId,
		intItemId,
		intItemUOMId,
		dblQuantity,
		dblAmount,
		intBillId,
		strBillId,
		intBillDetailId,
		strCode,
		ysnPostAction,
		dtmDateEntered
	)
	SELECT
		intTransactionId,
		strTransactionId,
		intTransactionType,
		strReferenceNumber,
		dbo.fnRemoveTimeOnDate(dtmDate),
		intEntityVendorId,
		intLocationId,
		intTransactionDetailId,
		intAccountId,
		intItemId,
		intItemUOMId,
		CASE WHEN @post = 1 THEN dblQuantity ELSE dblQuantity * -1 END,
		CASE WHEN @post = 1 THEN dblAmount ELSE dblAmount * -1 END,
		intBillId,
		strBillId,
		intBillDetailId,
		strCode,
		@post,
		GETDATE()
	FROM @APClearing
END TRY

BEGIN CATCH
	DECLARE @ErrorMessage NVARCHAR(4000),
	@ErrorSeverity INT,
	@ErrorState INT,
	@ErrorNumber INT
	-- Grab error information from SQL functions
	SET @ErrorMessage  = ERROR_MESSAGE()
	SET @ErrorSeverity = ERROR_SEVERITY()
	SET @ErrorState    = ERROR_STATE()
	SET @ErrorNumber   = ERROR_NUMBER()
	RAISERROR (@ErrorMessage , @ErrorSeverity, @ErrorState, @ErrorNumber)
END CATCH