CREATE VIEW [dbo].[vyuGLAccountDetail]
AS
	SELECT      TOP 1000000 
	account.intConcurrencyId,
	account.strAccountId,replace(account.strAccountId,'-','') strAccountId1,
	tblGLCrossReferenceMapping.strOldAccountId, 
	account.strDescription, dbo.tblGLAccountGroup.strAccountGroup, dbo.tblGLAccountGroup.strAccountType, dbo.tblGLAccountCategory.strAccountCategory, 
                         account.strComments, account.strCashFlow, account.ysnActive, account.ysnSystem, account.ysnRevalue, dbo.tblGLAccountUnit.intAccountUnitId, 
                         dbo.tblGLAccountUnit.strUOMCode, account.intAccountId, account.intCurrencyID, account.intCurrencyExchangeRateTypeId, account.strNote, dbo.tblSMCurrency.strCurrency, 
                         dbo.tblSMCurrencyExchangeRateType.strCurrencyExchangeRateType, account.intAccountGroupId, dbo.tblGLAccountSegment.intAccountCategoryId,
						 dbo.tblGLCOACrossReference.strExternalId,dbo.tblGLCOACrossReference.strCurrentExternalId, tblGLAccountSegment.strCode,
						 cast(0.00 as numeric(18,2)) as dblBalance
FROM            dbo.tblGLAccount account INNER JOIN
                         dbo.tblGLAccountSegmentMapping ON account.intAccountId = dbo.tblGLAccountSegmentMapping.intAccountId INNER JOIN
                         dbo.tblGLAccountSegment ON dbo.tblGLAccountSegmentMapping.intAccountSegmentId = dbo.tblGLAccountSegment.intAccountSegmentId INNER JOIN
                         dbo.tblGLAccountStructure ON dbo.tblGLAccountSegment.intAccountStructureId = dbo.tblGLAccountStructure.intAccountStructureId INNER JOIN
                         dbo.tblGLAccountCategory ON dbo.tblGLAccountSegment.intAccountCategoryId = dbo.tblGLAccountCategory.intAccountCategoryId LEFT OUTER JOIN
                         dbo.tblSMCurrencyExchangeRateType ON account.intCurrencyExchangeRateTypeId = dbo.tblSMCurrencyExchangeRateType.intCurrencyExchangeRateTypeId LEFT OUTER JOIN
                         dbo.tblSMCurrency ON account.intCurrencyID = dbo.tblSMCurrency.intCurrencyID LEFT OUTER JOIN
                         dbo.tblGLAccountUnit ON account.intAccountUnitId = dbo.tblGLAccountUnit.intAccountUnitId LEFT OUTER JOIN
						 dbo.tblGLCOACrossReference ON account.intAccountId = dbo.tblGLCOACrossReference.inti21Id LEFT OUTER JOIN
                         dbo.tblGLAccountGroup ON account.intAccountGroupId = dbo.tblGLAccountGroup.intAccountGroupId LEFT OUTER JOIN
						 dbo.tblGLCrossReferenceMapping ON account.intAccountId = dbo.tblGLCrossReferenceMapping.intAccountId  
						 and dbo.tblGLCrossReferenceMapping.intAccountSystemId in (select [intDefaultVisibleOldAccountSystemId] from tblGLCompanyPreferenceOption)
WHERE        (dbo.tblGLAccountStructure.strType = 'Primary')
GO
