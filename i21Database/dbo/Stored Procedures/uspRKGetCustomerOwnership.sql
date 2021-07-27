﻿CREATE PROC [dbo].[uspRKGetCustomerOwnership]
       @dtmFromTransactionDate date = null,
	   @dtmToTransactionDate date = null,
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
IF OBJECT_ID('tempdb..#LicensedLocation') IS NOT NULL
	DROP TABLE #LicensedLocation

DECLARE @ysnDisplayAllStorage bit
select @ysnDisplayAllStorage= isnull(ysnDisplayAllStorage,0) from tblRKCompanyPreference

DECLARE @intCommodityUnitMeasureId AS INT
		, @intCommodityStockUOMId INT
SELECT @intCommodityUnitMeasureId = intCommodityUnitMeasureId
		,@intCommodityStockUOMId = intUnitMeasureId
FROM tblICCommodityUnitMeasure
WHERE intCommodityId = @intCommodityId AND ysnStockUnit = 1

SELECT intCompanyLocationId
	INTO #LicensedLocation
	FROM tblSMCompanyLocation
	WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'Licensed Storage' THEN 1 
										WHEN @strPositionIncludes = 'Non-licensed Storage' THEN 0 ELSE isnull(ysnLicensed, 0) END

SELECT
	intRowNum = ROW_NUMBER() OVER (ORDER BY strDistributionType)
	,dtmDate
	,strDistribution = strDistributionType
	,dblIn = SUM(dblIn)
	,dblOut = SUM(dblOut)
	,dblNet = SUM(dblIn) - SUM(dblOut)
	,intStorageScheduleTypeId 
INTO #tempCustomer
FROM (
	select
		dtmDate = CONVERT(VARCHAR(10),dtmTransactionDate,110)
		, strDistributionType
		, dblIn = CASE WHEN dblTotal > 0 THEN dbo.fnCTConvertQuantityToTargetCommodityUOM(intOrigUOMId,@intCommodityUnitMeasureId,dblTotal) ELSE 0 END
		, dblOut = CASE WHEN dblTotal < 0 THEN ABS(dbo.fnCTConvertQuantityToTargetCommodityUOM(intOrigUOMId,@intCommodityUnitMeasureId,dblTotal)) ELSE 0 END
		, ST.intStorageScheduleTypeId
	from dbo.fnRKGetBucketCustomerOwned(@dtmToTransactionDate,@intCommodityId,NULL) CusOwn
	left join tblGRStorageType ST ON ST.strStorageTypeDescription = CusOwn.strDistributionType
	where CusOwn.intItemId = ISNULL(@intItemId, CusOwn.intItemId)
		and CusOwn.intLocationId = ISNULL(@intLocationId, CusOwn.intLocationId)
		and CusOwn.intLocationId IN (SELECT intCompanyLocationId FROM #LicensedLocation)
	
	union all
	select
		dtmDate = CONVERT(VARCHAR(10),dtmCreatedDate,110)
		, strDistributionType
		, dblIn = CASE WHEN dblTotal > 0 THEN dbo.fnCTConvertQuantityToTargetCommodityUOM(intOrigUOMId,@intCommodityUnitMeasureId,dblTotal) ELSE 0 END
		, dblOut = CASE WHEN dblTotal < 0 THEN ABS(dbo.fnCTConvertQuantityToTargetCommodityUOM(intOrigUOMId,@intCommodityUnitMeasureId,dblTotal)) ELSE 0 END
		, intStorageScheduleTypeId = 2
	from dbo.fnRKGetBucketDelayedPricing(@dtmToTransactionDate,@intCommodityId,NULL) OH
	where OH.intItemId = ISNULL(@intItemId, OH.intItemId)
		and OH.intLocationId = ISNULL(@intLocationId, OH.intLocationId)
		and OH.intLocationId IN (SELECT intCompanyLocationId FROM #LicensedLocation)

	union all
	select
		dtmDate = CONVERT(VARCHAR(10),dtmTransactionDate,110)
		, strDistributionType
		, dblIn = CASE WHEN dblTotal > 0 THEN dbo.fnCTConvertQuantityToTargetCommodityUOM(intOrigUOMId,@intCommodityUnitMeasureId,dblTotal) ELSE 0 END
		, dblOut = CASE WHEN dblTotal < 0 THEN ABS(dbo.fnCTConvertQuantityToTargetCommodityUOM(intOrigUOMId,@intCommodityUnitMeasureId,dblTotal)) ELSE 0 END
		, intStorageScheduleTypeId = -5
	from dbo.fnRKGetBucketOnHold(@dtmToTransactionDate,@intCommodityId,NULL) OH
	where OH.intItemId = ISNULL(@intItemId, OH.intItemId)
		and OH.intLocationId = ISNULL(@intLocationId, OH.intLocationId)
		and OH.intLocationId IN (SELECT intCompanyLocationId FROM #LicensedLocation)
) t
GROUP BY
	dtmDate
	,strDistributionType
	,intStorageScheduleTypeId




IF (@ysnDisplayAllStorage=1)
BEGIN			 
	declare @intRowNumber int
	SELECT TOP 1 @intRowNumber=intRowNum FROM #tempCustomer order by intRowNum desc
	INSERT INTO #tempCustomer (intRowNum,dtmDate,strDistribution,dblIn,dblOut,dblNet,intStorageScheduleTypeId)
		SELECT CONVERT(INT,ROW_NUMBER() OVER (ORDER BY strStorageTypeDescription))+isnull(@intRowNumber,0),CONVERT(VARCHAR(10),@dtmToTransactionDate,110),strStorageTypeDescription,0.0,0.0,0.0,intStorageScheduleTypeId
		FROM tblGRStorageScheduleRule SSR 
		INNER JOIN tblGRStorageType  ST ON SSR.intStorageType = ST.intStorageScheduleTypeId 
		WHERE SSR.intCommodity = @intCommodityId AND ISNULL(ysnActive,0) = 1 AND intStorageScheduleTypeId > 0 AND intStorageScheduleTypeId not in(SELECT DISTINCT intStorageScheduleTypeId FROM #tempCustomer)
		GROUP BY strStorageTypeDescription,intStorageScheduleTypeId
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
DECLARE @strInsertListBF NVARCHAR(MAX)='' --For Balance Forward
DECLARE @strInsertListBFGroupBy NVARCHAR(MAX) = ''
declare @strPermtableListBF NVARCHAR(MAX)=''
declare @intColCount int
declare @SQLBalanceForward nvarchar(max)=''
declare @SQLFinal nvarchar(max)=''

select @strInsertListBF += CASE WHEN name like '%Distribution%' THEN '['+ name +'],' ELSE 'SUM(ISNULL(['+ name +'],0)),' END from tempdb.sys.columns where object_id =object_id('tempdb..##tblRKDailyPositionForCustomer1') and  (name like '%_Net' or name like '%Distribution%') ORDER BY column_id
SELECT @strInsertListBF=  case when LEN(@strInsertListBF)>0 then LEFT(@strInsertListBF,LEN(@strInsertListBF)-1) else @strInsertListBF end  --Remove the comma at the end

select @strInsertListBFGroupBy += '['+ name +'],'  from tempdb.sys.columns where object_id =object_id('tempdb..##tblRKDailyPositionForCustomer1') and   name like '%Distribution%'  ORDER BY column_id
SELECT @strInsertListBFGroupBy=  case when LEN(@strInsertListBFGroupBy)>0 then LEFT(@strInsertListBFGroupBy,LEN(@strInsertListBFGroupBy)-1) else @strInsertListBFGroupBy end  --Remove the comma at the end


select @strInsertList+='['+name+'],' from tempdb.sys.columns where object_id =object_id('tempdb..##tblRKDailyPositionForCustomer1')   ORDER BY column_id
select @intColCount=count(name) from tempdb.sys.columns where object_id =object_id('tempdb..##tblRKDailyPositionForCustomer1') 
SELECT @strInsertList=  case when LEN(@strInsertList)>0 then LEFT(@strInsertList,LEN(@strInsertList)-1) else @strInsertList end  --Remove the comma at the end


select @strPermtableList+='['+COLUMN_NAME+'],' from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME ='tblRKDailyPositionForCustomer' and ORDINAL_POSITION<=@intColCount ORDER BY ORDINAL_POSITION ASC
SELECT @strPermtableList= LEFT(@strPermtableList,LEN(@strPermtableList)-1)  

select @strPermtableListBF+='['+COLUMN_NAME+'],' from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME ='tblRKDailyPositionForCustomer' and ORDINAL_POSITION<=@intColCount and ( COLUMN_NAME like '%Net' OR COLUMN_NAME like '%Distribution%')  ORDER BY ORDINAL_POSITION ASC

SELECT @strPermtableListBF= CASE WHEN LEN(@strPermtableListBF) = 0 THEN '' ELSE LEFT(@strPermtableListBF,LEN(@strPermtableListBF)-1)  END


IF LEN(@strPermtableListBF) <> 0 
BEGIN
	set @SQLBalanceForward='
	INSERT INTO tblRKDailyPositionForCustomer ('+@strPermtableListBF+')
	SELECT  '+@strInsertListBF+'
	FROM ##tblRKDailyPositionForCustomer1 t 
	WHERE dtmDate < ''' + CONVERT(VARCHAR(10),@dtmFromTransactionDate,110) + '''
	GROUP BY ' + @strInsertListBFGroupBy + '
	'

	EXEC sp_executesql @SQLBalanceForward
END

set @SQLFinal='
INSERT INTO tblRKDailyPositionForCustomer ('+@strPermtableList+')
SELECT  '+@strInsertList+'
FROM ##tblRKDailyPositionForCustomer1 t 
WHERE dtmDate between ''' + CONVERT(VARCHAR(10),@dtmFromTransactionDate,110) +''' AND ''' + CONVERT(VARCHAR(10),@dtmToTransactionDate,110) +'''
order by dtmDate'

EXEC sp_executesql @SQLFinal
