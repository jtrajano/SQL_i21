Create PROCEDURE [dbo].[uspICDCGLAcctsMigration]
--** Below Stored Procedure is to migrate inventory related gl accounts from origin to i21 tables such as tblICCategoryAccount, tblICItemAccount. **

AS
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

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
	,seg.intAccountCategoryId
	,act.intAccountId
	,1 FROM ptclsmst AS cls INNER JOIN tblICCategory AS cat ON cls.ptcls_class COLLATE SQL_Latin1_General_CP1_CS_AS = cat.strCategoryCode COLLATE SQL_Latin1_General_CP1_CS_AS INNER JOIN tblGLCOACrossReference AS coa ON coa.strExternalId = cls.ptcls_sls_acct_no INNER JOIN tblGLAccount AS act ON act.intAccountId = coa.intCrossReferenceId INNER JOIN tblGLAccountSegmentMapping AS segm ON segm.intAccountId = coa.intCrossReferenceId INNER JOIN tblGLAccountSegment AS seg ON seg.intAccountSegmentId = segm.intAccountSegmentId WHERE coa.strExternalId = cls.ptcls_sls_acct_no
	AND seg.strCode = SUBSTRING(strExternalId, 0, CHARINDEX('.', strExternalId))

UNION
	
	SELECT cat.intCategoryId
	,seg.intAccountCategoryId
	,act.intAccountId
	,1 FROM ptclsmst AS cls INNER JOIN tblICCategory AS cat ON cls.ptcls_class COLLATE SQL_Latin1_General_CP1_CS_AS = cat.strCategoryCode COLLATE SQL_Latin1_General_CP1_CS_AS INNER JOIN tblGLCOACrossReference AS coa ON coa.strExternalId = cls.ptcls_var_acct_no INNER JOIN tblGLAccount AS act ON act.intAccountId = coa.intCrossReferenceId INNER JOIN tblGLAccountSegmentMapping AS segm ON segm.intAccountId = coa.intCrossReferenceId INNER JOIN tblGLAccountSegment AS seg ON seg.intAccountSegmentId = segm.intAccountSegmentId WHERE coa.strExternalId = cls.ptcls_var_acct_no
	AND seg.strCode = SUBSTRING(strExternalId, 0, CHARINDEX('.', strExternalId))

UNION
	
	SELECT cat.intCategoryId
	,seg.intAccountCategoryId
	,act.intAccountId
	,1 FROM ptclsmst AS cls INNER JOIN tblICCategory AS cat ON cls.ptcls_class COLLATE SQL_Latin1_General_CP1_CS_AS = cat.strCategoryCode COLLATE SQL_Latin1_General_CP1_CS_AS INNER JOIN tblGLCOACrossReference AS coa ON coa.strExternalId = cls.ptcls_inv_acct_no INNER JOIN tblGLAccount AS act ON act.intAccountId = coa.intCrossReferenceId INNER JOIN tblGLAccountSegmentMapping AS segm ON segm.intAccountId = coa.intCrossReferenceId INNER JOIN tblGLAccountSegment AS seg ON seg.intAccountSegmentId = segm.intAccountSegmentId WHERE coa.strExternalId = cls.ptcls_inv_acct_no
	AND seg.strCode = SUBSTRING(strExternalId, 0, CHARINDEX('.', strExternalId))
	)

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
	,seg.intAccountCategoryId
	,act.intAccountId
	,1 FROM ptclsmst AS cls INNER JOIN tblICCategory AS cat ON cls.ptcls_class COLLATE SQL_Latin1_General_CP1_CS_AS = cat.strCategoryCode COLLATE SQL_Latin1_General_CP1_CS_AS INNER JOIN ptmglmst AS mgl ON mgl.ptmgl_key = 01 INNER JOIN tblGLCOACrossReference AS coa ON coa.strExternalId = mgl.ptmgl_ap INNER JOIN tblGLAccount AS act ON act.intAccountId = coa.intCrossReferenceId INNER JOIN tblGLAccountSegmentMapping AS segm ON segm.intAccountId = coa.intCrossReferenceId INNER JOIN tblGLAccountSegment AS seg ON seg.intAccountSegmentId = segm.intAccountSegmentId WHERE coa.strExternalId = mgl.ptmgl_ap
	AND seg.strCode = SUBSTRING(strExternalId, 0, CHARINDEX('.', strExternalId))

UNION
	
	SELECT cat.intCategoryId
	,seg.intAccountCategoryId
	,act.intAccountId
	,1 FROM ptclsmst AS cls INNER JOIN tblICCategory AS cat ON cls.ptcls_class COLLATE SQL_Latin1_General_CP1_CS_AS = cat.strCategoryCode COLLATE SQL_Latin1_General_CP1_CS_AS INNER JOIN ptmglmst AS mgl ON mgl.ptmgl_key = 01 INNER JOIN tblGLCOACrossReference AS coa ON coa.strExternalId = mgl.ptmgl_pur_variance INNER JOIN tblGLAccount AS act ON act.intAccountId = coa.intCrossReferenceId INNER JOIN tblGLAccountSegmentMapping AS segm ON segm.intAccountId = coa.intCrossReferenceId INNER JOIN tblGLAccountSegment AS seg ON seg.intAccountSegmentId = segm.intAccountSegmentId WHERE coa.strExternalId = mgl.ptmgl_pur_variance
	AND seg.strCode = SUBSTRING(strExternalId, 0, CHARINDEX('.', strExternalId))
	)

--** From Inventory (ptitmmst) table below 2 accounts (Sales and Variance account) are mapped 
--   into tblICItemAccount table removing duplicates and ignoring the invalid accounts. **
INSERT INTO tblICItemAccount (
	intItemId
	,intAccountCategoryId
	,intAccountId
	,intConcurrencyId
	) (
	SELECT inv.intItemId
	,seg.intAccountCategoryId
	,act.intAccountId
	,1 FROM ptitmmst AS itm INNER JOIN tblICItem AS inv ON (itm.ptitm_itm_no COLLATE SQL_Latin1_General_CP1_CS_AS = inv.strItemNo COLLATE SQL_Latin1_General_CP1_CS_AS) INNER JOIN tblICCategory AS cat ON inv.intCategoryId = cat.intCategoryId INNER JOIN tblGLCOACrossReference AS coa ON coa.strExternalId = itm.ptitm_sls_acct INNER JOIN tblGLAccount AS act ON act.intAccountId = coa.intCrossReferenceId INNER JOIN tblGLAccountSegmentMapping AS segm ON segm.intAccountId = coa.intCrossReferenceId INNER JOIN tblGLAccountSegment AS seg ON seg.intAccountSegmentId = segm.intAccountSegmentId WHERE coa.strExternalId = itm.ptitm_sls_acct
	AND seg.strCode = SUBSTRING(strExternalId, 0, CHARINDEX('.', strExternalId))
	)

UNION

SELECT inv.intItemId
	,seg.intAccountCategoryId
	,act.intAccountId
	,1
FROM ptitmmst AS itm
INNER JOIN tblICItem AS inv ON (itm.ptitm_itm_no COLLATE SQL_Latin1_General_CP1_CS_AS = inv.strItemNo COLLATE SQL_Latin1_General_CP1_CS_AS)
INNER JOIN tblICCategory AS cat ON inv.intCategoryId = cat.intCategoryId
INNER JOIN tblGLCOACrossReference AS coa ON coa.strExternalId = itm.ptitm_var_acct
INNER JOIN tblGLAccount AS act ON act.intAccountId = coa.intCrossReferenceId
INNER JOIN tblGLAccountSegmentMapping AS segm ON segm.intAccountId = coa.intCrossReferenceId
INNER JOIN tblGLAccountSegment AS seg ON seg.intAccountSegmentId = segm.intAccountSegmentId
WHERE coa.strExternalId = itm.ptitm_var_acct AND seg.strCode = SUBSTRING(strExternalId, 0, CHARINDEX('.', strExternalId))
--------------------------------------------------------------------------------------------------------------------------------------------