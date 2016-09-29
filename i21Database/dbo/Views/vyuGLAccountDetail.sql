CREATE VIEW [dbo].[vyuGLAccountDetail]
AS
	SELECT      TOP 1000000  dbo.tblGLAccount.strAccountId, 
	replace(dbo.tblGLAccount.strAccountId,'-','') strAccountId1,
	dbo.tblGLAccount.strDescription, dbo.tblGLAccountGroup.strAccountGroup, dbo.tblGLAccountGroup.strAccountType, dbo.tblGLAccountCategory.strAccountCategory, 
                         dbo.tblGLAccount.strComments, dbo.tblGLAccount.strCashFlow, dbo.tblGLAccount.ysnActive, dbo.tblGLAccount.ysnSystem, dbo.tblGLAccount.ysnRevalue, dbo.tblGLAccountUnit.intAccountUnitId, 
                         dbo.tblGLAccountUnit.strUOMCode, dbo.tblGLAccount.intAccountId, dbo.tblGLAccount.intCurrencyID, dbo.tblGLAccount.intCurrencyExchangeRateTypeId, dbo.tblGLAccount.strNote, dbo.tblSMCurrency.strCurrency, 
                         dbo.tblSMCurrencyExchangeRateType.strCurrencyExchangeRateType, dbo.tblGLAccount.intAccountGroupId, dbo.tblGLAccountSegment.intAccountCategoryId,
						 dbo.tblGLCOACrossReference.strExternalId,dbo.tblGLCOACrossReference.strCurrentExternalId, tblGLAccountSegment.strCode,
						 cast(0.00 as numeric(18,2)) as dblBalance
FROM            dbo.tblGLAccount INNER JOIN
                         dbo.tblGLAccountSegmentMapping ON dbo.tblGLAccount.intAccountId = dbo.tblGLAccountSegmentMapping.intAccountId INNER JOIN
                         dbo.tblGLAccountSegment ON dbo.tblGLAccountSegmentMapping.intAccountSegmentId = dbo.tblGLAccountSegment.intAccountSegmentId INNER JOIN
                         dbo.tblGLAccountStructure ON dbo.tblGLAccountSegment.intAccountStructureId = dbo.tblGLAccountStructure.intAccountStructureId INNER JOIN
                         dbo.tblGLAccountCategory ON dbo.tblGLAccountSegment.intAccountCategoryId = dbo.tblGLAccountCategory.intAccountCategoryId LEFT OUTER JOIN
                         dbo.tblSMCurrencyExchangeRateType ON dbo.tblGLAccount.intCurrencyExchangeRateTypeId = dbo.tblSMCurrencyExchangeRateType.intCurrencyExchangeRateTypeId LEFT OUTER JOIN
                         dbo.tblSMCurrency ON dbo.tblGLAccount.intCurrencyID = dbo.tblSMCurrency.intCurrencyID LEFT OUTER JOIN
                         dbo.tblGLAccountUnit ON dbo.tblGLAccount.intAccountUnitId = dbo.tblGLAccountUnit.intAccountUnitId LEFT OUTER JOIN
						 dbo.tblGLCOACrossReference ON dbo.tblGLAccount.intAccountId = dbo.tblGLCOACrossReference.inti21Id LEFT OUTER JOIN
                         dbo.tblGLAccountGroup ON dbo.tblGLAccount.intAccountGroupId = dbo.tblGLAccountGroup.intAccountGroupId
WHERE        (dbo.tblGLAccountStructure.strType = 'Primary')

