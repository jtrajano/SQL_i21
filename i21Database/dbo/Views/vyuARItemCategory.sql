CREATE VIEW [dbo].[vyuARItemCategory]
AS 
SELECT * FROM tblICCategory
WHERE intCategoryId NOT IN (SELECT intCategoryId FROM tblARProductTypeDetail)
