CREATE VIEW [dbo].[vyuICApiCategory]
AS

SELECT c.intCategoryId, c.strCategoryCode, c.strDescription, c.ysnRetailValuation, lob.strLineOfBusiness, c.dtmDateCreated, c.dtmDateModified
FROM tblICCategory c
LEFT OUTER JOIN tblSMLineOfBusiness lob ON lob.intLineOfBusinessId = c.intLineOfBusinessId