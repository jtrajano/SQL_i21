IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[uspICDCCatExtraGLAccounts]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [uspICDCCatExtraGLAccounts]; 
GO 

CREATE PROCEDURE [dbo].[uspICDCCatExtraGLAccounts]

AS
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF




--insert extra inventory accounts to Category GL table
--run this after class/category is imported

insert into tblICCategoryAccount 
(intCategoryId, intAccountCategoryId, intAccountId, intConcurrencyId)
(Select intCategoryId, intAccountCategoryId, intAccountId, 1 from tblICCategory C 
cross join 
(select top 1 51 intAccountCategoryId, intAccountId from tblGLAccount where strDescription like '%adjustment%'
union
select top 1 46 intAccountCategoryId, intAccountId from tblGLAccount where strDescription like '%transit%'
--union
--select top 1 44 intAccountCategoryId, intAccountId from tblGLAccount where strDescription like '%variance%'
--union
--select top 1 45 intAccountCategoryId, intAccountId from tblGLAccount where strDescription like '%Clearing%'
) ac
where C.strInventoryType = 'Inventory' )

GO