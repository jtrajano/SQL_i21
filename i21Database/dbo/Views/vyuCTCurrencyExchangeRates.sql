CREATE VIEW [dbo].[vyuCTCurrencyExchangeRates]
	AS
	select
		intCurrencyExchangeRateDetailId = 0
		,intCurrencyExchangeRateId = 0
		,intFromCurrencyId = cp.intDefaultCurrencyId
		,strFromCurrency = ct.strCurrency
		,intFromMainCurrency = ct.intMainCurrencyId
		,intToCurrencyId = cp.intDefaultCurrencyId
		,strToCurrency = ct.strCurrency
		,intToMainCurrency = ct.intMainCurrencyId
		,dblRate = 1
		,intRateTypeId = 1
		,dtmValidFromDate = getdate()
	from
		tblSMCompanyPreference cp
		join tblSMCurrency ct on ct.intCurrencyID = cp.intDefaultCurrencyId
	where isnull(cp.intDefaultCurrencyId,0) > 0
	union all
	select
		*
	from
	(
		select top 1 with ties
			erd.intCurrencyExchangeRateDetailId
			,erd.intCurrencyExchangeRateId
			,er.intFromCurrencyId
			,strFromCurrency = cf.strCurrency
			,intFromMainCurrency = cf.intMainCurrencyId
			,er.intToCurrencyId
			,strToCurrency = ct.strCurrency
			,intToMainCurrency = ct.intMainCurrencyId
			,erd.dblRate
			,erd.intRateTypeId
			,erd.dtmValidFromDate
		from
			tblSMCompanyPreference cp
			join tblSMCurrencyExchangeRate er on er.intToCurrencyId = cp.intDefaultCurrencyId
			join tblSMCurrencyExchangeRateDetail erd on erd.intCurrencyExchangeRateId = er.intCurrencyExchangeRateId
			join tblSMCurrency cf on cf.intCurrencyID = er.intFromCurrencyId
			join tblSMCurrency ct on ct.intCurrencyID = er.intToCurrencyId
		where isnull(cp.intDefaultCurrencyId,0) > 0
		order by
			row_number() over (
				partition by erd.intCurrencyExchangeRateId order by erd.dtmValidFromDate desc
			)
	) tbl
