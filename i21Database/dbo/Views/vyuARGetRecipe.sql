CREATE VIEW [dbo].[vyuARGetRecipe]
AS
SELECT DISTINCT
	 R.intRecipeId
     , R.intItemId
	 , I.strItemNo
	 , I.strDescription
	 , R.intItemUOMId
	 , UOM.strUnitMeasure
	 , intCompanyLocationId		= R.intLocationId
	 , L.strLocationName
	 , dblOrigQuantity			= R.dblQuantity
	 , R.dblQuantity
	 , R.intVersionNo
	 , R.intManufacturingProcessId
	 , MP.strProcessName
	 , intEntityCustomerId		= R.intCustomerId
	 , strCustomerNumber		= E.strEntityNo
	 , strRecipeName			= R.strName
	 , ysnHasLotted				= CONVERT(BIT, MAX(RII.ysnLotted))
FROM tblMFRecipe R
	INNER JOIN
	(
		SELECT I.intItemId
			 , RI.intRecipeId
			 , ysnLotted		= CASE WHEN UPPER(I.strLotTracking) = 'NO' THEN 0 ELSE 1 END
			 , I.strItemNo
		FROM tblMFRecipeItem RI
		INNER JOIN tblICItem I ON RI.intItemId = I.intItemId AND RI.intRecipeItemTypeId = 1  
	) RII ON R.intRecipeId = RII.intRecipeId
	LEFT JOIN tblICItem I ON R.intItemId = I.intItemId
	LEFT JOIN vyuARItemUOM UOM ON R.[intItemUOMId] = UOM.intItemUOMId
	LEFT JOIN tblSMCompanyLocation L ON R.intLocationId = L.intCompanyLocationId
	LEFT JOIN tblMFManufacturingProcess MP ON R.intManufacturingProcessId = MP.intManufacturingProcessId
	LEFT JOIN (vyuARCustomer C INNER JOIN tblEMEntity E ON C.[intEntityId] = E.intEntityId) ON R.intCustomerId = C.[intEntityId]
WHERE R.ysnActive = 1
GROUP BY R.intRecipeId
     , R.intItemId
	 , I.strItemNo
	 , I.strDescription
	 , R.intItemUOMId
	 , UOM.strUnitMeasure
	 , R.intLocationId
	 , L.strLocationName
	 , R.dblQuantity
	 , R.dblQuantity
	 , R.intVersionNo
	 , R.intManufacturingProcessId
	 , MP.strProcessName
	 , R.intCustomerId
	 , E.strEntityNo
	 , R.strName