﻿CREATE VIEW [dbo].[vyuHDTicket]
AS
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
		,strCreateBy = (select top 1 strName from tblEntity where intEntityId = tic.intCreatedUserEntityId)
		,tic.dtmCreated
		,tic.dtmLastModified
		,strCustomer = tic.strCustomerNumber
		,strAssignedTo = (select top 1 strName from tblEntity where intEntityId = tic.intAssignedToEntity)
		,tic.intConcurrencyId
		,intAssignToEntity = tic.intAssignedToEntity
		,strContactName = (select top 1 strName from tblEntity where intEntityId = tic.intCustomerContactId)
		,tic.intCustomerContactId
		,strDateCreated = convert(nvarchar,tic.dtmCreated, 101)
		,strDateLastModified = convert(nvarchar,tic.dtmLastModified, 101)
		,tic.strJiraKey
		,tic.intCustomerId
		,tic.intCreatedUserEntityId
		,proj.strProjectName
		,tic.dtmDueDate
		,strDueDate = convert(nvarchar,tic.dtmDueDate, 101)
		,tic.intTicketProductId
		,strTicketType = tic.strType
		,strCustomerName = (select top 1 strName from tblEntity where intEntityId = tic.intCustomerId)
	from
		tblHDTicket tic
		left outer join tblHDTicketType typ on typ.intTicketTypeId = tic.intTicketTypeId
		left outer join tblHDTicketStatus sta on sta.intTicketStatusId = tic.intTicketStatusId
		left outer join tblHDTicketPriority pri on pri.intTicketPriorityId = tic.intTicketPriorityId
		left outer join tblHDTicketProduct pro on pro.intTicketProductId = tic.intTicketProductId
		left outer join tblHDModule mo on mo.intModuleId = tic.intModuleId
		left outer join tblSMModule smmo on smmo.intModuleId = mo.intSMModuleId
		left outer join tblHDVersion ver on ver.intVersionId = tic.intVersionId  
		left outer join tblHDProject proj on proj.intProjectId = (select top 1 projt.intProjectId from tblHDProjectTask projt where projt.intTicketId = tic.intTicketId)
