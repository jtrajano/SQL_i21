UPDATE t
SET t.strDescription = i.strDescription,
    t.strItemType = i.strType
FROM tblICInventoryTransferDetail t
    INNER JOIN tblICItem i ON i.intItemId = t.intItemId
        AND i.strType <> 'Comment'
WHERE t.strItemType IS NULL

-- Also update the unit qty for the selected item uom
-- This is used for calculating the gross/net weights.
UPDATE td
SET td.dblItemUnitQty = iuom.dblUnitQty
FROM tblICInventoryTransferDetail td
	INNER JOIN tblICItemUOM iuom ON iuom.intItemUOMId = td.intItemUOMId
WHERE td.dblItemUnitQty IS NULL