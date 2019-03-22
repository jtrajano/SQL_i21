CREATE VIEW [dbo].[vwGLChartOfAccounts]
	AS 
	SELECT     dbo.tblGLAccount.strAccountId, dbo.tblGLAccount.strDescription, dbo.tblGLAccountGroup.strAccountGroup, dbo.tblGLAccountGroup.strAccountType, dbo.tblGLAccountCategory.strAccountCategory, 
                      dbo.tblGLAccount.strComments, dbo.tblGLAccount.strCashFlow, dbo.tblGLAccount.ysnActive, dbo.tblGLAccount.ysnSystem, dbo.tblGLAccount.ysnRevalue, dbo.tblGLAccountUnit.intAccountUnitId, 
                      dbo.tblGLAccountUnit.strUOMCode, dbo.tblGLAccount.intAccountId, dbo.tblSMCurrency.strCurrency, dbo.tblSMCurrencyExchangeRateType.strCurrencyExchangeRateType
FROM         dbo.tblGLAccount LEFT OUTER JOIN
                      dbo.tblSMCurrency ON dbo.tblGLAccount.intCurrencyID = dbo.tblSMCurrency.intCurrencyID LEFT OUTER JOIN
                      dbo.tblGLAccountUnit ON dbo.tblGLAccount.intAccountUnitId = dbo.tblGLAccountUnit.intAccountUnitId LEFT OUTER JOIN
                      dbo.tblGLAccountGroup ON dbo.tblGLAccount.intAccountGroupId = dbo.tblGLAccountGroup.intAccountGroupId LEFT OUTER JOIN
                      dbo.tblGLAccountCategory ON dbo.tblGLAccount.intAccountCategoryId = dbo.tblGLAccountCategory.intAccountCategoryId LEFT OUTER JOIN
                      dbo.tblSMCurrencyExchangeRateType ON dbo.tblGLAccount.intCurrencyExchangeRateTypeId = dbo.tblSMCurrencyExchangeRateType.intCurrencyExchangeRateTypeId
