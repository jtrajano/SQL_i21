CREATE PROCEDURE [dbo].[uspGLUpdateCategoryFromOrigin]
AS
	IF EXISTS(SELECT top 1 1  FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'coctlmst')
	BEGIN
		DECLARE @sql NVARCHAR(MAX) 
		DECLARE @ParmDefinition NVARCHAR(50);
		DECLARE @tablePrefix NVARCHAR(2) 
		SELECT @sql = 'SELECT @retvalOUT = CASE WHEN coctl_ag = ''Y'' THEN ''ag'' WHEN coctl_pt = ''Y'' THEN ''pt'' ELSE '''' END   FROM coctlmst'
		SET @ParmDefinition = N'@retvalOUT VARCHAR(2) OUTPUT';
		EXEC sp_executesql @sql, @ParmDefinition, @retvalOUT=@tablePrefix OUTPUT;

		IF @tablePrefix <> ''
		BEGIN
			SET @sql = 'DECLARE @length INT
				DECLARE @tbl TABLE(code VARCHAR(20), cat varchar(50))
				SELECT TOP 1 @length= intLength FROM tblGLAccountStructure WHERE strType = ''Primary''
				;WITH cogs AS (
				select distinct(left(CAST({0}itm_pur_acct AS VARCHAR),@length)) code,''Cost of Goods'' cat from {0}itmmst  
				),sales as
				---Sales Account Category
				(select distinct(left(CAST({0}itm_sls_acct AS VARCHAR),@length))code,''Sales Account''cat from {0}itmmst ),
				inv as(
				---Inventory Category
				select distinct(left(CAST({0}cls_inv_acct_no AS VARCHAR),@length))code, ''Inventory'' cat from {0}clsmst)'
			IF @tablePrefix = 'pt'
			SELECT @sql += '
				,ap as(
				---AP Clearing Category
				select distinct(left(CAST({0}mgl_ap AS VARCHAR),@length))code ,''AP Clearing'' cat from {0}mglmst),
				auto_v as (
				select distinct(LEFT(CAST({0}mgl_pur_variance AS VARCHAR),@length)) code, ''Auto-Variance'' cat from {0}mglmst  
				)'
			SELECT @sql +='
				INSERT INTO @tbl
				(
					code,
					cat
				)
				SELECT code , cat FROM cogs  
				UNION SELECT code , cat FROM sales 
				UNION SELECT code , cat FROM inv'
			IF @tablePrefix = 'pt'
			SELECT @sql += '
				UNION SELECT code , cat FROM ap 
				UNION SELECT code , cat FROM auto_v'

			SELECT @sql +='
				UPDATE tgs SET intAccountCategoryId = tgc.intAccountCategoryId
				FROM dbo.tblGLAccountSegment tgs  JOIN @tbl t ON tgs.strCode = t.code  COLLATE SQL_Latin1_General_CP1_CS_AS
				JOIN dbo.tblGLAccountCategory tgc ON t.cat  COLLATE SQL_Latin1_General_CP1_CS_AS = tgc.strAccountCategory'
			SELECT @sql = REPLACE (@sql,'{0}', @tablePrefix)
			EXEC sp_executesql @sql
			--PRINT @sql
		END
	END
RETURN 0
