﻿CREATE VIEW [dbo].[vyuGLMissingPrimaryCategories]
AS
SELECT 
Account.intAccountId,
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
OUTER APPLY (
	SELECT TOP 1 intAccountId FROM vyuGLAccountDetail WHERE intAccountCategoryId = D.intAccountCategoryId
)Account
WHERE Account.intAccountId IS NULL
GO


