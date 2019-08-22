CREATE PROCEDURE [dbo].[uspMBPostMeterReadingValidation]
	 @intMeterReadingId		INT
	,@Post				BIT	= NULL
	,@ynsValid			BIT = 1 OUTPUT
AS
	
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @ErrorSeverity INT
DECLARE @ErrorState INT
DECLARE @ErrorNumber INT
DECLARE @ErrorMessage NVARCHAR(MAX)

BEGIN TRY

	DECLARE @strTransactionId NVARCHAR(100) = NULL

	IF ((SELECT ISNULL(MA.intCompanyLocationId, 0) FROM tblMBMeterReading MR INNER JOIN tblMBMeterAccount MA ON MA.intMeterAccountId = MR.intMeterAccountId where intMeterReadingId = @intMeterReadingId) = 0)
    BEGIN
		RAISERROR('Company Location is required!', 16, 1)
		RETURN
    END

	-- Meter Reading Qty Sold should be >= 0
	IF EXISTS(SELECT TOP 1 1 FROM tblMBMeterReadingDetail WHERE intMeterReadingId = @intMeterReadingId AND dblCurrentReading < dblLastReading)
	BEGIN
		RAISERROR('"Quantity Sold" should be greater than or equal to 0.', 16, 1)
		RETURN
	END

	-- Posting and Unposting of Meter Reading should be by sequence
	IF (@Post = 1)
	BEGIN
		SELECT TOP 1 @strTransactionId = strTransactionId FROM tblMBMeterReading
		WHERE intMeterReadingId < @intMeterReadingId
		AND intMeterAccountId = (SELECT intMeterAccountId FROM tblMBMeterReading
		WHERE intMeterReadingId = @intMeterReadingId)
		AND ysnPosted = 0
		ORDER BY dtmTransaction DESC, intMeterReadingId DESC

		IF(@strTransactionId IS NOT NULL)
		BEGIN
			RAISERROR('This transaction cannot be Posted, because it is not the latest Unposted Meter Billing Transaction. To post this transaction, you must first post all transaction for the same Meter Key with an earlier Date.', 16, 1)
			RETURN
		END

		-- TOTAL SOLD QTY SHOULD BE > 0
		DECLARE @dblTotalSoldQty NUMERIC(18,6) = NULL

		SELECT @dblTotalSoldQty = SUM(dblCurrentReading) - SUM(dblLastReading) 
		FROM tblMBMeterReadingDetail 
		WHERE intMeterReadingId = @intMeterReadingId

		IF (@dblTotalSoldQty <= 0)
		BEGIN
			RAISERROR('"Total Quantity Sold" should be greater than 0.', 16, 1)
			RETURN
		END

	END
	ELSE IF (@Post = 0)
	BEGIN
		SELECT TOP 1 @strTransactionId = strTransactionId FROM tblMBMeterReading 
		WHERE intMeterReadingId > @intMeterReadingId
		AND intMeterAccountId = (SELECT intMeterAccountId FROM tblMBMeterReading
		WHERE intMeterReadingId = @intMeterReadingId)
		AND ysnPosted = 1
		ORDER BY dtmTransaction DESC, intMeterReadingId DESC

		IF(@strTransactionId IS NOT NULL)
		BEGIN
			RAISERROR('This transaction cannot be Unposted, because it is not the latest Posted Meter Billing Transaction.', 16, 1)
			RETURN
		END

	END

END TRY
BEGIN CATCH

	SET @ErrorMessage = ERROR_MESSAGE()
	SET @ErrorSeverity = ERROR_SEVERITY()
	SET @ErrorState = ERROR_STATE()
	SET @ErrorNumber   = ERROR_NUMBER()
		
	RAISERROR (@ErrorMessage , @ErrorSeverity, @ErrorState ,@ErrorNumber)
END CATCH