CREATE PROCEDURE [dbo].[uspGRDailyPositionRecordByRangeSecondPage]
	-- Add the parameters for the stored procedure here
		@xmlParam NVARCHAR(MAX)
AS
BEGIN
IF LTRIM(RTRIM(@xmlParam)) = ''
	SET @xmlParam = NULL
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	declare @intMonth			int = 0
	declare @intDay				int = 0
	,@Locations					AS Id
	,@dtmMonthYear				datetime = '01/01/1900'
	,@dtmLastDayMonthYear	    datetime
	,@intLocationId				int = 0
	,@intCommodityId			int = 1
	,@strLocation				nvarchar(500) = 'All Location'
	,@strCommodity				nvarchar(150)
	,@strLicensed				nvarchar(20)
	,@intCommodityUnitMeasureId	int
	,@dblTotalCustomerOwnership		decimal(18,6)
	,@dblTotalTerminalStorage		decimal(18,6)
	,@dblUnsettledBalance		decimal(18,6)
	,@dblUnsettledIncrease		decimal(18,6)
	,@dblUnsettledDecrease		decimal(18,6)
	,@dblSettledBalance			decimal(18,6)
	,@dblSettledIncrease		decimal(18,6)
	,@dblSettledDecrease		decimal(18,6)
	,@dblCOBalance				decimal(18,6)
	,@dblTotalWHROwned			DECIMAL(18,6)
	,@dblWHRIssued				DECIMAL(18,6)
	,@dblWHRCancelled			DECIMAL(18,6)
	,@dblWHROutstanding			DECIMAL(18,6)
	,@dblPLCIn					DECIMAL(18,6)
	,@dblPLCOut					DECIMAL(18,6)
	,@dblPLCBalance				DECIMAL(18,6)
	,@dblIOutboundBalance		DECIMAL(18,6)
	,@dblIInboundBalance			DECIMAL(18,6)

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
		DECLARE @CompanyOwnedData AS TABLE (
		id int,
		dtmDate DATETIME
		,dblIncrease DECIMAL(18,6) DEFAULT 0
		,dblDecrease DECIMAL(18,6) DEFAULT 0
		,strType NVARCHAR(40) COLLATE Latin1_General_CI_AS
	)
	DECLARE @ReportData TABLE
	(
		id [INT]					IDENTITY(1,1) NOT NULL
		,intDay						int
		,dblUnsettledBalance		decimal(18,6) 
		,dblUnsettledIncrease		decimal(18,6) 
		,dblUnsettledDecrease		decimal(18,6)
		,dblSettledBalance			decimal(18,6) 
		,dblSettledIncrease			decimal(18,6) 
		,dblSettledDecrease			decimal(18,6) 
		,dblCOBalance				decimal(18,6) 
		,dblTotalWHROwned			DECIMAL(18,6)
		,dblWHRIssued				DECIMAL(18,6)
		,dblWHRCancelled			DECIMAL(18,6)
		,dblWHROutstanding			DECIMAL(18,6)
		,dblPLCIn					DECIMAL(18,6)
		,dblPLCOut					DECIMAL(18,6)
		,dblPLCBalance				DECIMAL(18,6)
		,dblIOutboundBalance		DECIMAL(18,6)
		,dblIInboundBalance			DECIMAL(18,6)
		,dtmMonthYear				datetime
		,strCommodity				nvarchar(150)
		,strLocation				nvarchar(500)
	)
	
	select @dtmMonthYear = [from] from @temp_xml_table where fieldname =  'dtmMonthYear'
	select @intLocationId = [from] from @temp_xml_table where fieldname =  'intLocationId'
	select @intCommodityId = [from] from @temp_xml_table where fieldname =  'intCommodityId'	
	select @strLicensed = [from]  from @temp_xml_table where fieldname =  'strLicensed'
	select @strCommodity = strDescription from tblICCommodity where intCommodityId = @intCommodityId
	select @strLocation = strLocationName from tblSMCompanyLocation where intCompanyLocationId = @intLocationId

	set @dtmLastDayMonthYear =  dateadd(D,-1,dateadd(M,1,@dtmMonthYear))
    -- Insert statements for procedure here
	set @intMonth = MONTH(@dtmMonthYear)
	select top 1 @intCommodityUnitMeasureId= intCommodityUnitMeasureId from  tblICCommodityUnitMeasure where intCommodityId = @intCommodityId

	INSERT INTO @Locations
	SELECT intCompanyLocationId
	FROM tblSMCompanyLocation


	/*Delayed Pricing*/
	SELECT
		dtmDate = CONVERT(VARCHAR(10),dtmTransactionDate,110)
		,strTransactionNumber
		,strDistributionType
		,dblIn = CASE WHEN dblTotal > 0 THEN dbo.fnCTConvertQuantityToTargetCommodityUOM(intOrigUOMId,@intCommodityUnitMeasureId,dblTotal) ELSE 0 END
		,dblOut = CASE WHEN dblTotal < 0 THEN ABS(dbo.fnCTConvertQuantityToTargetCommodityUOM(intOrigUOMId,@intCommodityUnitMeasureId,dblTotal)) ELSE 0 END
		,ST.intStorageScheduleTypeId
		,DP.strStorageTypeCode
		,DP.strCommodityCode
		,DP.strTransactionType
	INTO #DelayedPricingALL
	FROM dbo.fnRKGetBucketDelayedPricing(dateadd(D,-1,dateadd(M,1,@dtmMonthYear)),@intCommodityId,NULL) DP
	left JOIN tblSMCompanyLocation CL
		ON CL.intCompanyLocationId = DP.intLocationId
			AND ((CL.ysnLicensed = case when @strLicensed = 'Licensed' then 1 else 0 end) or @strLicensed = 'All')
	JOIN tblGRStorageType ST 
		ON ST.strStorageTypeDescription = DP.strDistributionType 
			--AND ysnDPOwnedType = 1
			--AND ysnCustomerStorage = 0
			--AND strOwnedPhysicalStock = 'Company'
	WHERE DP.intCommodityId = @intCommodityId	and (intLocationId = @intLocationId or @intLocationId = 0)
	

	/*Ownder*/
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
				,ysnSettled = 0
			FROM dbo.fnRKGetBucketCustomerOwned(@dtmLastDayMonthYear,@intCommodityId,NULL) CusOwn
			inner JOIN tblGRStorageType ST 
				ON ST.strStorageTypeCode = CusOwn.strStorageTypeCode
				left JOIN tblSMCompanyLocation CL
				ON CL.intCompanyLocationId = CusOwn.intLocationId
				AND ((CL.ysnLicensed = case when @strLicensed = 'Licensed' then 1 else 0 end) or @strLicensed = 'All')
			WHERE CusOwn.intCommodityId = @intCommodityId and (CusOwn.intLocationId = @intLocationId or @intLocationId = 0)
				and intTicketId is not null
			UNION All
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
				,ysnSettled =  isnull ((select top 1 i.ysnPaid from tblARInvoiceDetail d
								left join tblARInvoice  i on d.intInvoiceId = i .intInvoiceId
								where  CusOwn.intTicketId = d.intTicketId and isnull(i.ysnCancelled, 0) = 0 and isnull(i.ysnPaid, 0) = 1), 0)
			FROM dbo.fnRKGetBucketCompanyOwned(@dtmLastDayMonthYear,@intCommodityId,NULL) CusOwn
			inner JOIN tblGRStorageType ST 
				ON ST.strStorageTypeDescription = CusOwn.strDistributionType
				left JOIN tblSMCompanyLocation CL
				ON CL.intCompanyLocationId = CusOwn.intLocationId
				AND ((CL.ysnLicensed = case when @strLicensed = 'Licensed' then 1 else 0 end) or @strLicensed = 'All')
			WHERE CusOwn.intCommodityId = @intCommodityId and (CusOwn.intLocationId = @intLocationId or @intLocationId = 0)--and strTransactionType in ('Inventory Adjustment' ,'Invoice')
				and intTicketId is not null
			UNION All
			SELECT
				dtmDate = CONVERT(VARCHAR(10),dtmTransactionDate,110)
				,strDistributionType = strBucketType
				,strTransactionNumber
				,dblIn = CASE WHEN strBucketType = 'Purchase In-Transit' THEN dbo.fnCTConvertQuantityToTargetCommodityUOM(intOrigUOMId,@intCommodityUnitMeasureId,dblOrigQty) ELSE 0 END
				,dblOut = CASE WHEN strBucketType = 'Sales In-Transit' THEN (dbo.fnCTConvertQuantityToTargetCommodityUOM(intOrigUOMId,@intCommodityUnitMeasureId,dblOrigQty)) ELSE 0 END
				,ST.intStorageScheduleTypeId
				,ST.strStorageTypeCode
				,transit.intLocationId
				,transit.strLocationName
				,transit.strCommodityCode
				,transit.strTransactionType
				,ST.ysnReceiptedStorage
				,strOwnedPhysicalStock = 'Intransit'
				,ysnSettled = isnull ((select top 1 i.ysnPaid from tblARInvoiceDetail d
								left join tblARInvoice  i on d.intInvoiceId = i .intInvoiceId
								where  transit.intTicketId = d.intTicketId and isnull(i.ysnCancelled, 0) = 0 and isnull(i.ysnPaid, 0) = 1), 0)
			FROM vyuRKGetSummaryLog transit
			LEFT JOIN tblGRStorageType ST 
				ON ST.strStorageTypeDescription = transit.strDistributionType  AND CONVERT(DATETIME, CONVERT(VARCHAR(10), dtmTransactionDate, 110), 110) <= CONVERT(DATETIME, @dtmLastDayMonthYear)
				left JOIN tblSMCompanyLocation CL
				ON CL.intCompanyLocationId = transit.intLocationId
				AND ((CL.ysnLicensed = case when @strLicensed = 'Licensed' then 1 else 0 end) or @strLicensed = 'All')
			WHERE transit.intCommodityId = @intCommodityId and (transit.intLocationId = @intLocationId or @intLocationId = 0) and strBucketType IN ('Sales In-Transit', 'Purchase In-Transit') 	
			and intTicketId is not null
			--AND transit.strTransactionType IN('Inventory Shipment','Outbound Shipment')
		) t
			
	/**/
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
	WHERE offsite.intCommodityId = @intCommodityId	 and (offsite.intLocationId = @intLocationId or @intLocationId = 0) and dtmTransactionDate <=@dtmLastDayMonthYear
	and intTicketId is not null

	/*Settled and Unsettled Company Owned*/
	insert into @CompanyOwnedData	
	EXEC dbo.uspGRDPRSettledAndUnsettledCommodity  @intCommodityId, @intLocationId, @dtmLastDayMonthYear
	



	while (@intMonth = MONTH(@dtmMonthYear))
	begin 		

		SELECT 			
			@dblPLCIn = SUM(dblIn)
			,@dblPLCOut = SUM(dblOut)
		FROM #DelayedPricingALL C
		WHERE CONVERT(DATETIME, CONVERT(VARCHAR(10), dtmDate, 110), 110) = CONVERT(DATETIME, @dtmMonthYear)
		 
		


		/*Customer Owner Totals*/
		

		/*Unsettled Company owned*/
		SELECT 			
			@dblUnsettledIncrease = SUM(dblIncrease) ,
			@dblUnsettledDecrease = SUM(dblDecrease)
		FROM @CompanyOwnedData C
		WHERE CONVERT(DATETIME, CONVERT(VARCHAR(10), dtmDate, 110), 110) = CONVERT(DATETIME, @dtmMonthYear)
		and strType = 'Unpaid' 
		 

		/*Settled Company owned*/
		SELECT 			
			@dblSettledIncrease = SUM(dblIncrease) ,
			@dblSettledDecrease = SUM(dblDecrease)
		FROM @CompanyOwnedData C
		WHERE CONVERT(DATETIME, CONVERT(VARCHAR(10), dtmDate, 110), 110) = CONVERT(DATETIME, @dtmMonthYear)
		and strType = 'Paid' 

		SELECT 			
			@dblWHRIssued = SUM(dblIn) ,
			@dblWHRCancelled = SUM(dblOut)
		FROM #OwnershipALL C
		WHERE CONVERT(DATETIME, CONVERT(VARCHAR(10), dtmDate, 110), 110) = CONVERT(DATETIME, @dtmMonthYear)
		and strTransactionType <> 'Inventory Adjustment' and  (strStorageTypeCode = 'WH' and ysnReceiptedStorage = 1)
		and strOwnedPhysicalStock = 'Company'
		 and  isnull(ysnSettled,0) = 1

		--GROUP BY strDistribution,intLocationId,strLocationName,strCommodityCode
		set @dblCOBalance = isnull(@dblUnsettledIncrease,0) - isnull(@dblSettledIncrease,0) + isnull(@dblSettledIncrease,0) - isnull(@dblSettledDecrease,0)
		--set @dblTotalWHROwned = 
		set @intDay = day(@dtmMonthYear)	
		
		/*previous balance*/
		if @intDay = 1
		begin 
			SELECT 
			
			@dblTotalCustomerOwnership = SUM(dblIn) -  SUM(dblOut)
			FROM #OwnershipALL C
			WHERE CONVERT(DATETIME, CONVERT(VARCHAR(10), dtmDate, 110), 110) < CONVERT(DATETIME, @dtmMonthYear)
			and strTransactionType <> 'Inventory Adjustment' --and strStorageTypeCode = 'WH' and ysnReceiptedStorage = 1
			and strOwnedPhysicalStock = 'Customer'			   

			SELECT 			
			@dblTotalTerminalStorage = SUM(dblIn) - SUM(dblOut)
			FROM #OffsiteStorage C
			WHERE CONVERT(DATETIME, CONVERT(VARCHAR(10), dtmDate, 110), 110) < CONVERT(DATETIME, @dtmMonthYear)

			SELECT 			
			@dblPLCBalance = SUM(dblIn) - SUM(dblOut)
			FROM #DelayedPricingALL C
			WHERE CONVERT(DATETIME, CONVERT(VARCHAR(10), dtmDate, 110), 110) < CONVERT(DATETIME, @dtmMonthYear)

			/*Unsettled Company owned*/
			SELECT 			
				@dblUnsettledBalance = SUM(dblIncrease) - SUM(dblDecrease)
			FROM @CompanyOwnedData C
			WHERE CONVERT(DATETIME, CONVERT(VARCHAR(10), dtmDate, 110), 110) < CONVERT(DATETIME, @dtmMonthYear)
			and strType = 'Unpaid' 

			/*Settled Company owned*/
			SELECT 			
				@dblSettledBalance = SUM(dblIncrease) - SUM(dblDecrease)
			FROM @CompanyOwnedData C
			WHERE CONVERT(DATETIME, CONVERT(VARCHAR(10), dtmDate, 110), 110) < CONVERT(DATETIME, @dtmMonthYear)
			and strType = 'Paid' 

			SELECT 			
			@dblWHROutstanding = SUM(dblIn) - SUM(dblOut)
			FROM #OwnershipALL C
			WHERE CONVERT(DATETIME, CONVERT(VARCHAR(10), dtmDate, 110), 110) < CONVERT(DATETIME, @dtmMonthYear)
			and strTransactionType <> 'Inventory Adjustment' and  (strStorageTypeCode = 'WH' and ysnReceiptedStorage = 1)
			and strOwnedPhysicalStock = 'Company'
			 and  isnull(ysnSettled,0) = 1
			 
			SELECT 
				@dblIInboundBalance =sum(ISNULL(dblIn,0)),
				@dblIOutboundBalance =sum(ISNULL(dblOut,0))
			FROM #OwnershipALL
			WHERE CONVERT(DATETIME,CONVERT(VARCHAR(10),dtmDate,110),110) < CONVERT(DATETIME, @dtmMonthYear)
			and strOwnedPhysicalStock = 'Intransit'		
			and isnull(ysnSettled,0) = 1

			insert into @ReportData  (
			intDay								
			,dblUnsettledBalance	
			
			,dblSettledBalance		
			
			--,dblCOBalance			
			,dblTotalWHROwned		
			
			,dblWHROutstanding		
				
			,dblPLCBalance			
			,dblIOutboundBalance	
			,dblIInboundBalance		
			,dtmMonthYear		
			,strCommodity
			,strLocation
		
			)  values (
			0							
			,isnull(@dblUnsettledBalance,0)					--dblUnsettledBalance	

			,isnull(@dblSettledBalance,0)					--dblSettledBalance		
	
			--,isnull(@dblCOBalance,0)			--dblCOBalance			
			,isnull(@dblTotalCustomerOwnership,0) - isnull(@dblTotalTerminalStorage,0)			--dblTotalWHROwned		
		
			,isnull(@dblWHROutstanding,0) 						--dblWHROutstanding		
			
			,isnull(@dblPLCBalance,0)				--dblPLCBalance			
			,abs(isnull(@dblIOutboundBalance,0))					--dblIOutboundBalance	
			,isnull(@dblIInboundBalance,0)					--dblIInboundBalance			
			,@dtmMonthYear
			,@strCommodity
			,@strLocation)
		end
		/*end previous balance*/
		SELECT 
			
			@dblTotalCustomerOwnership = SUM(dblIn) -  SUM(dblOut)
		FROM #OwnershipALL C
		WHERE CONVERT(DATETIME, CONVERT(VARCHAR(10), dtmDate, 110), 110) = CONVERT(DATETIME, @dtmMonthYear)
		and strTransactionType <> 'Inventory Adjustment' --and strStorageTypeCode = 'WH' and ysnReceiptedStorage = 1
		and strOwnedPhysicalStock = 'Customer'
		

		SELECT 			
			@dblTotalTerminalStorage = SUM(dblIn) - SUM(dblOut)
		FROM #OffsiteStorage C
		WHERE CONVERT(DATETIME, CONVERT(VARCHAR(10), dtmDate, 110), 110) = CONVERT(DATETIME, @dtmMonthYear)
				
		SELECT 
			@dblIInboundBalance =sum(ISNULL(dblIn,0)),
			@dblIOutboundBalance =sum(ISNULL(dblOut,0))
		FROM #OwnershipALL
		WHERE CONVERT(DATETIME,CONVERT(VARCHAR(10),dtmDate,110),110) = CONVERT(DATETIME, @dtmMonthYear)
		and strOwnedPhysicalStock = 'Intransit'		
		
		--/* END IN TRANSIT */

		insert into @ReportData  (
		intDay								
		,dblUnsettledBalance	
		,dblUnsettledIncrease	
		,dblUnsettledDecrease	
		,dblSettledBalance		
		,dblSettledIncrease		
		,dblSettledDecrease		
		--,dblCOBalance			
		,dblTotalWHROwned		
		,dblWHRIssued			
		,dblWHRCancelled		
		,dblWHROutstanding		
		,dblPLCIn				
		,dblPLCOut				
		,dblPLCBalance			
		,dblIOutboundBalance	
		,dblIInboundBalance		
		,dtmMonthYear		
		,strCommodity
		,strLocation
		
		)  values (
		@intDay							
		,isnull(@dblUnsettledIncrease,0) - isnull(@dblUnsettledDecrease,0)					--dblUnsettledBalance	
		,isnull(@dblUnsettledIncrease,0)				--dblUnsettledIncrease	
		,isnull(@dblUnsettledDecrease,0)						--dblUnsettledDecrease	
		,isnull(@dblSettledIncrease,0) - isnull(@dblSettledDecrease,0)					--dblSettledBalance		
		,isnull(@dblSettledIncrease,0)					--dblSettledIncrease		
		,isnull(@dblSettledDecrease,0)					--dblSettledDecrease		
		--,isnull(@dblUnsettledIncrease,0) - isnull(@dblUnsettledDecrease,0) + isnull(@dblSettledIncrease,0) - isnull(@dblSettledDecrease,0)			--dblCOBalance			
		,isnull(@dblTotalCustomerOwnership,0) - isnull(@dblTotalTerminalStorage,0)				--dblTotalWHROwned		
		,isnull(@dblWHRIssued,0)					--dblWHRIssued			
		,isnull(@dblWHRCancelled,0)					--dblWHRCancelled		
		,isnull(@dblWHRIssued,0) - isnull(@dblWHRCancelled,0)					--dblWHROutstanding		
		,isnull(@dblPLCIn,0)				--dblPLCIn				
		,isnull(@dblPLCOut,0)				--dblPLCOut				
		,isnull(@dblPLCIn,0) - isnull(@dblPLCOut,0)					--dblPLCBalance			
		,abs(isnull(@dblIOutboundBalance,0))					--dblIOutboundBalance	
		,isnull(@dblIInboundBalance,0)					--dblIInboundBalance			
		,@dtmMonthYear
		,@strCommodity
		,@strLocation)
				
		set @dtmMonthYear = dateadd(DAY,1 ,@dtmMonthYear)
	end
	DROP TABLE #DelayedPricingALL
	DROP TABLE #OwnershipALL
	--DROP TABLE #Vouchers
	DROP TABLE #OffsiteStorage
	update @ReportData set dblTotalWHROwned = dblUnsettledBalance + dblSettledBalance  + dblTotalWHROwned
	, dblCOBalance = dblUnsettledBalance + dblSettledBalance 
	SELECT * from @ReportData
END
GO