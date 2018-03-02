IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[uspICDCCommodityGLMigrationGr]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [uspICDCCommodityGLMigrationGr]; 
GO 

CREATE PROCEDURE [dbo].[uspICDCCommodityGLMigrationGr]

AS
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF



----===============================STEP 5===================================
----Import GL accounts for the category from origin commodity setup
----there could be multiple location. i21 adds the location segment to the account during transaction.
----only the primary account needs to be selected in category. Take one account for each category.
----*********************************************************************
----Only Sales and Inventory accounts are available from origin. Rest of the accounts like cogs, inventory adjustment etc have 
----to be manually setup as system will not know which one to pick.
----***********************************************************************
----sales account
INSERT INTO tblICCategoryAccount (	intCategoryId	,intAccountCategoryId	,intAccountId	,intConcurrencyId	) 
(
select c.intCategoryId, ac.AccountCategoryId, ac.intAccountId, 1 from tblICCategory c
cross apply
(SELECT top 1
cat.intCategoryId, cat.strCategoryCode ,
substring(coa.strExternalId, 0, CHARINDEX('.', coa.strExternalId)) ex,
--seg.intAccountCategoryId, 
(select intAccountCategoryId from tblGLAccountCategory where strAccountCategory = 'Sales Account') AccountCategoryId,
act.intAccountId, act.strDescription ACDescription 
	FROM gacommst AS cls 
	INNER JOIN tblICCategory AS cat ON cls.gacom_com_cd COLLATE SQL_Latin1_General_CP1_CS_AS = cat.strCategoryCode COLLATE SQL_Latin1_General_CP1_CS_AS 
	INNER JOIN tblGLCOACrossReference AS coa ON substring(coa.strExternalId, 0, CHARINDEX('.', coa.strExternalId)) = cls.gacom_gl_sls 
	INNER JOIN tblGLAccount AS act ON act.intAccountId = coa.inti21Id 
	WHERE substring(coa.strExternalId, 0, CHARINDEX('.', coa.strExternalId)) = cls.gacom_gl_sls 
	and c.intCategoryId = cat.intCategoryId) as ac)

----Inventory Account
INSERT INTO tblICCategoryAccount (	intCategoryId	,intAccountCategoryId	,intAccountId	,intConcurrencyId	) 
(
select c.intCategoryId, ac.AccountCategoryId, ac.intAccountId, 1 from tblICCategory c
cross apply
(SELECT top 1
cat.intCategoryId, cat.strCategoryCode ,
substring(coa.strExternalId, 0, CHARINDEX('.', coa.strExternalId)) ex,
--seg.intAccountCategoryId, 
(select intAccountCategoryId from tblGLAccountCategory where strAccountCategory = 'Inventory') AccountCategoryId,
act.intAccountId, act.strDescription ACDescription 
	FROM gacommst AS cls 
	INNER JOIN tblICCategory AS cat ON cls.gacom_com_cd COLLATE SQL_Latin1_General_CP1_CS_AS = cat.strCategoryCode COLLATE SQL_Latin1_General_CP1_CS_AS 
	INNER JOIN tblGLCOACrossReference AS coa ON substring(coa.strExternalId, 0, CHARINDEX('.', coa.strExternalId)) = cls.gacom_gl_inv 
	INNER JOIN tblGLAccount AS act ON act.intAccountId = coa.inti21Id 
	WHERE substring(coa.strExternalId, 0, CHARINDEX('.', coa.strExternalId)) = cls.gacom_gl_inv 
	and c.intCategoryId = cat.intCategoryId) as ac)

----COGS Account
INSERT INTO tblICCategoryAccount (	intCategoryId	,intAccountCategoryId	,intAccountId	,intConcurrencyId	) 
(
select c.intCategoryId, ac.AccountCategoryId, ac.intAccountId, 1 from tblICCategory c
cross apply
(SELECT top 1
cat.intCategoryId, cat.strCategoryCode ,
substring(coa.strExternalId, 0, CHARINDEX('.', coa.strExternalId)) ex,
--seg.intAccountCategoryId, 
(select intAccountCategoryId from tblGLAccountCategory where strAccountCategory = 'Cost of Goods') AccountCategoryId,
act.intAccountId, act.strDescription ACDescription 
	FROM gacommst AS cls 
	INNER JOIN tblICCategory AS cat ON cls.gacom_com_cd COLLATE SQL_Latin1_General_CP1_CS_AS = cat.strCategoryCode COLLATE SQL_Latin1_General_CP1_CS_AS 
	INNER JOIN tblGLCOACrossReference AS coa ON substring(coa.strExternalId, 0, CHARINDEX('.', coa.strExternalId)) = cls.gacom_gl_pur 
	INNER JOIN tblGLAccount AS act ON act.intAccountId = coa.inti21Id 
	WHERE substring(coa.strExternalId, 0, CHARINDEX('.', coa.strExternalId)) = cls.gacom_gl_pur 
	and c.intCategoryId = cat.intCategoryId) as ac)

--===================================
--insert AP clearing account required by i21. Origin does not have AP Clearing
--All other LOBs have AP Clearing in origin
--Other additional accounts will be imported in a separate sp


insert into tblICCategoryAccount 
(intCategoryId, intAccountCategoryId, intAccountId, intConcurrencyId)
(Select intCategoryId, intAccountCategoryId, intAccountId, 1 from tblICCategory C 
join tblICCommodity cm on C.strCategoryCode = cm.strCommodityCode
cross join 
(--select top 1 51 intAccountCategoryId, intAccountId from tblGLAccount where strDescription like '%adjustment%'
--union
--select top 1 46 intAccountCategoryId, intAccountId from tblGLAccount where strDescription like '%transit%'
--union
--select top 1 44 intAccountCategoryId, intAccountId from tblGLAccount where strDescription like '%variance%'
--union
select top 1 45 intAccountCategoryId, intAccountId from tblGLAccount where strDescription like '%Clearing%'
) ac
where C.strInventoryType = 'Inventory' )


---================================Grain Discounts=============================================
--add gl accounts for discount items
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
	FROM gacdcmst AS itm 
	INNER JOIN tblICItem AS inv ON (rtrim(itm.gacdc_com_cd)+rtrim(itm.gacdc_cd) COLLATE SQL_Latin1_General_CP1_CS_AS = inv.strItemNo COLLATE SQL_Latin1_General_CP1_CS_AS) 
	INNER JOIN tblGLCOACrossReference AS coa ON substring(strOldId, 0, CHARINDEX('-', strOldId)) = cast(itm.gacdc_sls_gl_acct_no as nvarchar)
	INNER JOIN tblGLAccount AS act ON act.intAccountId = coa.inti21Id 
	--WHERE coa.strExternalId = itm.gacdc_sls_gl_acct_no
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
	FROM gacdcmst AS itm 
	INNER JOIN tblICItem AS inv ON (rtrim(itm.gacdc_com_cd)+rtrim(itm.gacdc_cd) COLLATE SQL_Latin1_General_CP1_CS_AS = inv.strItemNo COLLATE SQL_Latin1_General_CP1_CS_AS) 
	INNER JOIN tblGLCOACrossReference AS coa ON substring(strOldId, 0, CHARINDEX('-', strOldId)) = cast(itm.gacdc_pur_gl_acct_no as nvarchar)
	INNER JOIN tblGLAccount AS act ON act.intAccountId = coa.inti21Id 
	--WHERE coa.strExternalId = itm.gacdc_sls_gl_acct_no
	and inv.strType = 'Other Charge' 
	and I.intItemId = inv.intItemId) as ac

---================================Grain Freight=============================================
--add gl accounts for freight items
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
	FROM gacommst AS itm 
	INNER JOIN tblICItem AS inv ON inv.strItemNo COLLATE SQL_Latin1_General_CP1_CS_AS = LTRIM(RTRIM(itm.gacom_com_cd))+' Freight' COLLATE SQL_Latin1_General_CP1_CS_AS)
	INNER JOIN tblGLCOACrossReference AS coa ON substring(strOldId, 0, CHARINDEX('-', strOldId)) = cast(itm.gacom_gl_frt_inc as nvarchar)
	INNER JOIN tblGLAccount AS act ON act.intAccountId = coa.inti21Id 
	--WHERE coa.strExternalId = itm.gacdc_sls_gl_acct_no
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
	FROM gacommst AS itm 
	INNER JOIN tblICItem AS inv ON inv.strItemNo COLLATE SQL_Latin1_General_CP1_CS_AS = LTRIM(RTRIM(itm.gacom_com_cd))+' Freight' COLLATE SQL_Latin1_General_CP1_CS_AS)
	INNER JOIN tblGLCOACrossReference AS coa ON substring(strOldId, 0, CHARINDEX('-', strOldId)) = cast(itm.gacom_gl_frt_exp as nvarchar)
	INNER JOIN tblGLAccount AS act ON act.intAccountId = coa.inti21Id 
	--WHERE coa.strExternalId = itm.gacdc_sls_gl_acct_no
	and inv.strType = 'Other Charge' 
	and I.intItemId = inv.intItemId) as ac	

--==================================================================
--update the account table with correct account category required for inventory to function

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