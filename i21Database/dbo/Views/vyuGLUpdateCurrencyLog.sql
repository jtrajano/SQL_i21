CREATE VIEW [dbo].[vyuGLUpdateCurrencyLog]
AS 
SELECT
	A.*
	,strAccountId = Account.strAccountId COLLATE Latin1_General_CI_AS
	,strOldCurrency = OldCurrency.strCurrency COLLATE Latin1_General_CI_AS
	,strNewCurrency = NewCurrency.strCurrency COLLATE Latin1_General_CI_AS
	,strUser = E.strName
FROM [dbo].[tblGLUpdateCurrencyLog] A
LEFT JOIN [dbo].[tblGLAccount] Account
	ON Account.intAccountId = A.intAccountId
LEFT JOIN [dbo].[tblSMCurrency] OldCurrency
	ON OldCurrency.intCurrencyID = A.intOldCurrencyId
LEFT JOIN [dbo].[tblSMCurrency] NewCurrency
	ON NewCurrency.intCurrencyID = A.intNewCurrencyId
LEFT JOIN [dbo].[tblEMEntity] E
	ON E.intEntityId = A.intEntityId