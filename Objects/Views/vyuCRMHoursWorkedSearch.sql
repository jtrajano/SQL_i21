CREATE VIEW [dbo].[vyuCRMHoursWorkedSearch]
	AS
		select
			a.*
			,strAgentName = b.strName
			,strCreatedBy = c.strName
			,d.strItemNo
			,e.strInvoiceNumber
			,strCurrency = f.strCurrency
			,strCurrencyExchangeRate = ltrim(rtrim(i.strCurrency)) + ' To ' + ltrim(rtrim(j.strCurrency))
			,strCurrencyExchangeRateType = h.strCurrencyExchangeRateType
		from
			tblCRMHoursWorked a
			left join tblEMEntity b on b.intEntityId = a.intEntityId
			left join tblEMEntity c on c.intEntityId = a.intCreatedByEntityId
			left join tblICItem d on d.intItemId = a.intItemId
			left join tblARInvoice e on e.intInvoiceId = a.intInvoiceId
			left join tblSMCurrency f on f.intCurrencyID = a.intCurrencyId
			left join tblSMCurrencyExchangeRate g on g.intCurrencyExchangeRateId = a.intCurrencyExchangeRateId
			left join tblSMCurrency i on i.intCurrencyID = g.intFromCurrencyId
			left join tblSMCurrency j on j.intCurrencyID = g.intToCurrencyId
			left join tblSMCurrencyExchangeRateType h on h.intCurrencyExchangeRateTypeId = a.intCurrencyExchangeRateTypeId
