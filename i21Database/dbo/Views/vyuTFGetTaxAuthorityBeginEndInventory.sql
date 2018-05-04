CREATE VIEW [dbo].[vyuTFGetTaxAuthorityBeginEndInventory]

AS

SELECT Detail.intTaxAuthorityBeginEndInventoryId
	, Detail.intTaxAuthorityId
	, TA.strTaxAuthorityCode
	, strTADescription = TA.strDescription
	, TA.dtmBeginDate
	, TA.dtmEndDate
	, Detail.intCompanyLocationId
	, [Location].strLocationName
	, [Location].strOregonFacilityNumber
	, Detail.intProductCodeId
	, PC.strProductCode
	, strProductCodeDescription = PC.strDescription
	, Detail.dblBeginInventory
	, Detail.dblEndInventory
	, Detail.intConcurrencyId
FROM tblTFTaxAuthorityBeginEndInventory Detail
LEFT JOIN tblTFProductCode PC ON PC.intProductCodeId = Detail.intProductCodeId AND Detail.intTaxAuthorityId = PC.intTaxAuthorityId
LEFT JOIN tblTFTaxAuthority TA ON TA.intTaxAuthorityId = Detail.intTaxAuthorityId
LEFT JOIN tblSMCompanyLocation  [Location] ON [Location].intCompanyLocationId  = Detail.intCompanyLocationId 