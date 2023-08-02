CREATE PROCEDURE [dbo].[uspGRDailyPositionRecordByRangeFirstPage]
				 	
	-- Add the parameters for the stored procedure here
		@xmlParam NVARCHAR(MAX)
AS
BEGIN
IF LTRIM(RTRIM(@xmlParam)) = ''
	SET @xmlParam = NULL
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	declare @intMonth	int = 0
	,@dtmMonthYear		datetime = '01/01/1900'
	,@dtmLastDayMonthYear		datetime 
	,@intDay			int
	,@intLocationId		int = 0
	,@intCommodityId	int = 1
	,@intCommodityUnitMeasureId	int
	,@strLocation		nvarchar(500) = 'All Location'
	,@strCommodity		nvarchar(150)
	,@strLicensed		nvarchar(30) = 'ALL'
	,@Locations			AS Id
	,@dblPMUnload			decimal(18,6)			=0
	,@dblPMLoadout			decimal(18,6) 			=0
	,@dblAdjustment			decimal(18,6) 			=0
	,@dblTotalStock			decimal(18,6) 			=0
	,@dblWHRIssued			DECIMAL(18,6)			=0
	,@dblWHRCancelled		DECIMAL(18,6)			=0
	,@dblWHROutstanding		DECIMAL(18,6)			=0
	,@dblTOSIn				DECIMAL(18,6)			=0
	,@dblTOSOut				DECIMAL(18,6)			=0
	,@dblTOSTotal			DECIMAL(18,6)			=0
	,@dblCSIn				DECIMAL(18,6)			=0
	,@dblCSOut				DECIMAL(18,6)			=0
	,@dblCSTotal			DECIMAL(18,6)			=0
	
	
	DECLARE @temp_xml_table TABLE 
	(
		[fieldname] NVARCHAR(50)
		,[condition] NVARCHAR(20)
		,[from] NVARCHAR(MAX)
		,[to] NVARCHAR(MAX)
		,[join] NVARCHAR(10)
		,[begingroup] NVARCHAR(50)
		,[endgroup] NVARCHAR(50)
		,[datatype] NVARCHAR(50)
	)
	DECLARE @xmlDocumentId AS INT

	EXEC sp_xml_preparedocument @xmlDocumentId OUTPUT,@xmlParam

	INSERT INTO @temp_xml_table
	SELECT *
	FROM OPENXML(@xmlDocumentId, 'xmlparam/filters/filter', 2) WITH 
	(
		[fieldname] NVARCHAR(50)
		,[condition] NVARCHAR(20)
		,[from] NVARCHAR(50)
		,[to] NVARCHAR(50)
		,[join] NVARCHAR(10)
		,[begingroup] NVARCHAR(50)
		,[endgroup] NVARCHAR(50)
		,[datatype] NVARCHAR(50)
	)	

	CREATE TABLE #Locations
	(
		intCompanyLocationId INT,
		strLocationName VARCHAR(MAX) COLLATE Latin1_General_CI_AS
	)


	DECLARE @ReportData TABLE
	(
		id [INT]				IDENTITY(1,1) NOT NULL
		,intDay					int
		,dblPMUnload			decimal(18,6) 
		,dblPMLoadout			decimal(18,6) 
		,dblAdjustment			decimal(18,6) 
		,dblTotalStock			decimal(18,6) 
		,dblWHRIssued			DECIMAL(18,6)
		,dblWHRCancelled		DECIMAL(18,6)
		,dblWHROutstanding		DECIMAL(18,6)
		,dblTOSIn				DECIMAL(18,6)
		,dblTOSOut				DECIMAL(18,6)
		,dblTOSTotal			DECIMAL(18,6)
		,dblCSIn				DECIMAL(18,6)
		,dblCSOut				DECIMAL(18,6)
		,dblCSTotal				DECIMAL(18,6)		
		,dtmMonthYear			datetime
		,strCommodity			nvarchar(150) COLLATE Latin1_General_CI_AS
		,strLocation			nvarchar(500) COLLATE Latin1_General_CI_AS
	)	
	
	select @dtmMonthYear = [from] from @temp_xml_table where fieldname =  'dtmMonthYear'
	select @intLocationId = [from] from @temp_xml_table where fieldname =  'intLocationId'
	select @intCommodityId = [from] from @temp_xml_table where fieldname =  'intCommodityId'
	select @strLicensed = [from]  from @temp_xml_table where fieldname =  'strLicensed'
	select @strCommodity = strDescription from tblICCommodity where intCommodityId = @intCommodityId
	select @strLocation = strLocationName from tblSMCompanyLocation where intCompanyLocationId = @intLocationId
	set @dtmLastDayMonthYear =  dateadd(D,-1,dateadd(M,1,@dtmMonthYear))
    -- Insert statements for procedure here
	INSERT INTO @Locations
	SELECT intCompanyLocationId
	FROM tblSMCompanyLocation
	WHERE (ysnLicensed = case when @strLicensed = 'Licensed' then 1 else 0 end) or @strLicensed = 'ALL'
	
	set @intMonth = MONTH(@dtmMonthYear)

	select top 1 @intCommodityUnitMeasureId= intCommodityUnitMeasureId from  tblICCommodityUnitMeasure where intCommodityId = @intCommodityId
	
	SELECT *
		INTO #OwnershipALL -- fnRKGetBucketCompanyOwned
		FROM (
			SELECT
				dtmDate = CONVERT(VARCHAR(10),dtmTransactionDate,110)
				,strDistributionType
				,strTransactionNumber
				,dblIn = CASE WHEN dblTotal > 0 THEN dbo.fnCTConvertQuantityToTargetCommodityUOM(intOrigUOMId,@intCommodityUnitMeasureId,dblTotal) ELSE 0 END
				,dblOut = CASE WHEN dblTotal < 0 THEN ABS(dbo.fnCTConvertQuantityToTargetCommodityUOM(intOrigUOMId,@intCommodityUnitMeasureId,dblTotal)) ELSE 0 END
				,ST.intStorageScheduleTypeId
				,CusOwn.strStorageTypeCode
				,CusOwn.intLocationId
				,CusOwn.strLocationName
				,CusOwn.strCommodityCode
				,CusOwn.strTransactionType
				,ST.ysnReceiptedStorage
				,strOwnedPhysicalStock = 'Customer'
			FROM dbo.fnRKGetBucketCustomerOwned(@dtmLastDayMonthYear,@intCommodityId,NULL) CusOwn
			LEFT JOIN tblGRStorageType ST 
				ON ST.strStorageTypeDescription = CusOwn.strDistributionType
			WHERE CusOwn.intCommodityId = @intCommodityId and (CusOwn.intLocationId = @intLocationId or @intLocationId = 0)
			UNION ALL
			SELECT
				dtmDate = CONVERT(VARCHAR(10),dtmTransactionDate,110)
				,strDistributionType
				,strTransactionNumber
				,dblIn = CASE WHEN dblTotal > 0 THEN dbo.fnCTConvertQuantityToTargetCommodityUOM(intOrigUOMId,@intCommodityUnitMeasureId,dblTotal) ELSE 0 END
				,dblOut = CASE WHEN dblTotal < 0 THEN ABS(dbo.fnCTConvertQuantityToTargetCommodityUOM(intOrigUOMId,@intCommodityUnitMeasureId,dblTotal)) ELSE 0 END
				,ST.intStorageScheduleTypeId
				,ST.strStorageTypeCode
				,CusOwn.intLocationId
				,CusOwn.strLocationName
				,CusOwn.strCommodityCode
				,CusOwn.strTransactionType
				,ST.ysnReceiptedStorage
				,strOwnedPhysicalStock = 'Company'
			FROM dbo.fnRKGetBucketCompanyOwned(@dtmLastDayMonthYear,@intCommodityId,NULL) CusOwn
			LEFT JOIN tblGRStorageType ST 
				ON ST.strStorageTypeDescription = CusOwn.strDistributionType
			WHERE CusOwn.intCommodityId = @intCommodityId and (CusOwn.intLocationId = @intLocationId or @intLocationId = 0)		
		) t		
	

	/*OffsiteStorage/Terminal*/
	SELECT
		dtmDate = CONVERT(VARCHAR(10),dtmTransactionDate,110)
		,strTransactionNumber
		,strDistributionType
		,dblIn = CASE WHEN dblOrigQty > 0 THEN dbo.fnCTConvertQuantityToTargetCommodityUOM(intOrigUOMId,@intCommodityUnitMeasureId,dblOrigQty) ELSE 0 END
		,dblOut = CASE WHEN dblOrigQty < 0 THEN ABS(dbo.fnCTConvertQuantityToTargetCommodityUOM(intOrigUOMId,@intCommodityUnitMeasureId,dblOrigQty)) ELSE 0 END
		,ST.intStorageScheduleTypeId
		,offsite.strStorageTypeCode
		,offsite.strCommodityCode
		,offsite.strTransactionType
	INTO #OffsiteStorage
	FROM vyuRKGetSummaryLog offsite
	INNER JOIN tblSMCompanyLocation CL
		ON CL.intCompanyLocationId = offsite.intLocationId
			AND ((CL.ysnLicensed = case when @strLicensed = 'Licensed' then 1 else 0 end) or @strLicensed = 'All')
	JOIN tblGRStorageType ST 
		ON ST.strStorageTypeDescription = offsite.strDistributionType 			
			AND ysnCustomerStorage = 1			
	WHERE offsite.intCommodityId = @intCommodityId	 and (offsite.intLocationId = @intLocationId or @intLocationId = 0)
	and intTicketId is not null
	
	
	while (@intMonth = MONTH(@dtmMonthYear))
	begin 		
				
		SELECT
			@dblPMUnload = SUM(ISNULL(dblIn,0))		
		FROM #OwnershipALL
		WHERE strTransactionType <> 'Inventory Adjustment'
			and dtmDate = @dtmMonthYear

		SELECT
			@dblPMLoadout = SUM(ISNULL(dblOut,0))			
		FROM #OwnershipALL
		WHERE  strTransactionType not in ('Inventory Adjustment')
			and dtmDate = @dtmMonthYear

		
		SELECT @dblAdjustment = SUM(ISNULL(dblIn,0) - ISNULL(dblOut,0))
		FROM #OwnershipALL
		WHERE strTransactionType IN ('Inventory Adjustment')
			 and dtmDate  = @dtmMonthYear

		
	
		SELECT 			
			@dblWHRIssued = SUM(dblIn)
			,@dblWHRCancelled = SUM(dblOut)
		FROM #OwnershipALL C
		WHERE CONVERT(DATETIME, CONVERT(VARCHAR(10), dtmDate, 110), 110) = CONVERT(DATETIME, @dtmMonthYear)
		 and   strStorageTypeCode = 'WH' and ysnReceiptedStorage = 1
		 and strOwnedPhysicalStock = 'Customer'
		and strTransactionType <> 'Inventory Adjustment'

		SELECT 
			@dblCSIn = SUM(dblIn)
			,@dblCSOut = SUM(dblOut)
		FROM #OwnershipALL C
		WHERE CONVERT(DATETIME, CONVERT(VARCHAR(10), dtmDate, 110), 110) = CONVERT(DATETIME, @dtmMonthYear)
		 and  not (strStorageTypeCode = 'WH' and ysnReceiptedStorage = 1)
		 and strOwnedPhysicalStock = 'Customer'
		and strTransactionType <> 'Inventory Adjustment'
		SELECT 			
			@dblTOSIn = SUM(dblIn)
			,@dblTOSOut = SUM(dblOut)
		FROM #OffsiteStorage C
		WHERE CONVERT(DATETIME, CONVERT(VARCHAR(10), dtmDate, 110), 110) = CONVERT(DATETIME, @dtmMonthYear)
		
		
		
		set @intDay = day(@dtmMonthYear)		
		/*previous balance*/
		if(@intDay = 1 )
		begin
			SELECT
			@dblTotalStock =  SUM(ISNULL(dblIn,0) -ISNULL(dblOut,0)	)	
			FROM #OwnershipALL
			WHERE strTransactionType <> 'Inventory Adjustment' and
				 dtmDate < @dtmMonthYear
			
			SELECT 			
			@dblTOSTotal = SUM(dblIn) - SUM(dblOut)
			FROM #OffsiteStorage C
			WHERE CONVERT(DATETIME, CONVERT(VARCHAR(10), dtmDate, 110), 110) < CONVERT(DATETIME, @dtmMonthYear)

			SELECT 			
			@dblWHROutstanding = SUM(dblIn) - SUM(dblOut)
			FROM #OwnershipALL C
			WHERE CONVERT(DATETIME, CONVERT(VARCHAR(10), dtmDate, 110), 110) < CONVERT(DATETIME, @dtmMonthYear) 
			and  	strStorageTypeCode = 'WH' and ysnReceiptedStorage = 1
			and strOwnedPhysicalStock = 'Customer'
			and strTransactionType <> 'Inventory Adjustment'

			SELECT 
			@dblCSTotal = SUM(dblIn) - SUM(dblOut)		
			FROM #OwnershipALL C
			WHERE CONVERT(DATETIME, CONVERT(VARCHAR(10), dtmDate, 110), 110) < CONVERT(DATETIME, @dtmMonthYear) 
			and  	strStorageTypeCode <> 'WH' and ysnReceiptedStorage <> 1
			and strOwnedPhysicalStock = 'Customer'
			and strTransactionType <> 'Inventory Adjustment'
			insert into @ReportData  (
			intDay			
			,dblPMUnload		
			,dblPMLoadout		
			,dblAdjustment		
			,dblTotalStock		
			,dblWHRIssued		
			,dblWHRCancelled	
			,dblWHROutstanding	
			,dblTOSIn			
			,dblTOSOut			
			,dblTOSTotal		
			,dblCSIn			
			,dblCSOut			
			,dblCSTotal			
			,dtmMonthYear		
			,strCommodity
			,strLocation
		
			)  values (
			0
			,null						--dblPMUnload		
			,null						--dblPMLoadout		
			,null						--dblAdjustment		
			,isnull(@dblTotalStock,0)	--dblTotalStock		
			,null						--dblWHRIssued		
			,null						--dblWHRCancelled	
			,isnull(@dblWHROutstanding,0)		--dblWHROutstanding	
			,null								--dblTOSIn			
			,null						--dblTOSOut			
			,isnull(@dblTOSTotal,0)				--dblTOSTotal		
			,null				--dblCSIn			
			,null				--dblCSOut			
			,isnull(@dblCSTotal,0)			--dblCSTotal	
			,@dtmMonthYear
			,isnull(@strCommodity,'ALL')
			,isnull(@strLocation,'ALL'))			
		end

		
		insert into @ReportData  (
		intDay			
		,dblPMUnload		
		,dblPMLoadout		
		,dblAdjustment		
		,dblTotalStock		
		,dblWHRIssued		
		,dblWHRCancelled	
		,dblWHROutstanding	
		,dblTOSIn			
		,dblTOSOut			
		,dblTOSTotal		
		,dblCSIn			
		,dblCSOut			
		,dblCSTotal			
		,dtmMonthYear		
		,strCommodity
		,strLocation
		
		)  values (
		@intDay
		,isnull(@dblPMUnload,0)			--dblPMUnload		
		,isnull(@dblPMLoadout,0)		--dblPMLoadout		
		,isnull(@dblAdjustment,0)		--dblAdjustment		
		,isnull(@dblPMUnload,0)- 	isnull(@dblPMLoadout,0)		--dblTotalStock		
		,isnull(@dblWHRIssued,0)			--dblWHRIssued		
		,isnull(@dblWHRCancelled,0)			--dblWHRCancelled	
		,isnull(@dblWHRIssued,0) - isnull(@dblWHRCancelled,0)			--dblWHROutstanding	
		,isnull(@dblTOSIn,0)			--dblTOSIn			
		,isnull(@dblTOSOut,0)			--dblTOSOut			
		,isnull(@dblTOSIn,0) - isnull(@dblTOSOut,0)				--dblTOSTotal		
		,isnull(@dblCSIn,0)			--dblCSIn			
		,isnull(@dblCSOut,0)				--dblCSOut			
		,isnull(@dblCSIn,0) - isnull(@dblCSOut,0)				--dblCSTotal	
		,@dtmMonthYear
		,isnull(@strCommodity,'ALL')
		,isnull(@strLocation,'ALL'))			
		
		set @dtmMonthYear = dateadd(DAY,1 ,@dtmMonthYear)
	end
	DROP TABLE #OwnershipALL
	DROP TABLE #OffsiteStorage
	SELECT * from @ReportData
END
GO