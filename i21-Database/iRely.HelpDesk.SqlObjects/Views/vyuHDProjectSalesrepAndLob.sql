CREATE VIEW [dbo].[vyuHDProjectSalesrepAndLob]
	AS
		Select intId = convert(int,ROW_NUMBER() over (order by intEntityId)),intEntityId,strEntityName,intSalespersonId,strSalespersonName,intLineOfBusinessId,strLineOfBusiness from 
		(
		select a.intEntityId, strEntityName = a.strName, intSalespersonId = b.intSalespersonId, strSalespersonName = c.strName, intLineOfBusinessId = 0, strLineOfBusiness = 'Default'
		from tblARCustomer b 
		left join tblEMEntity a on b.intEntityId = a.intEntityId
		left join tblEMEntity c on c.intEntityId = b.intSalespersonId
		where b.intSalespersonId not in (
			select d.intEntitySalespersonId
			from tblEMEntity e
			left join tblEMEntityLineOfBusiness d on d.intEntityId = e.intEntityId
			left join tblEMEntity f on f.intEntityId = d.intEntitySalespersonId
			left join tblSMLineOfBusiness g on g.intLineOfBusinessId = d.intLineOfBusinessId
			where e.intEntityId = b.intEntityId
		)
		--where b.intEntityId in (119,1150)
		union all
		select e.intEntityId, strEntityName = e.strName, intSalespersonId = d.intEntitySalespersonId, strSalespersonName = f.strName, d.intLineOfBusinessId, strLineOfBusiness = g.strLineOfBusiness
		from tblEMEntity e
		left join tblEMEntityLineOfBusiness d on d.intEntityId = e.intEntityId
		left join tblEMEntity f on f.intEntityId = d.intEntitySalespersonId
		left join tblSMLineOfBusiness g on g.intLineOfBusinessId = d.intLineOfBusinessId
		--where e.intEntityId in (119,1150)
		) as queryResult
