CREATE VIEW [dbo].[vyuARGetRecipe]
AS
SELECT R.intRecipeId
     , R.intItemId
	 , I.strItemNo
	 , I.strDescription
	 , R.[intItemUOMId]
	 , UOM.strUnitMeasure
	 , R.intLocationId AS intCompanyLocationId
	 , L.strLocationName
	 , R.dblQuantity
	 , R.intVersionNo
	 , R.intManufacturingCellId
	 , MC.strCellName
	 , R.intManufacturingProcessId
	 , MP.strProcessName
	 , R.intCustomerId AS intEntityCustomerId
	 , E.strEntityNo AS strCustomerNumber	 
FROM tblMFRecipe R
	LEFT JOIN tblICItem I ON R.intItemId = I.intItemId
	LEFT JOIN vyuARItemUOM UOM ON R.[intItemUOMId] = UOM.intItemUOMId
	LEFT JOIN tblSMCompanyLocation L ON R.intLocationId = L.intCompanyLocationId
	LEFT JOIN tblMFManufacturingCell MC ON R.intManufacturingCellId = MC.intManufacturingCellId
	LEFT JOIN tblMFManufacturingProcess MP ON R.intManufacturingProcessId = MP.intManufacturingProcessId
	LEFT JOIN (vyuARCustomer C INNER JOIN tblEntity E ON C.intEntityCustomerId = E.intEntityId) ON R.intCustomerId = C.intEntityCustomerId
WHERE R.ysnActive = 1