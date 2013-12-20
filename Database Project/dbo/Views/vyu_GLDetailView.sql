CREATE VIEW [dbo].[vyu_GLDetailView]
AS
SELECT     A.intGLDetailID, A.dtmDate, A.strBatchID, A.intAccountID, A.dblDebit, A.dblCredit, A.dblDebitUnit, A.dblCreditUnit, A.strDescription AS GLDescription, A.strCode, 
                      A.strTransactionID, A.strReference, A.strJobID, A.intCurrencyID, A.dblExchangeRate, A.dtmDateEntered, A.strProductID, A.strWarehouseID, A.strNum, 
                      A.strCompanyName, A.strBillInvoiceNumber, A.strJournalLineDescription, A.ysnIsUnposted, A.intConcurrencyID, A.intUserID, A.strTransactionForm, A.strModuleName, 
                      A.strUOMCode, B.strAccountID, B.strDescription, AG.strAccountGroup, AG.strAccountType
FROM         dbo.tblGLDetail AS A INNER JOIN
                      dbo.tblGLAccount AS B ON A.intAccountID = B.intAccountID INNER JOIN
                      dbo.tblGLAccountGroup AS AG ON B.intAccountGroupID = AG.intAccountGroupID
