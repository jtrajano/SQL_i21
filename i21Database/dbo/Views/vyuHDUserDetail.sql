CREATE VIEW [dbo].[vyuHDUserDetail]
	AS 
	select
			strCustomer = 'i21 User'
			,intCustomerId = null
			,strCompanyName = 'iRely'
			,us.strFullName
			,us.strPhone
			,strMobile = ''
			,strTimeZone = ''
			,strLocation = us.strLocation
			,strSLAPlan = ''
			,strReplyDue = ''
			,intUserId = us.[intEntityUserSecurityId]
			,intEntityId = us.[intEntityUserSecurityId]
			,ur.strName
			,us.strUserName
			,us.strFirstName
			,us.strMiddleName
			,us.strLastName
			,strEmail = (select (case when strEmail IS null then us.strEmail else strEmail end) from vyuEMEntityContact where intEntityId = us.[intEntityUserSecurityId] and ysnDefaultContact = 1)
			,ysni21User = 1
			,imgPhoto = (select top 1 imgPhoto from vyuEMEntityContact where intEntityId = us.[intEntityUserSecurityId] and ysnDefaultContact = 1)
			,intConcurrencyId = 1
			,strFullName2 = (select top 1 strName from vyuEMEntityContact where intEntityId = us.[intEntityUserSecurityId] and ysnDefaultContact = 1)
			,strEntityType = 'Agent'
		from
			tblSMUserSecurity us,
			tblSMUserRole ur
		where
			ur.intUserRoleID = us.intUserRoleID
		
		union all

		select
			strCustomer = cus.strCustomerNumber
			,intCustomerId = cus.[intEntityId]
			,strCompanyName = (select top 1 strName from tblEMEntity where intEntityId = cus.[intEntityId])
			,strFullName = ec.strEmail
			,strPhone = ec.strPhone
			,strMobile = ec.strMobile
			,strTimeZone = ec.strTimezone
			,strLocation = (select top 1 el.strLocationName from [tblEMEntityLocation] el where el.intEntityLocationId = (select top 1 et.intEntityLocationId from [tblEMEntityToContact] et where et.[intEntityContactId] = ec.[intEntityId]))
			,strSLAPlan = ''
			,strReplyDue = ''
			,intUserId = ec.[intEntityId]
			,intEntityId = ec.[intEntityId]
			,strName = ec.strEmail
			,strUserName = case when (select top 1 strUserName from [tblEMEntityCredential] where intEntityId = ec.[intEntityId]) is null then 'Contact_'+convert(nvarchar(50),ec.[intEntityId]) else (select top 1 strUserName from [tblEMEntityCredential] where intEntityId = ec.[intEntityId]) end
			,strFirstName = ec.strEmail
			,strMiddleName = ec.strEmail
			,strLastName = ec.strEmail
			,strEmail = ec.strEmail
			,ysni21User = 0
			,imgPhoto = ec.imgPhoto
			,intConcurrencyId = 1
			,strFullName2 = ec.strName
			,strEntityType = (select top 1 et.strType from [tblEMEntityType] et where et.intEntityId = cus.[intEntityId] and et.strType in ('Customer','Prospect'))
		from
			tblEMEntity ec
			inner join tblARCustomer cus on cus.[intEntityId] = (select top 1 et.[intEntityId] from [tblEMEntityToContact] et where et.[intEntityContactId] = ec.[intEntityId])
		
		union all

		select
			strCustomer = 'i21 User'
			,intCustomerId = null
			,strCompanyName = 'iRely'
			,strFullName = ec.strEmail
			,strPhone = ec.strPhone
			,strMobile = ec.strMobile
			,strTimeZone = ec.strTimezone
			,strLocation = (select top 1 el.strLocationName from [tblEMEntityLocation] el where el.intEntityLocationId = (select top 1 et.intEntityLocationId from [tblEMEntityToContact] et where et.[intEntityContactId] = ec.[intEntityId]))
			,strSLAPlan = ''
			,strReplyDue = ''
			,intUserId = ec.[intEntityId]
			,intEntityId = ec.[intEntityId]
			,strName = ec.strEmail
			,strUserName = case when (select top 1 strUserName from [tblEMEntityCredential] where intEntityId = ec.[intEntityId]) is null then 'Contact_'+convert(nvarchar(50),ec.[intEntityId]) else (select top 1 strUserName from [tblEMEntityCredential] where intEntityId = ec.[intEntityId]) end
			,strFirstName = ec.strEmail
			,strMiddleName = ec.strEmail
			,strLastName = ec.strEmail
			,strEmail = ec.strEmail
			,ysni21User = 1
			,imgPhoto = ec.imgPhoto
			,intConcurrencyId = 1
			,strFullName2 = (select top 1 strName from vyuEMEntityContact where intEntityId = sp.[intEntityId] and ysnDefaultContact = 1)
			,strEntityType = 'Agent'
		from
			tblEMEntity ec
			inner join tblARSalesperson sp on sp.[intEntityId] = (select top 1 et.[intEntityId] from [tblEMEntityToContact] et where et.[intEntityContactId] = ec.[intEntityId])
