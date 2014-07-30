CREATE VIEW [dbo].[vyuHDUserDetail]
	AS select
			strCustomer = 'i21 User'
			,strCompanyName = 'iRely'
			,us.strFullName
			,us.strPhone
			,strMobile = ''
			,strTimeZone = ''
			,strLocation = us.strLocation
			,strSLAPlan = ''
			,strReplyDue = ''
			,intUserId = us.intUserSecurityID
			,intEntityId = us.intEntityId
			,ur.strName
			,us.strUserName
			,us.strFirstName
			,us.strMiddleName
			,us.strLastName
			,strEmail = (select (case when strEmail IS null then us.strEmail else strEmail end) from tblEntity where intEntityId = us.intEntityId)
			,ysni21User = 1
			,imgPhoto = null
			,intConcurrencyId = 1
		from
			tblSMUserSecurity us,
			tblSMUserRole ur
		where
			ur.intUserRoleID = us.intUserRoleID
		
		union all

		select
			strCustomer = cus.strCustomerNumber
			,strCompanyName = (select top 1 strName from tblEntity where intEntityId = cus.intEntityId)
			,strFullName = en.strEmail
			,strPhone = ec.strPhone
			,strMobile = ec.strMobile
			,strTimeZone = ''
			,strLocation = el.strLocationName
			,strSLAPlan = ''
			,strReplyDue = ''
			,intUserId = ec.intEntityId
			,intEntityId = ec.intEntityId
			,strName = en.strEmail
			,strUserName = (select top 1 strUserName from tblEntityCredential where intEntityId = ec.intEntityId)
			,strFirstName = en.strEmail
			,strMiddleName = en.strEmail
			,strLastName = en.strEmail
			,strEmail = en.strEmail
			,ysni21User = 0
			,imgPhoto = ec.imgContactPhoto
			,intConcurrencyId = 1
		from
			tblEntityContact ec
			left outer join tblARCustomer cus on cus.intEntityId = (select top 1 et.intEntityId from tblEntityToContact et where et.intContactId = ec.intEntityId)
			left outer join tblEntity en on en.intEntityId = ec.intEntityId
			left outer join tblEntityLocation el on el.intEntityLocationId = (select top 1 et.intLocationId from tblEntityToContact et where et.intContactId = ec.intEntityId)
