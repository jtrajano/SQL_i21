CREATE VIEW [dbo].[vyuHDCurrencyRate]
	AS
		select
			a.intCurrencyExchangeRateId
			,a.intFromCurrencyId
			,a.intToCurrencyId
			,strCurrencyExchangeRate = b.strCurrency + ' To ' + c.strCurrency
			,strFromCurrency = b.strCurrency
			,strToCurrency = c.strCurrency 
		from
			tblSMCurrencyExchangeRate a
			left join tblSMCurrency b on b.intCurrencyID = a.intFromCurrencyId
			left join tblSMCurrency c on c.intCurrencyID = a.intToCurrencyId
