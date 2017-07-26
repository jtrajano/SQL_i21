CREATE PROCEDURE [dbo].[uspGRReportProductionSummaryDetail]
	@intStorageTypeId INT,
	@intEntityId INT,
	@intItemId   INT	
AS

BEGIN TRY
	
	DECLARE @ErrMsg NVARCHAR(MAX)
	DECLARE @strStorageType NVARCHAR(100)
	DECLARE @strInvoice NVARCHAR(MAX)

	DECLARE @TotalBeginingBalance FLOAT
	DECLARE @TotalEndingBalance FLOAT--DECIMAL(24,10)

	SELECT @TotalBeginingBalance = SUM(dblUnits) 
	FROM  tblGRStorageHistory SH
	JOIN  tblGRCustomerStorage CS ON CS.intCustomerStorageId=SH.intCustomerStorageId
	WHERE CS.intStorageTypeId = @intStorageTypeId 
	AND CS.intEntityId = CASE WHEN @intEntityId >0 THEN @intEntityId ELSE CS.intEntityId END
	AND CS.intItemId = CASE WHEN @intItemId  >0 THEN @intItemId  ELSE CS.intItemId END
	AND SH.dtmHistoryDate < GetDATE()

	SELECT @TotalEndingBalance = SUM(dblOpenBalance) FROM vyuGRStorageSearchView 
	WHERE intStorageTypeId = @intStorageTypeId 
	AND intEntityId = CASE WHEN @intEntityId >0 THEN @intEntityId ELSE intEntityId END
	AND intItemId = CASE WHEN @intItemId  >0 THEN @intItemId  ELSE intItemId END
	
	IF @intStorageTypeId >0
	SELECT @strStorageType=strStorageTypeDescription FROM tblGRStorageType WHERE intStorageScheduleTypeId=@intStorageTypeId
	
	SELECT @strInvoice=  
	STUFF((SELECT DISTINCT ', ' + CAST( b.strInvoiceNumber  AS VARCHAR(10)) [text()]
	FROM tblGRStorageHistory a 
	JOIN tblARInvoice b ON b.intInvoiceId=a.intInvoiceId
	WHERE  a.intCustomerStorageId IN (1,2)	AND a.intInvoiceId IS NOT NULL FOR XML PATH(''), TYPE).value('.','NVARCHAR(MAX)'),1,2,' ')

	SELECT	
	CS.intCustomerStorageId,
	CS.strStorageTicketNumber,
	CONVERT(Nvarchar,SH.dtmHistoryDate,101) AS dtmHistoryDate,
	CASE 
			WHEN SH.strType='From Scale' THEN 'DELIVERED'				
			ELSE NULL
	END
	AS strDescription,		
	dbo.fnRemoveTrailingZeroes(SH.dblUnits) AS dblTransactionUnits,
	dbo.fnRemoveTrailingZeroes(dbo.fnCTConvertQuantityToTargetItemUOM(CS.intItemId,CS.intUnitMeasureId,CU.intUnitMeasureId,CS.dblOpenBalance)) AS dblBalance,
	@strStorageType AS strStorageType,
	@strInvoice AS strInvoice,
	@TotalBeginingBalance AS BeginingBalance,
	@TotalEndingBalance AS EndingBalance  							
	FROM  tblGRCustomerStorage CS
	JOIN  tblGRStorageHistory SH ON SH.intCustomerStorageId=CS.intCustomerStorageId
	JOIN  tblICCommodityUnitMeasure CU ON CU.intCommodityId=CS.intCommodityId AND CU.ysnStockUnit=1  	
	WHERE CS.intStorageTypeId = @intStorageTypeId 
	AND   CS.intEntityId = CASE WHEN @intEntityId >0 THEN @intEntityId ELSE CS.intEntityId END
	AND	  CS.intItemId = CASE WHEN @intItemId  >0 THEN @intItemId  ELSE CS.intItemId END
	AND   ISNULL(SH.dblUnits,0) <>0
	ORDER BY CS.intCustomerStorageId

END TRY

BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()  
	RAISERROR (@ErrMsg,18,1,'WITH NOWAIT')  	
END CATCH
