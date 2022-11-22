CREATE VIEW [dbo].[vyuHDCustomerLineOfBusiness]
	AS
	SELECT		    intId				 = CONVERT(INT,ROW_NUMBER() OVER (ORDER BY Project.intProjectId))  
				   ,intEntityId          = SMLineOfBusiness.intEntityId
				   ,strEntityName        = Entity.strName
				   ,intSalespersonId     = SMLineOfBusiness.intEntityId
				   ,strSalespersonName   = Entity.strName
				   ,intLineOfBusinessId  = SMLineOfBusiness.intLineOfBusinessId
				   ,strLineOfBusiness    = SMLineOfBusiness.strLineOfBusiness
				   ,intProjectId		 = Project.intProjectId
	FROM tblHDProject Project
	OUTER APPLY
	(
		SELECT * 
		FROM [dbo].fnSplitStringWithTrim(Project.strLinesOfBusinessId, ',')
		WHERE ISNULL(Item, '') != ''
	) LineOfBusiness
	INNER JOIN tblSMLineOfBusiness SMLineOfBusiness
		ON SMLineOfBusiness.intLineOfBusinessId = convert(int,LineOfBusiness.Item)
	INNER JOIN tblEMEntity Entity
		ON Entity.intEntityId = SMLineOfBusiness.intEntityId
GO