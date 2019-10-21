CREATE VIEW [dbo].[vyuARCustomerTaxCode]
	AS 
	

SELECT 
	 C.[intEntityId]
	,C.strCustomerNumber 
	,C.ysnApplySalesTax
	,L.intEntityLocationId
	,L.strLocationName 
	,G.intTaxGroupId
	,G.strTaxGroup 
	,TC.intTaxCodeId
	,TC.strTaxCode
	,TC.intSalesTaxAccountId  
	--,TC.strCalculationMethod
	--,TC.numRate
FROM
	[tblEMEntityLocation] L
INNER JOIN
	tblARCustomer C
		ON L.intEntityId = C.[intEntityId] 
		AND L.intEntityLocationId = C.intDefaultLocationId
INNER JOIN
	tblSMTaxGroup G
		ON L.intTaxGroupId = G.intTaxGroupId		
INNER JOIN
	tblSMTaxGroupCode TG
		ON G.intTaxGroupId = TG.intTaxGroupId
LEFT OUTER JOIN
	tblSMTaxCode TC
		ON TG.intTaxCodeId = TC.intTaxCodeId 		

