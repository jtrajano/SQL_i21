CREATE VIEW [dbo].[vyuCRMAllLocation]
	AS
		select intId = ROW_NUMBER() over (order by strLocationName asc), * from
		(
		select intCustomerId = 0, intCompanyLocationId, strLocationName, strAddress, ysnIsContactLocation = convert(bit,0) from tblSMCompanyLocation
		union all
		select intCustomerId = intEntityId, intCompanyLocationId = intEntityLocationId, strLocationName, strAddress, ysnIsContactLocation = convert(bit,1)  from tblEMEntityLocation
		) as result
