CREATE VIEW [dbo].[vyuICGetItemTags]
AS
SELECT
	  intItemId					= item.intItemId
	, strItemNo					= item.strItemNo
	, strItemDescription		= item.strDescription
	, strIngredientTag			= it.strDescription
	, strMedicationTag			= mt.strDescription
	, strHazmatMessage			= hm.strDescription
	, strItemMessage			= im.strDescription
	, intIngredientTag			= it.intTagId
	, intMedicationTag			= mt.intTagId
	, intHazmatMessage			= hm.intTagId
	, intItemMessage			= im.intTagId
	, strIngredientTagMessage	= it.strMessage
	, strMedicationTagMessage	= mt.strMessage
	, strHazmatMessageMessage	= hm.strMessage
	, strItemMessageMessage		= im.strMessage
	, strIngredientTagType		= it.strType
	, strMedicationTagType		= mt.strType
	, strHazmatMessageType		= hm.strType
	, strItemMessageType		= im.strType
FROM tblICItem item
	LEFT JOIN tblICTag it ON it.intTagId = item.intIngredientTag
	LEFT JOIN tblICTag mt ON mt.intTagId = item.intMedicationTag
	LEFT JOIN tblICTag hm ON hm.intTagId = item.intHazmatMessage
	LEFT JOIN tblICTag im ON im.intTagId = item.intItemMessage
WHERE item.strType IN ('Inventory', 'Raw Material', 'Finished Good', 'Bundle', 'Kit', 'Software')