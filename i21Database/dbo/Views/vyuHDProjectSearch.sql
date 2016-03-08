CREATE VIEW [dbo].[vyuHDProjectSearch]
    AS
        select
            proj.intProjectId
            ,proj.strProjectName
			,strSalesPipeStatus = pipe.strStatus
			,dtmExpectedCloseDate = proj.dtmSalesDate
			,strExpectedCloseDate = CONVERT(nvarchar(10),proj.dtmSalesDate,101)
			,strPipePercentage = convert(nvarchar(20), cast(round(pipe.dblProbability,2) as numeric(36,2))) + '%'
			,dblOpportunityAmmount = (select sum(vyuSOSalesOrderSearch.dblAmountDue) from vyuSOSalesOrderSearch where vyuSOSalesOrderSearch.intSalesOrderId in (select tblHDOpportunityQuote.intSalesOrderId from tblHDOpportunityQuote where tblHDOpportunityQuote.intProjectId = proj.intProjectId))
			,dblNetOpportunityAmmount = (cast(round(pipe.dblProbability/100,2) as numeric (36,2))*(select sum(vyuSOSalesOrderSearch.dblAmountDue) from vyuSOSalesOrderSearch where vyuSOSalesOrderSearch.intSalesOrderId in (select tblHDOpportunityQuote.intSalesOrderId from tblHDOpportunityQuote where tblHDOpportunityQuote.intProjectId = proj.intProjectId)))
            ,dtmLastActivityDate = (select max(tblHDTicket.dtmCreated) from tblHDTicket where tblHDTicket.intTicketId in (select tblHDProjectTask.intTicketId from tblHDProjectTask where tblHDProjectTask.intProjectId = proj.intProjectId))
			,strSalesPerson = (select top 1 e.strName from tblEntity e where e.intEntityId = proj.intInternalSalesPerson)
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
			,proj.dtmCreated
			,proj.intCustomerId
			,proj.dtmClose
        from
            tblHDProject proj
            left outer join tblARCustomer cus on cus.[intEntityCustomerId] = proj.intCustomerId
			left outer join tblEntity con on con.[intEntityId] = proj.intCustomerContactId
            left outer join tblHDTicketType typ on typ.intTicketTypeId = proj.intTicketTypeId
            left outer join tblHDSalesPipeStatus pipe on pipe.intSalesPipeStatusId = proj.intSalesPipeStatusId
