CREATE VIEW [dbo].[vyuGLAccountGroupView]
AS
SELECT     intAccountGroupId, AccountGroupSub, strAccountType, AccountGroup, intParentGroupId, intSort
FROM         (SELECT     A.intAccountGroupId, B.strAccountGroup AS AccountGroupSub, A.strAccountType, A.strAccountGroup AS AccountGroup, A.intParentGroupId, A.intSort
                       FROM          dbo.tblGLAccountGroup AS A LEFT OUTER JOIN
                                              dbo.tblGLAccountGroup AS B ON A.intAccountGroupId = B.intParentGroupId) AS X
WHERE  AccountGroupSub IS NULL