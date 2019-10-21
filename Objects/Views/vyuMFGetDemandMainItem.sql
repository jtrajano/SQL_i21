CREATE VIEW vyuMFGetDemandMainItem
AS
SELECT I.intItemId
	,I.strItemNo
	,I.strDescription
	,I.strType
	,I.strStatus
	,C.strDescription AS strCategory
FROM tblICItem I
JOIN tblICCategory C ON C.intCategoryId = I.intCategoryId
