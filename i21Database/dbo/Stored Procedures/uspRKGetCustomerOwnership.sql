CREATE PROC [dbo].[uspRKGetCustomerOwnership]
       @dtmFromTransactionDate datetime = null,
	   @dtmToTransactionDate datetime = null,
	   @intCommodityId int =  null,
	   @intItemId int= null,
	   @strPositionIncludes nvarchar(100) = NULL,
	   @intLocationId int = null
AS

IF OBJECT_ID('tempdb..#tempCustomer') IS NOT NULL
    DROP TABLE #tempCustomer
IF OBJECT_ID('tempdb..##temp1') IS NOT NULL
    DROP TABLE ##temp1
IF OBJECT_ID('tempdb..#final') IS NOT NULL
    DROP TABLE #final

DECLARE @ysnDisplayAllStorage bit
select @ysnDisplayAllStorage= isnull(ysnDisplayAllStorage,0) from tblRKCompanyPreference

SELECT  CONVERT(INT,ROW_NUMBER() OVER (ORDER BY strStorageTypeDescription)) intRowNum,dtmDate,strStorageTypeDescription strDistribution,dblIn,dblOut,dblNet,intStorageScheduleTypeId
 into #tempCustomer 
 FROM (
   SELECT dtmDate,strStorageTypeDescription,sum(round(dblInQty,2)) dblIn,sum(round(isnull(dblOutQty,0)+isnull(dblSettleUnit,0),2))dblOut,round(sum(dblInQty),2)-sum(round(isnull(dblOutQty,0)+isnull(dblSettleUnit,0),2)) dblNet,intStorageScheduleTypeId FROM(		
		SELECT CONVERT(VARCHAR(10),st.dtmTicketDateTime,110) dtmDate,strStorageTypeDescription,	CASE WHEN strInOutFlag='I' THEN dblNetUnits ELSE 0 END dblInQty,
																								CASE WHEN strInOutFlag='O' THEN dblNetUnits ELSE 0 END dblOutQty,gs.intStorageScheduleTypeId  
			,(select sum(SH.dblUnits) from tblGRStorageHistory SH
				JOIN  tblGRCustomerStorage CS ON CS.intCustomerStorageId = SH.intCustomerStorageId
				JOIN tblGRSettleStorageTicket ST1 ON ST1.intCustomerStorageId = CS.intCustomerStorageId AND ST1.intSettleStorageId = SH.intSettleStorageId
				JOIN tblGRSettleStorage SS ON SS.intSettleStorageId = ST1.intSettleStorageId 
				WHERE strType='Settlement' 
				AND  ysnPosted=1 and CS.intTicketId=st.intTicketId and convert(DATETIME, CONVERT(VARCHAR(10), dtmHistoryDate, 110), 110)
										= convert(DATETIME, CONVERT(VARCHAR(10), st.dtmTicketDateTime, 110), 110)) 	dblSettleUnit																										
		FROM tblSCTicket st
		JOIN tblICItem i on i.intItemId=st.intItemId 								
		JOIN tblGRStorageType gs on gs.intStorageScheduleTypeId=st.intStorageScheduleTypeId 
		WHERE convert(datetime,CONVERT(VARCHAR(10),st.dtmTicketDateTime,110),110) BETWEEN
		 convert(datetime,CONVERT(VARCHAR(10),@dtmFromTransactionDate,110),110) AND convert(datetime,CONVERT(VARCHAR(10),@dtmToTransactionDate,110),110)
		AND i.intCommodityId= @intCommodityId
		and i.intItemId= case when isnull(@intItemId,0)=0 then i.intItemId else @intItemId end and isnull(strType,'') <> 'Other Charge'
		and  gs.intStorageScheduleTypeId > 0 and gs.strOwnedPhysicalStock='Customer' and strTicketStatus='C'
		AND  st.intProcessingLocationId  IN (
													SELECT intCompanyLocationId FROM tblSMCompanyLocation
													WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'licensed storage' THEN 1 
													WHEN @strPositionIncludes = 'Non-licensed storage' THEN 0 
													ELSE isnull(ysnLicensed, 0) END
											)
		AND st.intProcessingLocationId = case when isnull(@intLocationId,0)=0 then st.intProcessingLocationId else @intLocationId end

		UNION ALL --Delivery Sheet
			SELECT
				CONVERT(VARCHAR(10),DS.dtmDeliverySheetDate,110) dtmDate
				,strStorageTypeDescription
				,CASE WHEN strInOutFlag='I' THEN dblNetUnits * (DSS.dblSplitPercent/100)  ELSE 0 END dblInQty
				,CASE WHEN strInOutFlag='O' THEN dblNetUnits * (DSS.dblSplitPercent/100)  ELSE 0 END dblOutQty,gs.intStorageScheduleTypeId  
				,(select sum(SH.dblUnits) from tblGRStorageHistory SH
						JOIN  tblGRCustomerStorage CS ON CS.intCustomerStorageId = SH.intCustomerStorageId
						JOIN tblGRSettleStorageTicket ST1 ON ST1.intCustomerStorageId = CS.intCustomerStorageId AND ST1.intSettleStorageId = SH.intSettleStorageId
						JOIN tblGRSettleStorage SS ON SS.intSettleStorageId = ST1.intSettleStorageId 
						WHERE strType='Settlement' 
						AND  ysnPosted=1 and CS.intDeliverySheetId=DS.intDeliverySheetId and convert(DATETIME, CONVERT(VARCHAR(10), dtmHistoryDate, 110), 110)
												= convert(DATETIME, CONVERT(VARCHAR(10), st.dtmTicketDateTime, 110), 110)) 	dblSettleUnit		
			FROM tblSCTicket st
				JOIN tblICItem i on i.intItemId=st.intItemId
				JOIN tblSCDeliverySheet DS ON st.intDeliverySheetId = DS.intDeliverySheetId
				JOIN tblSCDeliverySheetSplit DSS ON DS.intDeliverySheetId = DSS.intDeliverySheetId
				--JOIN tblGRCustomerStorage GCS ON DS.intDeliverySheetId = GCS.intDeliverySheetId
				JOIN tblGRStorageType gs on gs.intStorageScheduleTypeId=DSS.intStorageScheduleTypeId 
				--JOIN tblICInventoryReceiptItem IRI on DS.intDeliverySheetId = IRI.intSourceId
			WHERE convert(datetime,CONVERT(VARCHAR(10),DS.dtmDeliverySheetDate,110),110) BETWEEN
				 convert(datetime,CONVERT(VARCHAR(10),@dtmFromTransactionDate,110),110) AND convert(datetime,CONVERT(VARCHAR(10),@dtmToTransactionDate,110),110)
				AND i.intCommodityId= @intCommodityId
				and i.intItemId= case when isnull(@intItemId,0)=0 then i.intItemId else @intItemId end and isnull(strType,'') <> 'Other Charge'
				and  DSS.intStorageScheduleTypeId > 0 --and DSS.strOwnedPhysicalStock='Customer' 
				AND  st.intProcessingLocationId  IN (
															SELECT intCompanyLocationId FROM tblSMCompanyLocation
															WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'licensed storage' THEN 1 
															WHEN @strPositionIncludes = 'Non-licensed storage' THEN 0 
															ELSE isnull(ysnLicensed, 0) END
													)
				AND st.intProcessingLocationId = case when isnull(@intLocationId,0)=0 then st.intProcessingLocationId else @intLocationId end
				AND st.strTicketStatus = 'H'
				AND DS.ysnPost = 0

		UNION ALL --Delivery
			SELECT 
				dtmDate 
				,strStorageTypeDescription
				,dblInQty
				,dblOutQty
				,intStorageTypeId
				,dblSettleUnit
			FROM (
				SELECT
					CONVERT(VARCHAR(10),GCS.dtmDeliveryDate,110) dtmDate
					,strStorageTypeDescription
					,sum(dblOpenBalance)  dblInQty
					,0 dblOutQty
					,GCS.intStorageTypeId  
					,0	dblSettleUnit	
					,intDeliverySheetId	
				FROM  vyuGRStorageSearchView GCS
				WHERE convert(datetime,CONVERT(VARCHAR(10),GCS.dtmDeliveryDate,110),110) BETWEEN
					 convert(datetime,CONVERT(VARCHAR(10),@dtmFromTransactionDate,110),110) AND convert(datetime,CONVERT(VARCHAR(10),@dtmToTransactionDate,110),110)
					AND GCS.intCommodityId= @intCommodityId
					and GCS.intItemId= case when isnull(@intItemId,0)=0 then GCS.intItemId else @intItemId end 
					and  GCS.intStorageTypeId > 0 
					AND  GCS.intCompanyLocationId  IN (
																SELECT intCompanyLocationId FROM tblSMCompanyLocation
																WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'licensed storage' THEN 1 
																WHEN @strPositionIncludes = 'Non-licensed storage' THEN 0 
																ELSE isnull(ysnLicensed, 0) END)
				
					AND GCS.intCompanyLocationId = case when isnull(@intLocationId,0)=0 then GCS.intCompanyLocationId  else @intLocationId end
					ANd GCS.intDeliverySheetId IS NOT NULL
					GROUP BY 
						CONVERT(VARCHAR(10),GCS.dtmDeliveryDate,110)
						,strStorageTypeDescription
						,intStorageTypeId
						,intDeliverySheetId
			) a

		--UNION ALL --Delivery Sheet with IR
		--	SELECT DISTINCT
		--		CONVERT(VARCHAR(10),GCS.dtmDeliveryDate,110) dtmDate
		--		,strStorageTypeDescription
		--		,CASE WHEN strInOutFlag='I' THEN dblNetUnits * (DSS.dblSplitPercent/100)  ELSE 0 END dblInQty
		--		,CASE WHEN strInOutFlag='O' THEN dblNetUnits * (DSS.dblSplitPercent/100)  ELSE 0 END dblOutQty,gs.intStorageScheduleTypeId  
		--		,(select sum(SH.dblUnits) from tblGRStorageHistory SH
		--				JOIN  tblGRCustomerStorage CS ON CS.intCustomerStorageId = SH.intCustomerStorageId
		--				JOIN tblGRSettleStorageTicket ST1 ON ST1.intCustomerStorageId = CS.intCustomerStorageId AND ST1.intSettleStorageId = SH.intSettleStorageId
		--				JOIN tblGRSettleStorage SS ON SS.intSettleStorageId = ST1.intSettleStorageId 
		--				WHERE strType='Settlement' 
		--				AND  ysnPosted=1 and CS.intDeliverySheetId=DS.intDeliverySheetId and convert(DATETIME, CONVERT(VARCHAR(10), dtmHistoryDate, 110), 110)
		--										= convert(DATETIME, CONVERT(VARCHAR(10), st.dtmTicketDateTime, 110), 110)) 	dblSettleUnit		
		--	FROM tblSCTicket st
		--		JOIN tblICItem i on i.intItemId=st.intItemId
		--		JOIN tblSCDeliverySheet DS ON st.intDeliverySheetId = DS.intDeliverySheetId
		--		JOIN tblSCDeliverySheetSplit DSS ON DS.intDeliverySheetId = DSS.intDeliverySheetId
		--		JOIN tblGRCustomerStorage GCS ON DS.intDeliverySheetId = GCS.intDeliverySheetId
		--		JOIN tblGRStorageType gs on gs.intStorageScheduleTypeId=DSS.intStorageScheduleTypeId 
		--		JOIN tblICInventoryReceiptItem IRI on DS.intDeliverySheetId = IRI.intSourceId
		--	WHERE convert(datetime,CONVERT(VARCHAR(10),GCS.dtmDeliveryDate,110),110) BETWEEN
		--		 convert(datetime,CONVERT(VARCHAR(10),@dtmFromTransactionDate,110),110) AND convert(datetime,CONVERT(VARCHAR(10),@dtmToTransactionDate,110),110)
		--		AND i.intCommodityId= @intCommodityId
		--		and i.intItemId= case when isnull(@intItemId,0)=0 then i.intItemId else @intItemId end and isnull(strType,'') <> 'Other Charge'
		--		and  DSS.intStorageScheduleTypeId > 0 --and DSS.strOwnedPhysicalStock='Customer' 
		--		AND  st.intProcessingLocationId  IN (
		--													SELECT intCompanyLocationId FROM tblSMCompanyLocation
		--													WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'licensed storage' THEN 1 
		--													WHEN @strPositionIncludes = 'Non-licensed storage' THEN 0 
		--													ELSE isnull(ysnLicensed, 0) END
		--											)
		--		AND st.intProcessingLocationId = case when isnull(@intLocationId,0)=0 then st.intProcessingLocationId else @intLocationId end
		--		AND st.strTicketStatus = 'H'

			UNION ALL --On Hold without Delivery Sheet
			SELECT 
				CONVERT(VARCHAR(10),st.dtmTicketDateTime,110) dtmDate
				,'On Hold' as strStorageTypeDescription
				,CASE WHEN strInOutFlag='I' THEN dblNetUnits   ELSE 0 END dblInQty
				,CASE WHEN strInOutFlag='O' THEN dblNetUnits  ELSE 0 END dblOutQty, st.intStorageScheduleTypeId  
				,NULL dblSettleUnit			
			FROM tblSCTicket st
				JOIN tblICItem i on i.intItemId=st.intItemId
			WHERE convert(datetime,CONVERT(VARCHAR(10),st.dtmTicketDateTime,110),110) BETWEEN
				 convert(datetime,CONVERT(VARCHAR(10),@dtmFromTransactionDate,110),110) AND convert(datetime,CONVERT(VARCHAR(10),@dtmToTransactionDate,110),110)
				AND i.intCommodityId= @intCommodityId
				and i.intItemId= case when isnull(@intItemId,0)=0 then i.intItemId else @intItemId end and isnull(strType,'') <> 'Other Charge'
				AND  st.intProcessingLocationId  IN (
															SELECT intCompanyLocationId FROM tblSMCompanyLocation
															WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'licensed storage' THEN 1 
															WHEN @strPositionIncludes = 'Non-licensed storage' THEN 0 
															ELSE isnull(ysnLicensed, 0) END
													)
				AND st.intProcessingLocationId = case when isnull(@intLocationId,0)=0 then st.intProcessingLocationId else @intLocationId end
				AND st.strTicketStatus = 'H' AND st.intDeliverySheetId IS NULL

			UNION ALL --Transfer Storage
			SELECT
				CONVERT(VARCHAR(10),GCS.dtmDeliveryDate,110) dtmDate
				,strStorageTypeDescription
				,dblOpenBalance * (GCS.dblSplitPercent/100)   dblInQty
				,0 dblOutQty
				,GCS.intStorageTypeId  
				,0	dblSettleUnit		
			FROM  vyuGRStorageSearchView GCS
			
				--JOIN tblICInventoryReceiptItem IRI on DS.intDeliverySheetId = IRI.intSourceId
			WHERE convert(datetime,CONVERT(VARCHAR(10),GCS.dtmDeliveryDate,110),110) BETWEEN
				 convert(datetime,CONVERT(VARCHAR(10),@dtmFromTransactionDate,110),110) AND convert(datetime,CONVERT(VARCHAR(10),@dtmToTransactionDate,110),110)
				AND GCS.intCommodityId= @intCommodityId
				and GCS.intItemId= case when isnull(@intItemId,0)=0 then GCS.intItemId else @intItemId end 
				and  GCS.intStorageTypeId > 0 --and DSS.strOwnedPhysicalStock='Customer' 
				AND  GCS.intCompanyLocationId  IN (
															SELECT intCompanyLocationId FROM tblSMCompanyLocation
															WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'licensed storage' THEN 1 
															WHEN @strPositionIncludes = 'Non-licensed storage' THEN 0 
															ELSE isnull(ysnLicensed, 0) END)
				
				AND GCS.intCompanyLocationId = case when isnull(@intLocationId,0)=0 then GCS.intCompanyLocationId  else @intLocationId end
				ANd GCS.intDeliverySheetId IS NULL

			

		  )t     GROUP BY  dtmDate,strStorageTypeDescription,intStorageScheduleTypeId
) t1

IF (@ysnDisplayAllStorage=1)
BEGIN			 
	declare @intRowNumber int
	SELECT TOP 1 @intRowNumber=intRowNum FROM #tempCustomer order by intRowNum desc
	INSERT INTO #tempCustomer (intRowNum,dtmDate,strDistribution,dblIn,dblOut,dblNet,intStorageScheduleTypeId)
		SELECT CONVERT(INT,ROW_NUMBER() OVER (ORDER BY strStorageTypeDescription))+@intRowNumber,CONVERT(VARCHAR(10),@dtmToTransactionDate,110),strStorageTypeDescription,0.0,0.0,0.0,intStorageScheduleTypeId
		FROM tblGRStorageScheduleRule SSR 
		INNER JOIN tblGRStorageType  ST ON SSR.intStorageType = ST.intStorageScheduleTypeId 
		WHERE SSR.intCommodity = @intCommodityId AND ISNULL(ysnActive,0) = 1 AND intStorageScheduleTypeId > 0 AND intStorageScheduleTypeId not in(SELECT DISTINCT intStorageScheduleTypeId FROM #tempCustomer)
END

declare @TempTableCreate nvarchar(max)=''
SELECT @TempTableCreate+='['+t.strDistribution +'_strDistribution] NVARCHAR(100)  COLLATE Latin1_General_CI_AS  NULL,'+
	   '['+t.strDistribution +'_In]  NUMERIC(18, 6) NULL,'+
	   '['+t.strDistribution +'_Out]  NUMERIC(18, 6) NULL,'+
	   '['+t.strDistribution +'_Net]  NUMERIC(18, 6) NULL,'  
FROM (
SELECT DISTINCT strDistribution from #tempCustomer)t

SET @TempTableCreate=case when LEN(@TempTableCreate)>0 then LEFT(@TempTableCreate,LEN(@TempTableCreate)-1) else @TempTableCreate end
SET @TempTableCreate = 'CREATE TABLE ##tblRKDailyPositionForCustomer1 ([dtmDate] datetime NULL,'+@TempTableCreate +')'
IF OBJECT_ID('tempdb..##tblRKDailyPositionForCustomer1') IS NOT NULL
DROP TABLE ##tblRKDailyPositionForCustomer1
EXEC sp_executesql @TempTableCreate
DELETE FROM tblRKDailyPositionForCustomer

DECLARE @FinalResult TABLE
(intRowNum INT identity(1,1),
  dtmDate datetime
)
INSERT INTO @FinalResult
SELECT DISTINCT dtmDate FROM #tempCustomer  WHERE strDistribution IS NOT NULL

declare @mRowNumber1 int=0
declare @dtmDate1 datetime =''
declare @SQL1 nvarchar(max) =''

SELECT DISTINCT @mRowNumber1=Min(intRowNum) FROM @FinalResult  
WHILE @mRowNumber1 > 0
BEGIN
	DECLARE @strCumulativeNum NVARCHAR(MAX)=''
	DECLARE @intColumn_Id INT
	DECLARE @Type nvarchar(max) =''
	SELECT @dtmDate1=dtmDate FROM @FinalResult WHERE intRowNum=@mRowNumber1
	
		SET @SQL1 =''
		DECLARE @intCount int =0
		SELECT @intCount=min(intRowNum) FROM #tempCustomer WHERE CONVERT(DATETIME,CONVERT(VARCHAR(10),dtmDate,110))= convert(datetime,CONVERT(VARCHAR(10),@dtmDate1,110))
		WHILE @intCount > 0
		BEGIN

		select @Type=strDistribution from #tempCustomer where CONVERT(DATETIME,CONVERT(VARCHAR(10),dtmDate,110))= convert(datetime,CONVERT(VARCHAR(10),@dtmDate1,110)) and intRowNum=@intCount
		SET @SQL1 = @SQL1+'(SELECT strDistribution as '''+convert(nvarchar(100),@Type)+'_strDistribution'+''', dblIn as '''+convert(nvarchar(100),@Type)+'_In'+''',dblOut as '''+convert(nvarchar(100),@Type)+'_Out'+''',dblNet as '''+convert(nvarchar(100),@Type)+'_Net'+''' FROM #tempCustomer WHERE intRowNum= ' + convert(nvarchar,@intCount) +') t' + convert(nvarchar(100),@intCount) + ' CROSS JOIN'
		
		SELECT @intCount = MIN(intRowNum) FROM #tempCustomer WHERE intRowNum > @intCount and CONVERT(DATETIME,CONVERT(VARCHAR(10),dtmDate,110))= convert(datetime,CONVERT(VARCHAR(10),@dtmDate1,110))
		END

		IF LEN(@SQL1)>0
		BEGIN
		IF OBJECT_ID('tempdb..##tempRunTime') IS NOT NULL
	    DROP TABLE ##tempRunTime
		SET @SQL1=' SELECT  @dtmDate1 dtmDate,* into ##tempRunTime FROM '+case when LEN(@SQL1)>0 then LEFT(@SQL1,LEN(@SQL1)-11) else @SQL1 end 
		EXEC sp_executesql @SQL1,N'@dtmDate1 DATETIME',@dtmDate1
	
				SELECT @intColumn_Id=min(column_id) from tempdb.sys.columns where object_id = object_id('tempdb..##tempRunTime')
				WHILE @intColumn_Id>0
				BEGIN
				 						
					SELECT @strCumulativeNum=@strCumulativeNum+'['+name+'],' from tempdb.sys.columns where object_id = object_id('tempdb..##tempRunTime') AND  column_id=@intColumn_Id				
				SELECT @intColumn_Id=min(column_id) from tempdb.sys.columns where object_id =object_id('tempdb..##tempRunTime') and column_id>@intColumn_Id
				END
	IF LEN(@strCumulativeNum) > 0
	BEGIN
				SELECT @strCumulativeNum= case when LEN(@strCumulativeNum)>0 then LEFT(@strCumulativeNum,LEN(@strCumulativeNum)-1) else @strCumulativeNum end   

		DECLARE @Seq NVARCHAR(MAX)=''
		SET @Seq = @Seq+'INSERT INTO ##tblRKDailyPositionForCustomer1 ('+@strCumulativeNum+')  SELECT '+@strCumulativeNum+' from ##tempRunTime'
 		EXEC sp_executesql @Seq

	END
END

SELECT @mRowNumber1 = MIN(intRowNum) FROM @FinalResult	WHERE intRowNum > @mRowNumber1
END

DECLARE @intColumn_Id1  int
DECLARE @strInsertList NVARCHAR(MAX)=''
declare @strPermtableList NVARCHAR(MAX)=''
declare @intColCount int
declare @SQLFinal nvarchar(max)=''

select @strInsertList+='['+name+'],' from tempdb.sys.columns where object_id =object_id('tempdb..##tblRKDailyPositionForCustomer1') 
select @intColCount=count(name) from tempdb.sys.columns where object_id =object_id('tempdb..##tblRKDailyPositionForCustomer1') 
SELECT @strInsertList=  case when LEN(@strInsertList)>0 then LEFT(@strInsertList,LEN(@strInsertList)-1) else @strInsertList end  

select @strPermtableList+='['+COLUMN_NAME+'],' from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME ='tblRKDailyPositionForCustomer' and ORDINAL_POSITION<=@intColCount
SELECT @strPermtableList= LEFT(@strPermtableList,LEN(@strPermtableList)-1)  
set @SQLFinal='
INSERT INTO tblRKDailyPositionForCustomer ('+@strPermtableList+')
SELECT  '+@strInsertList+'
FROM ##tblRKDailyPositionForCustomer1 t order by dtmDate'

EXEC sp_executesql @SQLFinal
