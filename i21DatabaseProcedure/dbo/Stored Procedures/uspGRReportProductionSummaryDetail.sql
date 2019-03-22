CREATE PROCEDURE [dbo].[uspGRReportProductionSummaryDetail]
	@intStorageTypeId INT,	
	@intItemId   INT,
	@intEntityId INT,	
	@dtmStartDate DATETIME,
	@dtmEndDate DATETIME = NULL	
AS

BEGIN TRY
	
	DECLARE @ErrMsg NVARCHAR(MAX)
	DECLARE @strStorageType NVARCHAR(100)
	DECLARE @strInvoice NVARCHAR(MAX)

	DECLARE @TotalBeginingBalance DECIMAL(24,10)
	DECLARE @TotalEndingBalance  DECIMAL(24,10)
	DECLARE @strCompanyName NVARCHAR(500)
	DECLARE @ScaleUOMId  INT
	DECLARE @intUnitMeasureId  INT
	DECLARE @CommodityStockUomId  INT
	DECLARE @CommodityStockUom NVARCHAR(50)
	DECLARE @CommodityStockUnitMeasure NVARCHAR(50)
	DECLARE @ScaleUOM NVARCHAR(50)
	DECLARE @dblDryingandDiscountsOnLoadsIn DECIMAL(24,10)
	DECLARE @dblDryingPremium DECIMAL(24,10)
	DECLARE @dblTotalStorageBilled DECIMAL(24,10)
	DECLARE @strComodity NVARCHAR(100)
	
	DECLARE @StorageTransaction AS TABLE 
	(
		 intSettleStorageKey INT IDENTITY(1, 1)
		,intCustomerStorageId INT
		,strStorageTicketNumber NVARCHAR(40) COLLATE Latin1_General_CI_AS NULL
		,dtmHistoryDate DATETIME
		,strDescription NVARCHAR(40) COLLATE Latin1_General_CI_AS NULL
		,dblScaleUOMIN DECIMAL(24, 10)
		,dblScaleUOMOUT DECIMAL(24, 10)
		,dblNetBalance DECIMAL(24, 10)
	)

	SELECT @strComodity=COM.strDescription FROM tblICCommodity COM
	JOIN tblICItem Item ON Item.intCommodityId=COM.intCommodityId 
	WHERE Item.intItemId=@intItemId

	SELECT	@intUnitMeasureId = a.intUnitMeasureId
	FROM	tblICCommodityUnitMeasure a 
	JOIN	tblICItem b ON b.intCommodityId = a.intCommodityId
	WHERE	b.intItemId = @intItemId AND a.ysnStockUnit = 1

	SELECT @CommodityStockUom = strSymbol,@CommodityStockUnitMeasure=strUnitMeasure 
	FROM tblICUnitMeasure WHERE intUnitMeasureId=@intUnitMeasureId

	SELECT	@CommodityStockUomId = intItemUOMId			
	FROM	tblICItemUOM UOM
	WHERE	intItemId = @intItemId AND intUnitMeasureId = @intUnitMeasureId

	SELECT	@strCompanyName	=	CASE WHEN LTRIM(RTRIM(strCompanyName)) = '' THEN NULL ELSE LTRIM(RTRIM(strCompanyName)) END
	FROM	tblSMCompanySetup
	
	IF @intStorageTypeId >0
	SELECT @strStorageType=strStorageTypeDescription FROM tblGRStorageType WHERE intStorageScheduleTypeId=@intStorageTypeId

	SELECT TOP 1 @ScaleUOMId=intUnitMeasureId FROM tblSCScaleSetup
	SELECT @ScaleUOM = strUnitMeasure 
	FROM tblICUnitMeasure WHERE intUnitMeasureId=@ScaleUOMId
	
	 SELECT @TotalBeginingBalance=[dbo].[fnRemoveTrailingZeroes](
	 ISNULL(SUM(
				CASE 
					WHEN (SH.strType='From Scale' OR SH.strType='From Delivery Sheet' OR SH.strType='Open Balance Adj' OR SH.strType='Reverse Adjustment' OR SH.strType='Reverse By Invoice' OR SH.strType='Reverse Settlement') THEN dbo.fnCTConvertQuantityToTargetItemUOM(CS.intItemId,CS.intUnitMeasureId,CU.intUnitMeasureId,ISNULL(SH.dblUnits,0))
					WHEN (SH.strType='Reduced By Invoice' OR SH.strType='Settlement') THEN - dbo.fnCTConvertQuantityToTargetItemUOM(CS.intItemId,CS.intUnitMeasureId,CU.intUnitMeasureId,ISNULL(SH.dblUnits,0))
					ELSE 0
				END
	   ),0))
	FROM  tblGRStorageHistory SH
	JOIN  tblGRCustomerStorage CS ON CS.intCustomerStorageId=SH.intCustomerStorageId
	JOIN tblICCommodityUnitMeasure CU ON CU.intCommodityId=CS.intCommodityId AND CU.ysnStockUnit=1 
	WHERE CS.intStorageTypeId =  @intStorageTypeId
	AND CS.intEntityId = @intEntityId
	AND CS.intItemId =  @intItemId
	AND dbo.fnRemoveTimeOnDate(SH.dtmHistoryDate) < dbo.fnRemoveTimeOnDate(@dtmStartDate)
	AND strType IN ('From Scale','From Delivery Sheet','Open Balance Adj','Reverse Adjustment','Reverse By Invoice','Reverse Settlement','Reduced By Invoice','Settlement')

	
	 
	 SELECT @strInvoice=  
	 STUFF((SELECT DISTINCT ', ' + CAST( b.strInvoiceNumber  AS VARCHAR(10)) [text()]
	 FROM tblGRStorageHistory a 
	 JOIN tblARInvoice b ON b.intInvoiceId=a.intInvoiceId
	 JOIN tblGRCustomerStorage CS ON CS.intCustomerStorageId=a.intCustomerStorageId
	 JOIN tblGRStorageHistory SH ON SH.intCustomerStorageId=CS.intCustomerStorageId
	 WHERE a.intInvoiceId IS NOT NULL
	 AND   CS.intStorageTypeId = @intStorageTypeId 
	 AND   CS.intEntityId =  @intEntityId
	 AND   CS.intItemId =  @intItemId
	 AND   dbo.fnRemoveTimeOnDate(SH.dtmHistoryDate) >= dbo.fnRemoveTimeOnDate(@dtmStartDate)
	 AND   dbo.fnRemoveTimeOnDate(SH.dtmHistoryDate) <= @dtmEndDate
	 FOR XML PATH(''), TYPE).value('.','NVARCHAR(MAX)'),1,2,' ')

	SELECT @dblDryingandDiscountsOnLoadsIn=[dbo].[fnRemoveTrailingZeroes](ISNULL(SUM(Invoice.dblInvoiceTotal),0))
	FROM  tblGRStorageHistory SH
	JOIN  tblGRCustomerStorage CS ON CS.intCustomerStorageId=SH.intCustomerStorageId
	JOIN tblARInvoice Invoice ON Invoice.intInvoiceId = SH.intInvoiceId
	WHERE CS.intStorageTypeId =  @intStorageTypeId AND SH.[strType]='Generated Discount Invoice'
	AND CS.intEntityId = @intEntityId
	AND CS.intItemId = @intItemId
	AND dbo.fnRemoveTimeOnDate(SH.dtmHistoryDate) >= dbo.fnRemoveTimeOnDate(@dtmStartDate)
	AND dbo.fnRemoveTimeOnDate(SH.dtmHistoryDate) <= @dtmEndDate

	SELECT @dblDryingPremium=[dbo].[fnRemoveTrailingZeroes](ISNULL(SUM(BillDtl.dblTotal),0))
	FROM  tblGRStorageHistory SH
	JOIN  tblGRCustomerStorage CS ON CS.intCustomerStorageId=SH.intCustomerStorageId
	JOIN  tblAPBill Bill ON Bill.intBillId = SH.intBillId
	JOIN  tblAPBillDetail BillDtl ON BillDtl.intBillId = Bill.intBillId
	WHERE CS.intStorageTypeId =  @intStorageTypeId AND SH.[strType]='Generated Bill'
	AND CS.intEntityId = @intEntityId
	AND CS.intItemId = @intItemId
	AND dbo.fnRemoveTimeOnDate(SH.dtmHistoryDate) >= dbo.fnRemoveTimeOnDate(@dtmStartDate)
	AND dbo.fnRemoveTimeOnDate(SH.dtmHistoryDate) <= @dtmEndDate

	SET @dblDryingandDiscountsOnLoadsIn=@dblDryingandDiscountsOnLoadsIn - @dblDryingPremium

	SELECT @dblTotalStorageBilled=[dbo].[fnRemoveTrailingZeroes](ISNULL(SUM(Invoice.dblInvoiceTotal),0))
	FROM  tblGRStorageHistory SH
	JOIN  tblGRCustomerStorage CS ON CS.intCustomerStorageId=SH.intCustomerStorageId
	JOIN tblARInvoice Invoice ON Invoice.intInvoiceId = SH.intInvoiceId
	WHERE CS.intStorageTypeId =  @intStorageTypeId AND SH.[strType]='Generated Storage Invoice'
	AND CS.intEntityId = @intEntityId
	AND CS.intItemId = @intItemId
	AND dbo.fnRemoveTimeOnDate(SH.dtmHistoryDate) >= dbo.fnRemoveTimeOnDate(@dtmStartDate)
	AND dbo.fnRemoveTimeOnDate(SH.dtmHistoryDate) <= @dtmEndDate
	 
	
	
	INSERT INTO  @StorageTransaction
	(
		 strStorageTicketNumber
		,dtmHistoryDate
		,strDescription		
		,dblNetBalance
	)
	SELECT
	 'BALANCE' AS strStorageTicketNumber
	,@dtmStartDate AS dtmHistoryDate
	,'BAL. FORWARD' AS strDescription
	, ROUND(dbo.fnCTConvertQuantityToTargetItemUOM(@intItemId,@intUnitMeasureId,@ScaleUOMId,@TotalBeginingBalance),3)
	
	INSERT INTO  @StorageTransaction
	(
		 intCustomerStorageId
		,strStorageTicketNumber
		,dtmHistoryDate
		,strDescription
		,dblScaleUOMIN
		,dblScaleUOMOUT
		,dblNetBalance
	)

	SELECT	
	CS.intCustomerStorageId,
	CS.strStorageTicketNumber,
	CONVERT(Nvarchar,SH.dtmHistoryDate,101) AS dtmHistoryDate,
	CASE 
			WHEN SH.strType IN('From Scale','From Delivery Sheet') THEN 'DELIVERED'				
			ELSE UPPER(SH.strType)
	END
	AS strDescription,
	
	[dbo].[fnRemoveTrailingZeroes]
	(
		CASE 
					WHEN (SH.strType='From Scale' OR SH.strType='From Delivery Sheet' OR SH.strType='Open Balance Adj' OR SH.strType='Reverse Adjustment' OR SH.strType='Reverse By Invoice' OR SH.strType='Reverse Settlement') THEN dbo.fnCTConvertQuantityToTargetItemUOM(CS.intItemId,CS.intUnitMeasureId,@ScaleUOMId,ISNULL(SH.dblUnits,0))				
					ELSE NULL
		END
	)
	AS dblScaleUOMIN,

	[dbo].[fnRemoveTrailingZeroes]
	(
		CASE 
					WHEN (SH.strType='Reduced By Invoice' OR SH.strType='Settlement') THEN dbo.fnCTConvertQuantityToTargetItemUOM(CS.intItemId,CS.intUnitMeasureId,@ScaleUOMId,ISNULL(SH.dblUnits,0))
					ELSE NULL
		END
    )
	AS dblScaleUOMOUT,
	[dbo].[fnRemoveTrailingZeroes]
	(
		CASE 
					WHEN (SH.strType='From Scale' OR SH.strType='From Delivery Sheet'  OR SH.strType='Open Balance Adj' OR SH.strType='Reverse Adjustment' OR SH.strType='Reverse By Invoice' OR SH.strType='Reverse Settlement') THEN ROUND(dbo.fnCTConvertQuantityToTargetItemUOM(CS.intItemId,CS.intUnitMeasureId,@ScaleUOMId,ISNULL(SH.dblUnits,0)),3)
					WHEN (SH.strType='Reduced By Invoice' OR SH.strType='Settlement') THEN - ROUND(dbo.fnCTConvertQuantityToTargetItemUOM(CS.intItemId,CS.intUnitMeasureId,@ScaleUOMId,ISNULL(SH.dblUnits,0)),3)			
					ELSE NULL
		END
	)
	AS dblNetBalance
	FROM  tblGRCustomerStorage CS
	JOIN  tblGRStorageHistory SH ON SH.intCustomerStorageId=CS.intCustomerStorageId
	JOIN  tblICCommodity Com ON Com.intCommodityId=CS.intCommodityId
	JOIN  tblICCommodityUnitMeasure CU ON CU.intCommodityId=CS.intCommodityId AND CU.ysnStockUnit=1	
	WHERE CS.intStorageTypeId = @intStorageTypeId 
	AND   CS.intEntityId = @intEntityId
	AND	  CS.intItemId =  @intItemId
	AND   ISNULL(SH.dblUnits,0) <>0
	AND   SH.strType IN ('From Scale','From Delivery Sheet','Open Balance Adj','Reverse Adjustment','Reverse By Invoice','Reverse Settlement','Reduced By Invoice','Settlement')
	AND   dbo.fnRemoveTimeOnDate(SH.dtmHistoryDate) >= dbo.fnRemoveTimeOnDate(@dtmStartDate)
	AND   dbo.fnRemoveTimeOnDate(SH.dtmHistoryDate) <= @dtmEndDate	 
	ORDER BY SH.intStorageHistoryId

	 SELECT @TotalEndingBalance=
	 [dbo].[fnRemoveTrailingZeroes](
									 ISNULL(SUM(dblNetBalance),0)
								   ) FROM @StorageTransaction

	SET @TotalEndingBalance=ROUND(dbo.fnCTConvertQuantityToTargetItemUOM(@intItemId,@ScaleUOMId,@intUnitMeasureId,@TotalEndingBalance),3)

	SELECT 
	 t1.intSettleStorageKey, 
	 t1.intCustomerStorageId
	,t1.strStorageTicketNumber
	,CONVERT(Nvarchar,t1.dtmHistoryDate,101) AS dtmHistoryDate
	,t1.strDescription
	,@ScaleUOM+' IN' AS strScaleUOMIN
	,[dbo].[fnRemoveTrailingZeroes](t1.dblScaleUOMIN) AS dblScaleUOMIN
	,@ScaleUOM+' OUT' AS strScaleUOMOUT
	,[dbo].[fnRemoveTrailingZeroes](t1.dblScaleUOMOUT) AS dblScaleUOMOUT
	,[dbo].[fnRemoveTrailingZeroes](@TotalBeginingBalance)+' '+@CommodityStockUom AS BeginingBalance
	,[dbo].[fnRemoveTrailingZeroes](@TotalEndingBalance)+' '+@CommodityStockUom AS EndingBalance
	,[dbo].[fnRemoveTrailingZeroes](SUM(t2.dblNetBalance)) dblBalance,
	@strInvoice AS strInvoice,
	'$'+[dbo].[fnRemoveTrailingZeroes](@dblDryingandDiscountsOnLoadsIn) AS dblDryingandDiscountsOnLoadsIn,
	@strCompanyName AS strCompanyName,
	@strStorageType+' Statement' AS strStorageType,
	@strComodity AS strCommodityCode,
	@strComodity AS strCommodityDescription,
	0.0 As dblBalanceUnits,
    NULL As dblStorageShrink,
	'$'+[dbo].[fnRemoveTrailingZeroes](@dblTotalStorageBilled+@dblDryingandDiscountsOnLoadsIn) As dblBilled,	
	'$'+[dbo].[fnRemoveTrailingZeroes](@dblDryingandDiscountsOnLoadsIn) As dblTotalDiscountsBilled,
	NULL As dblTotalODAFeesBilled,
	'$'+[dbo].[fnRemoveTrailingZeroes](@dblTotalStorageBilled) As dblTotalStorageBilled,
	NULL As dblTotalFreightBilled	
	FROM @StorageTransaction t1
    JOIN @StorageTransaction t2 ON t1.intSettleStorageKey >= t2.intSettleStorageKey
	GROUP BY 
		 t1.intSettleStorageKey, 
		 t1.intCustomerStorageId
		,t1.strStorageTicketNumber
		,t1.dtmHistoryDate
		,t1.strDescription
		,t1.dblScaleUOMIN
		,t1.dblScaleUOMOUT
		,t1.dblNetBalance

END TRY

BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()  
	RAISERROR (@ErrMsg,18,1,'WITH NOWAIT')  	
END CATCH
