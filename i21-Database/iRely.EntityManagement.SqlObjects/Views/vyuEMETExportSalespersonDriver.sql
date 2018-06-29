CREATE VIEW [dbo].[vyuEMETExportSalespersonDriver]
	AS 
select 
	case when a.strSalespersonId <> '' then a.strSalespersonId else RIGHT(c.strEntityNo, 3) end as bp_no,
	c.strName as bpname,
	dbo.fnEMSplitWithGetByIdx(b.strAddress, CHAR(10), 1) as addr1,
	dbo.fnEMSplitWithGetByIdx(b.strAddress, CHAR(10), 2) as addr2,
	dbo.fnEMSplitWithGetByIdx(b.strAddress, CHAR(10), 3) as addr3,
	b.strZipCode zip,
	b.strState [state],
	b.strCity [city],
	'' as Authority1,
	'' as Authority2
	from tblARSalesperson a
	join tblEMEntityLocation b
		on a.[intEntityId] = b.intEntityId
	join tblEMEntity c
		on a.[intEntityId] = c.intEntityId
	join tblETExportFilterDriver d
		on a.[intEntityId] = d.intEntitySalesPersonId
	where a.strType = 'Driver'


union all

select 
	RIGHT(RTRIM(LTRIM(isnull(a.strLocationNumber,''))), 3) bp_no,
	a.strLocationName as bpname,
	dbo.fnEMSplitWithGetByIdx(a.strAddress, CHAR(10), 1) as addr1,
	dbo.fnEMSplitWithGetByIdx(a.strAddress, CHAR(10), 2) as addr2,
	dbo.fnEMSplitWithGetByIdx(a.strAddress, CHAR(10), 3) as addr3,
	a.strZipPostalCode zip,
	a.strStateProvince [state],
	a.strCity [city],
	'' as Authority1,
	'' as Authority2
	from tblSMCompanyLocation a
		join tblETExportFilterLocation b
			on a.intCompanyLocationId = b.intCompanyLocationId