﻿CREATE VIEW [dbo].[vyuHDTimeEntryTicket]
	AS
		select
			a.intTicketId
			,a.strTicketNumber
			,a.intCurrencyId
			,a.intCurrencyExchangeRateTypeId
			,a.dblCurrencyRate
			,a.dtmExchangeRateDate
			,b.strCurrency
			,c.strCurrencyExchangeRateType
		from
			tblHDTicket a
			left join tblSMCurrency b on b.intCurrencyID = a.intCurrencyId
			left join tblSMCurrencyExchangeRateType c on c.intCurrencyExchangeRateTypeId = a.intCurrencyExchangeRateTypeId
