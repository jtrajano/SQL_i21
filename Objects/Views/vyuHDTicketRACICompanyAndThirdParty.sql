CREATE VIEW [dbo].[vyuHDTicketRACICompanyAndThirdParty]
	AS
	select intId = convert(int, ROW_NUMBER() over (order by intThirdPartyEntityId)), intThirdPartyEntityId, strThirdParty, intCompanyEntityId, strCompany, strEntityType from
	(
	select distinct intThirdPartyEntityId = b.intEntityId, strThirdParty = b.strName, intCompanyEntityId = b.intEntityId, strCompany = b.strName, strEntityType = a.strType from tblEMEntityType a, tblEMEntity b
	where b.intEntityId = a.intEntityId
	) as rawData
