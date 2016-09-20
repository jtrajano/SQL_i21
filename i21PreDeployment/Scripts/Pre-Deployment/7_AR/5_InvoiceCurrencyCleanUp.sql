IF(EXISTS(SELECT NULL FROM sys.tables WHERE name = N'tblARInvoice') AND EXISTS(SELECT NULL FROM sys.columns WHERE [name] = N'intCurrencyId' AND [object_id] = OBJECT_ID(N'tblARInvoice'))
			AND EXISTS(SELECT NULL FROM sys.tables WHERE name = N'tblSMCurrency') AND EXISTS(SELECT NULL FROM sys.columns WHERE [name] = N'intCurrencyID' AND [object_id] = OBJECT_ID(N'tblSMCurrency')))
BEGIN
	UPDATE
		tblARInvoice
	SET
		intCurrencyId = NULL
	WHERE
		intCurrencyId NOT IN (SELECT intCurrencyID FROM tblSMCurrency)
END