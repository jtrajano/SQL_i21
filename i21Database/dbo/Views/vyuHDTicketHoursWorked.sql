CREATE VIEW [dbo].[vyuHDTicketHoursWorked]
	AS
select
			intTicketHoursWorkedId
			,intTicketId
			,intAgentId
			,intAgentEntityId
			,intHours
			,dblHours
			,dblEstimatedHours
			,convert(datetime,ceiling(convert(numeric(18,6), dtmDate))) dtmDate
			,dtmStartTime
			,dtmEndTime
			,dblRate
			,strDescription
			,strJIRALink
			,intInvoiceId
			,dtmInvoiceDate
			,intBillId
			,ysnBillable
			,ysnReimburseable
			,ysnBilled
			,dtmBilled
			,intCreatedUserId
			,intCreatedUserEntityId
			,dtmCreated
			,intJobCodeId
			,intConcurrencyId
			,intCurrencyId
			,intCurrencyExchangeRateTypeId
			,dblCurrencyRate
			,intItemId
			,intItemUOMId
			,strAgent
			,strInvoiceNumber
			,strVoucherNumber
			,strCreatedUserName
			,strJobCode
			,strCurrency
			,strCurrencyExchangeRateType
			,strDate
			,strInvoiceDate
			,strItemNo
			,intTimeEntryId
			,strTicketNumber
			,intCustomerId
			,dblExtendedRate
			,strProjectName
			,intProjectId
			,ysnVendor
			,strServiceType
			,ysnTimeOff
			,strCustomerName 
from
(
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
			,ysnTimeOff = convert(bit,0)
			,strCustomerName = m.strName
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
			left join tblEMEntity m on m.intEntityId = i.intCustomerId

union all

		select
			intTicketHoursWorkedId = convert(int,ROW_NUMBER() over (order by a.intPREntityEmployeeId asc))
			,intTicketId = 0
			,intAgentId = a.intPREntityEmployeeId
			,intAgentEntityId = a.intPREntityEmployeeId
			,intHours = a.dblPRRequest
			,dblHours = a.dblPRRequest
			,dblEstimatedHours = a.dblPRRequest
			,dtmDate = a.dtmPRDate
			,dtmStartTime = null
			,dtmEndTime = null
			,dblRate = 0.00
			,strDescription = c.strTimeOff + ' (' + c.strDescription + ')'
			,strJIRALink = null
			,intInvoiceId = null
			,dtmInvoiceDate = null
			,intBillId = null
			,ysnBillable = convert(bit,0)
			,ysnReimburseable = convert(bit,0)
			,ysnBilled = null
			,dtmBilled = null
			,intCreatedUserId = a.intPREntityEmployeeId
			,intCreatedUserEntityId = a.intPREntityEmployeeId
			,dtmCreated = a.dtmPRDate
			,intJobCodeId = null
			,intConcurrencyId = 1
			,intCurrencyId = null
			,intCurrencyExchangeRateTypeId = null
			,dblCurrencyRate = null
			,intItemId = null
			,intItemUOMId = null
			,strAgent = d.strName
			,strInvoiceNumber = null
			,strVoucherNumber = null
			,strCreatedUserName = d.strName
			,strJobCode = null
			,strCurrency = null
			,strCurrencyExchangeRateType = null
			,strDate = convert(nvarchar(20), a.dtmPRDate, 101) COLLATE Latin1_General_CI_AS
			,strInvoiceDate = null
			,strItemNo = null
			,intTimeEntryId = 1
			,strTicketNumber = null
			,intCustomerId = 0
			,dblExtendedRate = null
			,strProjectName = null
			,intProjectId = null
			,ysnVendor = convert(bit,0)
			,strServiceType = null
			,ysnTimeOff = convert(bit,1)
			,strCustomerName = ''
		from
			tblHDTimeOffRequest a
			inner join tblPRTimeOffRequest b on b.intTimeOffRequestId = a.intPRTimeOffRequestId
			inner join tblPRTypeTimeOff c on c.intTypeTimeOffId = b.intTypeTimeOffId
			inner join tblEMEntity d on d.intEntityId = a.intPREntityEmployeeId
						
) as rawData