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
			,strCustomerName = g.strName
			,a.intAssignedToEntity
			,strAssignToEntityName = d.strName
			,a.intModuleId
			,intSMModuleId = f.intModuleId
			,f.strModule
			,i.strProjectName
			,i.intProjectId
			,j.strStatus
			,dtmCloseDate = FORMAT(a.dtmCompleted, 'MM/dd/yyyy')
		from
			tblHDTicket a
			left join tblSMCurrency b on b.intCurrencyID = a.intCurrencyId
			left join tblSMCurrencyExchangeRateType c on c.intCurrencyExchangeRateTypeId = a.intCurrencyExchangeRateTypeId
			left join tblEMEntity d on d.intEntityId = a.intAssignedToEntity
			left join tblHDModule e on e.intModuleId = a.intModuleId
			left join tblSMModule f on f.intModuleId = e.intSMModuleId
			left join tblEMEntity g on g.intEntityId = a.intCustomerId
			left join tblHDProjectTask h on h.intTicketId = a.intTicketId
			left join tblHDProject i on i.intProjectId = h.intProjectId
			left join tblHDTicketStatus j on a.intTicketStatusId = j.intTicketStatusId
		where
			a.strType <> 'CRM'
GO