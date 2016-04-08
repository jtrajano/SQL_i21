CREATE VIEW [dbo].[vyuARGetRecipe]
AS
SELECT R.intRecipeId
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
FROM tblMFRecipe R
	LEFT JOIN tblICItem I ON R.intItemId = I.intItemId
	LEFT JOIN vyuARItemUOM UOM ON R.[intItemUOMId] = UOM.intItemUOMId
	LEFT JOIN tblSMCompanyLocation L ON R.intLocationId = L.intCompanyLocationId
	LEFT JOIN tblMFManufacturingProcess MP ON R.intManufacturingProcessId = MP.intManufacturingProcessId
	LEFT JOIN (vyuARCustomer C INNER JOIN tblEMEntity E ON C.intEntityCustomerId = E.intEntityId) ON R.intCustomerId = C.intEntityCustomerId
WHERE R.ysnActive = 1