GO
	PRINT N'BEGIN INSERT DEFAULT CURRENCIES'
GO
	SET IDENTITY_INSERT [dbo].[tblSMCurrency] ON
GO
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMCurrency where intCurrencyID = 1 AND strCurrency = N'AUD')
	BEGIN
		INSERT [dbo].[tblSMCurrency] ([intCurrencyID], [strCurrency], [strDescription], [strCheckDescription], [dblDailyRate], [dblMinRate], [dblMaxRate], [intSort], [intConcurrencyID]) VALUES (1, N'AUD', N'Australian Dollar', NULL, CAST(1.075120 AS Numeric(18, 6)), CAST(1.075120 AS Numeric(18, 6)), CAST(1.075120 AS Numeric(18, 6)), NULL, 12)
	END
GO
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMCurrency where intCurrencyID = 2 AND strCurrency = N'CAD')
	BEGIN
		INSERT [dbo].[tblSMCurrency] ([intCurrencyID], [strCurrency], [strDescription], [strCheckDescription], [dblDailyRate], [dblMinRate], [dblMaxRate], [intSort], [intConcurrencyID]) VALUES (2, N'CAD', N'Canadian Dollar', NULL, CAST(1.030000 AS Numeric(18, 6)), CAST(1.075120 AS Numeric(18, 6)), CAST(1.075120 AS Numeric(18, 6)), NULL, 14)
	END
GO
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMCurrency where intCurrencyID = 3 AND strCurrency = N'USD')
	BEGIN
		INSERT [dbo].[tblSMCurrency] ([intCurrencyID], [strCurrency], [strDescription], [strCheckDescription], [dblDailyRate], [dblMinRate], [dblMaxRate], [intSort], [intConcurrencyID]) VALUES (3, N'USD', N'US Dollar', NULL, CAST(1.000000 AS Numeric(18, 6)), CAST(1.075120 AS Numeric(18, 6)), CAST(1.075120 AS Numeric(18, 6)), NULL, 6)
	END
GO
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMCurrency where intCurrencyID = 4 AND strCurrency = N'JPY')
	BEGIN
		INSERT [dbo].[tblSMCurrency] ([intCurrencyID], [strCurrency], [strDescription], [strCheckDescription], [dblDailyRate], [dblMinRate], [dblMaxRate], [intSort], [intConcurrencyID]) VALUES (4, N'JPY', N'Japan Yen', NULL, CAST(10.000000 AS Numeric(18, 6)), CAST(1.075120 AS Numeric(18, 6)), CAST(1.075120 AS Numeric(18, 6)), NULL, 10)
	END
GO
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMCurrency where intCurrencyID = 5 AND strCurrency = N'PHP')
	BEGIN
		INSERT [dbo].[tblSMCurrency] ([intCurrencyID], [strCurrency], [strDescription], [strCheckDescription], [dblDailyRate], [dblMinRate], [dblMaxRate], [intSort], [intConcurrencyID]) VALUES (5, N'PHP', N'Philippines Peso', NULL, CAST(46.450000 AS Numeric(18, 6)), CAST(1.075120 AS Numeric(18, 6)), CAST(1.075120 AS Numeric(18, 6)), NULL, 14)
	END
GO
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMCurrency where intCurrencyID = 6 AND strCurrency = N'GBP')
	BEGIN
		INSERT [dbo].[tblSMCurrency] ([intCurrencyID], [strCurrency], [strDescription], [strCheckDescription], [dblDailyRate], [dblMinRate], [dblMaxRate], [intSort], [intConcurrencyID]) VALUES (6, N'GBP', N'United Kingdom Pounds', NULL, CAST(100.000000 AS Numeric(18, 6)), CAST(1.075120 AS Numeric(18, 6)), CAST(1.075120 AS Numeric(18, 6)), NULL, 6)
	END
GO
	SET IDENTITY_INSERT [dbo].[tblSMCurrency] OFF
GO
	PRINT N'END INSERT DEFAULT CURRENCIES'
GO