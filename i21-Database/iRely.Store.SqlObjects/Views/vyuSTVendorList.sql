CREATE VIEW [dbo].[vyuSTVendorList]
AS
	Select DISTINCT V.[intEntityId], V.strVendorId
	--, V.intVendorType
	--, IL.intItemLocationId, IL.strDescription [ItemLocationDescription]
	--, CL.intCompanyLocationId, CL.strLocationName, CL.strLocationType
	, S.intStoreId, S.intStoreNo--, S.strDescription [StoreDescription]  
	FROM dbo.tblAPVendor V
	JOIN tblICItemLocation IL ON IL.intVendorId = V.[intEntityId]
	JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId = IL.intLocationId
	JOIN tblSTStore S ON S.intCompanyLocationId = CL.intCompanyLocationId
	
