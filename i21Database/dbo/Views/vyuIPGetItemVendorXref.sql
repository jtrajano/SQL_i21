CREATE VIEW dbo.vyuIPGetItemVendorXref
AS
SELECT IVX.[intItemId]
	,CL.strLocationName 
	,V.strVendorId 
	,VS.strCompany1Id
	,IVX.[strVendorProduct]
	,IVX.[strProductDescription]
	,IVX.[dblConversionFactor]
	,UM.strUnitMeasure 
	,IVX.intSort
	,IVX.intConcurrencyId
	,IVX.dtmDateCreated
	,IVX.dtmDateModified
	,US.strUserName AS strCreatedBy
	,US1.strUserName AS strModifiedBy
FROM tblICItemVendorXref IVX
JOIN tblICItemUOM IU ON IU.intItemUOMId = IVX.intItemUnitMeasureId
JOIN tblICUnitMeasure UM ON UM.intUnitMeasureId = IU.intUnitMeasureId
LEFT JOIN tblSMUserSecurity US ON US.intEntityId = IVX.intCreatedByUserId
LEFT JOIN tblSMUserSecurity US1 ON US1.intEntityId = IVX.intModifiedByUserId
Left JOIN tblICItemLocation IL on IL.intItemLocationId=IVX.intItemLocationId
Left JOIN tblSMCompanyLocation CL on CL.intCompanyLocationId=IL.intLocationId
JOIN tblAPVendor V on V.intEntityId=IVX.intVendorId
Left JOIN tblVRVendorSetup VS on VS.intVendorSetupId=IVX.intVendorSetupId
