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
		from
			tblHDTicket a
			left join tblSMCurrency b on b.intCurrencyID = a.intCurrencyId
			left join tblSMCurrencyExchangeRateType c on c.intCurrencyExchangeRateTypeId = a.intCurrencyExchangeRateTypeId
			left join tblEMEntity d on d.intEntityId = a.intAssignedToEntity
			left join tblHDModule e on e.intModuleId = a.intModuleId
			left join tblSMModule f on f.intModuleId = e.intSMModuleId
			left join tblEMEntity g on g.intEntityId = a.intCustomerId
		where
			a.strType <> 'CRM'