CREATE VIEW [dbo].[vyuARSpecialPricingEndpoint]
	AS 
SELECT
	SP.intSpecialPriceId
	,SP.intEntityCustomerId
	,Customer.strEntityNo strCustomerEntityNo
	,Customer.strName strCustomerName
	,SP.intCustomerLocationId
	,Loc.strLocationName strCustomerLocation
	,SP.intItemId
	,I.strItemNo
	,SP.dblDeviation
FROM
	tblARCustomerSpecialPrice SP
INNER JOIN
	tblARCustomer C
		ON SP.intEntityCustomerId = C.[intEntityId]
INNER JOIN
	tblEMEntity Customer 
		ON Customer.intEntityId = C.intEntityId
LEFT JOIN 
	tblEMEntityLocation Loc 
		ON Loc.intEntityLocationId = SP.intCustomerLocationId
LEFT JOIN
	tblICItem I
		ON I.intItemId = SP.intItemId