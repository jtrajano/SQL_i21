CREATE VIEW [dbo].[vyuHDTicket]
	AS 
	 select
      tic.intTicketId
      ,tic.strTicketNumber
      ,tic.strSubject
      ,typ.strType
      ,sta.strStatus
      ,pri.strPriority
      ,pro.strProduct
      ,mo.strModule
      ,ver.strVersionNo
      ,strCreateBy = cre.strUserName
      ,tic.dtmCreated
      ,tic.dtmLastModified
      ,cre.strCustomer
      ,strAssignedTo = assi.strUserName
      ,tic.intConcurrencyId
  from
      tblHDTicket tic
      ,tblHDTicketType typ
      ,tblHDTicketStatus sta
      ,tblHDTicketPriority pri
      ,tblHDTicketProduct pro
      ,tblHDModule mo
      ,tblHDVersion ver
      ,vyuHDUserDetail cre
      ,vyuHDUserDetail assi
  where
      typ.intTicketTypeId = tic.intTicketTypeId
      and sta.intTicketStatusId = tic.intTicketStatusId
      and pri.intTicketPriorityId = tic.intTicketPriorityId
      and pro.intTicketProductId = tic.intTicketProductId
      and mo.intModuleId = tic.intModuleId
      and ver.intVersionId = tic.intVersionId
      and cre.intUserId = tic.intCreatedUserId
      and assi.intUserId = tic.intAssignedTo
