CREATE PROCEDURE [dbo].[uspCTReportCoffeeNeedPlanDetail]
	 @IntCommodityId INT,
	 @IntUOMId INT,
	 @strNeedPlan Nvarchar(30)
AS
BEGIN

	DECLARE @FirstMonth NVARCHAR(100)
	DECLARE @SecondMonth NVARCHAR(100)
	DECLARE @ThirdMonth NVARCHAR(100)
	DECLARE @FourthMonth NVARCHAR(100)
	DECLARE @FifthMonth NVARCHAR(100)
	DECLARE @SixthMonth NVARCHAR(100)
	DECLARE @SeventhMonth NVARCHAR(100)
	DECLARE @EighthMonth NVARCHAR(100)
	DECLARE @NinthMonth NVARCHAR(100)
	DECLARE @TenthMonth NVARCHAR(100)

	DECLARE @intColumnKey INT
	DECLARE @intMonthKey INT
	DECLARE @intYearKey INT
	DECLARE @strColumnName NVARCHAR(40)
	DECLARE @SqlALTER NVARCHAR(MAX)
	DECLARE @SqlInsert NVARCHAR(MAX)
	DECLARE @SqlSelect NVARCHAR(MAX)
	DECLARE @IntWeekId INT
	DECLARE @IntYear INT
	
	SET @IntWeekId = LEFT(@strNeedPlan,2)
	SET @IntYear = RIGHT(@strNeedPlan,4)

	IF OBJECT_ID('tempdb..#tblCoffeeNeedPlan') IS NOT NULL
		DROP TABLE #tblCoffeeNeedPlan

	CREATE TABLE #tblCoffeeNeedPlan 
	(
		 [intNeedPlanKey] INT IDENTITY(1, 1)
		,[intItemId] INT NULL
		,[strItemName] NVARCHAR(100) COLLATE Latin1_General_CI_AS  NULL
		,[strItemDescription] NVARCHAR(400) COLLATE Latin1_General_CI_AS  NULL
		,[intSubLocationId] INT NULL
		,[strSubLocationName] NVARCHAR(400) COLLATE Latin1_General_CI_AS NULL		
	)
    
	IF OBJECT_ID('tempdb..#tblRequiredColumns') IS NOT NULL
		DROP TABLE #tblRequiredColumns

	CREATE TABLE #tblRequiredColumns 
	(
		  [intColumnKey] INT IDENTITY(1,1)
		 ,[intMonthKey] INT
		 ,[intYearKey] INT
		 ,[strColumnName] NVARCHAR(100) COLLATE Latin1_General_CI_AS
	 )

	  INSERT INTO #tblRequiredColumns ([intMonthKey], [intYearKey], [strColumnName])
	  SELECT DISTINCT [intMonthKey], [intYearKey], [strColumnName] 
	  FROM 
	   (SELECT DISTINCT 
			CASE
			WHEN LEFT(LTRIM(Stg.strPeriod), 3) = 'Jan' THEN 1
			WHEN LEFT(LTRIM(Stg.strPeriod), 3) = 'Feb' THEN 2
			WHEN LEFT(LTRIM(Stg.strPeriod), 3) = 'Mar' THEN 3
			WHEN LEFT(LTRIM(Stg.strPeriod), 3) = 'Apr' THEN 4
			WHEN LEFT(LTRIM(Stg.strPeriod), 3) = 'May' THEN 5
			WHEN LEFT(LTRIM(Stg.strPeriod), 3) = 'Jun' THEN 6
			WHEN LEFT(LTRIM(Stg.strPeriod), 3) = 'Jul' THEN 7
			WHEN LEFT(LTRIM(Stg.strPeriod), 3) = 'Aug' THEN 8
			WHEN LEFT(LTRIM(Stg.strPeriod), 3) = 'Sep' THEN 9
			WHEN LEFT(LTRIM(Stg.strPeriod), 3) = 'Oct' THEN 10
			WHEN LEFT(LTRIM(Stg.strPeriod), 3) = 'Nov' THEN 11
			WHEN LEFT(LTRIM(Stg.strPeriod), 3) = 'Dec' THEN 12
		  END 
		  [intMonthKey],
		  Stg.[intYear] AS [intYearKey],
		  LEFT(LTRIM(Stg.strPeriod), 3) + ' ' + RIGHT(RTRIM(Stg.strPeriod), 2)
		  + CHAR(13) + CHAR(10)
		  + '01.'
		  + CASE
				WHEN LEFT(LTRIM(Stg.strPeriod), 3) = 'Jan' THEN '01'
				WHEN LEFT(LTRIM(Stg.strPeriod), 3) = 'Feb' THEN '02'
				WHEN LEFT(LTRIM(Stg.strPeriod), 3) = 'Mar' THEN '03'
				WHEN LEFT(LTRIM(Stg.strPeriod), 3) = 'Apr' THEN '04'
				WHEN LEFT(LTRIM(Stg.strPeriod), 3) = 'May' THEN '05'
				WHEN LEFT(LTRIM(Stg.strPeriod), 3) = 'Jun' THEN '06'
				WHEN LEFT(LTRIM(Stg.strPeriod), 3) = 'Jul' THEN '07'
				WHEN LEFT(LTRIM(Stg.strPeriod), 3) = 'Aug' THEN '08'
				WHEN LEFT(LTRIM(Stg.strPeriod), 3) = 'Sep' THEN '09'
				WHEN LEFT(LTRIM(Stg.strPeriod), 3) = 'Oct' THEN '10'
				WHEN LEFT(LTRIM(Stg.strPeriod), 3) = 'Nov' THEN '11'
				WHEN LEFT(LTRIM(Stg.strPeriod), 3) = 'Dec' THEN '12'
		  END
		  + '.' + RIGHT(Stg.[intYear], 2)
		  + ' | ' +
		  +'16.'
		  + CASE
				WHEN LEFT(LTRIM(Stg.strPeriod), 3) = 'Jan' THEN '01'
				WHEN LEFT(LTRIM(Stg.strPeriod), 3) = 'Feb' THEN '02'
				WHEN LEFT(LTRIM(Stg.strPeriod), 3) = 'Mar' THEN '03'
				WHEN LEFT(LTRIM(Stg.strPeriod), 3) = 'Apr' THEN '04'
				WHEN LEFT(LTRIM(Stg.strPeriod), 3) = 'May' THEN '05'
				WHEN LEFT(LTRIM(Stg.strPeriod), 3) = 'Jun' THEN '06'
				WHEN LEFT(LTRIM(Stg.strPeriod), 3) = 'Jul' THEN '07'
				WHEN LEFT(LTRIM(Stg.strPeriod), 3) = 'Aug' THEN '08'
				WHEN LEFT(LTRIM(Stg.strPeriod), 3) = 'Sep' THEN '09'
				WHEN LEFT(LTRIM(Stg.strPeriod), 3) = 'Oct' THEN '10'
				WHEN LEFT(LTRIM(Stg.strPeriod), 3) = 'Nov' THEN '11'
				WHEN LEFT(LTRIM(Stg.strPeriod), 3) = 'Dec' THEN '12'
		  END
		  + '.' + RIGHT(Stg.[intYear], 2) AS strColumnName
		FROM tblRKStgBlendDemand Stg
		JOIN tblICItem Item ON Item.intItemId=Stg.intItemId AND Item.intCommodityId=@IntCommodityId AND Stg.dblQuantity >0
		WHERE CONVERT(NVARCHAR,Stg.dtmImportDate,106)=@strNeedPlan
		UNION
		SELECT DISTINCT 
			CASE
			WHEN LEFT(LTRIM(Stg.strPeriod), 3) = 'Jan' THEN 1
			WHEN LEFT(LTRIM(Stg.strPeriod), 3) = 'Feb' THEN 2
			WHEN LEFT(LTRIM(Stg.strPeriod), 3) = 'Mar' THEN 3
			WHEN LEFT(LTRIM(Stg.strPeriod), 3) = 'Apr' THEN 4
			WHEN LEFT(LTRIM(Stg.strPeriod), 3) = 'May' THEN 5
			WHEN LEFT(LTRIM(Stg.strPeriod), 3) = 'Jun' THEN 6
			WHEN LEFT(LTRIM(Stg.strPeriod), 3) = 'Jul' THEN 7
			WHEN LEFT(LTRIM(Stg.strPeriod), 3) = 'Aug' THEN 8
			WHEN LEFT(LTRIM(Stg.strPeriod), 3) = 'Sep' THEN 9
			WHEN LEFT(LTRIM(Stg.strPeriod), 3) = 'Oct' THEN 10
			WHEN LEFT(LTRIM(Stg.strPeriod), 3) = 'Nov' THEN 11
			WHEN LEFT(LTRIM(Stg.strPeriod), 3) = 'Dec' THEN 12
		  END 
		  [intMonthKey],
		  Stg.[intYear] AS [intYearKey],
		  LEFT(LTRIM(Stg.strPeriod), 3) + ' ' + RIGHT(RTRIM(Stg.strPeriod), 2)
		  + CHAR(13) + CHAR(10)
		  + '01.'
		  + CASE
				WHEN LEFT(LTRIM(Stg.strPeriod), 3) = 'Jan' THEN '01'
				WHEN LEFT(LTRIM(Stg.strPeriod), 3) = 'Feb' THEN '02'
				WHEN LEFT(LTRIM(Stg.strPeriod), 3) = 'Mar' THEN '03'
				WHEN LEFT(LTRIM(Stg.strPeriod), 3) = 'Apr' THEN '04'
				WHEN LEFT(LTRIM(Stg.strPeriod), 3) = 'May' THEN '05'
				WHEN LEFT(LTRIM(Stg.strPeriod), 3) = 'Jun' THEN '06'
				WHEN LEFT(LTRIM(Stg.strPeriod), 3) = 'Jul' THEN '07'
				WHEN LEFT(LTRIM(Stg.strPeriod), 3) = 'Aug' THEN '08'
				WHEN LEFT(LTRIM(Stg.strPeriod), 3) = 'Sep' THEN '09'
				WHEN LEFT(LTRIM(Stg.strPeriod), 3) = 'Oct' THEN '10'
				WHEN LEFT(LTRIM(Stg.strPeriod), 3) = 'Nov' THEN '11'
				WHEN LEFT(LTRIM(Stg.strPeriod), 3) = 'Dec' THEN '12'
		  END
		  + '.' + RIGHT(Stg.[intYear], 2)
		  + ' | ' +
		  +'16.'
		  + CASE
				WHEN LEFT(LTRIM(Stg.strPeriod), 3) = 'Jan' THEN '01'
				WHEN LEFT(LTRIM(Stg.strPeriod), 3) = 'Feb' THEN '02'
				WHEN LEFT(LTRIM(Stg.strPeriod), 3) = 'Mar' THEN '03'
				WHEN LEFT(LTRIM(Stg.strPeriod), 3) = 'Apr' THEN '04'
				WHEN LEFT(LTRIM(Stg.strPeriod), 3) = 'May' THEN '05'
				WHEN LEFT(LTRIM(Stg.strPeriod), 3) = 'Jun' THEN '06'
				WHEN LEFT(LTRIM(Stg.strPeriod), 3) = 'Jul' THEN '07'
				WHEN LEFT(LTRIM(Stg.strPeriod), 3) = 'Aug' THEN '08'
				WHEN LEFT(LTRIM(Stg.strPeriod), 3) = 'Sep' THEN '09'
				WHEN LEFT(LTRIM(Stg.strPeriod), 3) = 'Oct' THEN '10'
				WHEN LEFT(LTRIM(Stg.strPeriod), 3) = 'Nov' THEN '11'
				WHEN LEFT(LTRIM(Stg.strPeriod), 3) = 'Dec' THEN '12'
		  END
		  + '.' + RIGHT(Stg.[intYear], 2) AS strColumnName
		FROM tblRKArchBlendDemand Stg
		JOIN tblICItem Item ON Item.intItemId=Stg.intItemId AND Item.intCommodityId=@IntCommodityId AND Stg.dblQuantity >0
		WHERE CONVERT(NVARCHAR,Stg.dtmImportDate,106)=@strNeedPlan
		)t
		ORDER BY [intYearKey],[intMonthKey]

	 SELECT TOP 1  @FirstMonth=[strColumnName] FROM #tblRequiredColumns ORDER BY [intColumnKey]

	 IF @FirstMonth IS NOT NULL
	 BEGIN
			SELECT TOP 2  @SecondMonth= CASE WHEN [strColumnName]<>@FirstMonth THEN [strColumnName] ELSE NULL END  FROM #tblRequiredColumns ORDER BY [intColumnKey]
	 END
	 IF @SecondMonth IS NOT NULL
	 BEGIN
			SELECT TOP 3  @ThirdMonth= CASE WHEN [strColumnName]<>@SecondMonth THEN [strColumnName] ELSE NULL END  FROM #tblRequiredColumns ORDER BY [intColumnKey]
	 END
	 IF @ThirdMonth IS NOT NULL
	 BEGIN
			SELECT TOP 4  @FourthMonth= CASE WHEN [strColumnName]<>@ThirdMonth THEN [strColumnName] ELSE NULL END  FROM #tblRequiredColumns ORDER BY [intColumnKey]
	 END  
	  IF @FourthMonth IS NOT NULL
	 BEGIN
			SELECT TOP 5  @FifthMonth= CASE WHEN [strColumnName]<>@FourthMonth THEN [strColumnName] ELSE NULL END  FROM #tblRequiredColumns ORDER BY [intColumnKey]
	 END 
	 IF @FifthMonth IS NOT NULL
	 BEGIN
			SELECT TOP 6  @SixthMonth= CASE WHEN [strColumnName]<>@FifthMonth THEN [strColumnName] ELSE NULL END  FROM #tblRequiredColumns ORDER BY [intColumnKey]
	 END
	 IF @SixthMonth IS NOT NULL
	 BEGIN
			SELECT TOP 7  @SeventhMonth= CASE WHEN [strColumnName]<>@SixthMonth THEN [strColumnName] ELSE NULL END  FROM #tblRequiredColumns ORDER BY [intColumnKey]
	 END
	 IF @SeventhMonth IS NOT NULL
	 BEGIN
			SELECT TOP 8  @EighthMonth= CASE WHEN [strColumnName]<>@SeventhMonth THEN [strColumnName] ELSE NULL END  FROM #tblRequiredColumns ORDER BY [intColumnKey]
	 END
	 IF @EighthMonth IS NOT NULL
	 BEGIN
			SELECT TOP 9  @NinthMonth= CASE WHEN [strColumnName]<>@EighthMonth THEN [strColumnName] ELSE NULL END  FROM #tblRequiredColumns ORDER BY [intColumnKey]
	 END
	 IF @NinthMonth IS NOT NULL
	 BEGIN
			SELECT TOP 10  @TenthMonth= CASE WHEN [strColumnName]<>@NinthMonth THEN [strColumnName] ELSE NULL END  FROM #tblRequiredColumns ORDER BY [intColumnKey]
	 END

	 SELECT @intColumnKey = MIN(intColumnKey) FROM #tblRequiredColumns

	WHILE @intColumnKey > 0
	BEGIN
					
		SET @intMonthKey = NULL
		SET @intYearKey = NULL
		SET @strColumnName = NULL

		SET @SqlALTER = NULL
		SET @SqlInsert = NULL

		SELECT @intMonthKey=intMonthKey,@intYearKey=intYearKey ,@strColumnName = strColumnName
		FROM #tblRequiredColumns
		WHERE intColumnKey = @intColumnKey
					
		SET @SqlALTER = 'ALTER TABLE #tblCoffeeNeedPlan ADD  [First' + @strColumnName + ']  DECIMAL(24,2) NULL'		
		EXEC (@SqlALTER)

		SET @SqlALTER=NULL
		SET @SqlALTER = 'ALTER TABLE #tblCoffeeNeedPlan ADD  [End' + @strColumnName + ']   DECIMAL(24,2) NULL'
		
		EXEC (@SqlALTER)		
		
		SET @SqlInsert = 'INSERT INTO #tblCoffeeNeedPlan(intItemId,strItemName,strItemDescription,[intSubLocationId],[strSubLocationName],[First'+ @strColumnName + '],[End'+ @strColumnName + '])
							 SELECT Item.intItemId,Item.strItemNo,Item.strDescription,SLOC.intCompanyLocationSubLocationId,ISNULL(SLOC.strSubLocationName,''''),
							 CASE WHEN DATEPART(dd,dtmNeedDate)<16 THEN dbo.fnCTConvertQuantityToTargetItemUOM(Item.intItemId,ItemUOM.intUnitMeasureId,'+LTRIM(@IntUOMId)+',Stg.dblQuantity) ELSE NULL END AS dblQuantity1 
							,CASE WHEN DATEPART(dd,dtmNeedDate)>15 THEN dbo.fnCTConvertQuantityToTargetItemUOM(Item.intItemId,ItemUOM.intUnitMeasureId,'+LTRIM(@IntUOMId)+',Stg.dblQuantity) ELSE NULL END AS dblQuantity2 
							FROM tblRKStgBlendDemand Stg
							JOIN tblICItemUOM ItemUOM ON ItemUOM.intItemUOMId=Stg.intUOMId AND ItemUOM.intItemId=Stg.intItemId
							JOIN tblICItem Item ON Item.intItemId=Stg.intItemId AND Item.intCommodityId='+LTRIM(@IntCommodityId)+'
							JOIN tblSMCompanyLocationSubLocation SLOC ON SLOC.intCompanyLocationSubLocationId=Stg.intSubLocationId							
							WHERE CONVERT(NVARCHAR,Stg.dtmImportDate,106)='''+@strNeedPlan+''' AND Stg.dblQuantity >0 AND MONTH(dtmNeedDate)='+LTRIM(@intMonthKey)+' AND YEAR(dtmNeedDate)='+LTRIM(@intYearKey)+'
							UNION ALL
							SELECT Item.intItemId,Item.strItemNo,Item.strDescription,SLOC.intCompanyLocationSubLocationId,ISNULL(SLOC.strSubLocationName,''''),
							 CASE WHEN DATEPART(dd,dtmNeedDate)<16 THEN dbo.fnCTConvertQuantityToTargetItemUOM(Item.intItemId,ItemUOM.intUnitMeasureId,'+LTRIM(@IntUOMId)+',Stg.dblQuantity) ELSE NULL END AS dblQuantity1 
							,CASE WHEN DATEPART(dd,dtmNeedDate)>15 THEN dbo.fnCTConvertQuantityToTargetItemUOM(Item.intItemId,ItemUOM.intUnitMeasureId,'+LTRIM(@IntUOMId)+',Stg.dblQuantity) ELSE NULL END AS dblQuantity2 
							FROM tblRKArchBlendDemand Stg
							JOIN tblICItemUOM ItemUOM ON ItemUOM.intItemUOMId=Stg.intUOMId AND ItemUOM.intItemId=Stg.intItemId
							JOIN tblICItem Item ON Item.intItemId=Stg.intItemId AND Item.intCommodityId='+LTRIM(@IntCommodityId)+'
							JOIN tblSMCompanyLocationSubLocation SLOC ON SLOC.intCompanyLocationSubLocationId=Stg.intSubLocationId							
							WHERE CONVERT(NVARCHAR,Stg.dtmImportDate,106)='''+@strNeedPlan+''' AND Stg.dblQuantity >0 AND MONTH(dtmNeedDate)='+LTRIM(@intMonthKey)+' AND YEAR(dtmNeedDate)='+LTRIM(@intYearKey)

		EXEC (@SqlInsert)

		--SELECT @SqlInsert

		SET @SqlInsert=NULL
		SET @SqlInsert = 'INSERT INTO #tblCoffeeNeedPlan(intItemId,strItemName,strItemDescription,[intSubLocationId],[strSubLocationName],[First'+ @strColumnName + '],[End'+ @strColumnName + '])
						  SELECT intItemId,'' '','' '',0,'' '',NULL,SUM(ISNULL([First'+ @strColumnName + '],0))+SUM(ISNULL([End'+ @strColumnName + '],0))  
						  FROM #tblCoffeeNeedPlan
						  GROUP BY intItemId'
						  
		--SELECT @SqlInsert	
		EXEC (@SqlInsert)


		SELECT @intColumnKey = MIN(intColumnKey)
		FROM #tblRequiredColumns
		WHERE intColumnKey > @intColumnKey
	END
		
		SET @SqlSelect ='SELECT  
						 [intItemId]
						,RIGHT([strItemName],8) AS [strItemName]
						,[strItemDescription]
						,[intSubLocationId]
						,[strSubLocationName]'

		IF 	@FirstMonth  IS NOT NULL
		SET @SqlSelect=@SqlSelect+', CASE WHEN  @FirstMonth  IS NOT NULL THEN CASE WHEN [intSubLocationId]=0 THEN NULL ELSE dbo.fnRemoveTrailingZeroes(SUM(ISNULL([First' + @FirstMonth + '],0))) END ELSE NULL END AS Column1
									,CASE WHEN  @FirstMonth  IS NOT NULL THEN dbo.fnRemoveTrailingZeroes(SUM(ISNULL([End' + @FirstMonth + '],0))) ELSE NULL END AS Column2'
		
		IF 	@SecondMonth  IS NOT NULL														
		SET @SqlSelect=@SqlSelect+', CASE WHEN  @SecondMonth  IS NOT NULL THEN CASE WHEN [intSubLocationId]=0 THEN NULL ELSE dbo.fnRemoveTrailingZeroes(SUM(ISNULL([First' + @SecondMonth + '],0))) END ELSE NULL END AS Column3
									,CASE WHEN  @SecondMonth  IS NOT NULL THEN dbo.fnRemoveTrailingZeroes(SUM(ISNULL([End' + @SecondMonth + '],0))) ELSE NULL END AS Column4'
		
		IF 	@ThirdMonth  IS NOT NULL														
		SET @SqlSelect=@SqlSelect+', CASE WHEN  @ThirdMonth  IS NOT NULL THEN CASE WHEN [intSubLocationId]=0 THEN NULL ELSE dbo.fnRemoveTrailingZeroes(SUM(ISNULL([First' + @ThirdMonth + '],0))) END ELSE NULL END AS Column5
									,CASE WHEN  @ThirdMonth  IS NOT NULL THEN dbo.fnRemoveTrailingZeroes(SUM(ISNULL([End' + @ThirdMonth + '],0))) ELSE NULL END AS Column6'
		
		IF 	@FourthMonth  IS NOT NULL														
		SET @SqlSelect=@SqlSelect+', CASE WHEN  @FourthMonth  IS NOT NULL THEN CASE WHEN [intSubLocationId]=0 THEN NULL ELSE  dbo.fnRemoveTrailingZeroes(SUM(ISNULL([First' + @FourthMonth + '],0))) END ELSE NULL END AS Column7
									,CASE WHEN  @FourthMonth  IS NOT NULL THEN dbo.fnRemoveTrailingZeroes(SUM(ISNULL([End' + @FourthMonth + '],0))) ELSE NULL END AS Column8'
		
		IF 	@FifthMonth  IS NOT NULL														
		SET @SqlSelect=@SqlSelect+', CASE WHEN  @FifthMonth  IS NOT NULL THEN  CASE WHEN [intSubLocationId]=0 THEN NULL ELSE dbo.fnRemoveTrailingZeroes(SUM(ISNULL([First' + @FifthMonth + '],0))) END ELSE NULL END AS Column9
									,CASE WHEN  @FifthMonth  IS NOT NULL THEN dbo.fnRemoveTrailingZeroes(SUM(ISNULL([End' + @FifthMonth + '],0))) ELSE NULL END AS Column10'
		
		IF 	@SixthMonth  IS NOT NULL														
		SET @SqlSelect=@SqlSelect+',CASE WHEN   @SixthMonth  IS NOT NULL THEN  CASE WHEN [intSubLocationId]=0 THEN NULL ELSE dbo.fnRemoveTrailingZeroes(SUM(ISNULL([First' + @SixthMonth + '],0))) END ELSE NULL END AS Column11
									,CASE WHEN  @SixthMonth  IS NOT NULL THEN dbo.fnRemoveTrailingZeroes(SUM(ISNULL([End' + @SixthMonth + '],0))) ELSE NULL END AS Column12'
        IF 	@SeventhMonth  IS NOT NULL														
		SET @SqlSelect=@SqlSelect+',CASE WHEN   @SeventhMonth  IS NOT NULL THEN  CASE WHEN [intSubLocationId]=0 THEN NULL ELSE dbo.fnRemoveTrailingZeroes(SUM(ISNULL([First' + @SeventhMonth + '],0))) END ELSE NULL END AS Column13
									,CASE WHEN  @SeventhMonth  IS NOT NULL THEN dbo.fnRemoveTrailingZeroes(SUM(ISNULL([End' + @SeventhMonth + '],0))) ELSE NULL END AS Column14'
		
		IF 	@EighthMonth  IS NOT NULL														
		SET @SqlSelect=@SqlSelect+',CASE WHEN   @EighthMonth  IS NOT NULL THEN  CASE WHEN [intSubLocationId]=0 THEN NULL ELSE dbo.fnRemoveTrailingZeroes(SUM(ISNULL([First' +@EighthMonth + '],0))) END ELSE NULL END AS Column15
									,CASE WHEN  @EighthMonth  IS NOT NULL THEN dbo.fnRemoveTrailingZeroes(SUM(ISNULL([End' + @EighthMonth + '],0))) ELSE NULL END AS Column16'
		IF 	@NinthMonth  IS NOT NULL														
		SET @SqlSelect=@SqlSelect+',CASE WHEN   @NinthMonth  IS NOT NULL THEN  CASE WHEN [intSubLocationId]=0 THEN NULL ELSE dbo.fnRemoveTrailingZeroes(SUM(ISNULL([First' +@NinthMonth + '],0))) END ELSE NULL END AS Column17
									,CASE WHEN  @NinthMonth  IS NOT NULL THEN dbo.fnRemoveTrailingZeroes(SUM(ISNULL([End' + @NinthMonth + '],0))) ELSE NULL END AS Column18'
		IF 	@TenthMonth  IS NOT NULL														
		SET @SqlSelect=@SqlSelect+',CASE WHEN   @TenthMonth  IS NOT NULL THEN  CASE WHEN [intSubLocationId]=0 THEN NULL ELSE dbo.fnRemoveTrailingZeroes(SUM(ISNULL([First' +@TenthMonth + '],0))) END ELSE NULL END AS Column19
									,CASE WHEN  @TenthMonth  IS NOT NULL THEN dbo.fnRemoveTrailingZeroes(SUM(ISNULL([End' + @TenthMonth + '],0))) ELSE NULL END AS Column20'

		SET @SqlSelect=@SqlSelect+'  FROM #tblCoffeeNeedPlan
									 GROUP BY intItemId,strItemName,strItemDescription,[intSubLocationId],[strSubLocationName] ORDER BY intItemId,[intSubLocationId] DESC '
		
		EXEC sp_executesql @SqlSelect,N'@FirstMonth nvarchar(MAX),@SecondMonth nvarchar(MAX),@ThirdMonth nvarchar(MAX),@FourthMonth nvarchar(MAX),@FifthMonth nvarchar(MAX),@SixthMonth nvarchar(MAX),@SeventhMonth nvarchar(MAX),@EighthMonth nvarchar(MAX),@NinthMonth nvarchar(MAX),@TenthMonth nvarchar(MAX)'						
										,@FirstMonth=@FirstMonth
										,@SecondMonth= @SecondMonth
										,@ThirdMonth= @ThirdMonth
										,@FourthMonth= @FourthMonth
										,@FifthMonth= @FifthMonth
										,@SixthMonth=@SixthMonth
										,@SeventhMonth=@SeventhMonth
										,@EighthMonth=@EighthMonth
										,@NinthMonth=@NinthMonth
										,@TenthMonth=@TenthMonth
END