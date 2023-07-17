CREATE VIEW [dbo].[vyuEMCustomerSpecialPriceSearch]
AS 
SELECT intEntityId				= SP.intEntityCustomerId
	 , intEntityCustomerId		= SP.intEntityCustomerId
	 , strCustomerLocation		= CL.strLocationName
	 , strPriceBasis			= SP.strPriceBasis
	 , strCostToUse				= SP.strCostToUse
	 , strVendorId				= V.strVendorId
	 , strItemNo				= I.strItemNo
	 , strItemDescription		= I.strDescription
	 , strVendorLocationName	= VL.strLocationName
	 , strCategoryCode			= CAT.strCategoryCode
	 , strCustomerGroup			= SP.strCustomerGroup
	 , dblDeviation				= ISNULL(SP.dblDeviation, 0) + ISNULL(SP.dblDeviation2, 0) + ISNULL(SP.dblDeviation3, 0) + ISNULL(SP.dblDeviation4, 0)
	 , strLineNote				= SP.strLineNote
	 , dtmBeginDate				= SP.dtmBeginDate
	 , dtmEndDate				= SP.dtmEndDate
	 , strVendorRankId			= VR.strVendorId
	 , strItemRankId			= IR.strItemNo
	 , strVendorRankLocationName = VLR.strLocationName
	 , strInvoiceType			= SP.strInvoiceType
	 , strName					= E.strName
	 , strEntityNo				= E.strEntityNo
	 , intWarehouseId			= ISNULL(EL.intWarehouseId, -99)
FROM tblARCustomerSpecialPrice SP
INNER JOIN tblEMEntity E ON SP.intEntityCustomerId = E.intEntityId			
INNER JOIN tblEMEntityLocation EL ON E.intEntityId = EL.intEntityId and EL.ysnDefaultLocation = 1	
LEFT JOIN tblEMEntityLocation CL ON CL.intEntityId = SP.intEntityCustomerId AND SP.intCustomerLocationId = CL.intEntityLocationId
LEFT JOIN tblAPVendor V ON V.intEntityId = SP.intEntityVendorId	
LEFT JOIN tblAPVendor VR ON VR.intEntityId = SP.intRackVendorId
LEFT JOIN tblICItem I ON I.intItemId = SP.intItemId
LEFT JOIN tblICItem IR ON IR.intItemId = SP.intRackItemId
LEFT JOIN tblEMEntityLocation VL ON VL.intEntityId = V.intEntityId AND VL.intEntityLocationId = SP.intEntityLocationId
LEFT JOIN tblEMEntityLocation VLR ON VLR.intEntityId = VR.intEntityId AND VLR.intEntityLocationId = SP.intRackLocationId
LEFT JOIN tblICCategory CAT ON CAT.intCategoryId = SP.intCategoryId
WHERE I.intItemId IS NOT NULL