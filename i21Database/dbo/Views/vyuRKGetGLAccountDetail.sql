CREATE VIEW vyuRKGetGLAccountDetail
AS

SELECT strAccountId strAccountId,
		intAccountId 
FROM vyuGLAccountDetail 
WHERE strAccountCategory = 'General'
