CREATE VIEW [dbo].[vyuHDEntityLineOfBusiness]
	AS
	SELECT intEntityLineOfBusinessId	= a.intEntityLineOfBusinessId
	      ,intCustomerId				= a.intEntityId
		  ,intLineOfBusinessId			= a.intLineOfBusinessId
		  ,strLineOfBusiness			= b.strLineOfBusiness
		  ,intSalespersonId				= a.intEntitySalespersonId
		  ,strSalesperson				= c.strName
		  ,intConcurrencyId				= 1
	FROM tblEMEntityLineOfBusiness a
		INNER JOIN tblSMLineOfBusiness b on b.intLineOfBusinessId = a.intLineOfBusinessId
		LEFT JOIN tblEMEntity c on c.intEntityId = a.intEntitySalespersonId
GO