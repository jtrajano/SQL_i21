CREATE VIEW [dbo].[vyuARCustomerTaxCode]
	AS 
	

SELECT 
	 C.intEntityCustomerId
	,C.strCustomerNumber 
	,C.ysnApplySalesTax
	,L.intEntityLocationId
	,L.strLocationName 
	,G.intTaxGroupId
	,G.strTaxGroup 
	,TG.ysnSeparateOnInvoice
	,TC.intTaxCodeId
	,TC.strTaxCode
	,TC.intSalesTaxAccountId  
	,TC.strCalculationMethod
	,TC.numRate
FROM
	tblEntityLocation L
INNER JOIN
	tblARCustomer C
		ON L.intEntityId = C.intEntityCustomerId 
		AND L.intEntityLocationId = C.intDefaultLocationId
INNER JOIN
	tblSMTaxGroup G
		ON L.intTaxCodeId = G.intTaxGroupId		
INNER JOIN
	tblSMTaxGroupCode TG
		ON G.intTaxGroupId = TG.intTaxGroupId
LEFT OUTER JOIN
	tblSMTaxCode TC
		ON TG.intTaxCodeId = TC.intTaxCodeId 		

