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
      ,strCreateBy = (select top 1 strUserName from tblEntityCredential where intEntityId = tic.intCreatedUserEntityId)
      ,tic.dtmCreated
      ,tic.dtmLastModified
      ,strCustomer = tic.strCustomerNumber
      ,strAssignedTo = (select top 1 strUserName from tblEntityCredential where intEntityId = tic.intAssignedToEntity)
      ,tic.intConcurrencyId
  from
      tblHDTicket tic
      left outer join tblHDTicketType typ on typ.intTicketTypeId = tic.intTicketTypeId
      left outer join tblHDTicketStatus sta on sta.intTicketStatusId = tic.intTicketStatusId
      left outer join tblHDTicketPriority pri on pri.intTicketPriorityId = tic.intTicketPriorityId
      left outer join tblHDTicketProduct pro on pro.intTicketProductId = tic.intTicketProductId
      left outer join tblHDModule mo on mo.intModuleId = tic.intModuleId
      left outer join tblHDVersion ver on ver.intVersionId = tic.intVersionId 
	/*
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
      ,strCustomer = tic.strCustomerNumber
      ,strAssignedTo = assi.strUserName
      ,tic.intConcurrencyId
  from
      tblHDTicket tic
      left outer join tblHDTicketType typ on typ.intTicketTypeId = tic.intTicketTypeId
      left outer join tblHDTicketStatus sta on sta.intTicketStatusId = tic.intTicketStatusId
      left outer join tblHDTicketPriority pri on pri.intTicketPriorityId = tic.intTicketPriorityId
      left outer join tblHDTicketProduct pro on pro.intTicketProductId = tic.intTicketProductId
      left outer join tblHDModule mo on mo.intModuleId = tic.intModuleId
      left outer join tblHDVersion ver on ver.intVersionId = tic.intVersionId
      left outer join vyuHDUserDetail cre on cre.intEntityId = tic.intCreatedUserEntityId
      left outer join vyuHDUserDetail assi on assi.intEntityId = tic.intAssignedToEntity
	  */
