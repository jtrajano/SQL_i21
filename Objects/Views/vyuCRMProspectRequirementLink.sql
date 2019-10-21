CREATE VIEW [dbo].[vyuCRMProspectRequirementLink]
	AS
		select
			a.*, b.strModule, c.strLineOfBusiness
		from
			tblCRMProspectRequirement a
			left join tblSMModule b on b.intModuleId = a.intModuleId
			left join tblSMLineOfBusiness c on c.intLineOfBusinessId = a.intLineOfBusinessId
