CREATE VIEW [dbo].[vyuHDProjectSearch]
    AS
        select
            proj.intProjectId
            ,proj.strProjectName
            ,proj.strDescription
            ,strCustomerName = (select top 1 strName from tblEntity where intEntityId = cus.[intEntityCustomerId])
            ,strContactName = (select top 1 strName from tblEntity where intEntityId = con.[intEntityContactId])
            ,strType = (select top 1 strType from tblHDTicketType where intTicketTypeId = typ.intTicketTypeId)
            ,strGoLive = CONVERT(nvarchar(10),proj.dtmGoLive,101)
            ,proj.intPercentComplete
            ,proj.ysnCompleted
        from
            tblHDProject proj,
            tblARCustomer cus,
            tblEntityContact con,
            tblHDTicketType typ
        where
            cus.[intEntityCustomerId] = proj.intCustomerId
            and con.[intEntityContactId] = proj.intCustomerContactId
            and typ.intTicketTypeId = proj.intTicketTypeId
