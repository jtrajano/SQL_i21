
GO
/****** Object:  View [dbo].[vyu_GLAccountGroupView]    Script Date: 10/07/2013 18:02:51 ******/
IF OBJECT_ID(N'dbo.vyu_GLAccountGroupView', N'V') IS NOT NULL
BEGIN
	DROP VIEW dbo.vyu_GLAccountGroupView
END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vyu_GLAccountGroupView]
AS
SELECT     intAccountGroupID, AccountGroupSub, strAccountType, AccountGroup, intParentGroupID, intSort
FROM         (SELECT     A.intAccountGroupID, B.strAccountGroup AS AccountGroupSub, A.strAccountType, A.strAccountGroup AS AccountGroup, A.intParentGroupID, A.intSort
                       FROM          dbo.tblGLAccountGroup AS A LEFT OUTER JOIN
                                              dbo.tblGLAccountGroup AS B ON A.intAccountGroupID = B.intParentGroupID) AS X
WHERE  AccountGroupSub IS NULL
GO

/****** Object:  View [dbo].[vyu_GLAccountView]    Script Date: 10/07/2013 18:02:51 ******/
IF OBJECT_ID(N'dbo.vyu_GLAccountView', N'V') IS NOT NULL
BEGIN
	DROP VIEW dbo.vyu_GLAccountView
END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vyu_GLAccountView]
AS
SELECT     A.intAccountID, A.strAccountID, A.strDescription, A.strNote, A.intAccountGroupID, A.dblOpeningBalance, A.ysnIsUsed, A.intConcurrencyID, A.intAccountUnitID, 
                      A.strComments, A.ysnActive, A.ysnSystem, A.strCashFlow, B.strAccountGroup, B.strAccountType
FROM         dbo.tblGLAccount AS A INNER JOIN
                      dbo.tblGLAccountGroup AS B ON A.intAccountGroupID = B.intAccountGroupID
GO

/****** Object:  View [dbo].[vyu_GLFiscalYearPeriod]    Script Date: 10/07/2013 18:02:51 ******/
IF OBJECT_ID(N'dbo.vyu_GLFiscalYearPeriod', N'V') IS NOT NULL
BEGIN
	DROP VIEW dbo.vyu_GLFiscalYearPeriod
END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vyu_GLFiscalYearPeriod]
AS

SELECT A.[intGLFiscalYearPeriodID]
	,A.[intFiscalYearID]
	,A.[strPeriod]
	,A.[dtmStartDate]
	,A.[dtmEndDate]
	,A.[ysnOpen]
	,A.[intConcurrencyID]
	,B.[strFiscalYear]

FROM tblGLFiscalYearPeriod A
INNER JOIN tblGLFiscalYear B
ON A.intFiscalYearID = B.intFiscalYearID
GO

/****** Object:  View [dbo].[vyu_GLDetailView]    Script Date: 10/07/2013 18:02:51 ******/
IF OBJECT_ID(N'dbo.vyu_GLDetailView', N'V') IS NOT NULL
BEGIN
	DROP VIEW dbo.vyu_GLDetailView
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vyu_GLDetailView]
AS
SELECT     A.intGLDetailID, A.dtmDate, A.strBatchID, A.intAccountID, A.dblDebit, A.dblCredit, A.dblDebitUnit, A.dblCreditUnit, A.strDescription AS GLDescription, A.strCode, 
                      A.strTransactionID, A.strReference, A.strJobID, A.intCurrencyID, A.dblExchangeRate, A.dtmDateEntered, A.strProductID, A.strWarehouseID, A.strNum, 
                      A.strCompanyName, A.strBillInvoiceNumber, A.strJournalLineDescription, A.ysnIsUnposted, A.intConcurrencyID, A.intUserID, A.strTransactionForm, A.strModuleName, 
                      A.strUOMCode, B.strAccountID, B.strDescription, AG.strAccountGroup, AG.strAccountType
FROM         dbo.tblGLDetail AS A INNER JOIN
                      dbo.tblGLAccount AS B ON A.intAccountID = B.intAccountID INNER JOIN
                      dbo.tblGLAccountGroup AS AG ON B.intAccountGroupID = AG.intAccountGroupID
GO

