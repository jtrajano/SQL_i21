CREATE VIEW [dbo].[vyuEMSalesperson]
as
select 
	b.intEntitySalespersonId,
	b.strSalespersonId,
	a.strName as strSalespersonName,
	a.strName,
	b.strType,	
	d.strTitle,
	b.dtmBirthDate,
	b.strGender,
	b.intTerritoryId,
	d.strPhone,
	d.strPhone2,
	d.strMobile,
	d.strEmail2,
	d.strFax,
	e.strAddress,
	e.strZipCode,
	e.strCity,
	e.strState,
	e.strCountry,
	b.dtmHired,
	b.dtmTerminated,
	b.strReason,
	b.ysnActive,
	b.strCommission,
	b.dblPercent,
	b.strDispatchNotification,
	b.strTextMessage
from tblEntity a
	join tblARSalesperson b on
		a.intEntityId = b.intEntitySalespersonId
	left join tblEntityToContact c
		on a.intEntityId = c.intEntityId	
			and c.ysnDefaultContact = 1
	left join tblEntity d
		on c.intEntityContactId = d.intEntityId
	left join tblEntityLocation e
		on a.intEntityId = e.intEntityId 
			and e.ysnDefaultLocation = 1

GO		
