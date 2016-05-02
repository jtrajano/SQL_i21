CREATE VIEW [dbo].[vyuHDOpportunityCampaignSearch]
	AS
	select
		tblHDOpportunityCampaign.*
		,tblEMEntity.strName
		,tblHDLineOfBusiness.strLineOfBusiness
		,tblHDTicketType.strType
	from
		tblHDOpportunityCampaign
		left outer join tblEMEntity on tblEMEntity.intEntityId = tblHDOpportunityCampaign.intEntityId
		left outer join tblHDLineOfBusiness on tblHDLineOfBusiness.intLineOfBusinessId = tblHDOpportunityCampaign.intLineOfBusinessId
		left outer join tblHDTicketType on tblHDTicketType.intTicketTypeId = tblHDOpportunityCampaign.intTicketTypeId
