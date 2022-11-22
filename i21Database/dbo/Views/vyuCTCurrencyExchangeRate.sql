CREATE VIEW [dbo].[vyuCTCurrencyExchangeRate]
	as select
		erd.intCurrencyExchangeRateDetailId
		,er.intFromCurrencyId
		,er.intToCurrencyId
		,erd.dblRate
		,erd.dtmValidFromDate
	from
		tblSMCurrencyExchangeRate  er
		join tblSMCurrencyExchangeRateDetail erd on erd.intCurrencyExchangeRateId = er.intCurrencyExchangeRateId
	where
		erd.dtmValidFromDate <= getdate()
