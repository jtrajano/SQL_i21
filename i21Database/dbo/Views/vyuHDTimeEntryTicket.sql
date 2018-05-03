CREATE VIEW [dbo].[vyuHDTimeEntryTicket]
	AS
		select
			a.intTicketId
			,a.strTicketNumber
			,a.strSubject
			,a.intCurrencyId
			,a.intCurrencyExchangeRateTypeId
			,a.dblCurrencyRate
			,a.dtmExchangeRateDate
			,b.strCurrency
			,c.strCurrencyExchangeRateType
			,a.intCustomerId
		from
			tblHDTicket a
			left join tblSMCurrency b on b.intCurrencyID = a.intCurrencyId
			left join tblSMCurrencyExchangeRateType c on c.intCurrencyExchangeRateTypeId = a.intCurrencyExchangeRateTypeId
		where
			a.strType <> 'CRM'
