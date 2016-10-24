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
		,tblEMEntity
		,[tblEMEntityToContact]
		,[tblEMEntityLocation]
	where
		tblEMEntity.intEntityId = tblCRMOpportunityContact.intEntityId
		and [tblEMEntityToContact].intEntityContactId = tblEMEntity.intEntityId
		and [tblEMEntityLocation].intEntityLocationId = [tblEMEntityToContact].intEntityLocationId
