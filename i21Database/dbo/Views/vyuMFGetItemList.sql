CREATE VIEW vyuMFGetItemList
AS
SELECT I.intItemId
	,I.strItemNo
	,I.strDescription
	,I.intCategoryId
	,I.strExternalGroup
FROM tblICItem I
LEFT JOIN tblICCategory C ON C.intCategoryId = I.intCategoryId
WHERE I.strStatus = 'Active'
