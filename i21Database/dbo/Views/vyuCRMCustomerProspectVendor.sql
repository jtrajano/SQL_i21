CREATE VIEW [dbo].[vyuCRMCustomerProspectVendor]
	AS
		select
			intEntityCustomerId
			,strCustomerNumber
			,strName
			,strType = (case when SUBSTRING(strType,1,1) = ',' then SUBSTRING(strType,2,len(strType)) when SUBSTRING(strType,len(strType),1) = ',' then SUBSTRING(strType,1,len(strType)-1) else strType end)
			,ysnActive
		from
		(
			select
				intEntityCustomerId = a.intEntityId
				,strCustomerNumber = a.strEntityNo
				,strName = a.strName
				,strType = (case when d.strType is null or LTRIM(RTRIM(d.strType)) = '' then '' else d.strType end) + ',' + (case when e.strType is null or LTRIM(RTRIM(d.strType)) = '' then '' else e.strType end)
				,ysnActive = a.ysnActive
			from
				tblEMEntity a
				left join tblEMEntityType d on d.intEntityId = a.intEntityId and d.strType = 'Customer'
				left join tblEMEntityType e on e.intEntityId = a.intEntityId and e.strType = 'Vendor'
			where
				a.intEntityId in (select b.intEntityVendorId from tblAPVendor b union select c.intEntityCustomerId from tblARCustomer c)
		) as result
