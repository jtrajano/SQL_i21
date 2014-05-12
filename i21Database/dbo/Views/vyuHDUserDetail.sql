CREATE VIEW [dbo].[vyuHDUserDetail]
	AS select
			strCustomer = 'i21 User'
			,us.strFullName
			,us.strPhone
			,strTimeZone = ''
			,strLocation = us.strLocation
			,strSLAPlan = ''
			,strReplyDue = ''
			,intUserId = us.intUserSecurityID
			,ur.strName
			,us.strUserName
			,us.strFirstName
			,us.strMiddleName
			,us.strLastName
			,us.strEmail
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
			,strFullName = ec.strEmail
			,strPhone = ec.strPhone
			,strTimeZone = ''
			,strLocation = el.strCity
			,strSLAPlan = ''
			,strReplyDue = ''
			,intUserId = en.intEntityId
			,strName = ec.strEmail
			,strUserName = ec.strEmail
			,strFirstName = ec.strEmail
			,strMiddleName = ec.strEmail
			,strLastName = ec.strEmail
			,strEmail = ec.strEmail
			,ysni21User = 0
			,imgPhoto = ec.imgContactPhoto
			,intConcurrencyId = 1
		from
			tblEntityContact ec
			left outer join tblARCustomer cus on cus.intEntityId = (select et.intEntityId from tblEntityToContact et where et.intContactId = ec.intEntityId)
			left outer join tblEntity en on en.intEntityId = (select et.intEntityId from tblEntityToContact et where et.intEntityToContactId = ec.intEntityId)
			left outer join tblEntityLocation el on el.intEntityId = (select et.intEntityId from tblEntityToContact et where et.intEntityToContactId = ec.intEntityId)