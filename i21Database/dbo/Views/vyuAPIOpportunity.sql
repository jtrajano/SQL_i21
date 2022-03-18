CREATE VIEW [dbo].[vyuAPIOpportunity]
AS

SELECT
      s.intOpportunityId
    , o.strDirection
    , s.strName
    , s.strEntityLocation
    , link.strCustomerLeadershipSponsor
    , link.strCustomerProjectManager
    , link.strInternalProjectManager
    , o.strOpportunityStatus
    , s.strSalesPerson
    , o.ysnCompleted
    , o.dtmGoLive
    , o.dtmClose
    , o.strCompetitorEntity
    , s.strSource
    , s.strSalesPipeStatus
    , s.strCampaignName
    , s.strCompanyLocation
    , link.strReferredBy
    , s.dtmCreated
    , s.strLinesOfBusiness
    , s.strProjectType
    , s.strCurrentSolution
    , o.ysnInitialDataCollectionComplete
    , s.strCustomerName
    , link.strContactName
    , contact.strPhone
    , link.strDescription strExecutiveUpdate
    , created.dtmDate dtmDateCreated
	, COALESCE(updated.dtmDate, created.dtmDate, s.dtmCreated) dtmDateLastUpdated
FROM vyuCRMOpportunitySearch s
JOIN tblCRMOpportunity o ON o.intOpportunityId = s.intOpportunityId
JOIN vyuCRMOpportunityLink link ON link.intOpportunityId = s.intOpportunityId
OUTER APPLY (
    SELECT TOP 1 strPhone 
    FROM vyuCRMOpportunityCustomerContact c 
    WHERE c.intEntityCustomerId = s.intCustomerId
        AND c.ysnActive = 1
) contact
OUTER APPLY (
	SELECT TOP 1 au.dtmDate
	FROM vyuApiRecordAudit au
	WHERE au.intRecordId = s.intOpportunityId
		AND au.strAction = 'Created'
		AND au.strNamespace = 'CRM.view.Opportunity'
) created
OUTER APPLY (
	SELECT TOP 1 au.dtmDate
	FROM vyuApiRecordAudit au
	WHERE au.intRecordId = s.intOpportunityId
		AND au.strAction = 'Updated'
		AND au.strNamespace = 'CRM.view.Opportunity'
) updated