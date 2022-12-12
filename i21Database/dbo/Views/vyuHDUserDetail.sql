CREATE VIEW [dbo].[vyuHDUserDetail]
	AS 
	select
			strCustomer = 'i21 User' COLLATE Latin1_General_CI_AS
			,intCustomerId = null
			,strCompanyName = 'iRely' COLLATE Latin1_General_CI_AS
			,us.strFullName
			,us.strPhone
			,strMobile = '' COLLATE Latin1_General_CI_AS
			,strTimeZone = '' COLLATE Latin1_General_CI_AS
			,strLocation = us.strLocation
			,strSLAPlan = '' COLLATE Latin1_General_CI_AS
			,strReplyDue = '' COLLATE Latin1_General_CI_AS
			,intUserId = us.[intEntityId]
			,intEntityId = us.[intEntityId]
			,ur.strName
			,us.strUserName
			,us.strFirstName
			,us.strMiddleName
			,us.strLastName
			,strEmail = (select top 1 (case when strEmail IS null then us.strEmail else strEmail end) from vyuEMEntityContact where intEntityId = us.[intEntityId] and ysnDefaultContact = 1)
			,ysni21User = 1
			,imgPhoto = (select top 1 imgPhoto from vyuEMEntityContact where intEntityId = us.[intEntityId] and ysnDefaultContact = 1)
			,intConcurrencyId = 1
			,strFullName2 = (select top 1 strName from vyuEMEntityContact where intEntityId = us.[intEntityId] and ysnDefaultContact = 1)
			,strEntityType = 'Agent' COLLATE Latin1_General_CI_AS
			,intCustomerCount = NULL
			,strUAPLabel = '' COLLATE Latin1_General_CI_AS
		from
			tblSMUserSecurity us
			inner join tblSMUserRole ur on ur.intUserRoleID = us.intUserRoleID
		
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
			,strSLAPlan = '' COLLATE Latin1_General_CI_AS
			,strReplyDue = '' COLLATE Latin1_General_CI_AS
			,intUserId = ec.[intEntityId]
			,intEntityId = ec.[intEntityId]
			,strName = ec.strEmail
			,strUserName = case when (select top 1 strUserName from [tblEMEntityCredential] where intEntityId = ec.[intEntityId]) is null then 'Contact_'+convert(nvarchar(50),ec.[intEntityId]) else (select top 1 strUserName from [tblEMEntityCredential] where intEntityId = ec.[intEntityId]) end COLLATE Latin1_General_CI_AS
			,strFirstName = ec.strEmail
			,strMiddleName = ec.strEmail
			,strLastName = ec.strEmail
			,strEmail = ec.strEmail
			,ysni21User = 0
			,imgPhoto = ec.imgPhoto
			,intConcurrencyId = 1
			,strFullName2 = ec.strName
			,strEntityType = (select top 1 et.strType from [tblEMEntityType] et where et.intEntityId = cus.[intEntityId] and et.strType in ('Customer','Prospect'))
			,intCustomerCount = (select count(*)  from tblEMEntityToContact where intEntityContactId = ec.intEntityId)
			,strUAPLabel = CASE WHEN cus.ysnUAP = CONVERT(BIT, 1) 
									THEN 'YES'
								ELSE 'NO'
						   END  COLLATE Latin1_General_CI_AS
		from
			tblEMEntity ec
			inner join tblARCustomer cus on cus.[intEntityId] = (select top 1 et.[intEntityId] from [tblEMEntityToContact] et where et.[intEntityContactId] = ec.[intEntityId])
		
		union all

		select
			strCustomer = 'i21 User' COLLATE Latin1_General_CI_AS
			,intCustomerId = null
			,strCompanyName = 'iRely' COLLATE Latin1_General_CI_AS
			,strFullName = ec.strEmail
			,strPhone = ec.strPhone
			,strMobile = ec.strMobile
			,strTimeZone = ec.strTimezone
			,strLocation = (select top 1 el.strLocationName from [tblEMEntityLocation] el where el.intEntityLocationId = (select top 1 et.intEntityLocationId from [tblEMEntityToContact] et where et.[intEntityContactId] = ec.[intEntityId]))
			,strSLAPlan = '' COLLATE Latin1_General_CI_AS
			,strReplyDue = '' COLLATE Latin1_General_CI_AS
			,intUserId = ec.[intEntityId]
			,intEntityId = ec.[intEntityId]
			,strName = ec.strEmail
			,strUserName = case when (select top 1 strUserName from [tblEMEntityCredential] where intEntityId = ec.[intEntityId]) is null then 'Contact_'+convert(nvarchar(50),ec.[intEntityId]) else (select top 1 strUserName from [tblEMEntityCredential] where intEntityId = ec.[intEntityId]) end COLLATE Latin1_General_CI_AS
			,strFirstName = ec.strEmail
			,strMiddleName = ec.strEmail
			,strLastName = ec.strEmail
			,strEmail = ec.strEmail
			,ysni21User = 1
			,imgPhoto = ec.imgPhoto
			,intConcurrencyId = 1
			,strFullName2 = (select top 1 strName from vyuEMEntityContact where intEntityId = sp.[intEntityId] and ysnDefaultContact = 1)
			,strEntityType = 'Agent' COLLATE Latin1_General_CI_AS
			,intCustomerCount = NULL
			,strUAPLabel = '' COLLATE Latin1_General_CI_AS
		from
			tblEMEntity ec
			inner join tblARSalesperson sp on sp.[intEntityId] = (select top 1 et.[intEntityId] from [tblEMEntityToContact] et where et.[intEntityContactId] = ec.[intEntityId])
GO
