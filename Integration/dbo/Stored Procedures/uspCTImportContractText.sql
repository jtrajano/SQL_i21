IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[uspCTImportContractText]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [uspCTImportContractText]; 
GO 

CREATE PROCEDURE [dbo].[uspCTImportContractText]
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

IF OBJECT_ID('tempdb..#sstxtmst__sstxt_pur_sls_ind') IS NOT NULL  									
    DROP TABLE #sstxtmst__sstxt_pur_sls_ind									

SELECT distinct sstxt_pur_sls_ind into #sstxtmst__sstxt_pur_sls_ind FROM sstxtmst WHERE sstxt_pur_sls_ind <> 'W'

IF OBJECT_ID('tempdb..#sstxtmst__sstxt_type_ind') IS NOT NULL  									
    DROP TABLE #sstxtmst__sstxt_type_ind									

SELECT distinct sstxt_type_ind into #sstxtmst__sstxt_type_ind FROM sstxtmst WHERE sstxt_type_ind <> '4'

IF OBJECT_ID('tempdb..#sstxtmst__sstxt_txt_id') IS NOT NULL  									
    DROP TABLE #sstxtmst__sstxt_txt_id									

SELECT distinct sstxt_txt_id into #sstxtmst__sstxt_txt_id FROM sstxtmst

IF OBJECT_ID('tempdb..#sstxtmst_where') IS NOT NULL  									
    DROP TABLE #sstxtmst_where	

SELECT ROW_NUMBER() OVER (ORDER BY sstxt_pur_sls_ind,sstxt_type_ind,sstxt_txt_id ASC) id,*
INTO #sstxtmst_where
FROM #sstxtmst__sstxt_pur_sls_ind,#sstxtmst__sstxt_type_ind,#sstxtmst__sstxt_txt_id ORDER BY sstxt_pur_sls_ind,sstxt_type_ind,sstxt_txt_id


DECLARE @id INT,
		@sstxt_pur_sls_ind	NVARCHAR(50),
		@sstxt_type_ind	NVARCHAR(50),
		@sstxt_txt_id	NVARCHAR(50),
		@SQL NVARCHAR(MAX)


IF OBJECT_ID('tempdb..##sstxtmst') IS NOT NULL  									
    DROP TABLE ##sstxtmst	

CREATE TABLE ##sstxtmst
(
		sstxt_pur_sls_ind	NVARCHAR(MAX),
		sstxt_type_ind		NVARCHAR(MAX),
		sstxt_txt_id		NVARCHAR(MAX),
		sstxt_code			NVARCHAR(MAX),
		sstxt_desc			NVARCHAR(MAX)
)

SELECT @id = MIN(id) FROM #sstxtmst_where

WHILE ISNULL(@id,0)> 0 
BEGIN
	SELECT @sstxt_pur_sls_ind = sstxt_pur_sls_ind,@sstxt_type_ind = sstxt_type_ind,@sstxt_txt_id = sstxt_txt_id 
	FROM #sstxtmst_where WHERE id = @id

	SET @SQL = '
	DECLARE @sstxt_desc VARCHAR(MAX),@sstxt_code VARCHAR(MAX)
	SELECT @sstxt_desc = COALESCE(@sstxt_desc + CHAR(13)+CHAR(10), '''') +ISNULL(sstxt_desc,'''') FROM sstxtmst WHERE sstxt_key_rec_no > 0 AND  sstxt_pur_sls_ind = '''+@sstxt_pur_sls_ind+''' AND sstxt_type_ind = '''+@sstxt_type_ind+''' AND sstxt_txt_id = '''+@sstxt_txt_id+'''
	SELECT @sstxt_code = ISNULL(sstxt_desc,'''') FROM sstxtmst WHERE sstxt_key_rec_no = 0 AND  sstxt_pur_sls_ind = '''+@sstxt_pur_sls_ind+''' AND sstxt_type_ind = '''+@sstxt_type_ind+''' AND sstxt_txt_id = '''+@sstxt_txt_id+'''
	IF EXISTS(SELECT * FROM sstxtmst WHERE sstxt_pur_sls_ind = '''+@sstxt_pur_sls_ind+''' AND sstxt_type_ind = '''+@sstxt_type_ind+''' AND sstxt_txt_id = '''+@sstxt_txt_id+''')
	BEGIN
		INSERT INTO ##sstxtmst
		SELECT '''+@sstxt_pur_sls_ind+''','''+@sstxt_type_ind+''','''+@sstxt_txt_id+''',@sstxt_code,@sstxt_desc
	END
	' 
	--SELECT @SQL
	EXEC sp_executesql @SQL
	SELECT @id = MIN(id) FROM #sstxtmst_where WHERE id > @id
END

IF NOT EXISTS(SELECT * FROM tblCTContractText)
BEGIN
		INSERT INTO tblCTContractText (
			 intConcurrencyId
			,intContractType
			,intContractPriceType
			,strTextCode
			,strTextDescription
			,strText
			,ysnActive)
		SELECT 1
			,intContractTypeId
			,intPricingTypeId
			,sstxt_txt_id
			,sstxt_code
			,sstxt_desc
			,1
		FROM ##sstxtmst TX
		INNER JOIN tblCTContractType CT ON CT.strContractType = CASE WHEN sstxt_pur_sls_ind IN ('1','P')THEN 'Purchase'	ELSE 'Sale'	END
		INNER JOIN tblCTPricingType PT ON PT.strPricingType   = CASE WHEN LTRIM(RTRIM(ISNULL(sstxt_type_ind, ''))) = '' THEN 'DP (Priced Later)'
																	 WHEN LTRIM(RTRIM(ISNULL(sstxt_type_ind, ''))) = 'B'THEN 'Basis'
																	 WHEN LTRIM(RTRIM(ISNULL(sstxt_type_ind, ''))) = 'H'THEN 'HTA'
																	 WHEN LTRIM(RTRIM(ISNULL(sstxt_type_ind, ''))) = 'P'THEN 'Priced'
																	 WHEN LTRIM(RTRIM(ISNULL(sstxt_type_ind, ''))) = 'U'THEN 'Unit' END
END
GO