IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[uspICDCCommodityGLMigrationGr]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [uspICDCCommodityGLMigrationGr]; 
GO 

Create PROCEDURE [dbo].[uspICDCCommodityGLMigrationGr]

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
	INNER JOIN tblGLAccount AS act ON act.intAccountId = coa.intCrossReferenceId 
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
	INNER JOIN tblGLAccount AS act ON act.intAccountId = coa.intCrossReferenceId 
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
	INNER JOIN tblGLAccount AS act ON act.intAccountId = coa.intCrossReferenceId 
	WHERE substring(coa.strExternalId, 0, CHARINDEX('.', coa.strExternalId)) = cls.gacom_gl_pur 
	and c.intCategoryId = cat.intCategoryId) as ac)

--===================================
--insert AP clearing account required by i21. Origin does not have AP Clearing
--All other LOBs have AP Clearing in origin
--Other additional accounts will be imported in a separate sp


insert into tblICCategoryAccount 
(intCategoryId, intAccountCategoryId, intAccountId, intConcurrencyId)
(Select intCategoryId, intAccountCategoryId, intAccountId, 1 from tblICCategory C 
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



--==================================================================
--update the account table with correct account category required for inventory to function

UPDATE tgs SET intAccountCategoryId = tgc.intAccountCategoryId
--select tgs.strCode,  t.code, t.cat , tgc.strAccountCategory
FROM dbo.tblGLAccountSegment tgs  
JOIN 
(--purchase
--select distinct(CAST(gacom_gl_pur AS VARCHAR)) code,'Cost of Goods' cat from gacommst  
--union
-----Sales Account Category
--select distinct(CAST(gacom_gl_sls AS VARCHAR)) code,'Sales Account'cat from gacommst 
--union
---Inventory Category
select distinct(CAST(gacom_gl_inv AS VARCHAR)) code, 'Inventory' cat from gacommst
) as t 
ON tgs.strCode = t.code  
JOIN dbo.tblGLAccountCategory tgc ON t.cat  = tgc.strAccountCategory