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
	 , hasLotted = max(ysnLotted)
FROM tblMFRecipe R
	INNER JOIN
	(
		select I.intItemId, RI.intRecipeId,
			ysnLotted   = case when UPPER(I.strLotTracking) = 'NO' then 0 else 1 end
		from tblMFRecipeItem RI
		inner join tblICItem I on RI.intItemId = I.intItemId
	)RII on R.intRecipeId = RII.intRecipeId
	LEFT JOIN tblICItem I ON R.intItemId = I.intItemId
	LEFT JOIN vyuARItemUOM UOM ON R.[intItemUOMId] = UOM.intItemUOMId
	LEFT JOIN tblSMCompanyLocation L ON R.intLocationId = L.intCompanyLocationId
	LEFT JOIN tblMFManufacturingProcess MP ON R.intManufacturingProcessId = MP.intManufacturingProcessId
	LEFT JOIN (vyuARCustomer C INNER JOIN tblEMEntity E ON C.intEntityCustomerId = E.intEntityId) ON R.intCustomerId = C.intEntityCustomerId
WHERE R.ysnActive = 1
group by 
	 R.intRecipeId
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
having max(ysnLotted) = 0