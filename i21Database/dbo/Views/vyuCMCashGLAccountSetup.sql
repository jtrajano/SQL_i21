CREATE VIEW [dbo].[vyuCMCashGLAccountSetup]
AS 

SELECT 
*
FROM vyuGLAccountDetail
WHERE
strAccountCategory = 'Cash Account'
