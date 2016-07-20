UPDATE tblICItem
SET strDescription = strItemNo
WHERE NULLIF(strDescription, '') IS NULL