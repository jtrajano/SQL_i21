CREATE VIEW vyuMFGetDemandSubstituteItem
AS
SELECT I.intItemId
	,I.strItemNo
	,I.strDescription
	,'1' AS strIndicator
	,IB.intItemId AS intMainItemId
FROM tblICItemBundle IB
JOIN tblICItem I ON I.intItemId = IB.intBundleItemId

UNION ALL

SELECT I.intItemId
	,I.strItemNo
	,I.strDescription
	,'2' AS strIndicator
	,ISUB.intItemId AS intMainItemId
FROM tblICItemSubstitute ISUB
JOIN tblICItem I ON I.intItemId = ISUB.intSubstituteItemId
