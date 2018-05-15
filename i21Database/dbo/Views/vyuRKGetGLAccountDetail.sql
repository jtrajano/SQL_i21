CREATE VIEW vyuRKGetGLAccountDetail
AS

SELECT distinct strAccountId strAccountId, intAccountId, strDescription, strAccountType,strAccountCategory
FROM vyuGLAccountDetail 
WHERE strAccountCategory in('Mark to Market P&L','Mark to Market Offset')
