CREATE VIEW [dbo].[vyuARGetCustomerTaxException]
AS
SELECT TE.intEntityCustomerId
	 , TE.intItemId
	 , TE.intEntityCustomerLocationId
	 , TE.intTaxCodeId
	 , TE.intTaxClassId
	 , TE.strState
	 , TE.strException
	 , TE.dtmStartDate
	 , TE.dtmEndDate
	 , ITEM.strItemNo
	 , ITEMCATEGORY.strCategoryCode
	 , ENTITYLOCATION.strLocationName
	 , TAXCODE.strTaxCode
	 , TAXCLASS.strTaxClass
FROM dbo.tblARCustomerTaxingTaxException TE WITH (NOLOCK)
LEFT JOIN (
	SELECT intItemId
		 , intCategoryId
		 , strItemNo
	FROM dbo.tblICItem WITH (NOLOCK)
) ITEM ON TE.intItemId = ITEM.intItemId
LEFT JOIN (
	SELECT intCategoryId
		 , strCategoryCode
	FROM dbo.tblICCategory
) ITEMCATEGORY ON ITEM.intCategoryId = ITEMCATEGORY.intCategoryId
LEFT JOIN (
	SELECT intEntityLocationId
		 , strLocationName
	FROM dbo.tblEMEntityLocation WITH (NOLOCK)
) ENTITYLOCATION ON TE.intEntityCustomerLocationId = ENTITYLOCATION.intEntityLocationId
LEFT JOIN (
	SELECT intTaxCodeId
		 , strTaxCode
	FROM dbo.tblSMTaxCode WITH (NOLOCK)
) TAXCODE ON TE.intTaxCodeId = TAXCODE.intTaxCodeId
LEFT JOIN (
	SELECT intTaxClassId
		 , strTaxClass
	FROM dbo.tblSMTaxClass WITH (NOLOCK)
) TAXCLASS ON TE.intTaxClassId = TAXCLASS.intTaxClassId