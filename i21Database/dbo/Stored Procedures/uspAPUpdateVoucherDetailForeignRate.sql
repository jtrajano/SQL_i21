CREATE PROCEDURE [dbo].[uspAPUpdateVoucherDetailForeignRate]
	@voucherId INT
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

BEGIN TRY

DECLARE @foreignCurrency BIT = 0;
DECLARE @rate DECIMAL(18,6) = 1;
DECLARE @rateType INT;
DECLARE @voucherCurrency INT;
DECLARE @functionalCurrency INT;
DECLARE @transCount INT = @@TRANCOUNT;
IF @transCount = 0 BEGIN TRANSACTION

SELECT TOP 1 
	@voucherCurrency = voucher.intCurrencyId,
	@functionalCurrency = pref.intDefaultCurrencyId,
	@foreignCurrency = CASE WHEN intDefaultCurrencyId != voucher.intCurrencyId THEN 1 ELSE 0 END
FROM tblAPBill voucher
CROSS APPLY tblSMCompanyPreference pref
WHERE voucher.intBillId = @voucherId

IF @foreignCurrency = 1
BEGIN
	SELECT TOP 1
		@rateType = intAccountsPayableRateTypeId
	FROM tblSMMultiCurrency
		
	SELECT TOP 1
		@rate = exchangeRateDetail.dblRate
	FROM tblSMCurrencyExchangeRate exchangeRate
	INNER JOIN tblSMCurrencyExchangeRateDetail exchangeRateDetail ON exchangeRate.intCurrencyExchangeRateId = exchangeRateDetail.intCurrencyExchangeRateId
	WHERE exchangeRateDetail.intRateTypeId = @rateType
	AND exchangeRate.intFromCurrencyId = @voucherCurrency AND exchangeRate.intToCurrencyId = @functionalCurrency
	AND exchangeRateDetail.dtmValidFromDate <= GETDATE()
	ORDER BY exchangeRateDetail.dtmValidFromDate DESC

	IF @rateType IS NULL 
	BEGIN
		RAISERROR('No exchange rate type setup found. Please set on Multi Currency screen.', 16, 1);
		RETURN;
	END
	
	IF @rate IS NULL OR @rate < 0
	BEGIN
		RAISERROR('No exchange rate setup found. Please set on Currency screen.', 16, 1);
		RETURN;
	END

	UPDATE A
		SET A.dblRate = @rate, A.intCurrencyExchangeRateTypeId = @rateType --CASE WHEN ctd.intContractDetailId > 0 THEN ctd.dblRate ELSE @rate END, A.intCurrencyExchangeRateTypeId = @rateType 
	FROM tblAPBillDetail A
	-- LEFT JOIN vyuCTContractDetailView ctd ON A.intContractDetailId = ctd.intContractDetailId
	WHERE A.intBillId = @voucherId
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