CREATE VIEW [dbo].[vyuEMEntityGroupApproverUsage]
	AS 

	select 
			id = b.intApproverConfigurationDetailId,
			b.intValueId 
		from tblSMApproverConfigurationApprovalFor a 
			join tblSMApproverConfigurationDetail b
				on a.intScreenId = b.intScreenId and a.strApprovalFor = 'Entity Group'
