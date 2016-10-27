CREATE PROCEDURE [dbo].[uspPATProcessRefundsToVoucher]
	 @intUserId						INT
	,@intRefundId					INT
	,@intPaymentItemId				INT = NULL
	,@strErrorMessage				NVARCHAR(MAX) = NULL OUTPUT
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

BEGIN TRY
	DECLARE @intRefundCustomerId INT
	DECLARE @intCustomerId INT
	DECLARE @dblCheckAmount NUMERIC(18,6)
	DECLARE @dblServiceFee NUMERIC(18,6)

	DECLARE the_cursor CURSOR FAST_FORWARD
	FOR SELECT intRefundCustomerId,intCustomerId, dblCheckAmount, dblServiceFee
		FROM fnPATGetCustomerRequiredDetailsForVoucher(@intRefundId)
	OPEN the_cursor
	FETCH NEXT FROM the_cursor INTO @intRefundCustomerId,@intCustomerId,@dblCheckAmount,@dblServiceFee

	WHILE @@FETCH_STATUS = 0
	BEGIN
		EXEC uspPATRefundVoucherToAPBill @intRefundId,@intRefundCustomerId,@intCustomerId,@dblCheckAmount,@dblServiceFee,@intUserId,@intPaymentItemId

		FETCH NEXT FROM the_cursor INTO @intRefundCustomerId,@intCustomerId,@dblCheckAmount,@dblServiceFee
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