CREATE PROCEDURE [dbo].[uspMFStockControlReport]
	@xmlParam NVARCHAR(MAX)=NULL
AS

BEGIN TRY
	SET NOCOUNT ON;
	
	DECLARE @strWeekStart NVARCHAR(500)
	DECLARE @strIsDay NVARCHAR(100)
	DECLARE @ysnCurrentWeek BIT
	DECLARE @dblDemandUsageDate NUMERIC(18, 6)
	DECLARE @dtmNewDate DATETIME
	DECLARE @dtmSecONdWeekComDate DATETIME
	DECLARE @dtmThirdWeekComDate DATETIME
	DECLARE @dtmFourthWeekComDate DATETIME
	DECLARE @dtmFivthWeekComDate DATETIME
	DECLARE @dtmSixthWeekComDate DATETIME
	DECLARE @dtmSeventhWeekComDate DATETIME
	DECLARE @dtmEightWeekComDate DATETIME
	DECLARE @dtmFirstMONthDate DATETIME
	DECLARE @dtmSecONdMONthDate DATETIME
	DECLARE @dtmThirdMONthDate DATETIME
	DECLARE @dtmFourthMONthDate DATETIME
	DECLARE @dtmFivthMONthDate DATETIME
	DECLARE @dtmSixthMONthDate DATETIME
	DECLARE @dtmLAStMONthDate DATETIME
	DECLARE @dblAverageWeekTransitPeriod NUMERIC(18, 0)
	DECLARE @dblNumberOfdecimal NUMERIC(18, 0)
	DECLARE @dtmDate DATETIME
	DECLARE @strItem NVARCHAR(50)
	DECLARE @strFrmitem NVARCHAR(50)
	DECLARE @strToitem NVARCHAR(50)
	DECLARE @strVENDor NVARCHAR(50)
	DECLARE @strCompanyNumber NVARCHAR(50)
	DECLARE @strFrmCompanyNumber NVARCHAR(50)
	DECLARE @strToCompanyNumber NVARCHAR(50)
	DECLARE @strErrMsg NVARCHAR(MAX)
	DECLARE @intIdoc INT
	DECLARE @strItemOPerator NVARCHAR(50)
	DECLARE @strCompanyOPerator NVARCHAR(50)
	DECLARE @strFilterCriteria NVARCHAR(MAX)
	DECLARE @strUDAItemGroup NVARCHAR(100)
	DECLARE @intRowNumber INT
	DECLARE @dtmETA DATETIME
	DECLARE @intTargetUOMId INT 
	DECLARE @strDemandClause NVARCHAR(max)
	DECLARE @strDemandResult NVARCHAR(MAX)
	DECLARE @strVendorClause NVARCHAR(MAX)
	DECLARE @strVendorResult NVARCHAR(MAX)
	DECLARE @strUOM NVARCHAR(50)

    SET @strDemandClause=''
    SET @strDemandResult=''
    SET @strVendorClause=''
    SET @strVendorResult=''
	SET @dtmDate = getdate()

	IF @xmlParam = ''
	BEGIN
		SELECT '' AS [AVAILABLE STOCK]
			,'' AS [AVAILABLE WEEK COVER]
			,'' AS [CP3]
			,'' AS [CP3 COVER]
			,'' AS [CP4]
			,'' AS [CP4 COVER]
			,'' AS [CP5]
			,'' AS [CP5 COVER]
			,'' AS [CP6]
			,'' AS [CP6 COVER]
			,'' AS [CP7]
			,'' AS [CP7 COVER]
			,'' AS [CP8]
			,'' AS [CP8 COVER]
			,'' AS [CP9-12]
			,'' AS [CP9-12 COVER]
			,'' AS [FULL CONTAINER LOAD]
			,'' AS [MINIMUM STOCK  WKS]
			,'' AS [NEXT SHIP IN (WKS)]
			,'' AS [SHIP FREQUENCY]
			,'' AS [TOTAL COMMIMTMENT WEEK COVER]
			,'' AS [TOTAL COMMITMENTS]
			,'' AS [TRANSIT STOCK]
			,'' AS [TRANSIT STOCK WEEK COVER]
			,'' AS [UNSHIPPED STOCK]
			,'' AS [USAGE]
			,'' AS [WK1]
			,'' AS [WK1 COVER]
			,'' AS [WK2]
			,'' AS [WK2 COVER]
			,'' AS [WK3]
			,'' AS [WK3 COVER]
			,'' AS [WK4]
			,'' AS [WK4 COVER]
			,'' AS [WK5]
			,'' AS [WK5 COVER]
			,'' AS [WK6]
			,'' AS [WK6 COVER]
			,'' AS [WK7]
			,'' AS [WK7 COVER]
			,'' AS [WK8]
			,'' AS [WK8 COVER]
			,'' AS [ITEM #]
			,'' AS [CP3 DATE]
			,'' AS [CP4 DATE]
			,'' AS [CP5 DATE]
			,'' AS [CP6 DATE]
			,'' AS [CP7 DATE]
			,'' AS [CP8 DATE]
			,'' AS [CP9-12 DATE]
			,'' AS [strCompanyNumber]
			,'' AS [strItemNo]
			,'' AS [strVendor]
			,'' AS [UDA_ItemGroup]
			,'' AS [WK1 DATE]
			,'' AS [WK2 DATE]
			,'' AS [WK3 DATE]
			,'' AS [WK4 DATE]
			,'' AS [WK5 DATE]
			,'' AS [WK6 DATE]
			,'' AS [WK7 DATE]
			,'' AS [WK8 DATE]
			,'' AS [CompanyNumber]
	END

	EXEC sp_xml_preparedocument @intIdoc OUTPUT
		,@xmlParam

	DECLARE @temp_agaglp_params TABLE (
		fieldname NVARCHAR(50)
		,condition NVARCHAR(20)
		,[from] NVARCHAR(50)
		,[to] NVARCHAR(50)
		,[join] NVARCHAR(10)
		,[begingroup] NVARCHAR(50)
		,[endgroup] NVARCHAR(50)
		,[datatype] NVARCHAR(50)
		)

	INSERT INTO @temp_agaglp_params
	SELECT *
	FROM OPENXML(@intIdoc, 'xmlparam/filters/filter', 3) WITH (
			fieldname NVARCHAR(50)
			,condition NVARCHAR(20)
			,[from] NVARCHAR(50)
			,[to] NVARCHAR(50)
			,[join] NVARCHAR(10)
			,[begingroup] NVARCHAR(50)
			,[endgroup] NVARCHAR(50)
			,[datatype] NVARCHAR(50)
			)

    
	SELECT @strItem = [from]
	FROM @temp_agaglp_params
	WHERE [fieldname] = 'strItemNo'

	SELECT @strCompanyNumber = [from]
	FROM @temp_agaglp_params
	WHERE [fieldname] = 'strCompanyNumber'

	SELECT @strVENDor = [from]
	FROM @temp_agaglp_params
	WHERE [fieldname] = 'strVendor'

	SELECT @strUDAItemGroup = [from]
	FROM @temp_agaglp_params
	WHERE [fieldname] = 'UDA_ItemGroup'

	SELECT @strFrmitem = [from]
	FROM @temp_agaglp_params
	WHERE [fieldname] = 'strItemNo'

	SELECT @strToitem = [to]
	FROM @temp_agaglp_params
	WHERE [fieldname] = 'strItemNo'

	SELECT @strFrmCompanyNumber = [from]
	FROM @temp_agaglp_params
	WHERE [fieldname] = 'strCompanyNumber'

	SELECT @strToCompanyNumber = [to]
	FROM @temp_agaglp_params
	WHERE [fieldname] = 'strCompanyNumber'

	SELECT @strItemOPerator = condition
	FROM @temp_agaglp_params
	WHERE [fieldname] = 'strItemNo'

	SELECT @strCompanyOPerator = condition
	FROM @temp_agaglp_params
	WHERE [fieldname] = 'strCompanyNumber'

	SELECT @strUOM = [from]
	FROM @temp_agaglp_params
	WHERE [fieldname] = 'strUOM'

	--IF ISNULL(@strCompanyNumber,'') = ''
	--	SET @strCompanyNumber = '_ALL'

	IF ISNULL(@strCompanyNumber,'') = ''
	SET @strCompanyNumber = ''

	IF ISNULL(@strItem,'') = ''
		SET @strItem = '_ALL'

	IF ISNULL(@strUDAItemGroup,'') = ''
		SET @strUDAItemGroup = '_ALL'
	
	Select @intTargetUOMId=intUnitMeasureId From  tblICUnitMeasure Where strUnitMeasure=@strUOM
		
	DECLARE @tempDemand AS TABLE  (
		MaterialKey INT
		,[Item #] NVARCHAR(50)
		,usage FLOAT
		,[MINIMUM STOCK  WKS] FLOAT
		,[Full Container Load] FLOAT
		,[SHIP FREQUENCY] FLOAT
		,UDA_CompanyNumber NVARCHAR(500)
		)
	DECLARE @tempDemandFilter AS TABLE (
		MaterialKey INT
		,[Item #] NVARCHAR(50)
		,usage FLOAT
		,[MINIMUM STOCK  WKS] FLOAT
		,[Full Container Load] FLOAT
		,[SHIP FREQUENCY] FLOAT
		)
	DECLARE @tempDemandAvailableStock AS TABLE (MaterialKey INT)
	DECLARE @tmpInventory AS TABLE (
		PrimaryQty FLOAT
		,materialKey INT
		,UDA_CompanyNumber NVARCHAR(500)
		)
	DECLARE @tmpDetail AS TABLE (
		[Item #] NVARCHAR(50)
		,usage FLOAT
		,[AVAILABLE STOCK] FLOAT
		,MaterialKey INT
		,[MINIMUM STOCK  WKS] FLOAT
		,[Full Container Load] FLOAT
		,[SHIP FREQUENCY] FLOAT
		,UDA_CompanyNumber NVARCHAR(500)
		)
	DECLARE @tmpFinal AS TABLE (
		[Item #] NVARCHAR(50)
		,usage FLOAT
		,[AVAILABLE STOCK] FLOAT
		)
	DECLARE @Material AS TABLE (
		materialKey NUMERIC(18, 0)
		,inventorymaterialkey NUMERIC(18, 0)
		)
		
		
	DECLARE @Month AS TABLE (
		materialKey NUMERIC(18, 0)
		,Quantity FLOAT
		,ETA DATETIME
		,UDA_CompanyNumber NVARCHAR(500)
		)
	DECLARE @Week AS TABLE (
		materialKey NUMERIC(18, 0)
		,Quantity FLOAT
		,ETA DATETIME
		,[Expected Week] INT
		,UDA_CompanyNumber NVARCHAR(500)
		)
	DECLARE @MonthandWeek AS TABLE (
		materialKey NUMERIC(18, 0)
		 ,ETA DATETIME
		,[Week 1] FLOAT
		,[Week 2] FLOAT
		,[Week 3] FLOAT
		,[Week 4] FLOAT
		,[Week 5] FLOAT
		,[Week 6] FLOAT
		,[Week 7] FLOAT
		,[Week 8] FLOAT
		,[MONth 1] FLOAT
		,[MONth 2] FLOAT
		,[MONth 3] FLOAT
		,[MONth 4] FLOAT
		,[MONth 5] FLOAT
		,[MONth 6] FLOAT
		,[MONth 9-12] FLOAT
		,UDA_CompanyNumber NVARCHAR(500)
		)
	
	Select @strWeekStart=strStartDayOfTheWeekForDemandPlanning From  tblMFCompanyPreference 	      
	If ISNULL(@strWeekStart,'')=''
		SET @strWeekStart = 'Sunday'

	Select @ysnCurrentWeek=ISNULL(ysnConsiderCurrentWeekForDemandPlanning,1) From  tblMFCompanyPreference 
		
	Select @dblDemandUsageDate=dblDemandUsageDays From  tblMFCompanyPreference       
	If ISNULL(@dblDemandUsageDate,0)<=0
		SET @dblDemandUsageDate = 5

	Select @dblAverageWeekTransitPeriod=dblAverageWeekTransitPeriodForDemandPlanning From  tblMFCompanyPreference   
	If ISNULL(@dblAverageWeekTransitPeriod,0)<=0
		SET @dblAverageWeekTransitPeriod = 6

	SET @dblNumberOfdecimal = 3

	----SELECT day FROM date          
	SELECT @strIsDay = DATENAME(dw, @dtmDate)

	---    
	-----------calculate date based on both setting         
	IF @strWeekStart = 'Monday'
	BEGIN
		IF @strIsDay = 'Monday'
		BEGIN
			SET @dtmNewDate = @dtmDate
		END
		ELSE IF @strIsDay = 'Tuesday'
		BEGIN
			SET @dtmNewDate = DATEADD(dd, - 1, @dtmDate)
		END
		ELSE IF @strIsDay = 'Wednesday'
		BEGIN
			SET @dtmNewDate = DATEADD(dd, - 2, @dtmDate)
		END
		ELSE IF @strIsDay = 'Thursday'
		BEGIN
			SET @dtmNewDate = DATEADD(dd, - 3, @dtmDate)
		END
		ELSE IF @strIsDay = 'Friday'
		BEGIN
			SET @dtmNewDate = DATEADD(dd, - 4, @dtmDate)
		END
		ELSE IF @strIsDay = 'Saturday'
		BEGIN
			SET @dtmNewDate = DATEADD(dd, - 5, @dtmDate)
		END
		ELSE IF @strIsDay = 'Sunday'
		BEGIN
			SET @dtmNewDate = DATEADD(dd, - 6, @dtmDate)
		END
	END
	ELSE IF @strWeekStart = 'Tuesday'
	BEGIN
		IF @strIsDay = 'Monday'
		BEGIN
			SET @dtmNewDate = DATEADD(dd, - 6, @dtmDate)
		END
		ELSE IF @strIsDay = 'Tuesday'
		BEGIN
			SET @dtmNewDate = DATEADD(dd, 0, @dtmDate)
		END
		ELSE IF @strIsDay = 'Wednesday'
		BEGIN
			SET @dtmNewDate = DATEADD(dd, - 1, @dtmDate)
		END
		ELSE IF @strIsDay = 'Thursday'
		BEGIN
			SET @dtmNewDate = DATEADD(dd, - 2, @dtmDate)
		END
		ELSE IF @strIsDay = 'Friday'
		BEGIN
			SET @dtmNewDate = DATEADD(dd, - 3, @dtmDate)
		END
		ELSE IF @strIsDay = 'Saturday'
		BEGIN
			SET @dtmNewDate = DATEADD(dd, - 4, @dtmDate)
		END
		ELSE IF @strIsDay = 'Sunday'
		BEGIN
			SET @dtmNewDate = DATEADD(dd, - 5, @dtmDate)
		END
	END
	ELSE IF @strWeekStart = 'Wednesday'
	BEGIN
		IF @strIsDay = 'Monday'
		BEGIN
			SET @dtmNewDate = DATEADD(dd, - 5, @dtmDate)
		END
		ELSE IF @strIsDay = 'Tuesday'
		BEGIN
			SET @dtmNewDate = DATEADD(dd, - 6, @dtmDate)
		END
		ELSE IF @strIsDay = 'Wednesday'
		BEGIN
			SET @dtmNewDate = DATEADD(dd, 0, @dtmDate)
		END
		ELSE IF @strIsDay = 'Thursday'
		BEGIN
			SET @dtmNewDate = DATEADD(dd, - 1, @dtmDate)
		END
		ELSE IF @strIsDay = 'Friday'
		BEGIN
			SET @dtmNewDate = DATEADD(dd, - 2, @dtmDate)
		END
		ELSE IF @strIsDay = 'Saturday'
		BEGIN
			SET @dtmNewDate = DATEADD(dd, - 3, @dtmDate)
		END
		ELSE IF @strIsDay = 'Sunday'
		BEGIN
			SET @dtmNewDate = DATEADD(dd, - 4, @dtmDate)
		END
	END
	ELSE IF @strWeekStart = 'Thursday'
	BEGIN
		IF @strIsDay = 'Monday'
		BEGIN
			SET @dtmNewDate = DATEADD(dd, - 4, @dtmDate)
		END
		ELSE IF @strIsDay = 'Tuesday'
		BEGIN
			SET @dtmNewDate = DATEADD(dd, - 5, @dtmDate)
		END
		ELSE IF @strIsDay = 'Wednesday'
		BEGIN
			SET @dtmNewDate = DATEADD(dd, - 6, @dtmDate)
		END
		ELSE IF @strIsDay = 'Thursday'
		BEGIN
			SET @dtmNewDate = DATEADD(dd, 0, @dtmDate)
		END
		ELSE IF @strIsDay = 'Friday'
		BEGIN
			SET @dtmNewDate = DATEADD(dd, - 1, @dtmDate)
		END
		ELSE IF @strIsDay = 'Saturday'
		BEGIN
			SET @dtmNewDate = DATEADD(dd, - 2, @dtmDate)
		END
		ELSE IF @strIsDay = 'Sunday'
		BEGIN
			SET @dtmNewDate = DATEADD(dd, - 3, @dtmDate)
		END
	END
	ELSE IF @strWeekStart = 'Friday'
	BEGIN
		IF @strIsDay = 'Monday'
		BEGIN
			SET @dtmNewDate = DATEADD(dd, - 3, @dtmDate)
		END
		ELSE IF @strIsDay = 'Tuesday'
		BEGIN
			SET @dtmNewDate = DATEADD(dd, - 4, @dtmDate)
		END
		ELSE IF @strIsDay = 'Wednesday'
		BEGIN
			SET @dtmNewDate = DATEADD(dd, - 5, @dtmDate)
		END
		ELSE IF @strIsDay = 'Thursday'
		BEGIN
			SET @dtmNewDate = DATEADD(dd, - 6, @dtmDate)
		END
		ELSE IF @strIsDay = 'Friday'
		BEGIN
			SET @dtmNewDate = DATEADD(dd, 0, @dtmDate)
		END
		ELSE IF @strIsDay = 'Saturday'
		BEGIN
			SET @dtmNewDate = DATEADD(dd, - 1, @dtmDate)
		END
		ELSE IF @strIsDay = 'Sunday'
		BEGIN
			SET @dtmNewDate = DATEADD(dd, - 2, @dtmDate)
		END
	END
	ELSE IF @strWeekStart = 'Saturday'
	BEGIN
		IF @strIsDay = 'Monday'
		BEGIN
			SET @dtmNewDate = DATEADD(dd, - 2, @dtmDate)
		END
		ELSE IF @strIsDay = 'Tuesday'
		BEGIN
			SET @dtmNewDate = DATEADD(dd, - 3, @dtmDate)
		END
		ELSE IF @strIsDay = 'Wednesday'
		BEGIN
			SET @dtmNewDate = DATEADD(dd, - 4, @dtmDate)
		END
		ELSE IF @strIsDay = 'Thursday'
		BEGIN
			SET @dtmNewDate = DATEADD(dd, - 5, @dtmDate)
		END
		ELSE IF @strIsDay = 'Friday'
		BEGIN
			SET @dtmNewDate = DATEADD(dd, - 6, @dtmDate)
		END
		ELSE IF @strIsDay = 'Saturday'
		BEGIN
			SET @dtmNewDate = DATEADD(dd, 0, @dtmDate)
		END
		ELSE IF @strIsDay = 'Sunday'
		BEGIN
			SET @dtmNewDate = DATEADD(dd, - 1, @dtmDate)
		END
	END
	ELSE IF @strWeekStart = 'Sunday'
	BEGIN
		IF @strIsDay = 'Monday'
		BEGIN
			SET @dtmNewDate = DATEADD(dd, - 1, @dtmDate)
		END
		ELSE IF @strIsDay = 'Tuesday'
		BEGIN
			SET @dtmNewDate = DATEADD(dd, - 2, @dtmDate)
		END
		ELSE IF @strIsDay = 'Wednesday'
		BEGIN
			SET @dtmNewDate = DATEADD(dd, - 3, @dtmDate)
		END
		ELSE IF @strIsDay = 'Thursday'
		BEGIN
			SET @dtmNewDate = DATEADD(dd, - 4, @dtmDate)
		END
		ELSE IF @strIsDay = 'Friday'
		BEGIN
			SET @dtmNewDate = DATEADD(dd, - 5, @dtmDate)
		END
		ELSE IF @strIsDay = 'Saturday'
		BEGIN
			SET @dtmNewDate = DATEADD(dd, - 6, @dtmDate)
		END
		ELSE IF @strIsDay = 'Sunday'
		BEGIN
			SET @dtmNewDate = DATEADD(dd, 0, @dtmDate)
		END
	END

	IF @ysnCurrentWeek = 0
	BEGIN
		SET @dtmNewDate = DATEADD(dd, + 7, @dtmNewDate)
	END
       
	SET @dtmSecONdWeekComDate = DATEADD(dd, + 7, @dtmNewDate)
	SET @dtmThirdWeekComDate = DATEADD(dd, + 7, @dtmSecONdWeekComDate)
	SET @dtmFourthWeekComDate = DATEADD(dd, + 7, @dtmThirdWeekComDate)
	SET @dtmFivthWeekComDate = DATEADD(dd, + 7, @dtmFourthWeekComDate)
	SET @dtmSixthWeekComDate = DATEADD(dd, + 7, @dtmFivthWeekComDate)
	SET @dtmSeventhWeekComDate = DATEADD(dd, + 7, @dtmSixthWeekComDate)
	SET @dtmEightWeekComDate = DATEADD(dd, + 7, @dtmSeventhWeekComDate)
	SET @dtmFirstMONthDate = DATEADD(dd, + 7, @dtmEightWeekComDate)
	SET @dtmSecONdMONthDate = DATEADD(dd, + 28, @dtmFirstMONthDate)
	SET @dtmThirdMONthDate = DATEADD(dd, + 28, @dtmSecONdMONthDate)
	SET @dtmFourthMONthDate = DATEADD(dd, + 28, @dtmThirdMONthDate)
	SET @dtmFivthMONthDate = DATEADD(dd, + 28, @dtmFourthMONthDate)
	SET @dtmSixthMONthDate = DATEADD(dd, + 28, @dtmFivthMONthDate)
	SET @dtmLAStMONthDate = DATEADD(dd, + 28, @dtmSixthMONthDate)

	
    IF @strItem = '_ALL' AND @strCompanyNumber = '_ALL'
	SET @strDemandClause=''

	ELSE IF (@strItem <> '_ALL' AND @strCompanyNumber = '' AND @strItemOPerator = 'Equal To')
	SET @strDemandClause=' WHERE iRM.ItemNumber = '''+@strItem+ ''''
		
	ELSE IF (@strItem <> '_ALL' AND @strCompanyNumber = '_ALL' AND @strItemOPerator = 'Equal To')
	SET @strDemandClause=' WHERE iRM.ItemNumber = '''+@strItem+ ''''
	
	ELSE IF ((@strFrmitem <> '_ALL' AND @strToitem <> '_ALL') AND @strCompanyNumber = '_ALL' AND @strItemOPerator = 'Between')
	SET @strDemandClause=' WHERE iRM.ItemNumber BETWEEN '''+@strFrmitem+''' AND '''+@strToitem+''''
	
	ELSE IF ((@strFrmitem = '_ALL' OR @strToitem = '_ALL') AND @strCompanyNumber = '_ALL' AND @strItemOPerator = 'Between')
	SET @strDemandClause=''
	
	ELSE IF (@strItem = '_ALL' AND @strCompanyNumber <> '_ALL' AND @strCompanyOPerator = 'Equal To')
	SET @strDemandClause=' WHERE iRM.CompanyNumber = '''+@strCompanyNumber+''''
	
	ELSE IF (@strItem = '_ALL' AND @strCompanyNumber <> '_ALL' AND @strCompanyOPerator = 'Between')
	SET @strDemandClause=' WHERE iRM.CompanyNumber BETWEEN '''+@strFrmCompanyNumber+''' AND '''+@strToCompanyNumber+''''
	
	ELSE IF (@strItem <> '_ALL' AND @strCompanyNumber <> '_ALL' AND @strCompanyOPerator = 'Equal To' AND @strItemOPerator = 'Equal To')
	SET @strDemandClause=' WHERE iRM.CompanyNumber = '''+@strCompanyNumber+''' AND iRM.ItemNumber = '''+@strItem+''''
	
	ELSE IF ((@strFrmitem <> '_ALL' AND @strToitem <> '_ALL') AND @strCompanyNumber <> '_ALL' AND @strCompanyOPerator = 'Between' AND @strItemOPerator = 'Between')
	SET @strDemandClause=' WHERE (iRM.CompanyNumber BETWEEN '''+@strFrmCompanyNumber+''' AND '''+@strToCompanyNumber+''')AND (iRM.ItemNumber BETWEEN '''+@strFrmitem+''' AND '''+@strToitem+''')'
	
	ELSE IF ((@strFrmitem = '_ALL' OR @strToitem = '_ALL') AND @strCompanyNumber <> '_ALL' AND @strCompanyOPerator = 'Between' AND @strItemOPerator = 'Between')
	SET @strDemandClause=' WHERE (iRM.CompanyNumber BETWEEN '''+@strFrmCompanyNumber+''' AND '''+@strToCompanyNumber+''')'
	
	ELSE IF ((@strFrmitem <> '_ALL' AND @strToitem <> '_ALL') AND @strCompanyNumber <> '_ALL' AND @strCompanyOPerator = 'Equal To' AND @strItemOPerator = 'Between')
	SET @strDemandClause=' WHERE iRM.CompanyNumber = '''+@strCompanyNumber+''' AND ( iRM.ItemNumber BETWEEN '''+@strFrmitem+''' AND '''+@strToitem+''')'
	
	ELSE IF ((@strFrmitem = '_ALL'OR @strToitem = '_ALL') AND @strCompanyNumber <> '_ALL' AND @strCompanyOPerator = 'Equal To' AND @strItemOPerator = 'Between')
	SET @strDemandClause=' WHERE iRM.CompanyNumber = '''+@strCompanyNumber+''''
	
	ELSE IF (@strItem <> '_ALL' AND @strCompanyNumber <> '_ALL' AND @strCompanyOPerator = 'Between' AND @strItemOPerator = 'Equal To')
	SET @strDemandClause='	WHERE (iRM.CompanyNumber BETWEEN '''+@strFrmCompanyNumber+''' AND '''+@strToCompanyNumber+''' )AND iRM.ItemNumber = '''+@strItem+''''
    
	SET @strDemandResult= '
	
		DECLARE @tempDemand AS TABLE  (
		MaterialKey INT
		,[Item #] NVARCHAR(50)
		,usage FLOAT
		,[MINIMUM STOCK  WKS] FLOAT
		,[Full Container Load] FLOAT
		,[SHIP FREQUENCY] FLOAT
		,UDA_CompanyNumber NVARCHAR(50)
		)
		
		Declare @iMake_RawMaterialDemandPlan AS TABLE (
		ItemNumber NVARCHAR(100)
		,DemandQuantity DECIMAL(18, 7)
		,CompanyNumber NVARCHAR(50)
		)
		
		 DECLARE @CompanyNumber AS  TABLE         
		(strCompanyNumber NVARCHAR(50) COLLATE Latin1_General_CI_AS)
	
		INSERT INTO @CompanyNumber
		SELECT DISTINCT strCompanyCode FROM tblSMMultiCompany

		DECLARE @CompanyItemMap AS  TABLE         
		(strItemNumber NVARCHAR(100) COLLATE Latin1_General_CI_AS,strCompanyNumber NVARCHAR(50))

		INSERT INTO @CompanyItemMap
		SELECT IM.strItemNo,CASE WHEN ISNULL(''' + @strCompanyNumber + ''','''') = '''' THEN '''' ELSE L.strCompanyNumber END
		FROM @CompanyNumber L,tblICItem IM 
		Where IM.strType NOT IN (''Other Charge'',''Comment'')

		INSERT INTO @iMake_RawMaterialDemandPlan
		SELECT DISTINCT i.strItemNo
		,ISNULL(dbo.fnMFConvertQuantityToTargetItemUOM((Select a.intItemUOMId From tblICItemUOM a Join tblICUnitMeasure b on a.intUnitMeasureId=b.intUnitMeasureId Where a.intItemId=i.intItemId AND b.strUnitMeasure=RP.strUOM),iu.intItemUOMId,RP.dblQuantity),0)
		,IM.strCompanyNumber
		FROM @CompanyItemMap IM
		LEFT JOIN tblMFItemDemandStage RP ON RP.strItemNo =IM.strItemNumber 
		and ISNULL(RP.strCompanyCode,'''')=ISNULL(IM.strCompanyNumber,'''')  COLLATE SQL_Latin1_General_CP1_CS_AS
		JOIN tblICItem i ON RP.strItemNo =i.strItemNo
		JOIN tblICItemUOM iu on i.intItemId=iu.intItemId
		Where iu.intUnitMeasureId=' + CONVERT(VARCHAR, @intTargetUOMId) + '

	 INSERT INTO @tempDemand
		SELECT *
		FROM (
			SELECT DISTINCT M.intItemId
				,iRM.ItemNumber AS [Item #]
				,Round(ISNULL(iRM.DemandQuantity, 0),'+CONVERT(NVARCHAR(100),@dblNumberOfdecimal)+') * '+CONVERT(NVARCHAR(100),@dblDemandUsageDate)+' AS [USAGE]
				,ROUND(ISNULL(M.dblMinStockWeeks, 0),'+CONVERT(NVARCHAR(100),@dblNumberOfdecimal)+') AS [MINIMUM STOCK  WKS]
				,ROUND(ISNULL(M.dblFullContainerSize, 0), '+CONVERT(NVARCHAR(100),@dblNumberOfdecimal)+') AS [Full Container Load]
				,(
					ROUND(ISNULL(M.dblFullContainerSize, 0), '+CONVERT(NVARCHAR(100),@dblNumberOfdecimal)+') / CASE 
						WHEN Round(ISNULL(iRM.DemandQuantity, 0), '+CONVERT(NVARCHAR(100),@dblNumberOfdecimal)+') * '+CONVERT(NVARCHAR(100),@dblDemandUsageDate)+' = 0
							THEN 1
						ELSE Round(ISNULL(iRM.DemandQuantity, 0), '+CONVERT(NVARCHAR(100),@dblNumberOfdecimal)+') * '+CONVERT(NVARCHAR(100),@dblDemandUsageDate)+'
						END
					) AS [SHIP FREQUENCY]
				,iRM.CompanyNumber
			FROM @iMake_RawMaterialDemandPlan iRM
			JOIN tblICItem M ON M.strItemNo = iRM.ItemNumber collate Latin1_General_CI_AS
			'+@strDemandClause+'
			GROUP BY iRM.ItemNumber
				,iRM.DemandQuantity
				,M.intItemId
				,M.dblMinStockWeeks
				,M.dblFullContainerSize
				,iRM.CompanyNumber
						
			) T 
			Select * from @tempDemand

			'

    INSERT INTO @tempDemand EXEC(@strDemandResult)

	INSERT INTO @tempDemandAvailableStock
	SELECT DISTINCT MaterialKey
	FROM @tempDemand
   
    --Lot Tracked
	INSERT INTO @tmpInventory
	Select 
	SUM(PrimaryQty),
	MaterialKey,
	ISNULL(strCompanyCode,'')
	From
	(
	SELECT (ISNULL(dbo.fnMFConvertQuantityToTargetItemUOM(l.intItemUOMId,(Select intItemUOMId from tblICItemUOM Where intItemId=i.intItemId AND intUnitMeasureId=@intTargetUOMId),l.dblQty),0.0)) PrimaryQty
		,t.MaterialKey
		,m.strCompanyCode strCompanyCode
	FROM @tempDemandAvailableStock t
	LEFT JOIN tblICLot l ON l.intItemId = t.MaterialKey
	Join tblICItem i on i.intItemId=l.intItemId
		AND l.intLotStatusId IN (
			SELECT intLotStatusId
			FROM tblICLotStatus
			WHERE strPrimaryStatus IN (
					'Active'
					,'Quarantine'
					)
			)
	LEFT Join tblSMMultiCompany m on l.intCompanyId=m.intMultiCompanyId
	Where i.strLotTracking<>'No'
	) t
	GROUP BY t.MaterialKey,t.strCompanyCode

	--Item Tracked
	INSERT INTO @tmpInventory
	Select 
	SUM(PrimaryQty),
	MaterialKey,
	strCompanyCode
	From
	(
		SELECT (ISNULL(dbo.fnMFConvertQuantityToTargetItemUOM(sd.intItemUOMId,(Select intItemUOMId from tblICItemUOM Where intItemId=i.intItemId AND intUnitMeasureId=@intTargetUOMId),sd.dblAvailableQty),0.0)) PrimaryQty
		,t.MaterialKey
		,'' AS strCompanyCode
		FROM @tempDemandAvailableStock t
		Join vyuMFGetItemStockDetail sd on t.MaterialKey=sd.intItemId
		Join tblICItem i on i.intItemId=sd.intItemId
		Where i.strLotTracking='No'
	) t
	GROUP BY t.MaterialKey,t.strCompanyCode

	INSERT INTO @tmpDetail
	SELECT td.[Item #]
		,td.[USAGE]
		,ISNULL(ti.PrimaryQty, 0) AS [AVAILABLE STOCK]
		,td.MaterialKey
		,td.[MINIMUM STOCK  WKS]
		,td.[Full cONtainer load]
		,td.[SHIP FREQUENCY]
		,td.UDA_CompanyNumber
	FROM @tempDemand td
	LEFT JOIN @tmpInventory ti ON ti.MaterialKey = td.MaterialKey
	AND ti.UDA_CompanyNumber = td.UDA_CompanyNumber
	
   IF (@strVENDor <> '_ALL' AND @strItemOPerator = 'Between' AND (@strFrmitem <> '_ALL' AND @strToitem <> '_ALL'))
   SET @strVendorClause=' WHERE  E.strName = '''+@strVENDor+''' AND M.strItemNo BETWEEN '''+@strFrmitem+''' AND '''+@strToitem+''''
   
   ELSE IF (@strVENDor <> '_ALL' AND @strItemOPerator = 'Between' AND (@strFrmitem = '_ALL' OR @strToitem = '_ALL'))
   SET @strVendorClause=' WHERE E.strName = '''+@strVENDor+''''
   
   ELSE IF @strVENDor <> '_ALL' AND @strItemOPerator = 'Equal To' AND @strItem <> '_ALL'
   SET @strVendorClause=' WHERE M.strItemNo = '''+@strItem+''''
     
   ELSE IF @strVENDor <> '_ALL' AND @strItemOPerator = 'Equal To' AND @strItem = '_ALL'
   SET @strVendorClause=''
   
   ELSE IF @strVENDor = '_ALL' AND @strItemOPerator = 'Equal To' AND @strItem = '_ALL'
   SET @strVendorClause=''
   
   ELSE IF @strVENDor = '_ALL' AND @strItemOPerator = 'Equal To' AND @strItem <> '_ALL'
   SET @strVendorClause=' WHERE M.strItemNo = '''+@strItem+''''
   
   ELSE IF @strVENDor = '_ALL' AND @strItemOPerator = 'Between' AND ( @strFrmitem <> '_ALL' AND @strToitem <> '_ALL')
   SET @strVendorClause=' WHERE M.strItemNo BETWEEN '''+@strFrmitem+''' AND '''+@strToitem+''''
   
   ELSE IF @strVENDor = '_ALL' AND @strItemOPerator = 'Between' AND ( @strFrmitem = '_ALL' OR @strToitem = '_ALL')
   SET @strVendorClause=''
   
	SET @strVendorResult =' 
	DECLARE @Month AS TABLE (
		materialKey NUMERIC(18, 0)
		,Quantity FLOAT
		,ETA DATETIME
		,UDA_CompanyNumber NVARCHAR(50)
		)
		
	INSERT INTO @Month
		SELECT
		t.intItemId,
		SUM(t.dblQty),
		t.dtmUpdatedAvailabilityDate,
		ISNULL(t.strCompanyCode,'''') AS strCompanyCode
		From (
		SELECT M.intItemId
			,ROUND(ISNULL((dbo.fnMFConvertQuantityToTargetItemUOM(CD.intItemUOMId,(Select intItemUOMId from tblICItemUOM Where intItemId=CD.intItemId AND intUnitMeasureId=' + CONVERT(VARCHAR,@intTargetUOMId) + '),ISNULL(CD.dblQuantity,0))),0),'+CONVERT(NVARCHAR(100),@dblNumberOfdecimal)+') dblQty
			,CD.dtmUpdatedAvailabilityDate
			,m.strCompanyCode
		FROM tblCTContractHeader CH
		JOIN tblCTContractDetail CD ON CD.intContractHeaderId = CH.intContractHeaderId 
		--JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId=CD.intCompanyLocationId
		JOIN tblCTContractStatus CS ON CS.intContractStatusId = CD.intContractStatusId
			AND CS.strContractStatus NOT IN (''Cancelled'',''Complete'')
		--AND CL.strInternalNotes=CASE WHEN '''+@strCompanyNumber+'''=''_ALL'' THEN   CL.strInternalNotes ELSE  '''+@strCompanyNumber+''' END 
		JOIN tblEMEntity E ON E.intEntityId = CH.intEntityId
		JOIN tblICItem M ON M.intItemId = CD.intItemId
		LEFT JOIN tblSMMultiCompany m on CH.intCompanyId=m.intMultiCompanyId
		'+@strVendorClause+'
		) t
		GROUP BY t.intItemId
			,t.dtmUpdatedAvailabilityDate
			,t.strCompanyCode
		SELECT * FROM @Month'
   
   
    INSERT INTO @Month EXEC(@strVendorResult)
      
	  --select @strVendorResult
      --select * from @Month

	UPDATE @Month SET ETA = GETDATE() WHERE ETA < GETDATE() OR ETA IS NULL
	
    INSERT INTO @Week
	SELECT MaterialKey,Quantity,ETA,CEILING((DATEDIFF(dd, @dtmNewDate, ETA) + 1) / 7.0) AS [Expected Week] ,UDA_CompanyNumber
	FROM @Month

	INSERT INTO @MonthandWeek
	SELECT MaterialKey
		,ETA
		,CASE 
			WHEN [Expected Week] = 1
				THEN Quantity
			ELSE 0
			END AS [Week 1]
		,CASE 
			WHEN [Expected Week] = 2
				THEN Quantity
			ELSE 0
			END AS [Week 2]
		,CASE 
			WHEN [Expected Week] = 3
				THEN Quantity
			ELSE 0
			END AS [Week 3]
		,CASE 
			WHEN [Expected Week] = 4
				THEN Quantity
			ELSE 0
			END AS [Week 4]
		,CASE 
			WHEN [Expected Week] = 5
				THEN Quantity
			ELSE 0
			END AS [Week 5]
		,CASE 
			WHEN [Expected Week] = 6
				THEN Quantity
			ELSE 0
			END AS [Week 6]
		,CASE 
			WHEN [Expected Week] = 7
				THEN Quantity
			ELSE 0
			END AS [Week 7]
		,CASE 
			WHEN [Expected Week] = 8
				THEN Quantity
			ELSE 0
			END AS [Week 8]
		,CASE 
			WHEN [Expected Week] >= 9
				AND [Expected Week] <= 12
				THEN Quantity
			ELSE 0
			END AS [MONth 1]
		,CASE 
			WHEN [Expected Week] >= 13
				AND [Expected Week] <= 16
				THEN Quantity
			ELSE 0
			END AS [MONth 2]
		,CASE 
			WHEN [Expected Week] >= 17
				AND [Expected Week] <= 20
				THEN Quantity
			ELSE 0
			END AS [MONth 3]
		,CASE 
			WHEN [Expected Week] >= 21
				AND [Expected Week] <= 24
				THEN Quantity
			ELSE 0
			END AS [MONth 4]
		,CASE 
			WHEN [Expected Week] >= 25
				AND [Expected Week] <= 28
				THEN Quantity
			ELSE 0
			END AS [MONth 5]
		,CASE 
			WHEN [Expected Week] >= 29
				AND [Expected Week] <= 32
				THEN Quantity
			ELSE 0
			END AS [MONth 6]
		,CASE 
			WHEN [Expected Week] >= 33
				THEN Quantity
			ELSE 0
			END AS [MONth 9-12]
		,UDA_CompanyNumber
	FROM @Week
 
DECLARE @Final AS TABLE(
[ITEM #] NVARCHAR(50),
[USAGE] FLOAT,
[MINIMUM STOCK  WKS] FLOAT,
[AVAILABLE STOCK] FLOAT,
[WK1] FLOAT,
[WK2] FLOAT,
[WK3] FLOAT,
[WK4] FLOAT,
[WK5] FLOAT,
[WK6] FLOAT,
[WK7] FLOAT,
[WK8] FLOAT,
[TRANSIT STOCK] FLOAT,
[CP3] FLOAT,
[CP4] FLOAT,
[CP5] FLOAT,
[CP6] FLOAT,
[CP7] FLOAT,
[CP8] FLOAT,
[CP9-12] FLOAT,
[UNSHIPPED STOCK] FLOAT,
[AVAILABLE WEEK COVER] FLOAT,
[WK1 COVER] FLOAT,
[WK2 COVER] FLOAT,
[WK3 COVER] FLOAT,
[WK4 COVER] FLOAT,
[WK5 COVER] FLOAT,
[WK6 COVER] FLOAT,
[WK7 COVER] FLOAT,
[WK8 COVER] FLOAT,
[CP3 COVER] FLOAT,
[CP4 COVER] FLOAT,
[CP5 COVER] FLOAT,
[CP6 COVER] FLOAT,
[CP7 COVER] FLOAT,
[CP8 COVER] FLOAT,
[CP9-12 COVER] FLOAT,
[NEXT SHIP IN (WKS)] FLOAT,
[FULL CONTAINER LOAD] FLOAT,
[SHIP FREQUENCY] FLOAT,
[TOTAL COMMITMENTS] FLOAT,
[TRANSIT STOCK WEEK COVER] FLOAT,
[WK1 DATE] NVARCHAR(50),
[WK2 DATE] NVARCHAR(50),
[WK3 DATE] NVARCHAR(50),
[WK4 DATE] NVARCHAR(50),
[WK5 DATE] NVARCHAR(50),
[WK6 DATE] NVARCHAR(50),
[WK7 DATE] NVARCHAR(50),
[WK8 DATE] NVARCHAR(50),
[CP3 DATE] NVARCHAR(50),
[CP4 DATE] NVARCHAR(50),
[CP5 DATE] NVARCHAR(50),
[CP6 DATE] NVARCHAR(50),
[CP7 DATE] NVARCHAR(50),
[CP8 DATE] NVARCHAR(50),
[CP9-12 DATE] NVARCHAR(50),
[TOTAL COMMIMTMENT WEEK COVER] FLOAT,
[strItemNo] NVARCHAR(50),
[strVendor] NVARCHAR(500),
strCompanyNumber NVARCHAR(500),
UDA_ItemGroup NVARCHAR(500),
UDA_CompanyNumber NVARCHAR(500))

	INSERT INTO @Final
	SELECT DT.[ITEM #]
		,ROUND(DT.[OriginalUSAGE], @dblNumberOfdecimal) AS [USAGE]
		,ROUND(DT.[MINIMUM STOCK  WKS], 0) AS [MINIMUM STOCK  WKS]
		,ROUND(DT.[AVAILABLE STOCK], @dblNumberOfdecimal) AS [AVAILABLE STOCK]
		,ROUND(DT.[WK1], @dblNumberOfdecimal) AS [WK1]
		,ROUND(DT.[WK2], @dblNumberOfdecimal) AS [WK2]
		,ROUND(DT.[WK3], @dblNumberOfdecimal) AS [WK3]
		,ROUND(DT.[WK4], @dblNumberOfdecimal) AS [WK4]
		,ROUND(DT.[WK5], @dblNumberOfdecimal) AS [WK5]
		,ROUND(DT.[WK6], @dblNumberOfdecimal) AS [WK6]
		,ROUND(DT.[WK7], @dblNumberOfdecimal) AS [WK7]
		,ROUND(DT.[WK8], @dblNumberOfdecimal) AS [WK8]
		,ROUND(SUM(DT.[WK1] + DT.[WK2] + DT.[WK3] + DT.[WK4] + DT.[WK5] + DT.[WK6] + DT.[WK7] + DT.[WK8]), @dblNumberOfdecimal) AS [TRANSIT STOCK]
		,ROUND(DT.[CP3], @dblNumberOfdecimal) AS [CP3]
		,ROUND(DT.[CP4], @dblNumberOfdecimal) AS [CP4]
		,ROUND(DT.[CP5], @dblNumberOfdecimal) AS [CP5]
		,ROUND(DT.[CP6], @dblNumberOfdecimal) AS [CP6]
		,ROUND(DT.[CP7], @dblNumberOfdecimal) AS [CP7]
		,ROUND(DT.[CP8], @dblNumberOfdecimal) AS [CP8]
		,ROUND(DT.[CP9-12], @dblNumberOfdecimal) AS [CP9-12]
		,ROUND(SUM(DT.[CP3] + DT.[CP4] + DT.[CP5] + DT.[CP6] + DT.[CP7] + DT.[CP8] + DT.[CP9-12]), @dblNumberOfdecimal) AS [UNSHIPPED STOCK]
		,ROUND((DT.[AVAILABLE STOCK] / DT.[USAGE]), 1) AS [AVAILABLE WEEK COVER]
		,ROUND((DT.[WK1] / DT.[USAGE]), 1) AS [WK1 COVER]
		,ROUND((DT.[WK2] / DT.[USAGE]), 1) AS [WK2 COVER]
		,ROUND((DT.[WK3] / DT.[USAGE]), 1) AS [WK3 COVER]
		,ROUND((DT.[WK4] / DT.[USAGE]), 1) AS [WK4 COVER]
		,ROUND((DT.[WK5] / DT.[USAGE]), 1) AS [WK5 COVER]
		,ROUND((DT.[WK6] / DT.[USAGE]), 1) AS [WK6 COVER]
		,ROUND((DT.[WK7] / DT.[USAGE]), 1) AS [WK7 COVER]
		,ROUND((DT.[WK8] / DT.[USAGE]), 1) AS [WK8 COVER]
		,ROUND((DT.[CP3] / DT.[USAGE]), 1) AS [CP3 COVER]
		,ROUND((DT.[CP4] / DT.[USAGE]), 1) AS [CP4 COVER]
		,ROUND((DT.[CP5] / DT.[USAGE]), 1) AS [CP5 COVER]
		,ROUND((DT.[CP6] / DT.[USAGE]), 1) AS [CP6 COVER]
		,ROUND((DT.[CP7] / DT.[USAGE]), 1) AS [CP7 COVER]
		,ROUND((DT.[CP8] / DT.[USAGE]), 1) AS [CP8 COVER]
		,ROUND((DT.[CP9-12] / DT.[USAGE]), 1) AS [CP9-12 COVER]
		,ROUND((SUM((DT.[AVAILABLE STOCK] / DT.[USAGE]) + (DT.[WK1] / DT.[USAGE]) + (DT.[WK2] / DT.[USAGE]) + (DT.[WK3] / DT.[USAGE]) + (DT.[WK4] / DT.[USAGE]) + (DT.[WK5] / DT.[USAGE]) + (DT.[WK6] / DT.[USAGE]) + (DT.[WK7] / DT.[USAGE]) + (DT.[WK8] / DT.[USAGE])) - SUM(@dblAverageWeekTransitPeriod + DT.[MINIMUM STOCK  WKS])), 0) AS [NEXT SHIP IN (WKS)]
		,ROUND(DT.[FULL CONTAINER LOAD], @dblNumberOfdecimal) AS [FULL CONTAINER LOAD]
		,ROUND(DT.[SHIP FREQUENCY], 0) AS [SHIP FREQUENCY]
		,ROUND((DT.[AVAILABLE STOCK] + SUM(DT.[WK1] + DT.[WK2] + DT.[WK3] + DT.[WK4] + DT.[WK5] + DT.[WK6] + DT.[WK7] + DT.[WK8]) + SUM(DT.[CP3] + DT.[CP4] + DT.[CP5] + DT.[CP6] + DT.[CP7] + DT.[CP8] + DT.[CP9-12])), @dblNumberOfdecimal) AS [TOTAL COMMITMENTS]
		,ROUND(SUM((DT.[WK1] / DT.[USAGE]) + (DT.[WK2] / DT.[USAGE]) + (DT.[WK3] / DT.[USAGE]) + (DT.[WK4] / DT.[USAGE]) + (DT.[WK5] / DT.[USAGE]) + (DT.[WK6] / DT.[USAGE]) + (DT.[WK7] / DT.[USAGE]) + (DT.[WK8] / DT.[USAGE])), 1) AS [TRANSIT STOCK WEEK COVER]
		,CONVERT(VARCHAR(5), DT.[WK1 DATE], 101) AS [WK1 DATE]
		,CONVERT(VARCHAR(5), DT.[WK2 DATE], 101) AS [WK2 DATE]
		,CONVERT(VARCHAR(5), DT.[WK3 DATE], 101) AS [WK3 DATE]
		,CONVERT(VARCHAR(5), DT.[WK4 DATE], 101) AS [WK4 DATE]
		,CONVERT(VARCHAR(5), DT.[WK5 DATE], 101) AS [WK5 DATE]
		,CONVERT(VARCHAR(5), DT.[WK6 DATE], 101) AS [WK6 DATE]
		,CONVERT(VARCHAR(5), DT.[WK7 DATE], 101) AS [WK7 DATE]
		,CONVERT(VARCHAR(5), DT.[WK8 DATE], 101) AS [WK8 DATE]
		,CONVERT(VARCHAR(5), DT.[CP3 DATE], 101) AS [CP3 DATE]
		,CONVERT(VARCHAR(5), DT.[CP4 DATE], 101) AS [CP4 DATE]
		,CONVERT(VARCHAR(5), DT.[CP5 DATE], 101) AS [CP5 DATE]
		,CONVERT(VARCHAR(5), DT.[CP6 DATE], 101) AS [CP6 DATE]
		,CONVERT(VARCHAR(5), DT.[CP7 DATE], 101) AS [CP7 DATE]
		,CONVERT(VARCHAR(5), DT.[CP8 DATE], 101) AS [CP8 DATE]
		,CONVERT(VARCHAR(5), DT.[CP9-12 DATE], 101) AS [CP9-12 DATE]
		,ROUND((
				ROUND((DT.[AVAILABLE STOCK] + SUM(DT.[WK1] + DT.[WK2] + DT.[WK3] + DT.[WK4] + DT.[WK5] + DT.[WK6] + DT.[WK7] + DT.[WK8]) + SUM(DT.[CP3] + DT.[CP4] + DT.[CP5] + DT.[CP6] + DT.[CP7] + DT.[CP8] + DT.[CP9-12])), @dblNumberOfdecimal) / CASE 
					WHEN ROUND(DT.[USAGE], @dblNumberOfdecimal) = 0
						THEN 1
					ELSE ROUND(DT.[USAGE], @dblNumberOfdecimal)
					END
				), 1) AS [TOTAL COMMIMTMENT WEEK COVER]
		,'' AS [strItemNo]
		,'' AS [strVendor]
		,'' AS strCompanyNumber
		,'' AS UDA_ItemGroup
		,UDA_CompanyNumber
	FROM (
		SELECT t.[Item #] AS [ITEM #]
			,ROUND(CASE 
					WHEN t.[USAGE] = 0
						THEN 1
					ELSE t.[USAGE]
					END, @dblNumberOfdecimal) AS [USAGE]
			,ROUND(t.[USAGE], @dblNumberOfdecimal) AS [OriginalUSAGE]
			,ROUND(t.[MINIMUM STOCK  WKS], @dblNumberOfdecimal) AS [MINIMUM STOCK  WKS]
			,ROUND(t.[AVAILABLE STOCK], @dblNumberOfdecimal) AS [AVAILABLE STOCK]
			,ISNULL(ROUND(SUM(m.[Week 1]), @dblNumberOfdecimal), 0) AS [WK1]
			,ISNULL(ROUND(SUM(m.[Week 2]), @dblNumberOfdecimal), 0) AS [WK2]
			,ISNULL(ROUND(SUM(m.[Week 3]), @dblNumberOfdecimal), 0) AS [WK3]
			,ISNULL(ROUND(SUM(m.[Week 4]), @dblNumberOfdecimal), 0) AS [WK4]
			,ISNULL(ROUND(SUM(m.[Week 5]), @dblNumberOfdecimal), 0) AS [WK5]
			,ISNULL(ROUND(SUM(m.[Week 6]), @dblNumberOfdecimal), 0) AS [WK6]
			,ISNULL(ROUND(SUM(m.[Week 7]), @dblNumberOfdecimal), 0) AS [WK7]
			,ISNULL(ROUND(SUM(m.[Week 8]), @dblNumberOfdecimal), 0) AS [WK8]
			,ISNULL(ROUND(SUM(m.[MONth 1]), @dblNumberOfdecimal), 0) AS [CP3]
			,ISNULL(ROUND(SUM(m.[MONth 2]), @dblNumberOfdecimal), 0) AS [CP4]
			,ISNULL(ROUND(SUM(m.[MONth 3]), @dblNumberOfdecimal), 0) AS [CP5]
			,ISNULL(ROUND(SUM(m.[MONth 4]), @dblNumberOfdecimal), 0) AS [CP6]
			,ISNULL(ROUND(SUM(m.[MONth 5]), @dblNumberOfdecimal), 0) AS [CP7]
			,ISNULL(ROUND(SUM(m.[MONth 6]), @dblNumberOfdecimal), 0) AS [CP8]
			,ISNULL(ROUND(SUM(m.[MONth 9-12]), @dblNumberOfdecimal), 0) AS [CP9-12]
			,ROUND(t.[Full Container Load], @dblNumberOfdecimal) AS [FULL CONTAINER LOAD]
			,ROUND(t.[SHIP FREQUENCY], @dblNumberOfdecimal) AS [SHIP FREQUENCY]
			,@dtmNewDate AS [WK1 DATE]
			,@dtmSecONdWeekComDate AS [WK2 DATE]
			,@dtmThirdWeekComDate AS [WK3 DATE]
			,@dtmFourthWeekComDate AS [WK4 DATE]
			,@dtmFivthWeekComDate AS [WK5 DATE]
			,@dtmSixthWeekComDate AS [WK6 DATE]
			,@dtmSeventhWeekComDate AS [WK7 DATE]
			,@dtmEightWeekComDate AS [WK8 DATE]
			,@dtmFirstMONthDate AS [CP3 DATE]
			,@dtmSecONdMONthDate AS [CP4 DATE]
			,@dtmThirdMONthDate AS [CP5 DATE]
			,@dtmFourthMONthDate AS [CP6 DATE]
			,@dtmFivthMONthDate AS [CP7 DATE]
			,@dtmSixthMONthDate AS [CP8 DATE]
			,@dtmLAStMONthDate AS [CP9-12 DATE]
			,t.UDA_CompanyNumber
		FROM @tmpDetail t
		LEFT JOIN @MonthandWeek m ON m.MaterialKey = t.MaterialKey
			AND t.UDA_CompanyNumber = m.UDA_CompanyNumber
		GROUP BY t.[Item #]
			,t.[USAGE]
			,t.[AVAILABLE STOCK]
			,t.[MINIMUM STOCK  WKS]
			,t.[Full Container Load]
			,t.[SHIP FREQUENCY]
			,t.UDA_CompanyNumber
		) DT
	GROUP BY DT.[ITEM #]
		,DT.[USAGE]
		,DT.OriginalUSAGE
		,DT.[MINIMUM STOCK  WKS]
		,DT.[AVAILABLE STOCK]
		,DT.[WK1]
		,DT.[WK2]
		,DT.[WK3]
		,DT.[WK4]
		,DT.[WK5]
		,DT.[WK6]
		,DT.[WK7]
		,DT.[WK8]
		,DT.[CP3]
		,DT.[CP4]
		,DT.[CP5]
		,DT.[CP6]
		,DT.[CP7]
		,DT.[CP8]
		,DT.[CP9-12]
		,DT.[FULL CONTAINER LOAD]
		,DT.[SHIP FREQUENCY]
		,DT.[WK1 DATE]
		,DT.[WK2 DATE]
		,DT.[WK3 DATE]
		,DT.[WK4 DATE]
		,DT.[WK5 DATE]
		,DT.[WK6 DATE]
		,DT.[WK7 DATE]
		,DT.[WK8 DATE]
		,DT.[CP3 DATE]
		,DT.[CP4 DATE]
		,DT.[CP5 DATE]
		,DT.[CP6 DATE]
		,DT.[CP7 DATE]
		,DT.[CP8 DATE]
		,DT.[CP9-12 DATE]
		,UDA_CompanyNumber
		
		IF (select Count(*)from @Final WHERE [AVAILABLE STOCK] <> 0 OR [USAGE] <> 0 OR [TRANSIT STOCK] <> 0 OR [UNSHIPPED STOCK] <> 0)<1
		BEGIN
			SELECT 0 AS [AVAILABLE STOCK]
				,0 AS [AVAILABLE WEEK COVER]
				,0 AS [CP3]
				,0 AS [CP3 COVER]
				,0 AS [CP4]
				,0 AS [CP4 COVER]
				,0 AS [CP5]
				,0 AS [CP5 COVER]
				,0 AS [CP6]
				,0 AS [CP6 COVER]
				,0 AS [CP7]
				,0 AS [CP7 COVER]
				,0 AS [CP8]
				,0 AS [CP8 COVER]
				,0 AS [CP9-12]
				,0 AS [CP9-12 COVER]
				,0 AS [FULL CONTAINER LOAD]
				,0 AS [MINIMUM STOCK  WKS]
				,0 AS [NEXT SHIP IN (WKS)]
				,0 AS [SHIP FREQUENCY]
				,0 AS [TOTAL COMMIMTMENT WEEK COVER]
				,0 AS [TOTAL COMMITMENTS]
				,0 AS [TRANSIT STOCK]
				,0 AS [TRANSIT STOCK WEEK COVER]
				,0 AS [UNSHIPPED STOCK]
				,0 AS [USAGE]
				,0 AS [WK1]
				,0 AS [WK1 COVER]
				,0 AS [WK2]
				,0 AS [WK2 COVER]
				,0 AS [WK3]
				,0 AS [WK3 COVER]
				,0 AS [WK4]
				,0 AS [WK4 COVER]
				,0 AS [WK5]
				,0 AS [WK5 COVER]
				,0 AS [WK6]
				,0 AS [WK6 COVER]
				,0 AS [WK7]
				,0 AS [WK7 COVER]
				,0 AS [WK8]
				,0 AS [WK8 COVER]
				,'No data found' AS [ITEM #]
				,'' AS [CP3 DATE]
				,'' AS [CP4 DATE]
				,'' AS [CP5 DATE]
				,'' AS [CP6 DATE]
				,'' AS [CP7 DATE]
				,'' AS [CP8 DATE]
				,'' AS [CP9-12 DATE]
				,'' AS [strCompanyNumber]
				,'' AS [strItemNo]
				,'' AS [strVendor]
				,'' AS [UDA_ItemGroup]
				,'' AS [WK1 DATE]
				,'' AS [WK2 DATE]
				,'' AS [WK3 DATE]
				,'' AS [WK4 DATE]
				,'' AS [WK5 DATE]
				,'' AS [WK6 DATE]
				,'' AS [WK7 DATE]
				,'' AS [WK8 DATE]
				,'' AS [CompanyNumber]

				RAISERROR (
				'No data found'
				,16
				,1
				,'WITH NOWAIT'
				)
		END

	SELECT ISNULL([AVAILABLE STOCK], 0) AS [AVAILABLE STOCK]
		,ISNULL([AVAILABLE WEEK COVER], 0) AS [AVAILABLE WEEK COVER]
		,ISNULL([CP3], 0) AS [CP3]
		,ISNULL([CP3 COVER], 0) AS [CP3 COVER]
		,ISNULL([CP4], 0) AS [CP4]
		,ISNULL([CP4 COVER], 0) AS [CP4 COVER]
		,ISNULL([CP5], 0) AS [CP5]
		,ISNULL([CP5 COVER], 0) AS [CP5 COVER]
		,ISNULL([CP6], 0) AS [CP6]
		,ISNULL([CP6 COVER], 0) AS [CP6 COVER]
		,ISNULL([CP7], 0) AS [CP7]
		,ISNULL([CP7 COVER], 0) AS [CP7 COVER]
		,ISNULL([CP8], 0) AS [CP8]
		,ISNULL([CP8 COVER], 0) AS [CP8 COVER]
		,ISNULL([CP9-12], 0) AS [CP9-12]
		,ISNULL([CP9-12 COVER], 0) AS [CP9-12 COVER]
		,ISNULL([FULL CONTAINER LOAD], 0) AS [FULL CONTAINER LOAD]
		,ISNULL([MINIMUM STOCK  WKS], 0) AS [MINIMUM STOCK  WKS]
		,ISNULL([NEXT SHIP IN (WKS)], 0) AS [NEXT SHIP IN (WKS)]
		,ISNULL([SHIP FREQUENCY], 0) AS [SHIP FREQUENCY]
		,ISNULL([TOTAL COMMIMTMENT WEEK COVER], 0) AS [TOTAL COMMIMTMENT WEEK COVER]
		,ISNULL([TOTAL COMMITMENTS], 0) AS [TOTAL COMMITMENTS]
		,ISNULL([TRANSIT STOCK], 0) AS [TRANSIT STOCK]
		,ISNULL([TRANSIT STOCK WEEK COVER], 0) AS [TRANSIT STOCK WEEK COVER]
		,ISNULL([UNSHIPPED STOCK], 0) AS [UNSHIPPED STOCK]
		,ISNULL([USAGE], 0) AS [USAGE]
		,ISNULL([WK1], 0) AS [WK1]
		,ISNULL([WK1 COVER], 0) AS [WK1 COVER]
		,ISNULL([WK2], 0) AS [WK2]
		,ISNULL([WK2 COVER], 0) AS [WK2 COVER]
		,ISNULL([WK3], 0) AS [WK3]
		,ISNULL([WK3 COVER], 0) AS [WK3 COVER]
		,ISNULL([WK4], 0) AS [WK4]
		,ISNULL([WK4 COVER], 0) AS [WK4 COVER]
		,ISNULL([WK5], 0) AS [WK5]
		,ISNULL([WK5 COVER], 0) AS [WK5 COVER]
		,ISNULL([WK6], 0) AS [WK6]
		,ISNULL([WK6 COVER], 0) AS [WK6 COVER]
		,ISNULL([WK7], 0) AS [WK7]
		,ISNULL([WK7 COVER], 0) AS [WK7 COVER]
		,ISNULL([WK8], 0) AS [WK8]
		,ISNULL([WK8 COVER], 0) AS [WK8 COVER]
		,[ITEM #] AS [ITEM #]
		,[CP3 DATE] AS [CP3 DATE]
		,[CP4 DATE] AS [CP4 DATE]
		,[CP5 DATE] AS [CP5 DATE]
		,[CP6 DATE] AS [CP6 DATE]
		,[CP7 DATE] AS [CP7 DATE]
		,[CP8 DATE] AS [CP8 DATE]
		,[CP9-12 DATE] AS [CP9-12 DATE]
		,[strCompanyNumber] AS [strCompanyNumber]
		,[strItemNo] AS [strItemNo]
		,[strVendor] AS [strVendor]
		,[UDA_ItemGroup] AS [UDA_ItemGroup]
		,[WK1 DATE] AS [WK1 DATE]
		,[WK2 DATE] AS [WK2 DATE]
		,[WK3 DATE] AS [WK3 DATE]
		,[WK4 DATE] AS [WK4 DATE]
		,[WK5 DATE] AS [WK5 DATE]
		,[WK6 DATE] AS [WK6 DATE]
		,[WK7 DATE] AS [WK7 DATE]
		,[WK8 DATE] AS [WK8 DATE]
		,UDA_CompanyNumber AS [CompanyNumber]
	FROM @Final
	WHERE [AVAILABLE STOCK] <> 0
		OR [USAGE] <> 0
		OR [TRANSIT STOCK] <> 0
		OR [UNSHIPPED STOCK] <> 0
	ORDER BY [ITEM #]
		,UDA_CompanyNumber
		
END TRY

BEGIN CATCH
	SET @strErrMsg = ERROR_MESSAGE()

	IF @strErrMsg != ''
	BEGIN
		RAISERROR (
				@strErrMsg
				,16
				,1
				,'WITH NOWAIT'
				)
	END
END CATCH

