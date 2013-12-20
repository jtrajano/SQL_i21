CREATE VIEW [dbo].[vyu_GLAccountView]
AS
SELECT     A.intAccountID, A.strAccountID, A.strDescription, A.strNote, A.intAccountGroupID, A.dblOpeningBalance, A.ysnIsUsed, A.intConcurrencyID, A.intAccountUnitID, 
                      A.strComments, A.ysnActive, A.ysnSystem, A.strCashFlow, B.strAccountGroup, B.strAccountType
FROM         dbo.tblGLAccount AS A INNER JOIN
                      dbo.tblGLAccountGroup AS B ON A.intAccountGroupID = B.intAccountGroupID
