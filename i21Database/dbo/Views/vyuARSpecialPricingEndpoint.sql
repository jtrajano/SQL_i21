CREATE VIEW [dbo].[vyuARSpecialPricingEndpoint]
AS 
SELECT intSpecialPriceId		= SP.intSpecialPriceId
	 , intEntityCustomerId		= SP.intEntityCustomerId
	 , strCustomerEntityNo		= Customer.strEntityNo 
	 , strCustomerName			= Customer.strName 
	 , intCustomerLocationId	= SP.intCustomerLocationId
	 , strCustomerLocation		= Loc.strLocationName 
	 , intItemId				= SP.intItemId
	 , strItemNo				= I.strItemNo
	 , dblDeviation 			= ISNULL(SP.dblDeviation, 0) + ISNULL(SP.dblDeviation2, 0) + ISNULL(SP.dblDeviation3, 0) + ISNULL(SP.dblDeviation4, 0)
FROM tblARCustomerSpecialPrice SP
INNER JOIN tblARCustomer C ON SP.intEntityCustomerId = C.[intEntityId]
INNER JOIN tblEMEntity Customer ON Customer.intEntityId = C.intEntityId
LEFT JOIN tblEMEntityLocation Loc ON Loc.intEntityLocationId = SP.intCustomerLocationId
LEFT JOIN tblICItem I ON I.intItemId = SP.intItemId