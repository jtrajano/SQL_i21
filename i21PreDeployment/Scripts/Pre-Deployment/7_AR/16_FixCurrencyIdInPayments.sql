PRINT '********************** BEGIN - FIX INVALID CURRENCY **********************'
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE [name] = N'intCurrencyId' AND [object_id] = OBJECT_ID(N'tblARPayment'))
  AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE [name] = N'intCurrencyID' AND [object_id] = OBJECT_ID(N'tblSMCurrency'))
  
BEGIN
	IF OBJECT_ID('tempdb..#PAYMENTS') IS NOT NULL DROP TABLE #PAYMENTS	
	
	IF EXISTS (SELECT TOP 1 1 FROM sys.triggers WHERE [name] = 'trg_tblARPaymentUpdate')
		ALTER TABLE tblARPayment DISABLE TRIGGER trg_tblARPaymentUpdate

	DECLARE @DefaultCurrency	INT
			,@USDCurrency		INT

	SET @USDCurrency = ISNULL((SELECT TOP 1 intCurrencyID FROM tblSMCurrency WHERE strCurrency = 'USD'),0)
	SET @DefaultCurrency = ISNULL((SELECT TOP 1 intDefaultCurrencyId FROM tblSMCompanyPreference WHERE intDefaultCurrencyId IS NOT NULL AND intDefaultCurrencyId <> 0),@USDCurrency)
	
	IF @DefaultCurrency IS NOT NULL OR @DefaultCurrency <> 0
		BEGIN
			SELECT intPaymentId
				,intCurrencyId
			INTO #PAYMENTS
			FROM tblARPayment
			WHERE intCurrencyId = 0
			   OR intCurrencyId IS NULL

			UPDATE P
			SET intCurrencyId	= @DefaultCurrency
			FROM tblARPayment P
			INNER JOIN #PAYMENTS PP ON P.intPaymentId = PP.intPaymentId

		END

	IF EXISTS (SELECT TOP 1 1 FROM sys.triggers WHERE [name] = 'trg_tblARPaymentUpdate')
		ALTER TABLE tblARPayment ENABLE TRIGGER trg_tblARPaymentUpdate

	IF OBJECT_ID('tempdb..#PAYMENTS') IS NOT NULL DROP TABLE #PAYMENTS
END

PRINT '********************** END - FIX INVALID CURRENCY **********************'
GO