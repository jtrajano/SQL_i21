CREATE VIEW [dbo].[vyuCRMOpportunitySalesrepAndLob]
AS
	SELECT  intId				= intLineOfBusinessId
		   ,intEntityId         = LineOfBusiness.intEntityId
		   ,strEntityName       = Entity.strName
		   ,intSalespersonId    = LineOfBusiness.intEntityId
		   ,strSalespersonName  = Entity.strName
		   ,intLineOfBusinessId = LineOfBusiness.intLineOfBusinessId
		   ,strLineOfBusiness   = LineOfBusiness.strLineOfBusiness
	FROM tblSMLineOfBusiness LineOfBusiness
		INNER JOIN tblEMEntity Entity
	ON Entity.intEntityId = LineOfBusiness.intEntityId

GO
