CREATE VIEW [dbo].[vyuHDMention]
	AS
	select
		strId = NEWID()
		,cu.intEntityCustomerId
		,cu.strCustomerNumber
		,intEntityContactId = con.intEntityId
		,con.strName
		,con.strEmail
	from
		tblARCustomer cu
		left outer join tblARCustomerToContact cc on cc.intEntityCustomerId = cu.intEntityCustomerId
		left outer join tblEntity con on con.intEntityId = cc.intEntityContactId and con.ysnActive = 1
	where cu.ysnActive = 1
	union all
	select
		strId = NEWID()
		,intEntityCustomerId = us.intEntityId
		,strCustomerNumber = 'INTERNALUSER'
		,intEntityContactId = con.intEntityId
		,con.strName
		,con.strEmail
	from
		tblSMUserSecurity us
		left outer join tblEntity con on con.intEntityId = us.intEntityId
	where us.ysnDisabled <> 1
