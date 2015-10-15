CREATE VIEW [dbo].[vyuGLAccountDetail]
	AS SELECT        dbo.tblGLAccount.intAccountId, dbo.tblGLAccount.strAccountId, dbo.tblGLAccountCategory.strAccountCategory, dbo.tblGLAccount.strDescription, dbo.tblGLAccountGroup.strAccountGroup, 
                         dbo.tblGLAccount.ysnActive, dbo.tblGLAccount.strCashFlow, dbo.tblGLAccount.intCurrencyID, dbo.tblGLAccount.intCurrencyExchangeRateTypeId, dbo.tblGLAccount.strNote, dbo.tblGLAccount.strComments, 
                         dbo.tblSMCurrency.strCurrency, dbo.tblGLAccount.intAccountCategoryId, dbo.tblGLAccount.intAccountGroupId, dbo.tblGLAccountGroup.strAccountType
FROM            dbo.tblGLAccount INNER JOIN
                         dbo.tblGLAccountSegmentMapping ON dbo.tblGLAccount.intAccountId = dbo.tblGLAccountSegmentMapping.intAccountId INNER JOIN
                         dbo.tblGLAccountSegment ON dbo.tblGLAccountSegmentMapping.intAccountSegmentId = dbo.tblGLAccountSegment.intAccountSegmentId INNER JOIN
                         dbo.tblGLAccountStructure ON dbo.tblGLAccountSegment.intAccountStructureId = dbo.tblGLAccountStructure.intAccountStructureId INNER JOIN
                         dbo.tblGLAccountCategory ON dbo.tblGLAccountSegment.intAccountCategoryId = dbo.tblGLAccountCategory.intAccountCategoryId LEFT OUTER JOIN
                         dbo.tblSMCurrency ON dbo.tblGLAccount.intCurrencyID = dbo.tblSMCurrency.intCurrencyID LEFT OUTER JOIN
                         dbo.tblGLAccountUnit ON dbo.tblGLAccount.intAccountUnitId = dbo.tblGLAccountUnit.intAccountUnitId LEFT OUTER JOIN
                         dbo.tblGLAccountGroup ON dbo.tblGLAccount.intAccountGroupId = dbo.tblGLAccountGroup.intAccountGroupId
WHERE dbo.tblGLAccountStructure.strType='Primary'
