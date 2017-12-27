CREATE VIEW [dbo].[vyuTFGetTaxAuthorityBeginEndInventoryDetail]

AS

SELECT Detail.intTaxAuthorityBeginEndInventoryDetailId
	, Detail.intTaxAuthorityBeginEndInventoryId
	, Header.intTaxAuthorityId
	, TA.strTaxAuthorityCode
	, strTADescription = TA.strDescription
	, Header.dtmBeginDate
	, Header.dtmEndDate
	, Detail.intProductCodeId
	, PC.strProductCode
	, strProductCodeDescription = PC.strDescription
	, Detail.dblBeginInventory
	, Detail.dblEndInventory
	, Detail.intConcurrencyId
FROM tblTFTaxAuthorityBeginEndInventoryDetail Detail
LEFT JOIN tblTFTaxAuthorityBeginEndInventory Header ON Header.intTaxAuthorityBeginEndInventoryId = Detail.intTaxAuthorityBeginEndInventoryId
LEFT JOIN tblTFProductCode PC ON PC.intProductCodeId = Detail.intProductCodeId AND Header.intTaxAuthorityId = PC.intTaxAuthorityId
LEFT JOIN tblTFTaxAuthority TA ON TA.intTaxAuthorityId = Header.intTaxAuthorityId