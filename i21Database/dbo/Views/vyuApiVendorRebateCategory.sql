CREATE VIEW [dbo].[vyuApiVendorRebateCategory]
AS
SELECT
	  x.intCategoryVendorId
	, x.intCategoryId
	, c.strCategoryCode
	, x.intVendorSetupId
	, x.strVendorDepartment strVendorCategory
FROM tblICCategoryVendor x
LEFT JOIN tblICCategory c ON c.intCategoryId = x.intCategoryId