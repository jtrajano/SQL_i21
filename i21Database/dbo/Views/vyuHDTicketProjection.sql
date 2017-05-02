CREATE VIEW [dbo].[vyuHDTicketProjection]
	AS
	select
		a.*
		,strProjectionContactName = b.strName
		,strProjectionCustomerName = c.strName
		,strProjectionMileStone = d.strMileStone
		,strProjectionType = e.strType
		,strProjectionStatus = f.strStatus
		,strProjectionPriority = g.strPriority
		,strProjectionProduct = h.strProduct
		,strProjectionModule = i2.strModule
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
