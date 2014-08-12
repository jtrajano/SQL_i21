CREATE VIEW [dbo].[vyuHDCustomerDetail]
	AS 
	select
			strCustomer = ''
			,strFullName = ''
			,strPhone = ''
			,strTimeZone = ''
			,strLocation = ''
			,strSLAPlan = ''
			,strReplyDue = ''
			,intUserId = 0
			,strName = ''
			,strUserName = ''
			,strFirstName = ''
			,strMiddleName = ''
			,strLastName = ''
			,strEmail = ''
			,ysni21User = 0
			,imgPhoto = null
			,intConcurrencyId = 1
		--select
		--	strCustomer = cus.strCustomerNumber
		--	,strFullName = ec.strEmail
		--	,strPhone = ec.strPhone
		--	,strTimeZone = ''
		--	,strLocation = el.strCity
		--	,strSLAPlan = ''
		--	,strReplyDue = ''
		--	,intUserId = en.intEntityId
		--	,strName = ec.strEmail
		--	,strUserName = ec.strEmail
		--	,strFirstName = ec.strEmail
		--	,strMiddleName = ec.strEmail
		--	,strLastName = ec.strEmail
		--	,strEmail = ec.strEmail
		--	,ysni21User = 0
		--	,imgPhoto = ec.imgContactPhoto
		--	,intConcurrencyId = 1
		--from
		--	tblARCustomer cus
		--	left outer join tblEntityContact ec on ec.intEntityId = cus.intEntityId
		--	left outer join tblEntity en on en.intEntityId = cus.intEntityId
		--	left outer join tblEntityLocation el on el.intEntityId = cus.intEntityId
