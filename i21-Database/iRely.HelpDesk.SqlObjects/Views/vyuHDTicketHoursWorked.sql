CREATE VIEW [dbo].[vyuHDTicketHoursWorked]
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
			,a.intItemId
			,a.intItemUOMId
			,strAgent = b.strName
			,strInvoiceNumber = c.strInvoiceNumber
			,strCreatedUserName = d.strName
			,strJobCode = e.strJobCode
			,strCurrency = f.strCurrency
			,strCurrencyExchangeRateType = g.strCurrencyExchangeRateType
			,strDate = convert(nvarchar(20), a.dtmDate, 101)
			,strItemNo = h.strItemNo
			,intTimeEntryId = 1
			,i.strTicketNumber
			,i.intCustomerId
		from
			tblHDTicketHoursWorked a
			left join tblEMEntity b on b.intEntityId = a.intAgentEntityId
			left join tblARInvoice c on c.intInvoiceId = a.intInvoiceId
			left join tblEMEntity d on d.intEntityId = a.intCreatedUserEntityId
			left join tblHDJobCode e on e.intJobCodeId = a.intJobCodeId
			left join tblSMCurrency f on f.intCurrencyID = a.intCurrencyId
			left join tblSMCurrencyExchangeRateType g on g.intCurrencyExchangeRateTypeId = a.intCurrencyExchangeRateTypeId
			left join tblICItem h on h.intItemId = a.intItemId
			left join tblHDTicket i on i.intTicketId = a.intTicketId
