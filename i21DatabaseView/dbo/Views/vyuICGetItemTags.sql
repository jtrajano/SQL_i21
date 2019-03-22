CREATE VIEW [dbo].[vyuICGetItemTags]
AS
SELECT
	  intItemId					= item.intItemId
	, strItemNo					= item.strItemNo
	, strItemDescription		= item.strDescription
	, strIngredientTag			= it.strTagNumber
	, strMedicationTag			= mt.strTagNumber
	, strHazmatTag				= hm.strTagNumber
	, intIngredientTag			= it.intTagId
	, intMedicationTag			= mt.intTagId
	, intHazmatMessage			= hm.intTagId
	, strIngredientTagMessage	= it.strMessage
	, strMedicationTagMessage	= mt.strMessage
	, strHazmatMessageMessage	= hm.strMessage
	, strIngredientTagType		= it.strType
	, strMedicationTagType		= mt.strType
	, strHazmatMessageType		= hm.strType
FROM tblICItem item
	LEFT JOIN tblICTag it ON it.intTagId = item.intIngredientTag
	LEFT JOIN tblICTag mt ON mt.intTagId = item.intMedicationTag
	LEFT JOIN tblICTag hm ON hm.intTagId = item.intHazmatTag
WHERE item.strType IN ('Inventory', 'Raw Material', 'Finished Good', 'Bundle', 'Kit', 'Software')