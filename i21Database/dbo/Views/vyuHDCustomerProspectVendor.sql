CREATE VIEW [dbo].[vyuHDCustomerProspectVendor]
	AS
		select
			intEntityCustomerId = b.intEntityId
			,strCustomerNumber = a.strVendorId
			,strName = b.strName
			,strType = c.strType
			,ysnActive = b.ysnActive
		from
			tblAPVendor a
			,tblEMEntity b
			,tblEMEntityType c
		where b.intEntityId = a.intEntityVendorId
			and c.intEntityId = b.intEntityId

		union all

		select
			intEntityCustomerId = b.intEntityId
			,strCustomerNumber = a.strCustomerNumber
			,strName = b.strName
			,strType = c.strType
			,ysnActive = b.ysnActive
		from
			tblARCustomer a
			,tblEMEntity b
			,tblEMEntityType c
		where b.intEntityId = a.intEntityCustomerId
			and c.intEntityId = b.intEntityId