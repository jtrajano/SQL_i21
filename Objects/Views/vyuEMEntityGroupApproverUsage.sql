CREATE VIEW [dbo].[vyuEMEntityGroupApproverUsage]
AS 
SELECT 
id = b.intApproverConfigurationDetailId,
b.intValueId 
FROM tblSMApproverConfigurationApprovalFor a 
JOIN tblSMApproverConfigurationDetail b
ON a.intScreenId = b.intScreenId and a.strApprovalFor = 'Entity Group'