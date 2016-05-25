CREATE VIEW [dbo].[vyuEMSalesperson]
as
select 
	b.intEntitySalespersonId,
	strSalespersonId = case when b.strSalespersonId = '' then a.strEntityNo else b.strSalespersonId end ,
	a.strName as strSalespersonName,
	a.strName,
	b.strType,	
	d.strTitle,
	b.dtmBirthDate,
	b.strGender,
	b.intTerritoryId,
	strPhone = phone.strPhone,
	d.strPhone2,
	strMobile = mob.strPhone,
	d.strEmail,
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
from tblEMEntity a
	join tblARSalesperson b on
		a.intEntityId = b.intEntitySalespersonId
	left join [tblEMEntityToContact] c
		on a.intEntityId = c.intEntityId	
			and c.ysnDefaultContact = 1
	left join tblEMEntity d
		on c.intEntityContactId = d.intEntityId
	left join [tblEMEntityLocation] e
		on a.intEntityId = e.intEntityId 
			and e.ysnDefaultLocation = 1
	LEFT JOIN tblEMEntityPhoneNumber phone
		ON phone.intEntityId = d.intEntityId
	LEFT JOIN tblEMEntityMobileNumber mob
		ON mob.intEntityId = d.intEntityId
GO		
