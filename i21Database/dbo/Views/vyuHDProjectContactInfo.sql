CREATE VIEW [dbo].[vyuHDProjectContactInfo]
	AS
	select
		tblHDProjectContactInfo.intProjectContactInfoId
		,tblHDProjectContactInfo.intProjectId
		,tblHDProjectContactInfo.intEntityId
		,tblEntity.strName
		,tblEntity.strTitle
		,tblEntityLocation.strLocationName
		,tblHDProjectContactInfo.strDecisionRole
		,tblHDProjectContactInfo.strAttitude
		,tblHDProjectContactInfo.strExtent
		,tblHDProjectContactInfo.strConcerns
		,tblHDProjectContactInfo.strExpectations
		,tblHDProjectContactInfo.intSort
		,tblHDProjectContactInfo.intConcurrencyId
	from tblHDProjectContactInfo
		,tblEntity
		,tblEntityToContact
		,tblEntityLocation
	where
		tblEntity.intEntityId = tblHDProjectContactInfo.intEntityId
		and tblEntityToContact.intEntityContactId = tblEntity.intEntityId
		and tblEntityLocation.intEntityLocationId = tblEntityToContact.intEntityLocationId
