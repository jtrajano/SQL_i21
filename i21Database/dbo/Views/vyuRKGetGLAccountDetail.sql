CREATE VIEW vyuRKGetGLAccountDetail
AS

SELECT strAccountId strAccountId, intAccountId, strDescription, strAccountType
FROM vyuGLAccountDetail 
WHERE strAccountCategory = 'General'
