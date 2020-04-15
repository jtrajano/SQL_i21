CREATE VIEW [dbo].[vyuHDTicketProjection]
	AS
	select
		a.*
		,strProjectionContactName = b.strName
		,strProjectionCustomerName = c.strName
		,strProjectionMileStone = d.strMileStone
		,strProjectionType = e.strType
		,intTicketTypeTypeId = e.intTicketTypeTypeId
		,strProjectionStatus = f.strStatus
		,strProjectionStatusBcColor = f.strBackColor
		,strProjectionStatusFcColor = f.strFontColor
		,strProjectionPriority = g.strPriority
		,strProjectionPriorityBcColor = g.strBackColor
		,strProjectionPriorityFcColor = g.strFontColor
		,strProjectionPriorityJiraPriority = g.strJIRAPriority
		,strProjectionProduct = h.strProduct
		,strProjectionModule = i2.strModule
		,strProjectionModuleJiraProject = i.strJIRAProject
		,strProjectionVersionNo = j.strVersionNo
		,strProjectionAssignedToName = k.strName
		,strProjectionCreatedByName = l.strName
		,strProjectionLastModifiedByName = m.strName
		,strProjectionLastCommentedByName = n.strName
		,strProjectionCompanyLocationName = o.strLocationName
		,strProjectionEntityLocationName = p.strLocationName
		,intProjectId = r.intProjectId
		,strProjectName = r.strProjectName
		,strInternalNote = null
		,dtmGoLive = r.dtmGoLive
		,strOldTicketNumber = null
		,strAdditionalRecipient = null
		,strCurrency = s.strCurrency
		,strCurrencyExchangeRate = u.strCurrency + ' To ' + v.strCurrency
		,strCurrencyExchangeRateType = w.strCurrencyExchangeRateType
		,intMoveToStatusId = y.intTicketStatusId
		,strMoveToStatus = y.strStatus
		,strFeedbackWithSolution = (case a.intFeedbackWithSolutionId when 1 then 'Very Dissatisfied' when 2 then 'Dissatisfied' when 3 then 'Neutral' when 4 then 'Satisfied' when 5 then 'Very Satisfied' else null end) COLLATE Latin1_General_CI_AS
		,strFeedbackWithRepresentative = (case a.intFeedbackWithRepresentativeId when 1 then 'Very Dissatisfied' when 2 then 'Dissatisfied' when 3 then 'Neutral' when 4 then 'Satisfied' when 5 then 'Very Satisfied' else null end) COLLATE Latin1_General_CI_AS
		,strUpgradeType = z.strType
		,strUpgradeTargetVersionNo = a1.strVersionNo
		,strScreenConnectLink = a2.strScreenConnectLink
		,a3.strRootCause
		,a4.strSubcause
		,intCustomerCurrencyId = a2.intCurrencyId
		,intCustomerShipToLocationId = a2.intShipToId
		,intCustomerLocationId = (select top 1 intWarehouseId from tblEMEntityLocation where intEntityId = a.intCustomerId)
	from tblHDTicket a
		left join tblEMEntity b on b.intEntityId = a.intCustomerContactId
		left join tblEMEntity c on c.intEntityId = a.intCustomerId
		left join tblHDMilestone d on d.intMilestoneId = a.intMilestoneId
		left join tblHDTicketType e on e.intTicketTypeId = a.intTicketTypeId
		left join tblHDTicketStatus f on f.intTicketStatusId = a.intTicketStatusId
		left join tblHDTicketPriority g on g.intTicketPriorityId = a.intTicketPriorityId
		left join tblHDTicketProduct h on h.intTicketProductId = a.intTicketProductId
		left join tblHDModule i on i.intModuleId = a.intModuleId
		left join tblSMModule i2 on i2.intModuleId = i.intSMModuleId
		left join tblHDVersion j on j.intVersionId = a.intVersionId
		left join tblEMEntity k on k.intEntityId = a.intAssignedToEntity
		left join tblEMEntity l on l.intEntityId = a.intCreatedUserEntityId
		left join tblEMEntity m on m.intEntityId = a.intLastModifiedUserEntityId
		left join tblEMEntity n on n.intEntityId = a.intLastCommentedByEntityId
		left join tblSMCompanyLocation o on o.intCompanyLocationId = a.intCompanyLocationId
		left join tblEMEntityLocation p on p.intEntityLocationId = a.intEntityLocationId
		left join tblHDProjectTask q on q.intTicketId = a.intTicketId
		left join tblHDProject r on r.intProjectId = q.intProjectId
		left join tblSMCurrency s on s.intCurrencyID = a.intCurrencyId
		left join tblSMCurrencyExchangeRate t on t.intCurrencyExchangeRateId = a.intCurrencyExchangeRateId
		left join tblSMCurrency u on u.intCurrencyID = t.intFromCurrencyId
		left join tblSMCurrency v on v.intCurrencyID = t.intToCurrencyId
		left join tblSMCurrencyExchangeRateType w on w.intCurrencyExchangeRateTypeId = a.intCurrencyExchangeRateTypeId
		left join tblHDTicketStatusWorkflow x on x.intFromStatusId = a.intTicketStatusId and x.ysnActive = convert(bit,1) and x.strTiggerBy = 'Customer Responds'
		left join tblHDTicketStatus y on y.intTicketStatusId = x.intToStatusId
		left join tblHDUpgradeType z on z.intUpgradeTypeId = a.intUpgradeTypeId
		left join tblHDVersion a1 on a1.intVersionId = a.intUpgradeTargetVersionId
		left join tblARCustomer a2 on a2.intEntityId = a.intCustomerId
		left join tblHDTicketRootCause a3 on a3.intRootCauseId = a.intRootCauseId
		left join tblHDTicketSubcause a4 on a4.intSubcauseId = a.intSubcauseId
