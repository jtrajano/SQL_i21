CREATE VIEW [dbo].[vyuARAccountDetail]
AS 

SELECT 
	 intAccountId
	,strAccountId
	,strDescription
	,strAccountCategory
	,strAccountType
	,strAccountGroup
	,intLocationAccountSegmentId = ISNULL(GLLocation.intAccountSegmentId, 0)
	,intCompanyAccountSegmentId = ISNULL(GLCompany.intAccountSegmentId, 0)
	,intAccountCategoryId
FROM vyuGLAccountDetail GLAD
OUTER APPLY (
	SELECT TOP  1 intAccountSegmentId
	FROM vyuGLLocationAccountId
	WHERE intAccountId = GLAD.intAccountId
) GLLocation
OUTER APPLY (
	SELECT TOP  1 intAccountSegmentId
	FROM vyuGLCompanyAccountId
	WHERE intAccountId = GLAD.intAccountId
) GLCompany