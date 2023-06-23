CREATE VIEW [dbo].[vyuAPVendorContactSearch]
AS
SELECT
	a.intEntityId,
	isnull(a.strEntityNo,'') strEntityNo,
	isnull(a.strName,'') strName,
	isnull(c.strName,'') strContactName,
	isnull(c.strEmailDistributionOption,'') strEmailDistributionOption,
	isnull(c.strEmail,'') strEmail,
	isnull(c.strTitle,'') strTitle,
	isnull(d.strPhone,'') strPhone,
	isnull(e.strPhone,'') strMobile,
	isnull(f.strLocationName,'') strLocationName,
	isnull(f.strTimezone,'') strTimezone,
	b.ysnPortalAccess,
	c.ysnActive

	from tblEMEntity a
	join tblEMEntityToContact b
		on b.intEntityId = a.intEntityId
	left join tblEMEntity c
		on c.intEntityId = b.intEntityContactId
	join tblEMEntityPhoneNumber d
		on d.intEntityId = c.intEntityId
	join tblEMEntityMobileNumber e
		on e.intEntityId = c.intEntityId
	join tblEMEntityLocation f
		on f.intEntityLocationId = b.intEntityLocationId
	join tblEMEntityType etype
        on etype.intEntityId = a.intEntityId and strType = 'Vendor'

GO