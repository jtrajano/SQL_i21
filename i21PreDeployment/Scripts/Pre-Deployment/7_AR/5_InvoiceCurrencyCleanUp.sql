IF(EXISTS(SELECT NULL FROM sys.tables WHERE name = N'tblARInvoice') AND EXISTS(SELECT NULL FROM sys.columns WHERE [name] = N'intCurrencyId' AND [object_id] = OBJECT_ID(N'tblARInvoice'))
			AND EXISTS(SELECT NULL FROM sys.tables WHERE name = N'tblSMCurrency') AND EXISTS(SELECT NULL FROM sys.columns WHERE [name] = N'intCurrencyID' AND [object_id] = OBJECT_ID(N'tblSMCurrency'))
			AND EXISTS(SELECT NULL FROM sys.tables WHERE name = N'tblSMCompanyPreference') AND EXISTS(SELECT NULL FROM sys.columns WHERE [name] = N'intDefaultCurrencyId' AND [object_id] = OBJECT_ID(N'tblSMCompanyPreference')))
BEGIN
	DECLARE @DefaultCurrencyId INT
	SET @DefaultCurrencyId = (SELECT intDefaultCurrencyId FROM tblSMCompanyPreference) 

	UPDATE
		tblARInvoice
	SET
		intCurrencyId = @DefaultCurrencyId
	WHERE
		NOT EXISTS(SELECT SMC.intCurrencyID FROM tblSMCurrency SMC WHERE SMC.intCurrencyID = tblARInvoice.intCurrencyId)
		AND EXISTS(SELECT intCurrencyID FROM tblSMCurrency WHERE intCurrencyID = @DefaultCurrencyId)

END