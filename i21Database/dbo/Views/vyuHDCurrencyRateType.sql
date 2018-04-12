CREATE VIEW [dbo].[vyuHDCurrencyRateType]
	AS select * from tblSMCurrencyExchangeRateType
		/*
		select
			a.intFromCurrencyId
			,a.intToCurrencyId
			,c.intCurrencyExchangeRateTypeId
			,c.strCurrencyExchangeRateType
			,c.strDescription
		from
			tblSMCurrencyExchangeRate a
			,tblSMCurrencyExchangeRateDetail b
			,tblSMCurrencyExchangeRateType c
		where
			b.intCurrencyExchangeRateId = a.intCurrencyExchangeRateId
			and c.intCurrencyExchangeRateTypeId = b.intRateTypeId
		*/
