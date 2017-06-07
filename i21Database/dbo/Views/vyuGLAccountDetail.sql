CREATE VIEW [dbo].[vyuGLAccountDetail]
AS
	SELECT      TOP 1000000 
				account.intConcurrencyId,account.strAccountId,replace(account.strAccountId,'-','') strAccountId1,
				map.strOldAccountId, account.strDescription, grp.strAccountGroup, grp.strAccountType, cat.strAccountCategory, 
                account.strComments, account.strCashFlow, account.ysnActive, account.ysnSystem, account.ysnRevalue, u.intAccountUnitId, 
                u.strUOMCode, account.intAccountId, account.intCurrencyID, account.intCurrencyExchangeRateTypeId, account.strNote, 
				curr.strCurrency, rtype.strCurrencyExchangeRateType, account.intAccountGroupId, segment.intAccountCategoryId,
				coa.strExternalId, coa.strCurrentExternalId, segment.strCode, cast(0.00 as numeric(18,2)) as dblBalance
FROM            dbo.tblGLAccount account INNER JOIN
                dbo.tblGLAccountSegmentMapping ON account.intAccountId = dbo.tblGLAccountSegmentMapping.intAccountId INNER JOIN
                dbo.tblGLAccountSegment segment ON dbo.tblGLAccountSegmentMapping.intAccountSegmentId = segment.intAccountSegmentId INNER JOIN
                dbo.tblGLAccountStructure struc ON segment.intAccountStructureId = struc.intAccountStructureId INNER JOIN
                dbo.tblGLAccountCategory cat ON segment.intAccountCategoryId = cat.intAccountCategoryId LEFT OUTER JOIN
                dbo.tblSMCurrencyExchangeRateType rtype ON account.intCurrencyExchangeRateTypeId = rtype.intCurrencyExchangeRateTypeId LEFT OUTER JOIN
                dbo.tblSMCurrency curr ON account.intCurrencyID = curr.intCurrencyID LEFT OUTER JOIN
                dbo.tblGLAccountUnit u ON account.intAccountUnitId = u.intAccountUnitId LEFT OUTER JOIN
				dbo.tblGLCOACrossReference coa ON account.intAccountId =coa.inti21Id LEFT OUTER JOIN
                dbo.tblGLAccountGroup grp ON account.intAccountGroupId = grp.intAccountGroupId LEFT OUTER JOIN
				dbo.tblGLCrossReferenceMapping map ON account.intAccountId = map.intAccountId  
				and map.intAccountSystemId in (select [intDefaultVisibleOldAccountSystemId] from tblGLCompanyPreferenceOption)
WHERE        (struc.strType = 'Primary')
GO
