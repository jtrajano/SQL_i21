CREATE VIEW vyuRKGetGLAccountDetail
AS

SELECT strAccountId strAccountId, intAccountId, strDescription, strAccountCategory
FROM vyuGLAccountDetail 
WHERE strAccountCategory = 'General'
