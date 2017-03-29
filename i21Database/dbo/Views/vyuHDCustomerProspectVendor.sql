CREATE VIEW [dbo].[vyuHDCustomerProspectVendor]
	AS
		select
			intEntityCustomerId
			,strCustomerNumber
			,strName
			,strType
			,ysnActive
		from
		(
			select
				intEntityCustomerId = a.intEntityId
				,strCustomerNumber = a.strEntityNo
				,strName = a.strName
				,strType = (case when d.strType is null or LTRIM(RTRIM(d.strType)) = '' then '' else d.strType end)
						 + (case when e.strType is null or LTRIM(RTRIM(e.strType)) = '' then '' when d.strType is not null or LTRIM(RTRIM(d.strType)) <> '' then ',' + e.strType else e.strType end)
						 + (case when f.strType is null or LTRIM(RTRIM(f.strType)) = '' then '' when d.strType is not null or LTRIM(RTRIM(d.strType)) <> ''
																								  or e.strType is not null or LTRIM(RTRIM(e.strType)) <> '' then ',' + f.strType else f.strType end)
						 + (case when g.strType is null or LTRIM(RTRIM(g.strType)) = '' then '' when d.strType is not null or LTRIM(RTRIM(d.strType)) <> ''
																								  or e.strType is not null or LTRIM(RTRIM(e.strType)) <> ''
																								  or f.strType is not null or LTRIM(RTRIM(f.strType)) <> '' then ',' + g.strType else g.strType end)
						 + (case when h.strType is null or LTRIM(RTRIM(h.strType)) = '' then '' when d.strType is not null or LTRIM(RTRIM(d.strType)) <> ''
																								  or e.strType is not null or LTRIM(RTRIM(e.strType)) <> ''
																								  or f.strType is not null or LTRIM(RTRIM(f.strType)) <> ''
																								  or g.strType is not null or LTRIM(RTRIM(g.strType)) <> '' then ',' + h.strType else h.strType end)
						 + (case when i.strType is null or LTRIM(RTRIM(i.strType)) = '' then '' when d.strType is not null or LTRIM(RTRIM(d.strType)) <> ''
																								  or e.strType is not null or LTRIM(RTRIM(e.strType)) <> ''
																								  or f.strType is not null or LTRIM(RTRIM(f.strType)) <> ''
																								  or g.strType is not null or LTRIM(RTRIM(g.strType)) <> ''
																								  or h.strType is not null or LTRIM(RTRIM(h.strType)) <> '' then ',' + i.strType else i.strType end)
				,ysnActive = a.ysnActive
			from
				tblEMEntity a
				left join tblEMEntityType d on d.intEntityId = a.intEntityId and d.strType = 'Customer'
				left join tblEMEntityType e on e.intEntityId = a.intEntityId and e.strType = 'Vendor'
				left join tblEMEntityType f on f.intEntityId = a.intEntityId and f.strType = 'Prospect'
				left join tblEMEntityType g on g.intEntityId = a.intEntityId and g.strType = 'Competitor'
				left join tblEMEntityType h on h.intEntityId = a.intEntityId and h.strType = 'Partner'
				left join tblEMEntityType i on i.intEntityId = a.intEntityId and i.strType = 'Employee'
			where
				a.intEntityId in (select b.[intEntityId] from tblAPVendor b union select c.intEntityCustomerId from tblARCustomer c)
		) as result