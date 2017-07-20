IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[uspICDCItmGLAcctsMigrationPt]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [uspICDCItmGLAcctsMigrationPt]; 
GO 

CREATE PROCEDURE [dbo].[uspICDCItmGLAcctsMigrationPt]
--** Below Stored Procedure is to migrate inventory related gl accounts from origin to i21 tables such as tblICCategoryAccount, tblICItemAccount. **

AS
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF



--========================================================================================================================
--** From Inventory (ptitmmst) table below 2 accounts (Sales and Variance account) are mapped 
--   into tblICItemAccount table removing duplicates and ignoring the invalid accounts. **
-- select top 1 as multiple locations are repeated in origin table
-- update accounts for type 'Inventory' 
--sales account
MERGE tblICItemAccount AS [Target]
USING
(
	SELECT
		  intItemId				= I.intItemId
		, intAccountCategoryId	= ac.intAccountCategoryId
		, intAccountId			= ac.intAccountId
		, intConcurrencyId		= 1
	from tblICItem I
	Cross Apply (SELECT top 1 inv.intItemId
	--,seg.intAccountCategoryId
	,(select intAccountCategoryId from tblGLAccountCategory where strAccountCategory = 'Sales Account') intAccountCategoryId
		,act.intAccountId
		FROM ptitmmst AS itm 
			INNER JOIN tblICItem AS inv ON (itm.ptitm_itm_no COLLATE SQL_Latin1_General_CP1_CS_AS = inv.strItemNo COLLATE SQL_Latin1_General_CP1_CS_AS) 
			INNER JOIN tblGLCOACrossReference AS coa ON coa.strExternalId = itm.ptitm_sls_acct 
			INNER JOIN tblGLAccount AS act ON act.intAccountId = coa.intCrossReferenceId 
		WHERE coa.strExternalId = itm.ptitm_sls_acct
			and inv.strType in ('Inventory', 'Finished Good', 'Raw Material') 
			and I.intItemId = inv.intItemId
	) as ac
) AS [Source] (intItemId, intAccountCategoryId, intAccountId, intConcurrencyId)
ON [Target].intItemId = [Source].intItemId
	AND [Target].intAccountCategoryId = [Source].intAccountCategoryId
WHEN NOT MATCHED THEN
INSERT (intItemId, intAccountCategoryId, intAccountId, intConcurrencyId)
VALUES ([Source].intItemId, [Source].intAccountCategoryId, [Source].intAccountId, [Source].intConcurrencyId);

--cogs account
MERGE tblICItemAccount AS [Target]
USING
(
	SELECT
		  intItemId				= I.intItemId
		, intAccountCategoryId	= ac.intAccountCategoryId
		, intAccountId			= ac.intAccountId
		, intConcurrencyId		= 1
	from tblICItem I
	Cross Apply
	(SELECT top 1 inv.intItemId
		--,seg.intAccountCategoryId
		,(select intAccountCategoryId from tblGLAccountCategory where strAccountCategory = 'Cost of Goods') intAccountCategoryId
		,act.intAccountId
		FROM ptitmmst AS itm 
		INNER JOIN tblICItem AS inv ON (itm.ptitm_itm_no COLLATE SQL_Latin1_General_CP1_CS_AS = inv.strItemNo COLLATE SQL_Latin1_General_CP1_CS_AS) 
		INNER JOIN tblGLCOACrossReference AS coa ON coa.strExternalId = itm.ptitm_pur_acct 
		INNER JOIN tblGLAccount AS act ON act.intAccountId = coa.intCrossReferenceId 
		WHERE coa.strExternalId = itm.ptitm_pur_acct
		and inv.strType in ('Inventory', 'Finished Good', 'Raw Material') 
		and I.intItemId = inv.intItemId
	) as ac
) AS [Source] (intItemId, intAccountCategoryId, intAccountId, intConcurrencyId)
ON [Target].intItemId = [Source].intItemId
	AND [Target].intAccountCategoryId = [Source].intAccountCategoryId
WHEN NOT MATCHED THEN
INSERT (intItemId, intAccountCategoryId, intAccountId, intConcurrencyId)
VALUES ([Source].intItemId, [Source].intAccountCategoryId, [Source].intAccountId, [Source].intConcurrencyId);

-- update accounts for type 'Other Charge' 
--Sales account to Other Charge Income account
MERGE tblICItemAccount AS [Target]
USING
(
	SELECT
		  intItemId				= I.intItemId
		, intAccountCategoryId	= ac.intAccountCategoryId
		, intAccountId			= ac.intAccountId
		, intConcurrencyId		= 1
	from tblICItem I
	Cross Apply
	(SELECT top 1 inv.intItemId
		--,seg.intAccountCategoryId
		,(select intAccountCategoryId from tblGLAccountCategory where strAccountCategory = 'Other Charge Income') intAccountCategoryId
		,act.intAccountId
		FROM ptitmmst AS itm 
		INNER JOIN tblICItem AS inv ON (itm.ptitm_itm_no COLLATE SQL_Latin1_General_CP1_CS_AS = inv.strItemNo COLLATE SQL_Latin1_General_CP1_CS_AS) 
		INNER JOIN tblGLCOACrossReference AS coa ON coa.strExternalId = itm.ptitm_sls_acct 
		INNER JOIN tblGLAccount AS act ON act.intAccountId = coa.intCrossReferenceId 
		WHERE coa.strExternalId = itm.ptitm_sls_acct
		and inv.strType = 'Other Charge' 
		and I.intItemId = inv.intItemId
	) as ac
) AS [Source] (intItemId, intAccountCategoryId, intAccountId, intConcurrencyId)
ON [Target].intItemId = [Source].intItemId
	AND [Target].intAccountCategoryId = [Source].intAccountCategoryId
WHEN NOT MATCHED THEN
INSERT (intItemId, intAccountCategoryId, intAccountId, intConcurrencyId)
VALUES ([Source].intItemId, [Source].intAccountCategoryId, [Source].intAccountId, [Source].intConcurrencyId);

--Purchase account to Other Charge Expense account
MERGE tblICItemAccount AS [Target]
USING
(
	SELECT
		  intItemId				= I.intItemId
		, intAccountCategoryId	= ac.intAccountCategoryId
		, intAccountId			= ac.intAccountId
		, intConcurrencyId		= 1
	from tblICItem I
	Cross Apply
	(SELECT top 1 inv.intItemId
	--,seg.intAccountCategoryId
	,(select intAccountCategoryId from tblGLAccountCategory where strAccountCategory = 'Other Charge Expense') intAccountCategoryId
	,act.intAccountId
	FROM ptitmmst AS itm 
	INNER JOIN tblICItem AS inv ON (itm.ptitm_itm_no COLLATE SQL_Latin1_General_CP1_CS_AS = inv.strItemNo COLLATE SQL_Latin1_General_CP1_CS_AS) 
	INNER JOIN tblGLCOACrossReference AS coa ON coa.strExternalId = itm.ptitm_pur_acct 
	INNER JOIN tblGLAccount AS act ON act.intAccountId = coa.intCrossReferenceId 
	WHERE coa.strExternalId = itm.ptitm_pur_acct
	and inv.strType = 'Other Charge' 
	and I.intItemId = inv.intItemId) as ac
) AS [Source] (intItemId, intAccountCategoryId, intAccountId, intConcurrencyId)
ON [Target].intItemId = [Source].intItemId
	AND [Target].intAccountCategoryId = [Source].intAccountCategoryId
WHEN NOT MATCHED THEN
INSERT (intItemId, intAccountCategoryId, intAccountId, intConcurrencyId)
VALUES ([Source].intItemId, [Source].intAccountCategoryId, [Source].intAccountId, [Source].intConcurrencyId);

