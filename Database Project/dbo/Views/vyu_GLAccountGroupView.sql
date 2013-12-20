CREATE VIEW [dbo].[vyu_GLAccountGroupView]
AS
SELECT     intAccountGroupID, AccountGroupSub, strAccountType, AccountGroup, intParentGroupID, intSort
FROM         (SELECT     A.intAccountGroupID, B.strAccountGroup AS AccountGroupSub, A.strAccountType, A.strAccountGroup AS AccountGroup, A.intParentGroupID, A.intSort
                       FROM          dbo.tblGLAccountGroup AS A LEFT OUTER JOIN
                                              dbo.tblGLAccountGroup AS B ON A.intAccountGroupID = B.intParentGroupID) AS X
WHERE  AccountGroupSub IS NULL
