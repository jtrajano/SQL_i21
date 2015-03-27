﻿CREATE VIEW [dbo].[vyuHDProjectList]
	AS
select
	p.strProjectName
	,t.strTicketNumber
	,t.strCustomerNumber
	,strContactName = conEntity.strName
	,conEntity.strPhone
	,m.strModule
	,strAssignedToName = assEntity.strName
	,p.dtmGoLive
	,t.dtmCreated
	,ysnCompleted = (case when t.intTicketStatusId = 2 then convert(bit,1) else convert(bit,0) end)
	,intPercentModuleComplete = null
	,t.dblQuotedHours
	,t.dblActualHours
	,dblOverShort = t.dblQuotedHours - t.dblActualHours
	,t.intTicketId
	,p.intProjectId
	,pt.intProjectTaskId
	,m.intModuleId
	,intContactEntityId = t.intCustomerContactId
	--,intContactId = con.intEntityContactId
	,intContactId = conEntity.intEntityId
	,intAssignedToEntityId = t.intAssignedToEntity
	,t.intCustomerId
	,ysnProjectCompleted = p.ysnCompleted
	,strMilestone = ms.strDescription
	,ms.intPriority
from
	tblHDProjectTask pt
	left outer join tblHDProject p on p.intProjectId = pt.intProjectId
	left outer join tblHDTicket t on t.intTicketId = pt.intTicketId
	left outer join tblHDModule m on m.intModuleId = t.intModuleId
	left outer join tblEntity conEntity on conEntity.intEntityId = t.intCustomerContactId
	--left outer join tblEntityContact con on con.intEntityContactId = conEntity.intEntityId
	left outer join tblEntity assEntity on assEntity.intEntityId = t.intAssignedToEntity
	left outer join tblHDMilestone ms on ms.intMilestoneId = t.intMilestoneId
