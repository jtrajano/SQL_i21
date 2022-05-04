CREATE VIEW [dbo].[vyuHDAccountDetail]
AS 

SELECT 
	 intAccountId
	,strAccountId
	,strDescription
	,strAccountCategory
FROM vyuGLAccountDetail GLAD

GO