﻿CREATE VIEW [dbo].[vyuSCTicketInOutReport]
	AS 

	select 

		Ticket.strTicketNumber
		,Entity.strName
		,CompanyLocation.strLocationName
		,StorageType.strStorageTypeDescription 
		,case when Ticket.strInOutFlag = 'I' then 'INBOUND' 
				when Ticket.strInOutFlag = 'O' then 'OUTBOUND'
			else ''
		end
			as strIndicator
		, Ticket.dblGrossUnits
		, Ticket.intTicketType
		, TicketType.strTicketType
		, Ticket.dtmTicketDateTime
		, StorageType.strStorageTypeDescription  + ' ' +
			case when Ticket.strInOutFlag = 'I' then 'Inbound' 
				when Ticket.strInOutFlag = 'O' then 'Outbound'
			else ''
		end as strGroupIndicator

		from tblSCTicket Ticket
			join tblEMEntity Entity
				on Ticket.intEntityId = Entity.intEntityId
			join tblSMCompanyLocation CompanyLocation
				on Ticket.intProcessingLocationId = CompanyLocation.intCompanyLocationId
			join tblGRStorageType StorageType
				on Ticket.intStorageScheduleTypeId = StorageType.intStorageScheduleTypeId
			join tblSCListTicketTypes TicketType
				on Ticket.intTicketType = TicketType.intTicketType

	where Ticket.intTicketType = 1
		and CompanyLocation.ysnLicensed = 1
		--and dtmTicketDateTime between '2021-10-15' and '2021-10-22'

	union all
	select 

		Ticket.strTicketNumber
		, EntityCompanyLocation.strLocationName as strName
		,CompanyLocation.strLocationName
		,'Transfer' as strStorageTypeDescription
		,'Outbound' as strIndicator
		, Ticket.dblGrossUnits
		, Ticket.intTicketType
		, TicketType.strTicketType
		, Ticket.dtmTicketDateTime
		, 'Transfer Outbound' as strGroupIndicator
		from tblSCTicket Ticket			
			join tblSMCompanyLocation CompanyLocation
				on Ticket.intProcessingLocationId = CompanyLocation.intCompanyLocationId
			join tblSMCompanyLocation EntityCompanyLocation
				on Ticket.intTransferLocationId= EntityCompanyLocation.intCompanyLocationId	
			join tblSCListTicketTypes TicketType
				on Ticket.intTicketType = TicketType.intTicketType

	where Ticket.intTicketType = 7
		and CompanyLocation.ysnLicensed = 1
		and EntityCompanyLocation.ysnLicensed = 1
		--and dtmTicketDateTime between '2021-10-15' and '2021-10-22'

	union all
	select 

		Ticket.strTicketNumber
		, EntityCompanyLocation.strLocationName as strName
		,CompanyLocation.strLocationName
		,'Transfer' as strStorageTypeDescription
		,'Inbound' as strIndicator
		, Ticket.dblGrossUnits
		, Ticket.intTicketType
		, TicketType.strTicketType
		, Ticket.dtmTicketDateTime
		, 'Transfer Inbound' as strGroupIndicator
		from tblSCTicket Ticket			
			join tblSMCompanyLocation CompanyLocation
				on Ticket.intTransferLocationId = CompanyLocation.intCompanyLocationId		
			join tblSMCompanyLocation EntityCompanyLocation
				on Ticket.intProcessingLocationId= EntityCompanyLocation.intCompanyLocationId		
			join tblSCListTicketTypes TicketType
				on Ticket.intTicketType = TicketType.intTicketType

	where Ticket.intTicketType = 7
		and CompanyLocation.ysnLicensed = 1		
		and EntityCompanyLocation.ysnLicensed = 1
		--and dtmTicketDateTime between '2021-10-15' and '2021-10-22'


	
GO