CREATE VIEW [dbo].[vyuMFGetItemSubstitution]
	AS 
SELECT s.intItemSubstitutionId,i.strItemNo,i.strDescription,st.strName AS strSubstitutionTypeName,
s.ysnProcessed,s.ysnCancelled,s.strComment,cl.strLocationName 
FROM tblMFItemSubstitution s 
Join tblMFItemSubstitutionType st on s.intItemSubstitutionTypeId=st.intItemSubstitutionTypeId
Join tblICItem i on s.intItemId=i.intItemId
Join tblSMCompanyLocation cl on s.intLocationId=cl.intCompanyLocationId
Where s.ysnCancelled=0
