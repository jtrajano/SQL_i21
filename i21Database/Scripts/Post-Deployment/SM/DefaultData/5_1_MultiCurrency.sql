IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMultiCurrency)
BEGIN
	INSERT INTO [tblSMMultiCurrency] ([intConcurrencyId]) VALUES (1)
END