IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[uspICDCCatGLAcctsMigrationAg]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [uspICDCCatGLAcctsMigrationAg]; 
GO 

Create PROCEDURE [dbo].[uspICDCCatGLAcctsMigrationAg]
--** Below Stored Procedure is to migrate inventory related gl accounts from origin to i21 tables such as tblICCategoryAccount, tblICItemAccount. **

AS
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF



--------------------------------------------------------------------------------------------------------------------------------------------
-- GL ACCOUNTS data migration from origin tables agclsmst, agctlmst and agitmmst to i21 tables tblICCategoryAccount and tblICItemAccount 
-- Section 9
--** Category Accounts are migrated from origin tables agclsmst and agctlmst to i21 table tblICCategoryAccount **
--** Item Accounts are migrated from origin tables agitmmst to i21 table tblICItemAccount **
--** Refer "Inventory Accounts migration" document attached to the JIRA ticket for furter columne level mapping details **
--------------------------------------------------------------------------------------------------------------------------------------------
--** From Class (agclsmst) table below 3 accounts (Sales, Variance and Inventory accounts) are mapped 
--   into tblICCategoryAccount table removing duplicates and ignoring the invalid accounts. **
-- Items are of different types and it requires specific GL accounts categories. For example, Inventory type requires Inventory Account

INSERT INTO tblICCategoryAccount (
	intCategoryId
	,intAccountCategoryId
	,intAccountId
	,intConcurrencyId
	) (
	SELECT cat.intCategoryId
--	,seg.intAccountCategoryId
	,(select intAccountCategoryId from tblGLAccountCategory where strAccountCategory = 'Sales Account') AccountCategoryId
	,act.intAccountId
	,1 ConcurrencyId
	FROM agclsmst AS cls 
	INNER JOIN tblICCategory AS cat ON cls.agcls_cd COLLATE SQL_Latin1_General_CP1_CS_AS = cat.strCategoryCode COLLATE SQL_Latin1_General_CP1_CS_AS 
	INNER JOIN tblGLCOACrossReference AS coa ON coa.strExternalId = cls.agcls_sls_acct_no 
	INNER JOIN tblGLAccount AS act ON act.intAccountId = coa.inti21Id 
	WHERE coa.strExternalId = cls.agcls_sls_acct_no
	and cat.strInventoryType in ('Inventory', 'Finished Good', 'Raw Material')
UNION

	SELECT cat.intCategoryId
--	,seg.intAccountCategoryId
	,(select intAccountCategoryId from tblGLAccountCategory where strAccountCategory = 'Cost of Goods') AccountCategoryId
	,act.intAccountId
	,1 
	FROM agclsmst AS cls 
	INNER JOIN tblICCategory AS cat ON cls.agcls_cd COLLATE SQL_Latin1_General_CP1_CS_AS = cat.strCategoryCode COLLATE SQL_Latin1_General_CP1_CS_AS 
	INNER JOIN tblGLCOACrossReference AS coa ON coa.strExternalId = cls.agcls_pur_acct_no 
	INNER JOIN tblGLAccount AS act ON act.intAccountId = coa.inti21Id 
	WHERE coa.strExternalId = cls.agcls_pur_acct_no
	and cat.strInventoryType in ('Inventory', 'Finished Good', 'Raw Material')
UNION
	
	SELECT cat.intCategoryId
--	,seg.intAccountCategoryId
	,(select intAccountCategoryId from tblGLAccountCategory where strAccountCategory = 'Inventory') AccountCategoryId
	,act.intAccountId
	,1 
	FROM agclsmst AS cls 
	INNER JOIN tblICCategory AS cat ON cls.agcls_cd COLLATE SQL_Latin1_General_CP1_CS_AS = cat.strCategoryCode COLLATE SQL_Latin1_General_CP1_CS_AS 
	INNER JOIN tblGLCOACrossReference AS coa ON coa.strExternalId = cls.agcls_inv_acct_no 
	INNER JOIN tblGLAccount AS act ON act.intAccountId = coa.inti21Id 
	WHERE coa.strExternalId = cls.agcls_inv_acct_no
	and cat.strInventoryType in ('Inventory', 'Finished Good', 'Raw Material')
)
	


--** From Control File (agctlmst) table below 2 accounts (Pending A/P and COGS account) are mapped into tblICCategoryAccount
--   table removing duplicates and ignoring the invalid accounts. These accounts are mapped only for inventory classed.
--   These 2 accounts remains constant for all inventory classes. **
INSERT INTO tblICCategoryAccount (
	intCategoryId
	,intAccountCategoryId
	,intAccountId
	,intConcurrencyId
	) (
	SELECT cat.intCategoryId
--	,seg.intAccountCategoryId
	,(select intAccountCategoryId from tblGLAccountCategory where strAccountCategory = 'AP Clearing') AccountCategoryId
	,act.intAccountId
	,1 ConcurrencyId
	FROM agclsmst AS cls 
	INNER JOIN tblICCategory AS cat ON cls.agcls_cd COLLATE SQL_Latin1_General_CP1_CS_AS = cat.strCategoryCode COLLATE SQL_Latin1_General_CP1_CS_AS 
	INNER JOIN agctlmst AS cgl ON cgl.agctl_key = 06 
	INNER JOIN tblGLCOACrossReference AS coa ON coa.strExternalId = cgl.agcgl_pend_ap 
	INNER JOIN tblGLAccount AS act ON act.intAccountId = coa.inti21Id 
	WHERE coa.strExternalId = cgl.agcgl_pend_ap
	and cat.strInventoryType in ('Inventory', 'Finished Good', 'Raw Material')
)
------------------------------------------------------
--import gl accounts for 'Other Charge' category


INSERT INTO tblICCategoryAccount (
	intCategoryId
	,intAccountCategoryId
	,intAccountId
	,intConcurrencyId
	) (
	SELECT cat.intCategoryId
--	,seg.intAccountCategoryId
	,(select intAccountCategoryId from tblGLAccountCategory where strAccountCategory = 'Other Charge Income') AccountCategoryId
	,act.intAccountId
	,1 ConcurrencyId
	FROM agclsmst AS cls 
	INNER JOIN tblICCategory AS cat ON cls.agcls_cd COLLATE SQL_Latin1_General_CP1_CS_AS = cat.strCategoryCode COLLATE SQL_Latin1_General_CP1_CS_AS 
	INNER JOIN tblGLCOACrossReference AS coa ON coa.strExternalId = cls.agcls_sls_acct_no 
	INNER JOIN tblGLAccount AS act ON act.intAccountId = coa.inti21Id 
	WHERE coa.strExternalId = cls.agcls_sls_acct_no
	and cat.strInventoryType = 'Other Charge'
)

INSERT INTO tblICCategoryAccount (
	intCategoryId
	,intAccountCategoryId
	,intAccountId
	,intConcurrencyId
	) (
	SELECT cat.intCategoryId
--	,seg.intAccountCategoryId
	,(select intAccountCategoryId from tblGLAccountCategory where strAccountCategory = 'Other Charge Expense') AccountCategoryId
	,act.intAccountId
	,1 ConcurrencyId
	FROM agclsmst AS cls 
	INNER JOIN tblICCategory AS cat ON cls.agcls_cd COLLATE SQL_Latin1_General_CP1_CS_AS = cat.strCategoryCode COLLATE SQL_Latin1_General_CP1_CS_AS 
	INNER JOIN tblGLCOACrossReference AS coa ON coa.strExternalId = cls.agcls_pur_acct_no 
	INNER JOIN tblGLAccount AS act ON act.intAccountId = coa.inti21Id 
	WHERE coa.strExternalId = cls.agcls_pur_acct_no
	and cat.strInventoryType = 'Other Charge'
)

---------------------------------------------------------------------------------------------------
----update the account table with correct account category required for inventory & sales accounts to function

UPDATE tgs SET intAccountCategoryId = act.intAccountCategoryId
--select c.strDescription,ca.intCategoryId,ac.strAccountId,ac.strDescription, ca.intAccountCategoryId, tgs.intAccountCategoryId,act.intAccountCategoryId
from tblICCategoryAccount ca 
join tblGLAccount ac on ca.intAccountId = ac.intAccountId
join tblICCategory c on ca.intCategoryId = c.intCategoryId
join tblGLAccountCategory act on ca.intAccountCategoryId = act.intAccountCategoryId
join tblGLAccountSegmentMapping sm on sm.intAccountId = ac.intAccountId
join tblGLAccountSegment tgs on tgs.intAccountSegmentId = sm.intAccountSegmentId
join tblGLAccountStructure ast on ast.intAccountStructureId = tgs.intAccountStructureId
where act.strAccountCategory in ('Inventory', 'Sales Account')
and c.strInventoryType in ('Inventory', 'Raw Material', 'Finished Goods')
and ast.strType = 'Primary'


GO

