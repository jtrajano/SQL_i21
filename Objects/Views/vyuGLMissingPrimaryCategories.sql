CREATE VIEW [dbo].[vyuGLMissingPrimaryCategories]
AS
SELECT 
Account.intAccountId
,D.[intRequiredPrimaryCategoryId]
,D.[intAccountCategoryId]
,D.[intModuleId]
,D.[strScreen] COLLATE Latin1_General_CI_AS strScreen
,D.[strView] COLLATE Latin1_General_CI_AS strView
,D.[strTab] COLLATE Latin1_General_CI_AS strTab
,C.strAccountCategory COLLATE Latin1_General_CI_AS strAccountCategory
,M.strModuleName COLLATE Latin1_General_CI_AS strModuleName
FROM 
tblGLAccountCategory C 
join tblGLRequiredPrimaryCategory D on C.intAccountCategoryId = D.intAccountCategoryId
OUTER APPLY (
	select TOP 1 strModule strModuleName from tblSMModule where intModuleId = D.intModuleId
)M
OUTER APPLY (
	SELECT TOP 1 intAccountId FROM vyuGLAccountDetail WHERE intAccountCategoryId = D.intAccountCategoryId
)Account
WHERE Account.intAccountId IS NULL
GO


