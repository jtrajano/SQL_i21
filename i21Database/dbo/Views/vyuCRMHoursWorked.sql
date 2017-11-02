CREATE VIEW [dbo].[vyuCRMHoursWorked]
	AS
		select
			a.intHoursWorkedId
			,a.intTransactionId
			,a.intEntityId
			,strEntityName = b.strName
			,a.dblHours
			,a.dtmDate
			,a.intItemId
			,strItemNo = c.strItemNo
			,a.ysnBillable
			,a.dblRate
			,a.intInvoiceId
			,strInvoiceNo = d.strInvoiceNumber
			,a.strJiraKey
			,a.strDescription
			,a.intCreatedByEntityId
			,strCreatedByEntityName = e.strName
			,a.dtmCreatedDate
			,a.intCurrencyId
			,strCurrency = f.strCurrency
			,a.intCurrencyExchangeRateId
			,strCurrencyExchangeRate = ltrim(rtrim(i.strCurrency)) + ' To ' + ltrim(rtrim(j.strCurrency))
			,a.intCurrencyExchangeRateTypeId
			,strCurrencyExchangeRateType = h.strCurrencyExchangeRateType
			,a.intConcurrencyId
			,intLocationId = k.intCompanyLocationId
			,k.strLocationName
			,intItemUOMId = k.intItemUOMId
			,k.strUnitMeasure
			,intRecordId = null
			,strNameSpace = null
		from
			tblCRMHoursWorked a
			left join tblEMEntity b on b.intEntityId = a.intEntityId
			left join tblICItem c on c.intItemId = a.intItemId
			left join tblARInvoice d on d.intInvoiceId = a.intInvoiceId
			left join tblEMEntity e on e.intEntityId = a.intCreatedByEntityId
			left join tblSMCurrency f on f.intCurrencyID = a.intCurrencyId
			left join tblSMCurrencyExchangeRate g on g.intCurrencyExchangeRateId = a.intCurrencyExchangeRateId
			left join tblSMCurrency i on i.intCurrencyID = g.intFromCurrencyId
			left join tblSMCurrency j on j.intCurrencyID = g.intToCurrencyId
			left join tblSMCurrencyExchangeRateType h on h.intCurrencyExchangeRateTypeId = a.intCurrencyExchangeRateTypeId
			left join vyuHDItem k on k.intItemId = a.intItemId
