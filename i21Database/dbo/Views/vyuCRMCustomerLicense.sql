CREATE VIEW [dbo].[vyuCRMCustomerLicense]
	AS
	select
		intId = convert(int, ROW_NUMBER() over (order by a.intEntityId))
		,e.intCustomerLicenseInformationId
		,intCustomerId = a.intEntityId
		,intCustomerContactId = i.intEntityId
		,strCustomerName = b.strName
		,a.ysnActive
		,strLineOfBusiness = dbo.fnCRMCoalesceLinesOfBusiness(e.intEntityCustomerId)
		,strModule = dbo.fnCRMCoalesceModule(e.intEntityCustomerId,e.strCompanyId)
		,e.strCompanyId
		,intNumberOfUser = isnull(e.intNumberOfUser,0)
		,e.dtmDateExpiration
		,intNumberOfSite = isnull(e.intNumberOfSite,0)
		,e.dtmDateIssued
		,strPrimaryContact = i.strName
		,strPrimaryContactPhoneNumber = j.strPhone
		,strSalesperson = k.strName
	from
		tblARCustomer a
		left join tblEMEntity b on b.intEntityId = a.intEntityId
		left join tblARCustomerLicenseInformation e on e.intEntityCustomerId = a.intEntityId and e.dtmDateIssued = (select max(l.dtmDateIssued) from tblARCustomerLicenseInformation l where l.intEntityCustomerId = e.intEntityCustomerId and l.strCompanyId = e.strCompanyId)
		left join tblEMEntityToContact h on h.intEntityId = a.intEntityId and h.ysnDefaultContact = convert(bit,1)
		left join tblEMEntity i on i.intEntityId = h.intEntityContactId
		left join tblEMEntityPhoneNumber j on j.intEntityId = i.intEntityId
		left join tblEMEntity k on k.intEntityId = a.intSalespersonId
