CREATE PROCEDURE [dbo].[uspCTSaveAmendment]

AS

BEGIN TRY
	
	DECLARE @ErrMsg				NVARCHAR(MAX),
			@strAmendmentFields	NVARCHAR(MAX),
			@strTableColumns	NVARCHAR(MAX),
			@SQL				NVARCHAR(MAX)

	IF OBJECT_ID('tempdb..#OrigColumn') IS NOT NULL  	
		DROP TABLE #OrigColumn	

	CREATE	 TABLE #OrigColumn (strFieldIndex  NVARCHAR(MAX) COLLATE SQL_Latin1_General_CP1_CS_AS,strDataIndex  NVARCHAR(MAX) COLLATE SQL_Latin1_General_CP1_CS_AS)

	INSERT	INTO #OrigColumn					
				SELECT	'ysnEntity','intEntityId'		 
	UNION ALL	SELECT	'ysnTerm','intTermId'		
	UNION ALL	SELECT	'ysnGrade','intGradeId'		
	UNION ALL	SELECT	'ysnPosition','intPositionId'		
	UNION ALL	SELECT	'ysnWeight','intWeightId'	
	UNION ALL	SELECT	'ysnINCOTerm','intContractBasisId'	
	UNION ALL	SELECT	'ysnStatus','intContractStatusId'		
	UNION ALL	SELECT	'ysnStartDate','dtmStartDate'		
	UNION ALL	SELECT	'ysnEndDate','dtmEndDate'		
	UNION ALL	SELECT	'ysnItem','intItemId'		
	UNION ALL	SELECT	'ysnQuantity','dblQuantity'			
	UNION ALL	SELECT	'ysnQuantityUOM','intItemUOMId'	
	UNION ALL	SELECT	'ysnMarket','intFutureMarketId'
	UNION ALL	SELECT	'ysnMonth','intFutureMonthId'
	UNION ALL	SELECT	'ysnFuture','dblFutures'
	UNION ALL	SELECT	'ysnBasis','dblBasis'
	UNION ALL	SELECT	'ysnCashPrice','dblCashPrice'
	UNION ALL	SELECT	'ysnCurrency','intCurrencyId'
	UNION ALL	SELECT	'ysnPriceUOM','intPriceItemUOMId'

	SELECT	@strTableColumns = COALESCE(@strTableColumns+',' ,'') + OC.strFieldIndex
	FROM	INFORMATION_SCHEMA.COLUMNS COL 
	JOIN	#OrigColumn	OC	ON	OC.strFieldIndex = COL.COLUMN_NAME
	WHERE	COL.TABLE_NAME = 'tblCTAmendment' AND COLUMN_NAME NOT IN ('intAmendment','ysnHeaderQuantity','intConcurrencyId')
	
	SET @SQL = 
	'SELECT @strAmendmentFields = COALESCE(@strAmendmentFields+'','' ,'''') + strDataIndex
	from tblCTAmendment s
	UNPIVOT
	(
	  ysnValue
	  for strColumn in ('+@strTableColumns+')
	) u 
	JOIN	#OrigColumn	OC	ON	OC.strFieldIndex = u.strColumn
	WHERE ysnValue = 1'
	EXEC sp_executesql @SQL,N'@strAmendmentFields NVARCHAR(MAX) OUTPUT',@strAmendmentFields  = @strAmendmentFields OUTPUT

	UPDATE tblCTCompanyPreference SET  strAmendmentFields =  RTRIM(LTRIM(@strAmendmentFields))

END TRY

BEGIN CATCH

	SET @ErrMsg = ERROR_MESSAGE()  
	RAISERROR (@ErrMsg,18,1,'WITH NOWAIT')  
	
END CATCH
