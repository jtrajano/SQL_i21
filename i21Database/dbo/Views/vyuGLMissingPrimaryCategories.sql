CREATE VIEW [dbo].[vyuGLMissingPrimaryCategories]
AS
SELECT 
D.*,
C.strAccountCategory,
M.strModuleName
FROM 
tblGLAccountCategory C 
join tblGLRequiredPrimaryCategory D on C.intAccountCategoryId = D.intAccountCategoryId
OUTER APPLY (
	select TOP 1 strModuleName from tblARCustomerLicenseModule where intModuleId = D.intModuleId
)M
OUTER APPLY(
SELECT TOP 1 intAccountSegmentId, strCode FROM
tblGLAccountSegment  WHERE intAccountCategoryId = C.intAccountCategoryId
)S
WHERE D.intAccountId is  null