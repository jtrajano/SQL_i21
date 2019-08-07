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

	IF (@Post = 1)
	BEGIN
		SELECT TOP 1 @strTransactionId = strTransactionId FROM tblMBMeterReading
		WHERE intMeterReadingId < @intMeterReadingId
		AND intMeterAccountId = (SELECT intMeterAccountId FROM tblMBMeterReading
		WHERE intMeterReadingId = @intMeterReadingId)
		AND ysnPosted = 0
		ORDER BY intMeterReadingId DESC

		IF(@strTransactionId IS NOT NULL)
		BEGIN
			RAISERROR('This transaction cannot be Posted, because it is not the latest Unposted Meter Billing Transaction. To post this transaction, you must first post all transaction for the same Meter Key with an earlier Date.', 16, 1)
			RETURN
		END


		IF EXISTS(SELECT TOP 1 RD.intMeterAccountDetailId FROM tblMBMeterReadingDetail RD
			INNER JOIN tblMBMeterReading MR ON RD.intMeterReadingId = MR.intMeterReadingId
			INNER JOIN tblMBMeterAccountDetail AD ON AD.intMeterAccountDetailId = RD.intMeterAccountDetailId
			WHERE RD.intMeterReadingId = @intMeterReadingId
			AND (RD.dblLastReading <> AD.dblLastMeterReading
			OR RD.dblLastDollars <> AD.dblLastTotalSalesDollar)
		)
		BEGIN
			RAISERROR('This transaction cannot be Posted. Last reading/dollars is not equal.', 16, 1)
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
		ORDER BY intMeterReadingId DESC

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