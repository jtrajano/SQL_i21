CREATE VIEW [dbo].[vyuTFGetTaxAuthorityCountyLocation]
	AS
	
SELECT TACL.intTaxAuthorityCountyLocationId
	, TA.intTaxAuthorityId
	, TA.strTaxAuthorityCode
	, CL.intCountyLocationId
	, CL.strCounty
	, CL.strLocation
FROM tblTFTaxAuthorityCountyLocation TACL
LEFT JOIN tblTFTaxAuthority TA ON TA.intTaxAuthorityId = TACL.intTaxAuthorityId
LEFT JOIN tblTFCountyLocation CL ON CL.intCountyLocationId = TACL.intCountyLocationId
