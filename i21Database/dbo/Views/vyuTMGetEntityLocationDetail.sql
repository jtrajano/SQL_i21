CREATE VIEW [dbo].[vyuTMGetEntityLocationDetail]
AS 

SELECT 
    A.intEntityLocationId
    ,A.strZipCode
	,A.strCity
	,A.strState
	,A.strCounty
	,A.strCountry
	,A.dblLatitude
	,A.dblLongitude
	,A.intTaxGroupId
	,B.strTaxGroup
	,A.strAddress
	,A.strLocationRoute
	,A.strPricingLevel
	,A.intTermsId
	,C.strTerm
FROM tblEMEntityLocation A
LEFT JOIN tblSMTaxGroup B
	ON A.intTaxGroupId = B.intTaxGroupId
LEFT JOIN tblSMTerm C
	ON A.intTermsId = C.intTermID

GO