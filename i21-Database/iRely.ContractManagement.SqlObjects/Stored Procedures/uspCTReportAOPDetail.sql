CREATE PROCEDURE [dbo].[uspCTReportAOPDetail]
	 @IntCommodityId int ,
	 @strYear NVARCHAR(10)
AS
BEGIN

	DECLARE @FirstBasisItem nvarchar(100)
	DECLARE @SecondBasisItem nvarchar(100)
	DECLARE @ThirdBasisItem nvarchar(100)
	DECLARE @FourthBasisItem nvarchar(100)
	DECLARE @FifthBasisItem nvarchar(100)
	DECLARE @SixthBasisItem nvarchar(100)
	DECLARE @SeventhBasisItem nvarchar(100)
	DECLARE @EighthBasisItem nvarchar(100)

	DECLARE @intColumnKey INT
	DECLARE @strColumnName NVARCHAR(40)
	DECLARE @SqlALTER NVARCHAR(MAX)
	DECLARE @SqlInsert NVARCHAR(MAX)
	DECLARE @SqlUpdate NVARCHAR(MAX)
	DECLARE @SqlTotalPremiumCalculation NVARCHAR(MAX)
	DECLARE @SqlSelect NVARCHAR(MAX)
	DECLARE @IntWeekId INT
	DECLARE @IntYear INT
	
	

	IF OBJECT_ID('tempdb..#tblCoffeeNeedPlan') IS NOT NULL
		DROP TABLE #tblCoffeeNeedPlan

	CREATE TABLE #tblCoffeeNeedPlan 
	(
		 [intNeedPlanKey] INT IDENTITY(1, 1)		
		,[strCommodityCode] NVARCHAR(100) COLLATE Latin1_General_CI_AS  NULL
		,[strShortName] NVARCHAR(400) COLLATE Latin1_General_CI_AS  NULL
		,[strItemNo] NVARCHAR(400) COLLATE Latin1_General_CI_AS  NULL
		,[strProductType] NVARCHAR(400) COLLATE Latin1_General_CI_AS  NULL
		,[dblVolume] NUMERIC(18,6)
		,[strVolumnUOM] NVARCHAR(400) COLLATE Latin1_General_CI_AS NULL
		,[strCurrency] NVARCHAR(400) COLLATE Latin1_General_CI_AS NULL
		,[strWeightUOM] NVARCHAR(400) COLLATE Latin1_General_CI_AS NULL      
		,[dblTotalPremium] NUMERIC(18,6)	
	)
    
	IF OBJECT_ID('tempdb..#tblRequiredColumns') IS NOT NULL
		DROP TABLE #tblRequiredColumns

	CREATE TABLE #tblRequiredColumns 
	(
		[intColumnKey] int IDENTITY (1, 1),
		[intBasisItemId] int,    
		[strColumnName] nvarchar(100) COLLATE Latin1_General_CI_AS
	 )

	  INSERT INTO #tblRequiredColumns ([intBasisItemId], [strColumnName])
	  SELECT DISTINCT 
	  AD.intBasisItemId,Item.strItemNo FROM tblCTAOPDetail AD 
	  JOIN tblCTAOP A ON A.intAOPId=AD.intAOPId
	  JOIN tblICItem Item ON Item.intItemId=AD.intBasisItemId
	  WHERE AD.intCommodityId=1 AND A.strYear=@strYear
	  UNION
	  SELECT intItemId,strItemNo FROM tblICItem Where strType='Other Charge' AND  ysnBasisContract=1 

	 SELECT TOP 1  @FirstBasisItem=[strColumnName] FROM #tblRequiredColumns ORDER BY [intColumnKey]

	 IF @FirstBasisItem IS NOT NULL
	 BEGIN
			SELECT TOP 2  @SecondBasisItem= CASE WHEN [strColumnName]<>@FirstBasisItem THEN [strColumnName] ELSE NULL END  FROM #tblRequiredColumns ORDER BY [intColumnKey]
	 END
	 IF @SecondBasisItem IS NOT NULL
	 BEGIN
			SELECT TOP 3  @ThirdBasisItem= CASE WHEN [strColumnName]<>@SecondBasisItem THEN [strColumnName] ELSE NULL END  FROM #tblRequiredColumns ORDER BY [intColumnKey]
	 END
	 IF @ThirdBasisItem IS NOT NULL
	 BEGIN
			SELECT TOP 4  @FourthBasisItem= CASE WHEN [strColumnName]<>@ThirdBasisItem THEN [strColumnName] ELSE NULL END  FROM #tblRequiredColumns ORDER BY [intColumnKey]
	 END  
	  IF @FourthBasisItem IS NOT NULL
	 BEGIN
			SELECT TOP 5  @FifthBasisItem= CASE WHEN [strColumnName]<>@FourthBasisItem THEN [strColumnName] ELSE NULL END  FROM #tblRequiredColumns ORDER BY [intColumnKey]
	 END 
	 IF @FifthBasisItem IS NOT NULL
	 BEGIN
			SELECT TOP 6  @SixthBasisItem= CASE WHEN [strColumnName]<>@FifthBasisItem THEN [strColumnName] ELSE NULL END  FROM #tblRequiredColumns ORDER BY [intColumnKey]
	 END

	 IF @SixthBasisItem IS NOT NULL
	BEGIN
    SELECT TOP 7 @SeventhBasisItem =
                   CASE
                     WHEN [strColumnName] <> @SixthBasisItem THEN [strColumnName]
                     ELSE NULL
                   END
    FROM #tblRequiredColumns
    ORDER BY [intColumnKey]
	END

  IF @SeventhBasisItem IS NOT NULL
  BEGIN
    SELECT TOP 8
    @EighthBasisItem =
                   CASE
                     WHEN [strColumnName] <> @SeventhBasisItem THEN [strColumnName]
                     ELSE NULL
                   END
    FROM #tblRequiredColumns
    ORDER BY [intColumnKey]
  END


	 SELECT @intColumnKey = MIN(intColumnKey) FROM #tblRequiredColumns

	WHILE @intColumnKey > 0
	BEGIN
		
		SET @strColumnName = NULL

		SET @SqlALTER = NULL
		SET @SqlInsert = NULL
		SET @SqlUpdate=NULL
		SET @SqlTotalPremiumCalculation=NULL

		SELECT @strColumnName = strColumnName
		FROM #tblRequiredColumns
		WHERE intColumnKey = @intColumnKey
					
		SET @SqlALTER = 'ALTER TABLE #tblCoffeeNeedPlan ADD  [' + @strColumnName + ']  DECIMAL(24,2) NULL'		
		--SELECT @SqlALTER
		EXEC (@SqlALTER)	
		
				
		
		  SET @SqlInsert = 'IF NOT EXISTS(SELECT 1 FROM #tblCoffeeNeedPlan)
							BEGIN
								INSERT INTO #tblCoffeeNeedPlan([strCommodityCode],[strShortName],[strItemNo],[strProductType],[dblVolume],[strVolumnUOM],[strCurrency],[strWeightUOM])
								SELECT DISTINCT
								CO.strCommodityCode,
								IM.strShortName,
								IM.strItemNo,
								ProductType.strDescription AS strProductType,
								AD.dblVolume,
								VM.strUnitMeasure	AS strVolumeUOM,
								Currency.strCurrency,
								WM.strUnitMeasure	AS strWeightUOM
								FROM	tblCTAOPDetail		AD
								JOIN	tblCTAOP			AP	ON	AD.intAOPId			=	AP.intAOPId
								LEFT  JOIN     tblSMCurrency     Currency ON Currency.intCurrencyID=AD.intCurrencyId
								LEFT  JOIN	tblICCommodity		CO	On	CO.intCommodityId	=	AD.intCommodityId	LEFT
								JOIN	tblICItem			IM	ON	IM.intItemId		=	AD.intItemId		LEFT
								JOIN	tblICItem			BI	ON	BI.intItemId		=	AD.intBasisItemId	LEFT
								JOIN	tblICItemUOM		VU	ON	VU.intItemUOMId		=	AD.intVolumeUOMId	LEFT
								JOIN	tblICUnitMeasure	VM	ON	VM.intUnitMeasureId	=	VU.intUnitMeasureId	LEFT
								JOIN	tblICItemUOM		WU	ON	WU.intItemUOMId		=	AD.intWeightUOMId	LEFT
								JOIN	tblICUnitMeasure	WM	ON	WM.intUnitMeasureId	=	WU.intUnitMeasureId
								LEFT JOIN tblICCommodityAttribute ProductType ON ProductType.intCommodityAttributeId = IM.intProductTypeId							
								WHERE AD.dblCost >0 AND AD.intCommodityId='+LTRIM(@IntCommodityId)+' AND AP.strYear='+@strYear +'
							END'
		

		--SELECT @SqlInsert
		EXEC (@SqlInsert)
		SET @SqlUpdate='UPDATE #tblCoffeeNeedPlan 
						SET ['+ @strColumnName + ']=AD.dblCost
						FROM	tblCTAOPDetail		AD
						JOIN	tblCTAOP			AP	ON	AD.intAOPId			=	AP.intAOPId
						LEFT  JOIN     tblSMCurrency     Currency ON Currency.intCurrencyID=AD.intCurrencyId
						LEFT  JOIN	tblICCommodity		CO	On	CO.intCommodityId	=	AD.intCommodityId	LEFT
						JOIN	tblICItem			IM	ON	IM.intItemId		=	AD.intItemId		LEFT
						JOIN	tblICItem			BI	ON	BI.intItemId		=	AD.intBasisItemId	LEFT
						JOIN	tblICItemUOM		VU	ON	VU.intItemUOMId		=	AD.intVolumeUOMId	LEFT
						JOIN	tblICUnitMeasure	VM	ON	VM.intUnitMeasureId	=	VU.intUnitMeasureId	LEFT
						JOIN	tblICItemUOM		WU	ON	WU.intItemUOMId		=	AD.intWeightUOMId	LEFT
						JOIN	tblICUnitMeasure	WM	ON	WM.intUnitMeasureId	=	WU.intUnitMeasureId
						LEFT JOIN tblICCommodityAttribute ProductType ON ProductType.intCommodityAttributeId = IM.intProductTypeId							
						WHERE AD.dblCost >0 AND AD.intCommodityId='+LTRIM(@IntCommodityId)+' AND AP.strYear='+@strYear +' AND BI.strItemNo='''+@strColumnName+''''
		
		--SELECT @SqlUpdate
		EXEC (@SqlUpdate)
		
		--SELECT * INTO tblCoffeeNeedPlan_1 FROM  #tblCoffeeNeedPlan
		SET @SqlTotalPremiumCalculation='UPDATE #tblCoffeeNeedPlan 
										 SET [dblTotalPremium]=ISNULL([dblTotalPremium],0)+AD.dblCost
										 FROM	#tblCoffeeNeedPlan
										 JOIN   tblCTAOPDetail		AD ON 1=1
										 JOIN	tblCTAOP			AP	ON	AD.intAOPId			=	AP.intAOPId			LEFT
										 JOIN	tblICCommodity		CO	On	CO.intCommodityId	=	AD.intCommodityId	LEFT
										 JOIN	tblICItem			BI	ON	BI.intItemId		=	AD.intBasisItemId 
										 WHERE  AD.dblCost >0 AND AD.intCommodityId='+LTRIM(@IntCommodityId)+' AND AP.strYear='+@strYear +' AND BI.strItemNo='''+@strColumnName+''''
		--SELECT @SqlTotalPremiumCalculation

		EXEC (@SqlTotalPremiumCalculation)		
		SELECT @intColumnKey = MIN(intColumnKey)
		FROM #tblRequiredColumns
		WHERE intColumnKey > @intColumnKey
	END

		SET @SqlInsert=NULL
		SET @SqlInsert = 'INSERT INTO #tblCoffeeNeedPlan([strCommodityCode],[strShortName],[strItemNo],[strProductType],[dblVolume],[strVolumnUOM],[strCurrency],[strWeightUOM])
							SELECT 
							Item.strCommodity AS strCommodityCode
							,Item.strShortName
							,Item.strItemNo
							,ProductType.strDescription AS strProductType
							,NULL [dblVolume],NULL [strVolumnUOM],NULL [strCurrency],NULL [strWeightUOM] FROM vyuICGetCompactItem Item
							JOIN tblICItem IM ON IM.intItemId=Item.intItemId 
							LEFT JOIN tblICCommodityAttribute ProductType ON ProductType.intCommodityAttributeId = IM.intProductTypeId
							LEFT JOIN tblCTAOPDetail AD ON AD.intItemId=Item.intItemId
							WHERE Item.strType IN (''Raw Material'',''Inventory'') AND Item.intCommodityId='+LTRIM(@IntCommodityId)+' AND Item.strStatus <> ''Discontinued'' AND  AD.intItemId IS NULL'
		EXEC (@SqlInsert)

		--SELECT * FROM #tblCoffeeNeedPlan 

		SET @SqlSelect ='SELECT [intNeedPlanKey],[strCommodityCode],[strShortName],[strItemNo],[strProductType],dbo.fnRemoveTrailingZeroes([dblVolume]) AS[dblVolume],[strVolumnUOM],[strCurrency],[strWeightUOM]'

		IF 	@FirstBasisItem  IS NOT NULL
		SET @SqlSelect=@SqlSelect+',dbo.fnRemoveTrailingZeroes([' + @FirstBasisItem + ']) AS Column1'
		
		IF 	@SecondBasisItem  IS NOT NULL														
		SET @SqlSelect=@SqlSelect+',dbo.fnRemoveTrailingZeroes([' + @SecondBasisItem + ']) AS Column2'
		
		IF 	@ThirdBasisItem  IS NOT NULL														
		SET @SqlSelect=@SqlSelect+',dbo.fnRemoveTrailingZeroes([' + @ThirdBasisItem + ']) AS Column3'
		
		IF 	@FourthBasisItem  IS NOT NULL														
		SET @SqlSelect=@SqlSelect+',dbo.fnRemoveTrailingZeroes([' + @FourthBasisItem + ']) AS Column4'
		
		IF 	@FifthBasisItem  IS NOT NULL														
		SET @SqlSelect=@SqlSelect+',dbo.fnRemoveTrailingZeroes([' + @FifthBasisItem + ']) AS Column5'
		
		IF 	@SixthBasisItem  IS NOT NULL														
		SET @SqlSelect=@SqlSelect+',dbo.fnRemoveTrailingZeroes([' + @SixthBasisItem + ']) AS Column6'

		IF 	@SeventhBasisItem  IS NOT NULL														
				SET @SqlSelect=@SqlSelect+',dbo.fnRemoveTrailingZeroes([' + @SeventhBasisItem + ']) AS Column7'
		
		IF 	@EighthBasisItem  IS NOT NULL														
				SET @SqlSelect=@SqlSelect+',dbo.fnRemoveTrailingZeroes([' + @EighthBasisItem + ']) AS Column8'

		SET @SqlSelect=@SqlSelect+' ,dbo.fnRemoveTrailingZeroes(dblTotalPremium) AS dblTotalPremium  FROM #tblCoffeeNeedPlan ORDER BY [intNeedPlanKey]'

		--SELECT @SqlSelect
		
		EXEC sp_executesql @SqlSelect,N'@FirstBasisItem nvarchar(MAX),@SecondBasisItem nvarchar(MAX),@ThirdBasisItem nvarchar(MAX),@FourthBasisItem nvarchar(MAX),@FifthBasisItem nvarchar(MAX),@SixthBasisItem nvarchar(MAX),@SeventhBasisItem nvarchar(MAX),@EighthBasisItem nvarchar(MAX)'						
										,@FirstBasisItem=@FirstBasisItem
										,@SecondBasisItem= @SecondBasisItem
										,@ThirdBasisItem= @ThirdBasisItem
										,@FourthBasisItem= @FourthBasisItem
										,@FifthBasisItem= @FifthBasisItem
										,@SixthBasisItem=@SixthBasisItem
										,@SeventhBasisItem=@SeventhBasisItem
										,@EighthBasisItem=@EighthBasisItem
END