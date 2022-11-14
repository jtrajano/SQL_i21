CREATE VIEW [dbo].[vyuGLAccountGroup]
AS
SELECT     
A.intAccountGroupId, 
A.intParentGroupId,
B.strAccountGroup strParentGroup,
A.strAccountGroup,
B.strAccountType strParentType,
A.strAccountType, 
A.intSort
FROM
dbo.tblGLAccountGroup AS A LEFT JOIN                     
dbo.tblGLAccountGroup AS B ON A.intAccountGroupId = B.intParentGroupId