GO
	IF EXISTS (SELECT TOP 1 1 FROM tblSMCompanyPreference WHERE (intDefaultCurrencyId IS NULL OR intDefaultCurrencyId = 0))
	BEGIN
		DECLARE @currency NVARCHAR(50)
		DECLARE @currencyId INT

		SELECT TOP 1 @currency = coctl_base_currency COLLATE SQL_Latin1_General_CP1_CS_AS FROM coctlmst
		SELECT @currency
		IF(@currency IS NOT NULL OR @currency <> '')
		BEGIN
			SELECT @currencyId = intCurrencyID from tblSMCurrency where strCurrency = @currency
			SELECT @currencyId

			IF(@currencyId IS NOT NULL)
			BEGIN
				UPDATE tblSMCompanyPreference SET intDefaultCurrencyId = @currencyId
			END
		END
	END
GO