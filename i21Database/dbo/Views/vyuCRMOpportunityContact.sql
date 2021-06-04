CREATE VIEW [dbo].[vyuCRMOpportunityContact]
	AS
	select
		tblCRMOpportunityContact.intOpportunityContactId
		,tblCRMOpportunityContact.intOpportunityId
		,tblCRMOpportunityContact.intEntityId
		,tblEMEntity.strName
		,tblEMEntity.strTitle
		,[tblEMEntityLocation].strLocationName
		,tblCRMOpportunityContact.strDecisionRole
		,tblCRMOpportunityContact.strAttitude
		,tblCRMOpportunityContact.strExtent
		,tblCRMOpportunityContact.strConcerns
		,tblCRMOpportunityContact.strExpectations
		,tblCRMOpportunityContact.intSort
		,tblCRMOpportunityContact.intConcurrencyId
	from tblCRMOpportunityContact
		inner join tblEMEntity on tblEMEntity.intEntityId = tblCRMOpportunityContact.intEntityId
		inner join [tblEMEntityToContact] on [tblEMEntityToContact].intEntityContactId = tblEMEntity.intEntityId
		inner join [tblEMEntityLocation] on [tblEMEntityLocation].intEntityLocationId = [tblEMEntityToContact].intEntityLocationId