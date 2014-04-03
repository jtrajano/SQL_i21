IF EXISTS(select top 1 1 from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vyuHDUserDetail')
	DROP VIEW vyuHDUserDetail

-- GRAINS DEPENDENT
IF  (SELECT TOP 1 ysnUsed FROM ##tblOriginMod WHERE strPrefix = 'HD' and strDBName = db_name()) = 1
	EXEC ('
		CREATE VIEW [dbo].[vyuCPStorage]
		AS
		select
			strCustomer = ''i21 User''
			,us.strFullName
			,us.strPhone
			,strTimeZone = ''''
			,strSLAPlan = ''''
			,strReplyDue = ''''
			,intUserId = us.intUserSecurityID
			,ur.strName
			,us.strUserName
			,us.strFirstName
			,us.strMiddleName
			,us.strLastName
			,us.strEmail
			,ysni21User = 1
			,intConcurrencyId = 1
		from
			tblSMUserSecurity us,
			tblSMUserRole ur
		where
			ur.intUserRoleID = us.intUserRoleID
		
		union all

		select
			strCustomerNumber = cus.strCustomerNumber
			,strFullName = ec.strEmail
			,strPhone = ec.strPhone
			,strTimeZone = ''''
			,strSLAPlan = ''''
			,strReplyDue = ''''
			,intUserId = en.intEntityId
			,strName = ec.strEmail
			,strUserName = ec.strEmail
			,strFirstName = ec.strEmail
			,strMiddleName = ec.strEmail
			,strLastName = ec.strEmail
			,strEmail = ec.strEmail
			,ysni21User = 0
			,intConcurrencyId = 1
		from
			tblEntity en,
			tblEntityContact ec,
			tblARCustomer cus
		where
			cus.intEntityId = en.intEntityId
			and ec.intEntityId = en.intEntityId
		')
