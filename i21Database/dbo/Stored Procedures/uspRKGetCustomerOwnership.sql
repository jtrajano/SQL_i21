CREATE PROC [dbo].[uspRKGetCustomerOwnership]
       @dtmFromTransactionDate datetime = null,
	   @dtmToTransactionDate datetime = null,
	   @intCommodityId int =  null,
	   @intItemId int= null
AS

SELECT  CONVERT(INT,ROW_NUMBER() OVER (ORDER BY strStorageTypeDescription)) intRowNum,dtmDate,strStorageTypeDescription strDistribution,dblIn,dblOut,dblNet into #tempCustomer FROM (
  SELECT dtmDate,strStorageTypeDescription,0.0 dblIn,0.0 dblOut,sum(dblInQty)-sum(dblOutQty) dblNet 
   FROM(			
		SELECT '1900-01-01' dtmDate,strStorageTypeDescription,CASE WHEN strInOutFlag='I' THEN dblNetUnits ELSE 0 END dblInQty,
													  CASE WHEN strInOutFlag='O' THEN dblNetUnits ELSE 0 END dblOutQty  
		FROM tblSCTicket st
		JOIN tblICItem i on i.intItemId=st.intItemId 
		JOIN tblGRStorageType gs on gs.intStorageScheduleTypeId=st.intStorageScheduleTypeId 
		WHERE CONVERT(DATETIME,CONVERT(VARCHAR(10),st.dtmTicketDateTime,110),110)	< convert(datetime,CONVERT(VARCHAR(10),@dtmFromTransactionDate,110),110) and i.intCommodityId= @intCommodityId
		AND i.intItemId= CASE WHEN ISNULL(@intItemId,0)=0 then i.intItemId else @intItemId end and isnull(strType,'') <> 'Other Charge'
		AND gs.intStorageScheduleTypeId > 0 and gs.strOwnedPhysicalStock='Customer'
)t     GROUP BY  strStorageTypeDescription,dtmDate

 UNION

   SELECT dtmDate,strStorageTypeDescription,sum(dblInQty) dblIn,sum(dblOutQty) dblOut,sum(dblInQty)-sum(dblOutQty) dblNet FROM(			
		SELECT CONVERT(VARCHAR(10),st.dtmTicketDateTime,110) dtmDate,strStorageTypeDescription,	CASE WHEN strInOutFlag='I' THEN dblNetUnits ELSE 0 END dblInQty,
																								CASE WHEN strInOutFlag='O' THEN dblNetUnits ELSE 0 END dblOutQty  				
		FROM tblSCTicket st
		JOIN tblICItem i on i.intItemId=st.intItemId 
		JOIN tblGRStorageType gs on gs.intStorageScheduleTypeId=st.intStorageScheduleTypeId 
		WHERE convert(datetime,CONVERT(VARCHAR(10),st.dtmTicketDateTime,110),110) BETWEEN
		 convert(datetime,CONVERT(VARCHAR(10),@dtmFromTransactionDate,110),110) AND convert(datetime,CONVERT(VARCHAR(10),@dtmToTransactionDate,110),110)
		AND i.intCommodityId= @intCommodityId
		and i.intItemId= case when isnull(@intItemId,0)=0 then i.intItemId else @intItemId end and isnull(strType,'') <> 'Other Charge'
		and  gs.intStorageScheduleTypeId > 0 and gs.strOwnedPhysicalStock='Customer'
		  )t     GROUP BY  dtmDate,strStorageTypeDescription
) t1

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
	DECLARE @strInsertList NVARCHAR(MAX)=''
	DECLARE @intColumn_Id INT
	SELECT @dtmDate1=dtmDate FROM @FinalResult WHERE intRowNum=@mRowNumber1

		SET @SQL1 =''
		DECLARE @intCount int =0
		SELECT @intCount=min(intRowNum) FROM #tempCustomer WHERE CONVERT(DATETIME,CONVERT(VARCHAR(10),dtmDate,110))= convert(datetime,CONVERT(VARCHAR(10),@dtmDate1,110))
		WHILE @intCount > 0
		BEGIN
		SET @SQL1 = @SQL1+'(SELECT strDistribution as '''+convert(nvarchar(100),@intCount)+'-strDistribution'+''', dblIn as '''+convert(nvarchar(100),@intCount)+'-In'+''',dblOut as '''+convert(nvarchar(100),@intCount)+'-Out'+''',dblNet as '''+convert(nvarchar(100),@intCount)+'-Net'+''' FROM #tempCustomer WHERE intRowNum= ' + convert(nvarchar,@intCount) +') t' + convert(nvarchar(100),@intCount) + ' CROSS JOIN'
		SELECT @intCount = MIN(intRowNum) FROM #tempCustomer WHERE intRowNum > @intCount and CONVERT(DATETIME,CONVERT(VARCHAR(10),dtmDate,110))= convert(datetime,CONVERT(VARCHAR(10),@dtmDate1,110))
		END

		IF LEN(@SQL1)>0
		BEGIN
		IF OBJECT_ID('tempdb..##tempRunTime') IS NOT NULL
	    DROP TABLE ##tempRunTime
		SET @SQL1=' SELECT  @dtmDate1 dtmDate,* into ##tempRunTime  FROM '+LEFT(@SQL1,LEN(@SQL1)-11)
		EXEC sp_executesql @SQL1,N'@dtmDate1 DATETIME',@dtmDate1

				SELECT @intColumn_Id=min(column_id) from tempdb.sys.columns where object_id = object_id('tempdb..##tempRunTime')
				WHILE @intColumn_Id>0
				BEGIN							
					SELECT @strCumulativeNum=@strCumulativeNum+'['+name+'],' from tempdb.sys.columns where object_id = object_id('tempdb..##tempRunTime') AND  column_id=@intColumn_Id
					SELECT @strInsertList=@strInsertList+'['+COLUMN_NAME+'],' from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME ='tblRKDailyPositionForCustomer' AND  ORDINAL_POSITION=@intColumn_Id
				SELECT @intColumn_Id=min(column_id) from tempdb.sys.columns where object_id =object_id('tempdb..##tempRunTime') and column_id>@intColumn_Id
				END
	IF LEN(@strCumulativeNum) > 0
	BEGIN
				SELECT @strCumulativeNum= LEFT(@strCumulativeNum,LEN(@strCumulativeNum)-1)  	
				SELECT @strInsertList=LEFT(@strInsertList,LEN(@strInsertList)-1)  
		DECLARE @Seq NVARCHAR(MAX)=''
		SET @Seq = @Seq+'INSERT INTO tblRKDailyPositionForCustomer ('+@strInsertList+')  SELECT '+@strCumulativeNum+' from ##tempRunTime'
 		EXEC sp_executesql @Seq

	END
END

SELECT @mRowNumber1 = MIN(intRowNum) FROM @FinalResult	WHERE intRowNum > @mRowNumber1
END
