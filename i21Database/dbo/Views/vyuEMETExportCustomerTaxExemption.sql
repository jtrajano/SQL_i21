CREATE VIEW [dbo].[vyuEMETExportCustomerTaxExemption]
	AS 

	SELECT 
		CustomerNumber = a.CustomerNumber,
		ItemNumber = a.strItemNo,
		state =Substring(c.strTaxGroup, 1, 2),
		Authority1 = c.intTaxGroupId,
		Authority2 = '',
		FETCharge = CASE WHEN b.strTaxCodeReference = 'FET' THEN 'Y' ELSE 'N' END,
		SETCharge = CASE WHEN b.strTaxCodeReference = 'SET' THEN 'Y' ELSE 'N' END,
		SSTCharge = CASE WHEN b.strTaxCodeReference = 'SST' THEN 'Y' ELSE 'N' END,
		Locale1Charge = CASE WHEN b.strTaxCodeReference = 'LC1' THEN 'Y' ELSE 'N' END,
		Locale2Charge = CASE WHEN b.strTaxCodeReference = 'LC2' THEN 'Y' ELSE 'N' END ,
		Locale3Charge = CASE WHEN b.strTaxCodeReference = 'LC3' THEN 'Y' ELSE 'N' END,
		Locale4Charge = CASE WHEN b.strTaxCodeReference = 'LC4' THEN 'Y' ELSE 'N' END,
		Locale5Charge = CASE WHEN b.strTaxCodeReference = 'LC5' THEN 'Y' ELSE 'N' END,
		Locale6Charge = CASE WHEN b.strTaxCodeReference = 'LC6' THEN 'Y' ELSE 'N' END


	 FROM (

		select 
		CustomerNumber = bb.strEntityNo,
		strItemNo = f.strItemNo,
		intTaxCodeId = e.intTaxCodeId,
		state = e.strState,
		autho1 = isnull(c.intTaxGroupId, d.intTaxGroupId),


		'1' as id
		from tblARCustomer a
			join vyuEMEntityType b
				on a.[intEntityId] = b.intEntityId
			join tblEMEntity bb
				on a.[intEntityId] = bb.intEntityId
			join tblEMEntityLocation c
				on a.[intEntityId] = c.intEntityId and c.ysnDefaultLocation = 1 and c.intTaxGroupId in (select intTaxGroupId from tblETExportFilterTaxGroup)
			join tblSMCompanyLocation d
				on c.intWarehouseId = d.intCompanyLocationId and d.intTaxGroupId is not null
			join tblARCustomerTaxingTaxException e
				on e.intEntityCustomerId = a.[intEntityId] and e.intItemId is not null and e.intCategoryId is not null
			join tblICItem f
				on e.intItemId = f.intItemId
			--join tblETExportFilterItem g
			--	on g.intItemId = f.intItemId
			--join tblETExportFilterCategory h
			--	on h.intCategoryId = e.intCategoryId	
		where e.intItemId in (select intItemId from tblETExportFilterItem) or e.intCategoryId in (select intCategoryId from tblETExportFilterCategory )


		union

		select 
		CustomerNumber = bb.strEntityNo,
		strItemNo = f.strItemNo,
		intTaxCodeId = e.intTaxCodeId,
		state = e.strState,

		autho1 = isnull(c.intTaxGroupId, d.intTaxGroupId),

		'2' as id
		from tblARCustomer a
			join vyuEMEntityType b
				on a.[intEntityId] = b.intEntityId
			join tblEMEntity bb
				on a.[intEntityId] = bb.intEntityId
			join tblEMEntityLocation c
				on a.[intEntityId] = c.intEntityId and c.ysnDefaultLocation = 1 and c.intTaxGroupId in (select intTaxGroupId from tblETExportFilterTaxGroup)
			join tblSMCompanyLocation d
				on c.intWarehouseId = d.intCompanyLocationId and d.intTaxGroupId is not null
			join tblARCustomerTaxingTaxException e
				on e.intEntityCustomerId = a.[intEntityId] and e.intCategoryId is not null and e.intItemId is null
			join tblICItem f
				on f.intCategoryId = e.intCategoryId
			--join tblETExportFilterItem g
			--	on f.intItemId = g.intItemId
			--join tblETExportFilterCategory h
			--	on h.intCategoryId = e.intCategoryId
			where e.intItemId in (select intItemId from tblETExportFilterItem) or e.intCategoryId in (select intCategoryId from tblETExportFilterCategory )
		union	

		select 
		CustomerNumber = bb.strEntityNo,
		strItemNo = g.strItemNo,
		intTaxCodeId = e.intTaxCodeId,
		state = e.strState,
		autho1 = isnull(c.intTaxGroupId, d.intTaxGroupId),
		'3' as id
		from tblARCustomer a
			join vyuEMEntityType b
				on a.[intEntityId] = b.intEntityId
			join tblEMEntity bb
				on a.[intEntityId] = bb.intEntityId
			join tblEMEntityLocation c
				on a.[intEntityId] = c.intEntityId and c.ysnDefaultLocation = 1 and c.intTaxGroupId in (select intTaxGroupId from tblETExportFilterTaxGroup)
			join tblSMCompanyLocation d
				on c.intWarehouseId = d.intCompanyLocationId and d.intTaxGroupId is not null
			join tblARCustomerTaxingTaxException e
				on e.intEntityCustomerId = a.[intEntityId] and e.intCategoryId is null and e.intItemId is null
			left join tblETExportFilterItem f
				on e.intItemId is null and e.intCategoryId is null
			left join tblICItem g
				on g.intItemId = f.intItemId
	
	) a
		left join tblETExportTaxCodeMapping b
			on a.intTaxCodeId = b.intTaxCodeId
		left join tblSMTaxGroup c
			on c.intTaxGroupId = a.autho1
	--order by a.strItemNo

--	select 
--		CustomerNumber = bb.strEntityNo,
--		ItemNumber = d.strItemNo,
--		state = a.strState,
--		Authority1 = '',
--		Authority2 = '',
--		FETCharge = CASE WHEN e.strTaxCodeReference = 'FET' THEN 'Y' ELSE 'N' END,
--		SETCharge = CASE WHEN e.strTaxCodeReference = 'SET' THEN 'Y' ELSE 'N' END,
--		SSTCharge = CASE WHEN e.strTaxCodeReference = 'SST' THEN 'Y' ELSE 'N' END,
--		Locale1Charge = CASE WHEN e.strTaxCodeReference = 'LC1' THEN 'Y' ELSE 'N' END,
--		Locale2Charge = CASE WHEN e.strTaxCodeReference = 'LC2' THEN 'Y' ELSE 'N' END ,
--		Locale3Charge = CASE WHEN e.strTaxCodeReference = 'LC3' THEN 'Y' ELSE 'N' END,
--		Locale4Charge = CASE WHEN e.strTaxCodeReference = 'LC4' THEN 'Y' ELSE 'N' END,
--		Locale5Charge = CASE WHEN e.strTaxCodeReference = 'LC5' THEN 'Y' ELSE 'N' END,
--		Locale6Charge = CASE WHEN e.strTaxCodeReference = 'LC6' THEN 'Y' ELSE 'N' END
		 
--from tblARCustomerTaxingTaxException a
--	join tblARCustomer b
--		on a.intEntityCustomerId = b.intEntityCustomerId
--	join tblEMEntity bb
--		on b.intEntityCustomerId = bb.intEntityId
--	join vyuEMEntityType c
--		on c.intEntityId = b.intEntityCustomerId and Customer = 1
--	left join tblICItem d
--		on a.intItemId = d.intItemId
--	left join tblETExportTaxCodeMapping e
--		on a.intTaxCodeId = e.intTaxCodeId