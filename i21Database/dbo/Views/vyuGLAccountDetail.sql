CREATE VIEW [dbo].[vyuGLAccountDetail]
AS

	SELECT      TOP 1000000 
				account.intConcurrencyId,
				account.strAccountId COLLATE Latin1_General_CI_AS strAccountId,
				CAST(replace(account.strAccountId,'-','') AS NVARCHAR(40)) COLLATE Latin1_General_CI_AS strAccountId1,
				account.strOldAccountId COLLATE Latin1_General_CI_AS strOldAccountId,
				cast(replace(account.strOldAccountId,'-','') AS NVARCHAR(50)) COLLATE Latin1_General_CI_AS strOldAccountId1,
				account.strDescription COLLATE Latin1_General_CI_AS strDescription, 
				grp.strAccountGroup COLLATE Latin1_General_CI_AS strAccountGroup, 
				grp.strAccountType COLLATE Latin1_General_CI_AS strAccountType, 
				sg.strAccountCategory COLLATE Latin1_General_CI_AS strAccountCategory, 
                account.strComments COLLATE Latin1_General_CI_AS strComments, 
				account.strCashFlow COLLATE Latin1_General_CI_AS strCashFlow, 
				account.ysnActive, account.ysnSystem, account.ysnRevalue, u.intAccountUnitId, 
                u.strUOMCode COLLATE Latin1_General_CI_AS strUOMCode, 
				account.intAccountId, account.intCurrencyID, account.intCurrencyExchangeRateTypeId, 
				cast (account.strNote as nvarchar(255)) COLLATE Latin1_General_CI_AS strNote, 
				curr.strCurrency COLLATE Latin1_General_CI_AS strCurrency, 
				rtype.strCurrencyExchangeRateType COLLATE Latin1_General_CI_AS strCurrencyExchangeRateType, 
				account.intAccountGroupId, sg.intAccountCategoryId,
				coa.strExternalId COLLATE Latin1_General_CI_AS strExternalId, 
				coa.strCurrentExternalId COLLATE Latin1_General_CI_AS strCurrentExternalId, 
				sg.strCode COLLATE Latin1_General_CI_AS strCode, 
				cast(0.00 as numeric(18,2)) as dblBalance,
				sg.ysnGLRestricted, 
				sg.ysnAPRestricted
FROM            dbo.tblGLAccount account 
				CROSS APPLY (
					SELECT 
					strCode, 
					cat.intAccountCategoryId, 
					cat.strAccountCategory, 
					cat.ysnGLRestricted, 
					cat.ysnAPRestricted
					FROM dbo.tblGLAccountSegmentMapping mapping 
					LEFT JOIN dbo.tblGLAccountSegment segment ON segment.intAccountSegmentId = mapping.intAccountSegmentId
					LEFT JOIN dbo.tblGLAccountCategory cat ON segment.intAccountCategoryId = cat.intAccountCategoryId
					JOIN dbo.tblGLAccountStructure struc ON segment.intAccountStructureId = struc.intAccountStructureId 
					AND struc.strType = 'Primary'
					where intAccountId = account.intAccountId
				)sg
				
                LEFT JOIN dbo.tblSMCurrencyExchangeRateType rtype ON account.intCurrencyExchangeRateTypeId = rtype.intCurrencyExchangeRateTypeId 
				LEFT JOIN dbo.tblSMCurrency curr ON account.intCurrencyID = curr.intCurrencyID 
				LEFT JOIN dbo.tblGLAccountUnit u ON account.intAccountUnitId = u.intAccountUnitId
				LEFT JOIN dbo.tblGLCOACrossReference coa  on account.intAccountId =inti21Id
				LEFT JOIN dbo.tblGLAccountGroup grp ON account.intAccountGroupId = grp.intAccountGroupId
GO


