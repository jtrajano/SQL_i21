CREATE VIEW [dbo].[vyuHDTicketType]
AS
SELECT    intTicketTypeId		= TicketType.intTicketTypeId
         ,strType				= TicketType.strType
         ,strDescription		= TicketType.strDescription
         ,strJIRAType			= TicketType.strJIRAType
         ,strIcon				= TicketType.strIcon
         ,intSort				= TicketType.intSort
         ,ysnTicket				= TicketType.ysnTicket
         ,intTicketTypeTypeId	= TicketType.intTicketTypeTypeId
         ,ysnActivity			= TicketType.ysnActivity
         ,ysnOpportunity		= TicketType.ysnOpportunity
         ,ysnProject			= TicketType.ysnProject
         ,ysnCampaign			= TicketType.ysnCampaign
         ,ysnDefaultProject		= TicketType.ysnDefaultProject
         ,ysnDefaultTicket      = TicketType.ysnDefaultTicket
         ,ysnSupported			= TicketType.ysnSupported
         ,strTicketTypeType		= CASE WHEN TicketType.intTicketTypeTypeId = 1
											THEN 'No'
									   WHEN TicketType.intTicketTypeTypeId = 2
											THEN 'Help Ticket'
									   WHEN TicketType.intTicketTypeTypeId = 3
											THEN 'Upgrade Ticket'
									   WHEN TicketType.intTicketTypeTypeId = 4
											THEN 'Statement of Work'
									   ELSE ''
								  END
		  ,intConcurrencyId = TicketType.intConcurrencyId
FROM tblHDTicketType TicketType

		
GO 