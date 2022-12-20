CREATE VIEW [dbo].[vyuHDEntityLineOfBusiness]
	AS
	SELECT intEntityLineOfBusinessId	= a.intEntityLineOfBusinessId
	      ,intCustomerId				= a.intEntityId
		  ,intLineOfBusinessId			= a.intLineOfBusinessId
		  ,strLineOfBusiness			= b.strLineOfBusiness
		  ,intSalespersonId				= COALESCE(a.intEntitySalespersonId, d.intSalespersonId)
		  ,strSalesperson				= COALESCE(c.strName, e.strName)
		  ,intConcurrencyId				= 1
	FROM tblEMEntityLineOfBusiness a
		INNER JOIN tblSMLineOfBusiness b on b.intLineOfBusinessId = a.intLineOfBusinessId
		LEFT JOIN tblEMEntity c on c.intEntityId = a.intEntitySalespersonId
		LEFT JOIN tblARCustomer d on d.intEntityId = a.intEntityId
		LEFT JOIN tblEMEntity e on e.intEntityId = d.intSalespersonId
GO