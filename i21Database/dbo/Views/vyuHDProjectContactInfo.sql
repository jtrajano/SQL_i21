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
		inner join tblEMEntity on tblEMEntity.intEntityId = tblHDProjectContactInfo.intEntityId
		inner join [tblEMEntityToContact] on [tblEMEntityToContact].intEntityContactId = tblEMEntity.intEntityId
		inner join [tblEMEntityLocation] on [tblEMEntityLocation].intEntityLocationId = [tblEMEntityToContact].intEntityLocationId
	