CREATE VIEW [dbo].[vyuCRMBrandIntegrationLog]
AS
	SELECT intBrandIntegrationLogId		= IntegrationLog.intBrandIntegrationLogId
		  ,intBrandId					= IntegrationLog.intBrandId
		  ,intOpportunityId				= IntegrationLog.intOpportunityId
		  ,dtmIntegrationDate			= IntegrationLog.dtmIntegrationDate
		  ,strAPIMessage				= IntegrationLog.strAPIMessage
		  ,strStatus					= IntegrationLog.strStatus
		  ,strAction					= IntegrationLog.strAction
		  ,strBrandName					= Brand.strBrand
		  ,strOpportunityName			= Opportunity.strName
	FROM tblCRMBrandIntegrationLog IntegrationLog
		INNER JOIN tblCRMBrand Brand
	ON Brand.intBrandId = IntegrationLog.intBrandId
		LEFT JOIN tblCRMOpportunity Opportunity
	ON Opportunity.intOpportunityId = IntegrationLog.intOpportunityId

GO