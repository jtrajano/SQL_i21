CREATE VIEW [dbo].[vyuARSpecialPricingEndpoint]
	AS 
SELECT
	SP.intSpecialPriceId
	,SP.intEntityCustomerId
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
INNER JOIN 
	tblEMEntityLocation Loc 
		ON Loc.intEntityLocationId = SP.intCustomerLocationId AND Loc.intEntityId = SP.intEntityCustomerId
INNER JOIN
	tblICItem I
		ON I.intItemId = SP.intItemId
WHERE intCustomerLocationId IS NOT NULL
AND SP.intEntityVendorId IS NULL
