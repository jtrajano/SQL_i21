CREATE PROCEDURE [dbo].[uspPATProcessRefundsToVoucher]
	 @intUserId						INT
	,@intRefundId					INT
	,@intPaymentItemId				INT
	,@strErrorMessage				NVARCHAR(MAX) = NULL OUTPUT
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

BEGIN TRY
	DECLARE @intCustomerId INT
	DECLARE @dblCheckAmount DECIMAL

	DECLARE the_cursor CURSOR FAST_FORWARD
	FOR SELECT intCustomerId, dblCheckAmount
		FROM fnPATGetCustomerRequiredDetailsForVoucher(@intRefundId)
	OPEN the_cursor
	FETCH NEXT FROM the_cursor INTO @intCustomerId,@dblCheckAmount

	WHILE @@FETCH_STATUS = 0
	BEGIN
		EXEC uspPATRefundVoucherToAPBill @intRefundId,@intCustomerId,@dblCheckAmount,@intUserId,@intPaymentItemId

		FETCH NEXT FROM the_cursor INTO @intCustomerId,@dblCheckAmount
	END

	CLOSE the_cursor
	DEALLOCATE the_cursor
END TRY
BEGIN CATCH
	DECLARE @intErrorSeverity INT,
			@intErrorNumber   INT,
			@intErrorState INT;
		
	SET @intErrorSeverity = ERROR_SEVERITY()
	SET @intErrorNumber   = ERROR_NUMBER()
	SET @strErrorMessage  = ERROR_MESSAGE()
	SET @intErrorState    = ERROR_STATE()
	RAISERROR (@strErrorMessage , @intErrorSeverity, @intErrorState, @intErrorNumber)
END CATCH

GO
