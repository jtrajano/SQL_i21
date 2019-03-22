CREATE VIEW [dbo].[vyuHDProjectContactInfo]
	AS
	select
		tblHDProjectContactInfo.intProjectContactInfoId
		,tblHDProjectContactInfo.intProjectId
		,tblHDProjectContactInfo.intEntityId
		,tblEMEntity.strName
		,tblEMEntity.strTitle
		,[tblEMEntityLocation].strLocationName
		,tblHDProjectContactInfo.strDecisionRole
		,tblHDProjectContactInfo.strAttitude
		,tblHDProjectContactInfo.strExtent
		,tblHDProjectContactInfo.strConcerns
		,tblHDProjectContactInfo.strExpectations
		,tblHDProjectContactInfo.intSort
		,tblHDProjectContactInfo.intConcurrencyId
	from tblHDProjectContactInfo
		,tblEMEntity
		,[tblEMEntityToContact]
		,[tblEMEntityLocation]
	where
		tblEMEntity.intEntityId = tblHDProjectContactInfo.intEntityId
		and [tblEMEntityToContact].intEntityContactId = tblEMEntity.intEntityId
		and [tblEMEntityLocation].intEntityLocationId = [tblEMEntityToContact].intEntityLocationId
