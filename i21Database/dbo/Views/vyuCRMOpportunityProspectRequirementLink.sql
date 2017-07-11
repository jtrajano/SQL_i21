CREATE VIEW [dbo].[vyuCRMOpportunityProspectRequirementLink]
	AS
		select
			a.*
			,b.intLineOfBusinessId
			,b.strLineOfBusiness
			,b.intModuleId
			,b.strModule
			,b.strQuestionType
			,b.strQuestion
			,c.strName
		from
			tblCRMOpportunityPropectRequirement a
			left join vyuCRMProspectRequirementLink b on b.intProspectRequirementId = a.intProspectRequirementId
			left join tblEMEntity c on c.intEntityId = a.intEntityId
