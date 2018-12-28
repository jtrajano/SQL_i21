CREATE VIEW [dbo].[vyuGLAccountDetail]
AS
	SELECT      TOP 1000000 
				account.intConcurrencyId,
				account.strAccountId COLLATE Latin1_General_CI_AS strAccountId,
				replace(account.strAccountId,'-','') COLLATE Latin1_General_CI_AS strAccountId1,
				account.strOldAccountId COLLATE Latin1_General_CI_AS strOldAccountId,
				replace(account.strOldAccountId,'-','') COLLATE Latin1_General_CI_AS strOldAccountId1,
				account.strDescription COLLATE Latin1_General_CI_AS strDescription, 
				grp.strAccountGroup COLLATE Latin1_General_CI_AS strAccountGroup, 
				grp.strAccountType COLLATE Latin1_General_CI_AS strAccountType, 
				cat.strAccountCategory COLLATE Latin1_General_CI_AS strAccountCategory, 
                account.strComments COLLATE Latin1_General_CI_AS strComments, 
				account.strCashFlow COLLATE Latin1_General_CI_AS strCashFlow, 
				account.ysnActive, account.ysnSystem, account.ysnRevalue, u.intAccountUnitId, 
                u.strUOMCode COLLATE Latin1_General_CI_AS strUOMCode, 
				account.intAccountId, account.intCurrencyID, account.intCurrencyExchangeRateTypeId, 
				account.strNote COLLATE Latin1_General_CI_AS strNote, 
				curr.strCurrency COLLATE Latin1_General_CI_AS strCurrency, 
				rtype.strCurrencyExchangeRateType COLLATE Latin1_General_CI_AS strCurrencyExchangeRateType, 
				account.intAccountGroupId, segment.intAccountCategoryId,
				coa.strExternalId COLLATE Latin1_General_CI_AS strExternalId, 
				coa.strCurrentExternalId COLLATE Latin1_General_CI_AS strCurrentExternalId, 
				segment.strCode COLLATE Latin1_General_CI_AS strCode, 
				cast(0.00 as numeric(18,2)) as dblBalance
FROM            dbo.tblGLAccount account INNER JOIN
                dbo.tblGLAccountSegmentMapping ON account.intAccountId = dbo.tblGLAccountSegmentMapping.intAccountId INNER JOIN
                dbo.tblGLAccountSegment segment ON dbo.tblGLAccountSegmentMapping.intAccountSegmentId = segment.intAccountSegmentId INNER JOIN
                dbo.tblGLAccountStructure struc ON segment.intAccountStructureId = struc.intAccountStructureId INNER JOIN
                dbo.tblGLAccountCategory cat ON segment.intAccountCategoryId = cat.intAccountCategoryId LEFT OUTER JOIN
                dbo.tblSMCurrencyExchangeRateType rtype ON account.intCurrencyExchangeRateTypeId = rtype.intCurrencyExchangeRateTypeId LEFT OUTER JOIN
                dbo.tblSMCurrency curr ON account.intCurrencyID = curr.intCurrencyID LEFT OUTER JOIN
                dbo.tblGLAccountUnit u ON account.intAccountUnitId = u.intAccountUnitId LEFT OUTER JOIN
				dbo.tblGLCOACrossReference coa ON account.intAccountId =coa.inti21Id LEFT OUTER JOIN
                dbo.tblGLAccountGroup grp ON account.intAccountGroupId = grp.intAccountGroupId
				
WHERE        (struc.strType = 'Primary')
GO
