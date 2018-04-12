﻿CREATE VIEW [dbo].[vyuHDTicketHoursWorked]
	AS
		select
			a.intTicketHoursWorkedId
			,a.intTicketId
			,a.intAgentId
			,a.intAgentEntityId
			,a.intHours
			,a.dtmDate
			,a.dblRate
			,a.strDescription
			,a.strJIRALink
			,a.intInvoiceId
			,a.ysnBillable
			,a.ysnBilled
			,a.dtmBilled
			,a.intCreatedUserId
			,a.intCreatedUserEntityId
			,a.dtmCreated
			,a.intJobCodeId
			,a.intConcurrencyId
			,a.intCurrencyId
			,a.intCurrencyExchangeRateTypeId
			,a.dblCurrencyRate
			,strAgent = b.strName
			,strInvoiceNumber = c.strInvoiceNumber
			,strCreatedUserName = d.strName
			,strJobCode = e.strJobCode
			,strCurrency = f.strCurrency
			,strCurrencyExchangeRateType = g.strCurrencyExchangeRateType
		from
			tblHDTicketHoursWorked a
			left join tblEMEntity b on b.intEntityId = a.intAgentEntityId
			left join tblARInvoice c on c.intInvoiceId = a.intInvoiceId
			left join tblEMEntity d on d.intEntityId = a.intCreatedUserEntityId
			left join tblHDJobCode e on e.intJobCodeId = a.intJobCodeId
			left join tblSMCurrency f on f.intCurrencyID = a.intCurrencyId
			left join tblSMCurrencyExchangeRateType g on g.intCurrencyExchangeRateTypeId = a.intCurrencyExchangeRateTypeId
