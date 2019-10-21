CREATE VIEW [dbo].[vyuHDCustomerDetail]
	AS 
	select
			strCustomer = '' COLLATE Latin1_General_CI_AS
			,strFullName = '' COLLATE Latin1_General_CI_AS
			,strPhone = '' COLLATE Latin1_General_CI_AS
			,strTimeZone = '' COLLATE Latin1_General_CI_AS
			,strLocation = '' COLLATE Latin1_General_CI_AS
			,strSLAPlan = '' COLLATE Latin1_General_CI_AS
			,strReplyDue = '' COLLATE Latin1_General_CI_AS
			,intUserId = 0
			,strName = '' COLLATE Latin1_General_CI_AS
			,strUserName = '' COLLATE Latin1_General_CI_AS
			,strFirstName = '' COLLATE Latin1_General_CI_AS
			,strMiddleName = '' COLLATE Latin1_General_CI_AS
			,strLastName = '' COLLATE Latin1_General_CI_AS
			,strEmail = '' COLLATE Latin1_General_CI_AS
			,ysni21User = 0
			,imgPhoto = null
			,intConcurrencyId = 1
			,strEntityType = '' COLLATE Latin1_General_CI_AS
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
		--	left outer join tblEMEntityContact ec on ec.intEntityId = cus.intEntityId
		--	left outer join tblEMEntity en on en.intEntityId = cus.intEntityId
		--	left outer join tblEMEntityLocation el on el.intEntityId = cus.intEntityId
