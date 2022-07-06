CREATE VIEW [dbo].[vyuAGApplicationMethod]  
AS  
  
SELECT   
 AM.intApplicationMethodId  
,AM.strApplicationMethod  
,AM.strDescription  
,AM.intApplicationTypeId  
,ATYPE.strType  
,AM.intConcurrencyId  
  
FROM tblAGApplicationMethod AM  
LEFT JOIN  tblAGApplicationType ATYPE ON ATYPE.intApplicationTypeId = AM.intApplicationTypeId  