CREATE VIEW [dbo].[vyuHDTicketHoursWorked]
	AS
		select
			a.intTicketHoursWorkedId
			,a.intTicketId
			,a.intAgentId
			,a.intAgentEntityId
			,a.intHours
			,dblHours = a.intHours
			,a.dblEstimatedHours
			,a.dtmDate
			,a.dtmStartTime
			,a.dtmEndTime
			,a.dblRate
			,a.strDescription
			,a.strJIRALink
			,a.intInvoiceId
			,dtmInvoiceDate = c.dtmDate
			,a.intBillId
			,a.ysnBillable
			,a.ysnReimburseable
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
			,strVoucherNumber = l.strBillId
			,strCreatedUserName = d.strName
			,strJobCode = e.strJobCode
			,strCurrency = f.strCurrency
			,strCurrencyExchangeRateType = g.strCurrencyExchangeRateType
			,strDate = convert(nvarchar(20), a.dtmDate, 101) COLLATE Latin1_General_CI_AS
			,strInvoiceDate = convert(nvarchar(20), c.dtmDate, 101) COLLATE Latin1_General_CI_AS
			,strItemNo = h.strItemNo
			,intTimeEntryId = 1
			,i.strTicketNumber
			,i.intCustomerId
			,dblExtendedRate = (case when (isnull(a.intHours, 0.00) = 0.00 or isnull(a.dblRate,0.00) = 0.00) then 0.00 else a.intHours * a.dblRate end)
			,k.strProjectName
			,k.intProjectId
			,ysnVendor = (select case when count(*) < 1 then convert(bit,0) else convert(bit,1) end from tblEMEntityType m where m.intEntityId = a.intAgentEntityId and m.strType = 'Vendor')
			,strServiceType = h.strServiceType
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
			left join tblHDProjectTask j on j.intTicketId = a.intTicketId
			left join tblHDProject k on k.intProjectId = j.intProjectId
			left join tblAPBill l on l.intBillId = a.intBillId
