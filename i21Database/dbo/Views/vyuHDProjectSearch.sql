CREATE VIEW [dbo].[vyuHDProjectSearch]
    AS
        select
            proj.intProjectId
            ,proj.strProjectName
            ,proj.strDescription
            ,strCustomerName = (select top 1 strName from tblEntity where intEntityId = cus.[intEntityCustomerId])
            ,strContactName = (select top 1 strName from tblEntity where intEntityId = con.[intEntityId])
            ,strType = (select top 1 strType from tblHDTicketType where intTicketTypeId = typ.intTicketTypeId)
            ,strGoLive = CONVERT(nvarchar(10),proj.dtmGoLive,101)
            ,proj.intPercentComplete
            ,proj.ysnCompleted
            ,proj.strProjectStatus
			,strProjectManager = (select top 1 e.strName from tblEntity e where e.intEntityId = proj.intInternalProjectManager)
			,strProjectType = proj.strType
			,proj.intCustomerContactId
			,strEntityType = (select top 1 et.strType from tblEntityType et where et.intEntityId = cus.[intEntityCustomerId] and et.strType in ('Customer','Prospect'))
        from
            tblHDProject proj
            left outer join tblARCustomer cus on cus.[intEntityCustomerId] = proj.intCustomerId
			left outer join tblEntity con on con.[intEntityId] = proj.intCustomerContactId
            left outer join tblHDTicketType typ on typ.intTicketTypeId = proj.intTicketTypeId
