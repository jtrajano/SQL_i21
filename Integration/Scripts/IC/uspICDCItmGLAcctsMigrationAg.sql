IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[uspICDCItmGLAcctsMigrationAg]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [uspICDCItmGLAcctsMigrationAg]; 
GO 

CREATE PROCEDURE [dbo].[uspICDCItmGLAcctsMigrationAg]
--** Below Stored Procedure is to migrate inventory related gl accounts from origin to i21 tables such as tblICCategoryAccount, tblICItemAccount. **

AS
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

--=============================================================
--RUN THIS SCRIPT ONLY IF ACCOUNTS ARE SETUP ONLY IN ITEMS IN ORIGIN
---------=======================================================
--** From Inventory (agitmmst) table below 2 accounts (Sales and Variance account) are mapped 
--   into tblICItemAccount table removing duplicates and ignoring the invalid accounts. **
-- select top 1 as multiple locations are repeated in origin table
-- update accounts for type 'Inventory' 
--sales account
INSERT INTO tblICItemAccount (
	intItemId
	,intAccountCategoryId
	,intAccountId
	,intConcurrencyId
	) 
select I.intItemId,ac.intAccountCategoryId, ac.intAccountId, 1 intConcurrencyId from tblICItem I
Cross Apply
	(SELECT top 1 inv.intItemId
	--,seg.intAccountCategoryId
	,(select intAccountCategoryId from tblGLAccountCategory where strAccountCategory = 'Sales Account') intAccountCategoryId
	,act.intAccountId
	FROM agitmmst AS itm 
	INNER JOIN tblICItem AS inv ON (itm.agitm_no COLLATE SQL_Latin1_General_CP1_CS_AS = inv.strItemNo COLLATE SQL_Latin1_General_CP1_CS_AS) 
	INNER JOIN tblGLCOACrossReference AS coa ON coa.strExternalId = itm.agitm_sls_acct 
	INNER JOIN tblGLAccount AS act ON act.intAccountId = coa.intCrossReferenceId 
	WHERE coa.strExternalId = itm.agitm_sls_acct
	and inv.strType in ('Inventory', 'Finished Good', 'Raw Material') 
	and I.intItemId = inv.intItemId) as ac

--cogs account	
INSERT INTO tblICItemAccount (
	intItemId
	,intAccountCategoryId
	,intAccountId
	,intConcurrencyId
	) 
	select I.intItemId,ac.intAccountCategoryId, ac.intAccountId, 1 intConcurrencyId from tblICItem I
Cross Apply
	(SELECT top 1 inv.intItemId
	--,seg.intAccountCategoryId
	,(select intAccountCategoryId from tblGLAccountCategory where strAccountCategory = 'Cost of Goods') intAccountCategoryId
	,act.intAccountId
	FROM agitmmst AS itm 
	INNER JOIN tblICItem AS inv ON (itm.agitm_no COLLATE SQL_Latin1_General_CP1_CS_AS = inv.strItemNo COLLATE SQL_Latin1_General_CP1_CS_AS) 
	INNER JOIN tblGLCOACrossReference AS coa ON coa.strExternalId = itm.agitm_pur_acct 
	INNER JOIN tblGLAccount AS act ON act.intAccountId = coa.intCrossReferenceId 
	WHERE coa.strExternalId = itm.agitm_pur_acct
	and inv.strType in ('Inventory', 'Finished Good', 'Raw Material') 
	and I.intItemId = inv.intItemId) as ac

-- update accounts for type 'Other Charge' 
--Sales account to Other Charge Income account
INSERT INTO tblICItemAccount (
	intItemId
	,intAccountCategoryId
	,intAccountId
	,intConcurrencyId
	) 
select I.intItemId,ac.intAccountCategoryId, ac.intAccountId, 1 intConcurrencyId from tblICItem I
Cross Apply
	(SELECT top 1 inv.intItemId
	--,seg.intAccountCategoryId
	,(select intAccountCategoryId from tblGLAccountCategory where strAccountCategory = 'Other Charge Income') intAccountCategoryId
	,act.intAccountId
	FROM agitmmst AS itm 
	INNER JOIN tblICItem AS inv ON (itm.agitm_no COLLATE SQL_Latin1_General_CP1_CS_AS = inv.strItemNo COLLATE SQL_Latin1_General_CP1_CS_AS) 
	INNER JOIN tblGLCOACrossReference AS coa ON coa.strExternalId = itm.agitm_sls_acct 
	INNER JOIN tblGLAccount AS act ON act.intAccountId = coa.intCrossReferenceId 
	WHERE coa.strExternalId = itm.agitm_sls_acct
	and inv.strType = 'Other Charge' 
	and I.intItemId = inv.intItemId) as ac

--Purchase account to Other Charge Expense account
INSERT INTO tblICItemAccount (
	intItemId
	,intAccountCategoryId
	,intAccountId
	,intConcurrencyId
	) 
select I.intItemId,ac.intAccountCategoryId, ac.intAccountId, 1 intConcurrencyId from tblICItem I
Cross Apply
	(SELECT top 1 inv.intItemId
	--,seg.intAccountCategoryId
	,(select intAccountCategoryId from tblGLAccountCategory where strAccountCategory = 'Other Charge Expense') intAccountCategoryId
	,act.intAccountId
	FROM agitmmst AS itm 
	INNER JOIN tblICItem AS inv ON (itm.agitm_no COLLATE SQL_Latin1_General_CP1_CS_AS = inv.strItemNo COLLATE SQL_Latin1_General_CP1_CS_AS) 
	INNER JOIN tblGLCOACrossReference AS coa ON coa.strExternalId = itm.agitm_pur_acct 
	INNER JOIN tblGLAccount AS act ON act.intAccountId = coa.intCrossReferenceId 
	WHERE coa.strExternalId = itm.agitm_pur_acct
	and inv.strType = 'Other Charge' 
	and I.intItemId = inv.intItemId) as ac

GO

