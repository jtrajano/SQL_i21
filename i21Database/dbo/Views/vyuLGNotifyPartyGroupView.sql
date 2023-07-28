CREATE VIEW [dbo].[vyuLGNotifyPartyGroupView]
AS
SELECT 
	N.[intNotifyPartyGroupId],
	N.[intCountryId],
	N.[strDestinationPort],
	N.[strSubLocationName],
	N.[intConcurrencyId],
	NG.intNotifyPartyGroupDetailId,
	NG.intBankId,
	NG.intCompanyLocationId,
	NG.intCompanySetupID,
	NG.intEntityId,
	NG.intEntityLocationId,
	NG.strNotifyOrConsignee,
	NG.strType,
	NG.strParty,
	NG.strPartyLocation,
	NG.strAddress,
	NG.strCity,
	NG.strState,
	NG.strCountry,
	strOriginCountry = C.strCountry
FROM tblLGNotifyPartyGroup N
INNER JOIN vyuLGNotifyPartyGroup NG ON NG.intNotifyPartyGroupId = N.intNotifyPartyGroupId
LEFT JOIN tblSMCountry C ON C.intCountryID = N.intCountryId