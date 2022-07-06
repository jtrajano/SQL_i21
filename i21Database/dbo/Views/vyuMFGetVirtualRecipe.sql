CREATE VIEW vyuMFGetVirtualRecipe
AS
SELECT VR.intRecipeId AS intVirtualRecipeId
	,VR.strName AS strVirtualRecipeName
	--,VI.strItemNo
	,AR.strName AS strActualRecipeName
	,AI.strItemNo
	,AR.intVersionNo
	,C.strName AS strCustomer
	,B.strBook
	,SB.strSubBook
	,NULL AS strBlendCode
	,CL.strLocationName
	,CLSL.strSubLocationName
	,AR.dtmValidFrom
	,AR.dtmValidTo
	,RM.intVirtualRecipeMapId
FROM tblMFVirtualRecipeMap RM
JOIN tblMFRecipe VR ON VR.intRecipeId = RM.intVirtualRecipeId
JOIN tblICItem VI ON VI.intItemId = VR.intItemId
JOIN tblMFRecipe AR ON AR.intRecipeId = RM.intRecipeId
JOIN tblICItem AI ON AI.intItemId = AR.intItemId
LEFT JOIN tblCTBook B ON B.intBookId = AR.intBookId
LEFT JOIN tblCTSubBook SB ON SB.intSubBookId = AR.intSubBookId
LEFT JOIN tblEMEntity C ON C.intEntityId = AR.intCustomerId
LEFT JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId = AR.intLocationId
LEFT JOIN tblSMCompanyLocationSubLocation CLSL ON CLSL.intCompanyLocationSubLocationId = AR.intSubLocationId
