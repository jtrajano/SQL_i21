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

--UPDATE tgs SET intAccountCategoryId = tgc.intAccountCategoryId
--FROM dbo.tblGLAccountSegment tgs  
--JOIN 
--(--purchase
----select distinct(SUBSTRING(CAST(ptitm_pur_acct AS VARCHAR), 0, CHARINDEX('.', ptitm_pur_acct))) code,'Cost of Goods' cat from ptitmmst  
----where ptitm_phys_inv_yno = 'Y'
----union
-----Sales Account Category
----select distinct(SUBSTRING(CAST(ptitm_sls_acct AS VARCHAR), 0, CHARINDEX('.', ptitm_sls_acct))) code,'Sales Account'cat from ptitmmst 
----where ptitm_phys_inv_yno = 'Y'
----union
-----Inventory Category
--select distinct(SUBSTRING(CAST(ptcls_inv_acct_no AS VARCHAR), 0, CHARINDEX('.', ptcls_inv_acct_no))) code, 'Inventory' cat from ptclsmst
--where ptcls_class in (select distinct ptitm_class from ptitmmst where ptitm_phys_inv_yno = 'Y')
--union
-----AP Clearing Category 
--select distinct(SUBSTRING(CAST(ptmgl_ap AS VARCHAR), 0, CHARINDEX('.', ptmgl_ap))) code, 'AP Clearing' cat from ptmglmst
--) as t 
--ON tgs.strCode = t.code  COLLATE SQL_Latin1_General_CP1_CS_AS
--JOIN dbo.tblGLAccountCategory tgc ON t.cat  COLLATE SQL_Latin1_General_CP1_CS_AS = tgc.strAccountCategory 


--------------------------------------------------------------------------------------------------------------------------------------------
-- GL ACCOUNTS data migration from origin tables ptclsmst, ptmglmst and ptitmmst to i21 tables tblICCategoryAccount and tblICItemAccount 
-- Section 9
--** Category Accounts are migrated from origin tables ptclsmst and ptmglmst to i21 table tblICCategoryAccount **
--** Item Accounts are migrated from origin tables ptitmmst to i21 table tblICItemAccount **
--** Refer "Inventory Accounts migration" document attached to the JIRA ticket for furter columne level mapping details **
--------------------------------------------------------------------------------------------------------------------------------------------
--** From Class (ptclsmst) table below 3 accounts (Sales, Variance and Inventory accounts) are mapped 
--   into tblICCategoryAccount table removing duplicates and ignoring the invalid accounts. **

	SELECT distinct ptcls_class INTO #TMPCLS FROM ptfrmmst
	inner join ptitmmst itm on itm.ptitm_itm_no = ptfrm_itm_no and itm.ptitm_loc_no = ptfrm_loc_no
	inner join ptclsmst cls on cls.ptcls_class = itm.ptitm_class
	DECLARE @cnt INT = 1,
	@SQLCMD VARCHAR (3000)

	WHILE @cnt < 11
	BEGIN
	   SET @SQLCMD = '	INSERT INTO #TMPCLS (ptcls_class) SELECT distinct ptcls_class FROM ptfrmmst 
				inner join ptitmmst itm on itm.ptitm_itm_no = ptfrm_ingr_itm_no_'+CAST(@cnt AS NVARCHAR)+' and itm.ptitm_loc_no = ptfrm_loc_no
				inner join ptclsmst cls on cls.ptcls_class = itm.ptitm_class'+
				' WHERE ptfrm_ingr_itm_no_'+CAST(@cnt AS NVARCHAR)+' IS NOT NULL  '

				EXEC (@SQLCMD)
	   SET @cnt = @cnt + 1;
	END

MERGE tblICCategoryAccount AS [Target]
USING
(
	SELECT
		  intCategoryId			= cat.intCategoryId
		, intAccountCategoryId	= (select intAccountCategoryId from tblGLAccountCategory where strAccountCategory = 'Sales Account')
		, intAccountId			= act.intAccountId
		, intConcurrencyId		= 1
	FROM ptclsmst AS cls 
		INNER JOIN tblICCategory AS cat ON cls.ptcls_class COLLATE SQL_Latin1_General_CP1_CS_AS = cat.strCategoryCode COLLATE SQL_Latin1_General_CP1_CS_AS 
		INNER JOIN tblGLCOACrossReference AS coa ON coa.strExternalId = cls.ptcls_sls_acct_no 
		INNER JOIN tblGLAccount AS act ON act.intAccountId = coa.inti21Id 
	WHERE coa.strExternalId = cls.ptcls_sls_acct_no
		and cat.strInventoryType in ('Inventory', 'Finished Good', 'Raw Material')

	UNION
	
		SELECT 
			  intCategoryId			= cat.intCategoryId
			, intAccountCategoryId	= (select intAccountCategoryId from tblGLAccountCategory where strAccountCategory = 'Cost of Goods')
			, intAccountId			= act.intAccountId
			, intConcurrencyId		= 1
		FROM ptclsmst AS cls 
			INNER JOIN tblICCategory AS cat ON cls.ptcls_class COLLATE SQL_Latin1_General_CP1_CS_AS = cat.strCategoryCode COLLATE SQL_Latin1_General_CP1_CS_AS 
			INNER JOIN tblGLCOACrossReference AS coa ON coa.strExternalId = cls.ptcls_pur_acct_no 
			INNER JOIN tblGLAccount AS act ON act.intAccountId = coa.inti21Id 
		WHERE coa.strExternalId = cls.ptcls_pur_acct_no
			and cat.strInventoryType in ('Inventory', 'Finished Good', 'Raw Material')

	UNION
		SELECT
		  intCategoryId			= cat.intCategoryId
		, intAccountCategoryId	= (select intAccountCategoryId from tblGLAccountCategory where strAccountCategory = 'Inventory')
		, intAccountId			= act.intAccountId
		, intConcurrencyId		= 1
		FROM ptclsmst AS cls 
			INNER JOIN tblICCategory AS cat ON cls.ptcls_class COLLATE SQL_Latin1_General_CP1_CS_AS = cat.strCategoryCode COLLATE SQL_Latin1_General_CP1_CS_AS 
			INNER JOIN tblGLCOACrossReference AS coa ON coa.strExternalId = cls.ptcls_inv_acct_no 
			INNER JOIN tblGLAccount AS act ON act.intAccountId = coa.inti21Id 
		WHERE coa.strExternalId = cls.ptcls_inv_acct_no
			and cat.strInventoryType in ('Inventory', 'Finished Good', 'Raw Material')
	UNION
		SELECT
		  intCategoryId			= cat.intCategoryId
		, intAccountCategoryId	= (select intAccountCategoryId from tblGLAccountCategory where strAccountCategory = 'Inventory In-Transit')
		, intAccountId			= act.intAccountId
		, intConcurrencyId		= 1
		FROM ptclsmst AS cls 
			INNER JOIN tblICCategory AS cat ON cls.ptcls_class COLLATE SQL_Latin1_General_CP1_CS_AS = cat.strCategoryCode COLLATE SQL_Latin1_General_CP1_CS_AS 
			INNER JOIN tblGLCOACrossReference AS coa ON coa.strExternalId = cls.ptcls_inv_acct_no 
			INNER JOIN tblGLAccount AS act ON act.intAccountId = coa.inti21Id 
		WHERE coa.strExternalId = cls.ptcls_inv_acct_no
			and cat.strInventoryType in ('Inventory', 'Finished Good', 'Raw Material')
	UNION
		SELECT
		  intCategoryId			= cat.intCategoryId
		, intAccountCategoryId	= (select intAccountCategoryId from tblGLAccountCategory where strAccountCategory = 'Work In Progress')
		, intAccountId			= act.intAccountId
		, intConcurrencyId		= 1
		FROM ptclsmst AS cls 
			INNER JOIN tblICCategory AS cat ON cls.ptcls_class COLLATE SQL_Latin1_General_CP1_CS_AS = cat.strCategoryCode COLLATE SQL_Latin1_General_CP1_CS_AS 
			INNER JOIN tblGLCOACrossReference AS coa ON coa.strExternalId = cls.ptcls_inv_acct_no 
			INNER JOIN tblGLAccount AS act ON act.intAccountId = coa.inti21Id 
		WHERE coa.strExternalId = cls.ptcls_inv_acct_no
			and cat.strInventoryType in ('Inventory', 'Finished Good', 'Raw Material')
			AND cls.ptcls_class  in (select ptcls_class from #TMPCLS where ptcls_class = cls.ptcls_class)
) AS [Source] (intCategoryId, intAccountCategoryId, intAccountId, intConcurrencyId)
ON [Target].intAccountCategoryId = [Source].intAccountCategoryId
	AND [Target].intCategoryId = [Source].intCategoryId
WHEN NOT MATCHED THEN
INSERT (intCategoryId, intAccountCategoryId, intAccountId, intConcurrencyId)
VALUES ([Source].intCategoryId, [Source].intAccountCategoryId, [Source].intAccountId, [Source].intConcurrencyId);

--** From PT Control File (ptmglmst) table below 2 accounts (Pending A/P and COGS account) are mapped into tblICCategoryAccount
--   table removing duplicates and ignoring the invalid accounts. These accounts are mapped only for inventory classed.
--   These 2 accounts remains constant for all inventory classes. **
MERGE tblICCategoryAccount AS [Target]
USING
(
	SELECT
		  intCategoryId			= cat.intCategoryId
		, intAccountCategoryId	= (select intAccountCategoryId from tblGLAccountCategory where strAccountCategory = 'AP Clearing')
		, intAccountId			= act.intAccountId
		, intConcurrencyId		= 1
	FROM ptclsmst AS cls 
		INNER JOIN tblICCategory AS cat ON cls.ptcls_class COLLATE SQL_Latin1_General_CP1_CS_AS = cat.strCategoryCode COLLATE SQL_Latin1_General_CP1_CS_AS 
		INNER JOIN ptmglmst AS cgl ON cgl.ptmgl_key = 01 
		INNER JOIN tblGLCOACrossReference AS coa ON coa.strExternalId = cgl.ptmgl_ap 
		INNER JOIN tblGLAccount AS act ON act.intAccountId = coa.inti21Id 
	WHERE coa.strExternalId = cgl.ptmgl_ap
) AS [Source] (intCategoryId, intAccountCategoryId, intAccountId, intConcurrencyId)
ON [Target].intAccountCategoryId = [Source].intAccountCategoryId
	AND [Target].intCategoryId = [Source].intCategoryId
WHEN NOT MATCHED THEN
INSERT (intCategoryId, intAccountCategoryId, intAccountId, intConcurrencyId)
VALUES ([Source].intCategoryId, [Source].intAccountCategoryId, [Source].intAccountId, [Source].intConcurrencyId);


--UNION
	
--	SELECT cat.intCategoryId
--	,seg.intAccountCategoryId
--	,act.intAccountId
--	,1 FROM ptclsmst AS cls INNER JOIN tblICCategory AS cat ON cls.ptcls_class COLLATE SQL_Latin1_General_CP1_CS_AS = cat.strCategoryCode COLLATE SQL_Latin1_General_CP1_CS_AS INNER JOIN ptmglmst AS mgl ON mgl.ptmgl_key = 01 INNER JOIN tblGLCOACrossReference AS coa ON coa.strExternalId = mgl.ptmgl_pur_variance INNER JOIN tblGLAccount AS act ON act.intAccountId = coa.inti21Id INNER JOIN tblGLAccountSegmentMapping AS segm ON segm.intAccountId = coa.inti21Id INNER JOIN tblGLAccountSegment AS seg ON seg.intAccountSegmentId = segm.intAccountSegmentId WHERE coa.strExternalId = mgl.ptmgl_pur_variance
--	AND seg.strCode = SUBSTRING(strExternalId, 0, CHARINDEX('.', strExternalId))
--)

------------------------------------------------------
--import gl accounts for 'Other Charge' category
MERGE tblICCategoryAccount AS [Target]
USING
(
	SELECT
		  intCategoryId			= cat.intCategoryId
		, intAccountCategoryId	= (select intAccountCategoryId from tblGLAccountCategory where strAccountCategory = 'Other Charge Income')
		, intAccountId			= act.intAccountId
		, intConcurrencyId		= 1
	FROM ptclsmst AS cls 
		INNER JOIN tblICCategory AS cat ON cls.ptcls_class COLLATE SQL_Latin1_General_CP1_CS_AS = cat.strCategoryCode COLLATE SQL_Latin1_General_CP1_CS_AS 
		INNER JOIN tblGLCOACrossReference AS coa ON coa.strExternalId = cls.ptcls_sls_acct_no 
		INNER JOIN tblGLAccount AS act ON act.intAccountId = coa.inti21Id 
	WHERE coa.strExternalId = cls.ptcls_sls_acct_no
		and cat.strInventoryType = 'Other Charge'
) AS [Source] (intCategoryId, intAccountCategoryId, intAccountId, intConcurrencyId)
ON [Target].intAccountCategoryId = [Source].intAccountCategoryId
	AND [Target].intCategoryId = [Source].intCategoryId
WHEN NOT MATCHED THEN
INSERT (intCategoryId, intAccountCategoryId, intAccountId, intConcurrencyId)
VALUES ([Source].intCategoryId, [Source].intAccountCategoryId, [Source].intAccountId, [Source].intConcurrencyId);


MERGE tblICCategoryAccount AS [Target]
USING
(
	SELECT
		  intCategoryId			= cat.intCategoryId
		, intAccountCategoryId	= (select intAccountCategoryId from tblGLAccountCategory where strAccountCategory = 'Other Charge Expense') 
		, intAccountId			= act.intAccountId
		, intConcurrencyId		= 1
	FROM ptclsmst AS cls 
		INNER JOIN tblICCategory AS cat ON cls.ptcls_class COLLATE SQL_Latin1_General_CP1_CS_AS = cat.strCategoryCode COLLATE SQL_Latin1_General_CP1_CS_AS 
		INNER JOIN tblGLCOACrossReference AS coa ON coa.strExternalId = cls.ptcls_pur_acct_no 
		INNER JOIN tblGLAccount AS act ON act.intAccountId = coa.inti21Id 
	WHERE coa.strExternalId = cls.ptcls_pur_acct_no
		and cat.strInventoryType = 'Other Charge'
) AS [Source] (intCategoryId, intAccountCategoryId, intAccountId, intConcurrencyId)
ON [Target].intAccountCategoryId = [Source].intAccountCategoryId
	AND [Target].intCategoryId = [Source].intCategoryId
WHEN NOT MATCHED THEN
INSERT (intCategoryId, intAccountCategoryId, intAccountId, intConcurrencyId)
VALUES ([Source].intCategoryId, [Source].intAccountCategoryId, [Source].intAccountId, [Source].intConcurrencyId);

-----------------------------------------------------------------------------------------------------
--------update the account table with correct account category required for inventory to function
UPDATE tgs SET intAccountCategoryId = act.intAccountCategoryId
--select c.strDescription,ca.intCategoryId,ac.strAccountId,ac.strDescription, ca.intAccountCategoryId, tgs.intAccountCategoryId,act.intAccountCategoryId
from tblICCategoryAccount ca 
join tblGLAccount ac on ca.intAccountId = ac.intAccountId
join tblICCategory c on ca.intCategoryId = c.intCategoryId
join tblGLAccountCategory act on ca.intAccountCategoryId = act.intAccountCategoryId
join tblGLAccountSegmentMapping sm on sm.intAccountId = ac.intAccountId
join tblGLAccountSegment tgs on tgs.intAccountSegmentId = sm.intAccountSegmentId
join tblGLAccountStructure ast on ast.intAccountStructureId = tgs.intAccountStructureId
where act.strAccountCategory in ('Inventory', 'Sales Account','Inventory Adjustment','AP Clearing')
and c.strInventoryType in ('Inventory', 'Raw Material', 'Finished Good')
and ast.strType = 'Primary'

GO
--------------------------------------------------------------------------------------------------------------------------------------------