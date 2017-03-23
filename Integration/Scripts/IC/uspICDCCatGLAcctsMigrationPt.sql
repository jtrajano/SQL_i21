IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[uspICDCCatGLAcctsMigrationPt]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [uspICDCCatGLAcctsMigrationPt]; 
GO 

CREATE PROCEDURE [dbo].[uspICDCCatGLAcctsMigrationPt]
--** Below Stored Procedure is to migrate inventory related gl accounts from origin to i21 tables such as tblICCategoryAccount, tblICItemAccount. **

AS
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF



---------------------------------------------------------------------------------------------------
------update the account table with correct account category required for inventory to function

UPDATE tgs SET intAccountCategoryId = tgc.intAccountCategoryId
FROM dbo.tblGLAccountSegment tgs  
JOIN 
(--purchase
--select distinct(SUBSTRING(CAST(ptitm_pur_acct AS VARCHAR), 0, CHARINDEX('.', ptitm_pur_acct))) code,'Cost of Goods' cat from ptitmmst  
--where ptitm_phys_inv_yno = 'Y'
--union
---Sales Account Category
--select distinct(SUBSTRING(CAST(ptitm_sls_acct AS VARCHAR), 0, CHARINDEX('.', ptitm_sls_acct))) code,'Sales Account'cat from ptitmmst 
--where ptitm_phys_inv_yno = 'Y'
--union
---Inventory Category
select distinct(SUBSTRING(CAST(ptcls_inv_acct_no AS VARCHAR), 0, CHARINDEX('.', ptcls_inv_acct_no))) code, 'Inventory' cat from ptclsmst
where ptcls_class in (select distinct ptitm_class from ptitmmst where ptitm_phys_inv_yno = 'Y')
union
---AP Clearing Category 
select distinct(SUBSTRING(CAST(ptmgl_ap AS VARCHAR), 0, CHARINDEX('.', ptmgl_ap))) code, 'AP Clearing' cat from ptmglmst
) as t 
ON tgs.strCode = t.code  COLLATE SQL_Latin1_General_CP1_CS_AS
JOIN dbo.tblGLAccountCategory tgc ON t.cat  COLLATE SQL_Latin1_General_CP1_CS_AS = tgc.strAccountCategory 


--------------------------------------------------------------------------------------------------------------------------------------------
-- GL ACCOUNTS data migration from origin tables ptclsmst, ptmglmst and ptitmmst to i21 tables tblICCategoryAccount and tblICItemAccount 
-- Section 9
--** Category Accounts are migrated from origin tables ptclsmst and ptmglmst to i21 table tblICCategoryAccount **
--** Item Accounts are migrated from origin tables ptitmmst to i21 table tblICItemAccount **
--** Refer "Inventory Accounts migration" document attached to the JIRA ticket for furter columne level mapping details **
--------------------------------------------------------------------------------------------------------------------------------------------
--** From Class (ptclsmst) table below 3 accounts (Sales, Variance and Inventory accounts) are mapped 
--   into tblICCategoryAccount table removing duplicates and ignoring the invalid accounts. **
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
	FROM ptclsmst AS cls 
	INNER JOIN tblICCategory AS cat ON cls.ptcls_class COLLATE SQL_Latin1_General_CP1_CS_AS = cat.strCategoryCode COLLATE SQL_Latin1_General_CP1_CS_AS 
	INNER JOIN tblGLCOACrossReference AS coa ON coa.strExternalId = cls.ptcls_sls_acct_no 
	INNER JOIN tblGLAccount AS act ON act.intAccountId = coa.intCrossReferenceId 
	WHERE coa.strExternalId = cls.ptcls_sls_acct_no
	and cat.strInventoryType in ('Inventory', 'Finished Good', 'Raw Material')

UNION
	
		SELECT cat.intCategoryId
--	,seg.intAccountCategoryId
	,(select intAccountCategoryId from tblGLAccountCategory where strAccountCategory = 'Cost of Goods') AccountCategoryId
	,act.intAccountId
	,1 ConcurrencyId
	FROM ptclsmst AS cls 
	INNER JOIN tblICCategory AS cat ON cls.ptcls_class COLLATE SQL_Latin1_General_CP1_CS_AS = cat.strCategoryCode COLLATE SQL_Latin1_General_CP1_CS_AS 
	INNER JOIN tblGLCOACrossReference AS coa ON coa.strExternalId = cls.ptcls_pur_acct_no 
	INNER JOIN tblGLAccount AS act ON act.intAccountId = coa.intCrossReferenceId 
	WHERE coa.strExternalId = cls.ptcls_pur_acct_no
	and cat.strInventoryType in ('Inventory', 'Finished Good', 'Raw Material')

UNION
	
		SELECT cat.intCategoryId
--	,seg.intAccountCategoryId
	,(select intAccountCategoryId from tblGLAccountCategory where strAccountCategory = 'Inventory') AccountCategoryId
	,act.intAccountId
	,1 ConcurrencyId
	FROM ptclsmst AS cls 
	INNER JOIN tblICCategory AS cat ON cls.ptcls_class COLLATE SQL_Latin1_General_CP1_CS_AS = cat.strCategoryCode COLLATE SQL_Latin1_General_CP1_CS_AS 
	INNER JOIN tblGLCOACrossReference AS coa ON coa.strExternalId = cls.ptcls_inv_acct_no 
	INNER JOIN tblGLAccount AS act ON act.intAccountId = coa.intCrossReferenceId 
	WHERE coa.strExternalId = cls.ptcls_inv_acct_no
	and cat.strInventoryType in ('Inventory', 'Finished Good', 'Raw Material')	)

--** From PT Control File (ptmglmst) table below 2 accounts (Pending A/P and COGS account) are mapped into tblICCategoryAccount
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
	FROM ptclsmst AS cls 
	INNER JOIN tblICCategory AS cat ON cls.ptcls_class COLLATE SQL_Latin1_General_CP1_CS_AS = cat.strCategoryCode COLLATE SQL_Latin1_General_CP1_CS_AS 
	INNER JOIN ptmglmst AS cgl ON cgl.ptmgl_key = 01 
	INNER JOIN tblGLCOACrossReference AS coa ON coa.strExternalId = cgl.ptmgl_ap 
	INNER JOIN tblGLAccount AS act ON act.intAccountId = coa.intCrossReferenceId 
	WHERE coa.strExternalId = cgl.ptmgl_ap
	and cat.strInventoryType in ('Inventory', 'Finished Good', 'Raw Material')
)

--UNION
	
--	SELECT cat.intCategoryId
--	,seg.intAccountCategoryId
--	,act.intAccountId
--	,1 FROM ptclsmst AS cls INNER JOIN tblICCategory AS cat ON cls.ptcls_class COLLATE SQL_Latin1_General_CP1_CS_AS = cat.strCategoryCode COLLATE SQL_Latin1_General_CP1_CS_AS INNER JOIN ptmglmst AS mgl ON mgl.ptmgl_key = 01 INNER JOIN tblGLCOACrossReference AS coa ON coa.strExternalId = mgl.ptmgl_pur_variance INNER JOIN tblGLAccount AS act ON act.intAccountId = coa.intCrossReferenceId INNER JOIN tblGLAccountSegmentMapping AS segm ON segm.intAccountId = coa.intCrossReferenceId INNER JOIN tblGLAccountSegment AS seg ON seg.intAccountSegmentId = segm.intAccountSegmentId WHERE coa.strExternalId = mgl.ptmgl_pur_variance
--	AND seg.strCode = SUBSTRING(strExternalId, 0, CHARINDEX('.', strExternalId))
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
	FROM ptclsmst AS cls 
	INNER JOIN tblICCategory AS cat ON cls.ptcls_class COLLATE SQL_Latin1_General_CP1_CS_AS = cat.strCategoryCode COLLATE SQL_Latin1_General_CP1_CS_AS 
	INNER JOIN tblGLCOACrossReference AS coa ON coa.strExternalId = cls.ptcls_sls_acct_no 
	INNER JOIN tblGLAccount AS act ON act.intAccountId = coa.intCrossReferenceId 
	WHERE coa.strExternalId = cls.ptcls_sls_acct_no
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
	FROM ptclsmst AS cls 
	INNER JOIN tblICCategory AS cat ON cls.ptcls_class COLLATE SQL_Latin1_General_CP1_CS_AS = cat.strCategoryCode COLLATE SQL_Latin1_General_CP1_CS_AS 
	INNER JOIN tblGLCOACrossReference AS coa ON coa.strExternalId = cls.ptcls_pur_acct_no 
	INNER JOIN tblGLAccount AS act ON act.intAccountId = coa.intCrossReferenceId 
	WHERE coa.strExternalId = cls.ptcls_pur_acct_no
	and cat.strInventoryType = 'Other Charge'
)

GO
--------------------------------------------------------------------------------------------------------------------------------------------