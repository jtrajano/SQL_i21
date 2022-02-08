CREATE VIEW [dbo].[vyuHDTicket]
AS
	with x as (
		select hr.intTicketId, dblEstimatedHours = sum(hr.dblEstimatedHours) from tblHDTicketHoursWorked hr group by hr.intTicketId
	)
	select
		tic.intTicketId
		,tic.strTicketNumber
		,tic.strSubject
		,typ.strType
		,sta.strStatus
		,strStatusIcon = sta.strIcon
		,strStatusFontColor = sta.strFontColor
		,strStatusBackColor = sta.strBackColor
		,pri.strPriority
		,strPriorityIcon = pri.strIcon
		,strPriorityFontColor = pri.strFontColor
		,strPriorityBackColor = pri.strBackColor
		,pro.strProduct
		,smmo.strModule
		,ver.strVersionNo
		,strCreateBy = created.strName --(select top 1 strName from tblEMEntity where intEntityId = tic.intCreatedUserEntityId)
		,tic.dtmCreated
		,tic.dtmLastModified
		,strCustomer = tic.strCustomerNumber
		,strAssignedTo = assignto.strName --(select top 1 strName from tblEMEntity where intEntityId = tic.intAssignedToEntity)
		,tic.intConcurrencyId
		,intAssignToEntity = tic.intAssignedToEntity
		,strContactName = contact.strName --(select top 1 strName from tblEMEntity where intEntityId = tic.intCustomerContactId)
		,tic.intCustomerContactId
		,intContactRank = ISNULL(contact.intEntityRank,1)
		,strDateCreated = convert(nvarchar,tic.dtmCreated, 101) COLLATE Latin1_General_CI_AS
		,strDateLastModified = convert(nvarchar,tic.dtmLastModified, 101) COLLATE Latin1_General_CI_AS
		,strJiraKey = dbo.fnHDCoalesceJiraKey(tic.intTicketId,convert(bit,0)) COLLATE Latin1_General_CI_AS
		,strJiraKeyDisplay = dbo.fnHDCoalesceJiraKey(tic.intTicketId,convert(bit,1)) COLLATE Latin1_General_CI_AS
		,tic.intCustomerId
		,tic.intCreatedUserEntityId
		,proj.strProjectName
		,tic.dtmDueDate
		,strDueDate = convert(nvarchar,tic.dtmDueDate, 101) COLLATE Latin1_General_CI_AS
		,tic.intTicketProductId
		,strTicketType = tic.strType
		,strCustomerName = cus.strName --(select top 1 strName from tblEMEntity where intEntityId = tic.intCustomerId)
		,tic.dtmLastCommented
		,strDateLastCommented = convert(nvarchar,tic.dtmLastCommented, 101) COLLATE Latin1_General_CI_AS
		,strLastCommentedBy = lastcomment.strName --(select top 1 strName from tblEMEntity where intEntityId = tic.intLastCommentedByEntityId)
		,strCompanyLocation = camloc.strLocationName
		,strEntityLocation = enloc.strLocationName
		,tic.strDescription
		,tic.strResolution
		,tic.strImageId
		,tic.strFeedbackComment
		,strCampaignName = null
		,strFeedbackWithSolution = (case when tic.intFeedbackWithSolutionId = 1 then 'Very Dissatisfied'
										 when tic.intFeedbackWithSolutionId = 2 then 'Dissatisfied'
										 when tic.intFeedbackWithSolutionId = 3 then 'Neutral'
										 when tic.intFeedbackWithSolutionId = 4 then 'Satisfied'
										 when tic.intFeedbackWithSolutionId = 5 then 'Very Satisfied'
										 else ''
									end) COLLATE Latin1_General_CI_AS
		,strFeedbackWithRepresentative = (case when tic.intFeedbackWithRepresentativeId = 1 then 'Very Dissatisfied'
											   when tic.intFeedbackWithRepresentativeId = 2 then 'Dissatisfied'
											   when tic.intFeedbackWithRepresentativeId = 3 then 'Neutral'
											   when tic.intFeedbackWithRepresentativeId = 4 then 'Satisfied'
											   when tic.intFeedbackWithRepresentativeId = 5 then 'Very Satisfied'
											   else ''
										  end) COLLATE Latin1_General_CI_AS
		,strTicketTypeType = (case when typ.intTicketTypeTypeId = 1 then 'No'
								   when typ.intTicketTypeTypeId = 2 then 'Help Ticket'
								   when typ.intTicketTypeTypeId = 3 then 'Upgrade Ticket'
								   when typ.intTicketTypeTypeId = 4 then 'Statement of Work'
								   else null
							  end) COLLATE Latin1_General_CI_AS
		,tic.dblActualHours
		,tic.dblNonBillableHours
		,dblEstimatedHours = isnull(x.dblEstimatedHours, 0)
		,ut.intUpgradeTypeId
		,strUpgradeType = ut.strType
		,tic.strUpgradeEnvironmentId
		,strUpgradeEnvironmentValue = tic.strUpgradeEnvironment
		,tic.intUpgradeTargetVersionId
		,strUpgradeTargetVersionNo = uv.strVersionNo
		,tic.strUpgradeCompany
		,tic.strUpgradeCustomerContactId
		,tic.strUpgradeCustomerContact
		,tic.dtmUpgradeStartTime
		,tic.strUpgradeCustomerTimeZone
		,tic.dtmUpgradeEndTime
		,tic.intUpgradeTimeTook
		,tic.strUpgradeCopyDataFrom
		,tic.strUpgradeCopyDataTo
		,tic.strUpgradeSpecialInstruction
		,rc.strRootCause
	from
		tblHDTicket tic
		join tblHDTicketType typ on typ.intTicketTypeId = tic.intTicketTypeId
		join tblHDTicketStatus sta on sta.intTicketStatusId = tic.intTicketStatusId
		join tblHDTicketPriority pri on pri.intTicketPriorityId = tic.intTicketPriorityId
		join tblHDTicketProduct pro on pro.intTicketProductId = tic.intTicketProductId
		join tblHDModule mo on mo.intModuleId = tic.intModuleId
		join tblSMModule smmo on smmo.intModuleId = mo.intSMModuleId
		join tblHDVersion ver on ver.intVersionId = tic.intVersionId  
		join tblEMEntity contact on contact.intEntityId = tic.intCustomerContactId
		join tblEMEntity cus on cus.intEntityId = tic.intCustomerId
		join tblEMEntity created on created.intEntityId = tic.intCreatedUserEntityId
		left join tblHDProjectTask projt on projt.intTicketId = tic.intTicketId
		left join tblHDProject proj on proj.intProjectId = projt.intProjectId
		left join tblSMCompanyLocation camloc on camloc.intCompanyLocationId = tic.intCompanyLocationId
		left join tblEMEntityLocation enloc on enloc.intEntityLocationId = tic.intEntityLocationId
		left join tblEMEntity lastcomment on lastcomment.intEntityId = tic.intLastCommentedByEntityId
		left join tblEMEntity assignto on assignto.intEntityId = tic.intAssignedToEntity
		left join x on x.intTicketId = tic.intTicketId
		left join tblHDUpgradeType ut on ut.intUpgradeTypeId = tic.intUpgradeTypeId
		left join tblHDVersion uv on uv.intVersionId = tic.intUpgradeTargetVersionId
		left join tblHDTicketRootCause rc on rc.intRootCauseId = tic.intRootCauseId