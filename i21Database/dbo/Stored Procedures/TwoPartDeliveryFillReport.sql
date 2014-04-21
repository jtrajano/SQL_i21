  
  
CREATE PROCEDURE [dbo].[TwoPartDeliveryFillReport] (@xmlParam NVARCHAR(MAX)=null)  
AS  
  
/*set @xmlparam = '<xmlparam><filters><filter><fieldname>strLocation</fieldname><condition>Between</condition><from /><to /><join>And</join><begingroup>0</begingroup><endgroup>0</endgroup><datatype>String</datatype></filter><filter><fieldname>strDriverID<
/fieldname><condition>Equal To</condition><from /><to /><join>And</join><begingroup>0</begingroup><endgroup>0</endgroup><datatype>String</datatype></filter><filter><fieldname>strRouteId</fieldname><condition>Between</condition><from /><to /><join>And</joi
n><begingroup>0</begingroup><endgroup>0</endgroup><datatype>String</datatype></filter><filter><fieldname>intNextDeliveryDegreeDay</fieldname><condition>Between</condition><from /><to /><join>And</join><begingroup>0</begingroup><endgroup>0</endgroup><datat
ype>Integer</datatype></filter><filter><fieldname>dtmNextDeliveryDate</fieldname><condition>Between</condition><from /><to /><join>And</join><begingroup>0</begingroup><endgroup>0</endgroup><datatype>String</datatype></filter><filter><fieldname>dtmRequeste
dDate</fieldname><condition>Between</condition><from /><to /><join>And</join><begingroup>0</begingroup><endgroup>0</endgroup><datatype>DateTime</datatype></filter><filter><fieldname>strFillMethod</fieldname><condition>Equal To</condition><from /><to /><jo
in>And</join><begingroup>0</begingroup><endgroup>0</endgroup><datatype>String</datatype></filter><filter><fieldname>dblQuantity</fieldname><condition>Between</condition><from /><to /><join>And</join><begingroup>0</begingroup><endgroup>0</endgroup><datatyp
e>Decimal</datatype></filter><filter><fieldname>dblEstimatedPercentLeft</fieldname><condition>Less Than Or Equal</condition><from /><to /><join>And</join><begingroup>0</begingroup><endgroup>0</endgroup><datatype>Decimal</datatype></filter><filter><fieldna
me>dtmForecastedDelivery</fieldname><condition>Between</condition><from /><to /><join>And</join><begingroup>0</begingroup><endgroup>0</endgroup><datatype>DateTime</datatype></filter><filter><fieldname>strProductID</fieldname><condition>Between</condition>
<from>2225</from><to>2225</to><join>And</join><begingroup>0</begingroup><endgroup>0</endgroup><datatype>String</datatype></filter></filters><options /></xmlparam>'  
*/  
 SET NOCOUNT ON  
 IF (ISNULL(@xmlParam,'') = '')  
 BEGIN  
 SELECT 0 as intCustomerID   
  ,0.0 as dblProductCost  
  ,'' as agcus_last_name   
  ,'' as agcus_first_name   
  ,'' as CustomerName   
  ,'' as agcus_phone  
  ,'' as agcus_key   
  ,'' as agcus_tax_state  
  ,0.0 as agcus_ar_per1   
  ,0 as agcus_cred_limit   
  ,0.0 as agcus_last_stmt_bal   
  ,0.0 as agcus_budget_amt_due   
  ,0.0 as agcus_ar_future  
  ,0 as agcus_prc_lvl  
  ,'' as TermDesc  
  ,0.0 as Credits   
  ,0.0 as TotalPast  
  ,0.0 as ARBalance   
  ,0.0 as dblPastCredit   
  ,0 as intSiteNumber   
  ,0.0 as dblLastDeliveredGal   
  ,'' as strSequenceID   
  ,0 as intLastDeliveryDegreeDay  
  ,'' as strSiteAddress   
  ,getdate() as dtmOnHoldEndDate   
  ,0 as ysnOnHold   
  ,'' as strHoldReason  
  ,'' as strOnHold  
  ,0 as intFillMethodId   
  ,'' as strCity   
  ,'' as strState   
  ,'' as strZipCode  
  ,'' as strComment  
  ,'' as strInstruction   
  ,0.0 as dblDegreeDayBetweenDelivery   
  ,0.0 as dblTotalCapacity  
  ,0.0 as dblTotalReserve  
  ,'' as strSiteDescription   
  ,0.0 as dblLastGalsInTank  
  ,getdate() as dtmLastDeliveryDate   
  ,'' as intSiteID   
  ,0.0 as dblEstimatedPercentLeft   
  ,getdate() as dtmNextDeliveryDate   
  ,0 as intNextDeliveryDegreeDay   
  ,'' as SiteLabel   
  ,'' as SiteDeliveryDD   
  ,0.0 as dblDailyUse   
  ,'' as strFillGroupCode   
  ,'' as strDescription   
  ,0 as ysnActive   
  ,0 as intFillGroupId   
  ,'' as strDriverName   
  ,'' as strDriverID   
  ,getdate() as dtmRequestedDate   
  ,0.0 as dblQuantity   
  ,'' as strProductID   
  ,'' as strProductDescription   
  ,'' as strFillMethod   
  ,'' as strRouteId   
  ,'' as strBetweenDlvry   
  ,'' as strLocation   
  , '' as strLine  
  , '' as strPagePart  
  ,getdate() as dtmForecastedDelivery   
 RETURN;  
 END    
  
 DECLARE @agcus_key AS VARCHAR(100)  
 DECLARE @intSiteNumber AS INT   
  
 DECLARE @agcus_phone AS VARCHAR(100)  
 DECLARE @CustomerName AS VARCHAR(500)  
 DECLARE @strProductID AS VARCHAR(100)  
 DECLARE @strProductDescription AS VARCHAR(500)  
 DECLARE @dblTotalCapacity AS NUMERIC(18,6)  
 DECLARE @dblTotalReserve AS NUMERIC(18,6)  
 DECLARE @dblProductCost AS NUMERIC(18,6)  
 DECLARE @strFillMethod AS VARCHAR(100)  
 DECLARE @TermDesc AS NVARCHAR(100)  
 DECLARE @RTE_SQID AS VARCHAR(100)  
 DECLARE @strRouteId AS VARCHAR (50)  
 DECLARE @strSequenceID AS VARCHAR (50)  
 DECLARE @strBetweenDlvry AS NVARCHAR(100)  
 DECLARE @dtmLastDeliveryDate AS DATETIME  
 DECLARE @intLastDeliveryDegreeDay AS INTEGER  
 DECLARE @dblLastDeliveredGal AS NUMERIC(18,6)  
 DECLARE @dtmForecastedDelivery AS DATETIME   
 DECLARE @strDriverID AS VARCHAR(100)  
 DECLARE @strDriverName AS VARCHAR(500)  
 DECLARE @dblDailyUse AS NUMERIC(18,6)  
 DECLARE @SiteLabel AS VARCHAR(100)  
 DECLARE @SiteDeliveryDD AS VARCHAR(100)  
 DECLARE @intNextDeliveryDegreeDay AS INTEGER  
 DECLARE @dblEstimatedPercentLeft AS NUMERIC(18, 6)  
 DECLARE @dblLastGalsInTank AS NUMERIC(18,6)  
 DECLARE @agcus_prc_lvl AS INTEGER  
 DECLARE @SiteAddress AS VARCHAR(500)  
 DECLARE @strLocation AS VARCHAR(100)  
 DECLARE @agcus_tax_state AS VARCHAR(100)  
 DECLARE @strSiteDescription AS VARCHAR(100)  
 DECLARE @agcus_cred_limit AS INTEGER   
 DECLARE @ARBalance AS NUMERIC(18,6)  
 DECLARE @agcus_ar_future AS NUMERIC(18,6)  
 DECLARE @agcus_ar_per1 AS NUMERIC(18,6)  
 DECLARE @TotalPast AS NUMERIC(18,6)  
 DECLARE @Credits AS NUMERIC(18,6)  
 DECLARE @strInstruction VARCHAR(2000)  
 DECLARE @strComment VARCHAR(2000)  
 DECLARE @idPhone AS VARCHAR(500)   
 DECLARE @FullName AS VARCHAR(500)  
 DECLARE @strFillGroupCode AS VARCHAR(100)   
 DECLARE @strHoldReason AS NVARCHAR(100)  
 DECLARE @strOnHold AS VARCHAR(20)    
  
 DECLARE @intCounter AS INT   
 SET @intCounter = 0   
   
 DECLARE @PageCounter AS INT  
 SET @PageCounter = 1  
   
 DECLARE @BlankLineNumber AS INT  
 SET @BlankLineNumber = 99999  
   
 DECLARE @BlankLine AS VARCHAR(MAX)  
 --SET @BlankLine = '<font face="courier new" size="1">1234567890 1234567890 1234567890 1234567890 1234567890 1234567890 1234567890 1234567890 1234567890 1234567890</font>'  
 SET @BlankLine = ''  
   
 DECLARE @Gaps AS VARCHAR(100)  
 SET @Gaps = '&#160;&#160;' -- This allots 2 spaces as gaps per header text and data. You can change this as needed.  
   
 DECLARE @HalfPageLimit AS INT  
 SET @HalfPageLimit = 7 -- If you change this, make sure you update the TOP clause used in inserting the blank lines.   
   
 DECLARE @GapAfterHalfPage AS INT  
 SET @GapAfterHalfPage = 4  
   
 -- This is the number of lines we can fit in one full page without the group header data.   
 -- This is used for overflows.   
 DECLARE @FullPageLimit AS INT  
 SET @FullPageLimit = 16  
  
 DECLARE @BlankLimitSuppressor AS BIT  
 SET @BlankLimitSuppressor = 0   
   
 DECLARE @WhereClause as nvarchar(max) = ''  
  
 IF EXISTS(SELECT * FROM tempdb.dbo.sysobjects WHERE ID = OBJECT_ID(N'tempdb..#tmpLoopQuery')) BEGIN DROP TABLE #tmpLoopQuery END  
 IF EXISTS(SELECT * FROM tempdb.dbo.sysobjects WHERE ID = OBJECT_ID(N'tempdb..#tmpDetailToCut')) BEGIN DROP TABLE #tmpDetailToCut END  
 IF EXISTS(SELECT * FROM tempdb.dbo.sysobjects WHERE ID = OBJECT_ID(N'tempdb..#tmpResult')) BEGIN DROP TABLE #tmpResult END  
 IF EXISTS(SELECT * FROM tempdb.dbo.sysobjects WHERE ID = OBJECT_ID(N'tempdb..#tmpResultClone')) BEGIN DROP TABLE #tmpResultClone END  
   
   
  
   
 --Building the parameters  
 DECLARE @idoc int,  
   @FromLocation nvarchar(50),@ToLocation nvarchar(50),  
   @FromDriverID nvarchar(50),@ToDriverID nvarchar(50),  
   @FromProductID nvarchar(50),@ToProductID nvarchar(50),  
   @FromRouteID nvarchar(50),@ToRouteID nvarchar(50),  
   @FromFillMethod nvarchar(50),  
   @FromQuantity nvarchar(50),@ToQuantity nvarchar(50),  
   @FromForecastedDelivery nvarchar(50),@ToForecastedDelivery nvarchar(50),  
   @FromNextDelivery nvarchar(50),@ToNextDelivery nvarchar(50),  
   @FromRequestedDate nvarchar(50),@ToRequestedDate nvarchar(50),  
   @FromEstimatedPercent nvarchar(50),@ToEstimatedPercent nvarchar(50),  
   @FromJulianDelivery nvarchar(50), @ToJulianDelivery nvarchar(50),@EstimatedPercentCondition nvarchar(50)  
   
  --Variables for Design Parameters  
  DECLARE @TankInfo as nvarchar(50)  
  DECLARE @CustomerContract as nvarchar(50)   
  DECLARE @RegulatorInfo as nvarchar(50)  
  DECLARE @FillGroup as nvarchar(50)  
  DECLARE @OnHold as nvarchar(50)  
  DECLARE @ListTotals as nvarchar(50)  
    
 exec sp_xml_preparedocument @idoc output, @xmlParam  
  --For Filter  
   DECLARE @temp_params table ([fieldname] nvarchar(50)  
     , [condition] nvarchar(20)        
     , [from] nvarchar(50)  
     , [to] nvarchar(50)  
     , [join] nvarchar(10)  
     , [begingroup] nvarchar(50)  
     , [endgroup] nvarchar(50)  
     , [datatype] nvarchar(50))  
              
      insert into @temp_params  
      select *  
      from openxml(@idoc, 'xmlparam/filters/filter',2)  
      with ([fieldname] nvarchar(50)  
            , [condition] nvarchar(20)  
            , [from] nvarchar(50)  
            , [to] nvarchar(50)  
            , [join] nvarchar(10)  
            , [begingroup] nvarchar(50)  
            , [endgroup] nvarchar(50)  
            , [datatype] nvarchar(50))  
   

 --For Design Parameter  
 DECLARE @temp_designParam table ([name] nvarchar(max),[enable] nvarchar(10))  
   
 INSERT INTO @temp_designParam  
    SELECT *  
 FROM OPENXML(@idoc,'xmlparam/options/option',2)   
 WITH ([name] nvarchar(50),[enable] nvarchar(10))  
   
 --select * from @temp_params  --FOR DEBUGGING  
   
 --Assigning values to variables  
  
 --Location  
 SELECT @FromLocation = [from]  
    ,@ToLocation = [to]  
 FROM @temp_params where [fieldname] = 'strLocation'  
   
 --DriverID  
 SELECT @FromDriverID = [from]  
    ,@ToDriverID = [to]  
 FROM @temp_params where [fieldname] = 'strDriverID'  
   
 --ProductID  
 SELECT @FromProductID = [from]  
    ,@ToProductID = [to]  
 FROM @temp_params where [fieldname] = 'strProductID'   
   
 --RouteID  
 SELECT @FromRouteID = [from]  
    ,@ToRouteID = [to]  
 FROM @temp_params where [fieldname] = 'strRouteId'  
   
 --FillMethod  
 SELECT @FromFillMethod = [from]  
 FROM @temp_params where [fieldname] = 'strFillMethod'  
   
 --Quantity  
 SELECT @FromQuantity = [from]  
    ,@ToQuantity = [to]  
 FROM @temp_params where [fieldname] = 'dblQuantity'      
   
 --ForecastedDelivery  
 SELECT @FromForecastedDelivery = [from]  
    ,@ToForecastedDelivery = [to]  
 FROM @temp_params where [fieldname] = 'dtmForecastedDelivery'   
   
 --NextDelivery  
 SELECT @FromNextDelivery = [from]  
    ,@ToNextDelivery = [to]  
 FROM @temp_params where [fieldname] = 'intNextDeliveryDegreeDay'   
  
 --RequestDate  
 SELECT @FromRequestedDate = [from]  
    ,@ToRequestedDate = [to]  
 FROM @temp_params where [fieldname] = 'dtmRequestedDate'   
   
 --Quantity  
 SELECT @FromEstimatedPercent = [from]  
    ,@ToEstimatedPercent = [to]  
    ,@EstimatedPercentCondition = condition  
 FROM @temp_params where [fieldname] = 'dblEstimatedPercentLeft'   
  
 --NextJulianDelivery  
 SELECT @FromJulianDelivery = [from]  
    ,@ToJulianDelivery = [to]  
 FROM @temp_params where [fieldname] = 'dtmNextDeliveryDate'   

 --List Totals  
 SELECT @ListTotals = [enable] FROM @temp_designParam WHERE [name] = 'List Totals Only'  
   
 --Tank Info  
 SELECT @TankInfo = [enable] FROM @temp_designParam WHERE [name] = 'Print Tank Info'  
  
 --Customer Contracts  
 SELECT @CustomerContract = [enable] FROM @temp_designParam WHERE [name] = 'Print Contracts'   
   
 --Regulator Info  
 SELECT @RegulatorInfo = [enable] FROM @temp_designParam WHERE [name] = 'Print Regulator Info'  
   
 --Fill Group  
 SELECT @FillGroup = [enable] FROM @temp_designParam WHERE [name] = 'Include Consumption Site on the same Fill Group'  
   
 --On Hold  
 SELECT @OnHold = [enable] FROM @temp_designParam WHERE [name] = 'Include Consumption Sites On Hold'  
   
 --Building the where clause  
   
 --strLocation  
 IF (ISNULL(@FromLocation,'') != '')  
 BEGIN SET @WhereClause = @WhereClause + ' AND strLocation BETWEEN ''' + @FromLocation + ''' AND ''' + @ToLocation + '''' END  
   
 --strDriverID  
 IF (ISNULL(@FromDriverID,'') != '')  
 BEGIN SET @WhereClause = @WhereClause + ' AND strDriverID BETWEEN ''' + @FromDriverID + ''' AND ''' + @ToDriverID + '''' END  
    
 --strProductID  
 IF (ISNULL(@FromProductID,'') != '')  
 BEGIN SET @WhereClause = @WhereClause + ' AND strProductID BETWEEN ''' + @FromProductID + ''' AND ''' + @ToProductID + '''' END  
   
 --strRouteID  
 IF (ISNULL(@FromRouteID,'') != '')  
 BEGIN SET @WhereClause = @WhereClause + ' AND strRouteId BETWEEN ''' + @FromRouteID + ''' AND ''' + @ToRouteID + '''' END  
  
 --strFillMethod  
 IF (ISNULL(@FromFillMethod,'') != '')  
 BEGIN SET @WhereClause = @WhereClause + ' AND strFillMethod = ''' + @FromFillMethod + ''' ' END  
   
 --intNextDeliveryDegreeDay  
 IF (ISNULL(@FromNextDelivery,'') != '')  
 BEGIN SET @WhereClause = @WhereClause + ' AND intNextDeliveryDegreeDay BETWEEN ' + @FromNextDelivery + ' AND ' + @ToNextDelivery + ' ' END  
   
 --dtmNextDeliveryDate  
 IF (ISNULL(@FromJulianDelivery,'') != '')  
 BEGIN SET @WhereClause = @WhereClause + ' AND dtmNextDeliveryDate BETWEEN ''' + @FromJulianDelivery + ''' AND ''' + @ToJulianDelivery + '''' END     
   
 --dtmRequestedDate  
 IF (ISNULL(@FromRequestedDate,'') != '')  
 BEGIN SET @WhereClause = @WhereClause + ' AND dtmRequestedDate BETWEEN ''' + @FromRequestedDate + ''' AND ''' + @ToRequestedDate + '''' END     
  
 --dblQuantity  
 IF (ISNULL(@FromQuantity,'') != '')  
 BEGIN SET @WhereClause = @WhereClause + ' AND dblQuantity BETWEEN ' + @FromQuantity + ' AND ' + @ToQuantity + ' ' END     
   
 --dtmForecastedDelivery  
 IF (ISNULL(@FromForecastedDelivery,'') != '')  
 BEGIN SET @WhereClause = @WhereClause + ' AND dtmForecastedDelivery BETWEEN ''' + @FromForecastedDelivery + ''' AND ''' + @ToForecastedDelivery + '''' END     
   
 --dblEstimatedPercentLeft  
 IF (ISNULL(@FromEstimatedPercent,'') != '' AND @EstimatedPercentCondition = 'Between')  
 BEGIN SET @WhereClause = @WhereClause + ' AND dblEstimatedPercentLeft BETWEEN ' + @FromEstimatedPercent + ' AND ' + @ToEstimatedPercent + ' ' END     
 IF ISNULL(@FromEstimatedPercent,'') != '' AND @EstimatedPercentCondition = 'Less Than Or Equal'  
 BEGIN SET @WhereClause = @WhereClause + ' AND dblEstimatedPercentLeft <= ' + @FromEstimatedPercent END  
   
 --On Hold  
 IF @OnHold = 'False'  
 BEGIN SET @WhereClause = @WhereClause + ' AND NOT(ysnOnHold = 1 AND dtmOnHoldEndDate > GetDate()) AND NOT(ysnOnHold = 1 AND dtmOnHoldEndDate IS NULL) OR ysnOnHold IS NULL' END  
   
 --Building the main query  
   
 DECLARE @DeliveryFillTable  table  
 (  
  intCustomerID int  
  ,dblProductCost numeric(18,6)-- 9   
  ,agcus_last_name nvarchar(max)  
  ,agcus_first_name nvarchar(max)  
  ,CustomerName nvarchar(100)-- 3  
  ,agcus_phone varchar(50)-- 2  
  ,agcus_key nvarchar(20)-- 1 PK  
  ,agcus_tax_state varchar(100)-- 28  
  ,agcus_ar_per1 numeric(18,6)-- 33  
  ,agcus_cred_limit int-- 30  
  ,agcus_last_stmt_bal decimal  
  ,agcus_budget_amt_due decimal  
  ,agcus_ar_future numeric(18,6)-- 32  
  ,agcus_prc_lvl int-- 25  
  ,TermDesc nvarchar(max)-- 11  
  ,Credits numeric(18,6)-- 35  
  ,TotalPast numeric(18,6)-- 34  
  ,ARBalance numeric(18,6)-- 31  
  ,dblPastCredit numeric(18,6)  
  ,intSiteNumber int-- 6  PK  
  ,dblLastDeliveredGal numeric(18,6)-- 16  
  ,strSequenceID nvarchar(50)  
  ,intLastDeliveryDegreeDay int-- 15  
  ,strSiteAddress nvarchar(100)  
  ,dtmOnHoldEndDate DateTime --50  
  ,ysnOnHold bit  
  ,strHoldReason nvarchar(100)  
  ,strOnHold nvarchar(20)  
  ,intFillMethodId int  
  ,strCity nvarchar(50)  
  ,strState nvarchar(50)  
  ,strZipCode nvarchar(50)-- 26  
  ,strComment nvarchar(max)-- 37  
  ,strInstruction nvarchar(max)-- 36  
  ,dblDegreeDayBetweenDelivery decimal(18,6)  
  ,dblTotalCapacity numeric(18,6)-- 7   
  ,dblTotalReserve numeric(18,6)-- 8   
  ,strSiteDescription nvarchar(max)-- 29  
  ,dblLastGalsInTank numeric(18,6)-- 24  
  ,dtmLastDeliveryDate DateTime-- 14  
  ,intSiteID int  
  ,dblEstimatedPercentLeft numeric(18,6)-- 23  
  ,dtmNextDeliveryDate DateTime  
  ,intNextDeliveryDegreeDay int-- 22  
  ,SiteLabel varchar(50)-- 21  
  ,SiteDeliveryDD nvarchar(50)  
  ,dblDailyUse numeric(18,6)-- 20  
  ,strFillGroupCode nvarchar(50)  
  ,strDescription nvarchar(100)  
  ,ysnActive varchar(10)  
  ,intFillGroupId int  
  ,strDriverName nvarchar(100)-- 19  
  ,strDriverID nvarchar(50)-- 18  
  ,dtmRequestedDate DateTime  
  ,dblQuantity numeric(18,6)  
  ,strProductID nvarchar(50)-- 4  
  ,strProductDescription nvarchar(max)-- 5  
  ,strRouteId nvarchar(50)  
  ,strFillMethod nvarchar(max)-- 10   
  ,strBetweenDlvry NVARCHAR(100)-- 13  
  ,strLocation nvarchar(50)-- 27  
  ,dtmForecastedDelivery DateTime-- 17  
   
 )  
   
 DECLARE @Query as nvarchar(max) = ''  
   
 SET @Query = 'SELECT A.intCustomerID  
     ,dblProductCost =   
      ISNULL((CASE B.vwcus_prc_lvl  
       WHEN 1 THEN  
        G.vwitm_un_prc1  
       WHEN 2 THEN  
        G.vwitm_un_prc2  
       WHEN 3 THEN  
        G.vwitm_un_prc3  
       WHEN 4 THEN  
        G.vwitm_un_prc4  
       WHEN 5 THEN  
        G.vwitm_un_prc5  
       WHEN 6 THEN  
        G.vwitm_un_prc6  
       WHEN 7 THEN  
        G.vwitm_un_prc7  
       WHEN 8 THEN  
        G.vwitm_un_prc8  
       WHEN 9 THEN  
        G.vwitm_un_prc9  
      END),0)   
     ,agcus_last_name = RTRIM(LTRIM(B.vwcus_last_name))   
     ,agcus_first_name = rtrim(ltrim(B.vwcus_first_name))   
     ,(CASE WHEN B.vwcus_first_name IS NULL OR B.vwcus_first_name = ''''  THEN RTRIM(B.vwcus_last_name) ELSE RTRIM(B.vwcus_last_name) + '', '' + RTRIM(B.vwcus_first_name) END) as CustomerName  
     ,agcus_phone = B.vwcus_phone   
     ,agcus_key = B.vwcus_key   
     ,agcus_tax_state = B.vwcus_tax_state   
     ,agcus_ar_per1 = B.vwcus_ar_per1   
     ,agcus_cred_limit = B.vwcus_cred_limit   
     ,agcus_last_stmt_bal = B.vwcus_last_stmt_bal   
     ,agcus_budget_amt_due = B.vwcus_budget_amt_due   
     ,agcus_ar_future = B.vwcus_ar_future   
     ,agcus_prc_lvl = B.vwcus_prc_lvl  
     ,(Case  (Select ysnUseDeliveryTermOnCS From tblTMPreferenceCompany)  when 0 then   
      Cast(B.vwcus_terms_cd as nvarchar(5))+ '' - '' + (Select vwtrm_desc from vwtrmmst where vwtrm_key_n = B.vwcus_terms_cd)  
      when 1 then   
      Cast(C.intDeliveryTermID as nvarchar(5))+ '' - '' + (Select vwtrm_desc from vwtrmmst where vwtrm_key_n = C.intDeliveryTermID)  
      end) as TermDesc   
     ,Credits = (B.vwcus_cred_reg + B.vwcus_cred_ppd + B.vwcus_cred_ga)   
     ,TotalPast = (B.vwcus_ar_per2 + B.vwcus_ar_per3 + B.vwcus_ar_per4 + B.vwcus_ar_per5 - B.vwcus_cred_reg - B.vwcus_cred_ga)   
     ,ARBalance = (B.vwcus_ar_future + B.vwcus_ar_per1 + B.vwcus_ar_per2 +  B.vwcus_ar_per3 + B.vwcus_ar_per4 + B.vwcus_ar_per5 - B.vwcus_cred_reg - B.vwcus_cred_ppd - B.vwcus_cred_ga)  
     ,dblPastCredit = CAST((B.vwcus_ar_per2 + B.vwcus_ar_per3 +   
         B.vwcus_ar_per4 + B.vwcus_ar_per5 -   
         B.vwcus_cred_reg - B.vwcus_cred_ga) AS MONEY)  
     ,C.intSiteNumber  
     ,dblLastDeliveredGal = ISNULL(C.dblLastDeliveredGal,0)   
     ,C.strSequenceID  
     ,intLastDeliveryDegreeDay = ISNULL(C.intLastDeliveryDegreeDay,0)  
     ,Replace(C.strSiteAddress, Char(13), '' '') as strSiteAddress  
     ,C.dtmOnHoldEndDate  
     ,C.ysnOnHold  
     ,(Case When C.ysnOnHold = 0 Then  
       ''''  
       When C.ysnOnHold = 1 Then   
        ISNULL(HR.strHoldReason,'''')  
       When (C.dtmOnHoldEndDate > GetDate() or C.dtmOnHoldEndDate is null)THEN  
        ISNULL(HR.strHoldReason,'''')  
       End)as strHoldReason  
     , (Case C.ysnOnHold   
      When 1 then  
       ''Yes''  
      When 0 then  
       ''No''  
      End) as strOnHold  
     ,C.intFillMethodId  
     ,strCity =  
      CASE WHEN C.strSiteAddress IS NOT NULL THEN '', '' + C.strCity  
        ELSE C.strCity    
      END   
     ,strState =   
      CASE WHEN C.strCity IS NOT NULL AND C.strSiteAddress IS NOT NULL THEN '', '' + C.strState  
        ELSE C.strState    
      END  
     ,strZipCode =   
      CASE WHEN C.strState IS NOT NULL AND C.strCity IS NOT NULL AND C.strSiteAddress IS NOT NULL THEN '' '' + C.strZipCode  
        ELSE C.strZipCode    
      END   
     ,C.strComment  
     ,C.strInstruction  
     ,C.dblDegreeDayBetweenDelivery  
     ,C.dblTotalCapacity  
     ,C.dblTotalReserve  
     ,strSiteDescription = C.strDescription   
     ,dblLastGalsInTank = ISNULL(C.dblLastGalsInTank,0)   
     ,C.dtmLastDeliveryDate  
     ,C.intSiteID  
     ,dblEstimatedPercentLeft = ISNULL(C.dblEstimatedPercentLeft,0)  
     ,C.dtmNextDeliveryDate  
     ,ISNULL(C.intNextDeliveryDegreeDay,0) AS intNextDeliveryDegreeDay  
     ,(Case When C.dtmNextDeliveryDate is not Null Then ''Date''  
       Else ''DD'' End) as [SiteLabel]  
     ,(Case When C.dtmNextDeliveryDate is not Null Then  
       CONVERT(varchar,C.dtmNextDeliveryDate,101)  
       Else  
       CAST(C.intNextDeliveryDegreeDay as nvarchar(20))  
      End) as [SiteDeliveryDD]  
     ,dblDailyUse =   
      CASE WHEN H.strCurrentSeason = ''Summer'' THEN C.dblSummerDailyUse  
        WHEN H.strCurrentSeason = ''Winter'' THEN C.dblWinterDailyUse  
        ELSE COALESCE(C.dblWinterDailyUse, 0)   
      END  
     ,strFillGroupCode = ISNULL( I.strFillGroupCode,'''')   
     ,I.strDescription  
     ,ysnActive =  
      CASE I.ysnActive  
       WHEN 1 THEN ''Yes''  
       WHEN 0 THEN ''No''  
      END  
     ,I.intFillGroupId  
     ,J.vwsls_name as strDriverName  
     ,strDriverID = J.vwsls_slsmn_id   
     ,F.dtmRequestedDate  
     ,dblQuantity = COALESCE(F.dblQuantity,0.0)   
     ,strProductID = G.vwitm_no   
     ,strProductDescription = G.vwitm_desc   
     ,strRouteId = (SELECT TOP 1 r.strRouteId FROM tblTMRoute r WHERE r.intRouteId = C.intRouteId)   
     ,strFillMethod = (SELECT TOP 1 strFillMethod FROM tblTMFillMethod tt WHERE tt.intFillMethodId = C.intFillMethodId)   
     ,strBetweenDlvry =   
      CAST(  
       CASE WHEN C.intFillMethodId = 1 THEN  
          CASE WHEN (SELECT COUNT(intSiteID)FROM tblTMSiteJulianCalendar t WHERE t.intSiteID = C.intSiteID) > 1 THEN ''Varies''  
            WHEN (SELECT COUNT(intSiteID)FROM tblTMSiteJulianCalendar t WHERE t.intSiteID = C.intSiteID) = 1 THEN  
            CASE WHEN K.intRecurPattern = 0 THEN CAST(K.intRecurInterval AS VARCHAR(50))   
              WHEN K.intRecurPattern = 1 THEN ''Weekly''  
              WHEN K.intRecurPattern = 2 THEN ''Monthly''  
              WHEN K.intRecurPattern = 3 THEN ''Single''  
            END  
          END  
         ELSE CAST(CONVERT(DECIMAL(10,2),C.dblDegreeDayBetweenDelivery) AS VARCHAR(50))   
       END   
      AS VARCHAR(50))  
     ,strLocation =  
      CASE WHEN ISNUMERIC(C.strLocation) = 1 THEN C.strLocation  
        ELSE SUBSTRING(C.strLocation, PATINDEX(''%[^0]%'',C.strLocation), 50)   
      END  
     ,C.dtmForecastedDelivery  
   FROM tblTMCustomer A INNER JOIN vwcusmst B   
      ON A.intCustomerNumber = B.A4GLIdentity   
     LEFT JOIN tblTMSite C   
      ON A.intCustomerID = C.intCustomerID  
     LEFT JOIN tblTMDispatch F   
      ON C.intSiteID = F.intSiteID  
     LEFT JOIN vwitmmst G   
      ON C.intProduct = G.A4GLIdentity  
     LEFT JOIN tblTMClock H   
      ON H.intClockID = C.intClockID  
     LEFT JOIN tblTMFillGroup I   
      ON I.intFillGroupId = C.intFillGroupId  
     LEFT JOIN vwslsmst J   
      ON J.A4GLIdentity = C.intDriverID  
     LEFT JOIN tblTMSiteJulianCalendar K   
      ON K.intSiteID = C.intSiteID  
     LEFT JOIN tblTMHoldReason HR   
      ON C.intHoldReasonID = HR.intHoldReasonID   
   WHERE vwcus_active_yn = ''Y''   
     AND C.ysnActive = 1'-- AND vwcus_key = ''00000000A1'''  
      
 IF(ISNULL(@WhereClause,'') != '')BEGIN SET @Query = 'SELECT * FROM (' + @Query + ') tbl WHERE ' + RIGHT(@WhereClause,LEN(@WhereClause)-4) END  
 --select @WhereClause, @Query --For DEBUGGING  
   
   
   
 INSERT INTO @DeliveryFillTable EXECUTE(@Query)  
 --SELECT * INTO #tmpDeliveryFillTable FROM @DeliveryFillTable  
     
 SELECT -- NOTE: Remember to remove the "TOP" when deploying the script in the test/production environment.   
   agcus_key -- 1 PK  
   ,agcus_phone -- 2  
   ,CustomerName -- 3  
   ,strProductID -- 4  
   ,strProductDescription -- 5  
   ,intSiteNumber -- 6  PK  
   ,dblTotalCapacity -- 7   
   ,dblTotalReserve -- 8   
   ,dblProductCost -- 9   
   ,strFillMethod -- 10   
   ,TermDesc  
   ,RTE_SQID = strRouteId + '-' + strSequenceID -- 12  
   ,strRouteId  
   ,strSequenceID  
   ,strBetweenDlvry -- 13  
   ,dtmLastDeliveryDate -- 14  
   ,intLastDeliveryDegreeDay -- 15  
   ,dblLastDeliveredGal -- 16  
   ,dtmForecastedDelivery -- 17  
   ,strDriverID -- 18  
   ,strDriverName -- 19  
   ,dblDailyUse -- 20  
   ,SiteLabel -- 21  
   ,SiteDeliveryDD  
   ,intNextDeliveryDegreeDay -- 22  
   ,dblEstimatedPercentLeft -- 23  
   ,dblLastGalsInTank -- 24  
   ,agcus_prc_lvl -- 25  
   ,SiteAddress = [strSiteAddress] +  [strCity] +  [strState] + [strZipCode] -- 26  
   ,strLocation -- 27  
   ,agcus_tax_state -- 28  
   ,strSiteDescription -- 29  
   ,agcus_cred_limit -- 30  
   ,ARBalance -- 31  
   ,agcus_ar_future -- 32   
   ,agcus_ar_per1 -- 33  
   ,TotalPast -- 34  
   ,Credits -- 35  
   ,strInstruction -- 36  
   ,strComment -- 37   
   ,idPhone = [agcus_key] + '  ' + [agcus_phone]  
   ,FullName = LTRIM(RTRIM([agcus_last_name])) + ', ' + LTRIM(RTRIM([agcus_first_name]))   
   ,strFillGroupCode  
   ,strHoldReason  
   ,strOnHold   
 INTO #tmpLoopQuery  
 FROM  @DeliveryFillTable  
     
   
  
   
 -- Optimize the loop table by adding indexes  
 IF OBJECT_ID('tempdb..#tmpDetailToCut') IS NOT NULL  
 BEGIN  
  CREATE CLUSTERED INDEX IDX_tmpDetailToCut_intSiteNumber ON #tmpDetailToCut(intSiteNumber)  
  CREATE INDEX IDX_tmpDetailToCut_agcus_key ON #tmpDetailToCut(agcus_key)  
 END   
  
 -- Create another temporary table where the result will be generated.   
 SELECT *   
   ,strLine = CAST(NULL AS VARCHAR(MAX))   
   ,intLineNumber = IDENTITY(INT, 1, 1)  
 INTO #tmpDetailToCut  
 FROM #tmpLoopQuery  
 WHERE 1 = 0  ORDER BY #tmpLoopQuery.agcus_key, #tmpLoopQuery.intSiteNumber  
   
 -- Allow NULLABLE on all non-primary columns in the temporary table.   
 ALTER TABLE #tmpDetailToCut ALTER COLUMN agcus_phone VARCHAR(100) NULL  
 ALTER TABLE #tmpDetailToCut ALTER COLUMN CustomerName VARCHAR(500) NULL  
 ALTER TABLE #tmpDetailToCut ALTER COLUMN strProductID VARCHAR(100) NULL  
 ALTER TABLE #tmpDetailToCut ALTER COLUMN strProductDescription VARCHAR(500) NULL  
 ALTER TABLE #tmpDetailToCut ALTER COLUMN dblTotalCapacity NUMERIC(18,6) NULL  
 ALTER TABLE #tmpDetailToCut ALTER COLUMN dblTotalReserve NUMERIC(18,6) NULL  
 ALTER TABLE #tmpDetailToCut ALTER COLUMN dblProductCost NUMERIC(18,6) NULL  
 ALTER TABLE #tmpDetailToCut ALTER COLUMN strFillMethod VARCHAR(100) NULL  
 ALTER TABLE #tmpDetailToCut ALTER COLUMN TermDesc NVARCHAR(100) NULL  
 ALTER TABLE #tmpDetailToCut ALTER COLUMN RTE_SQID VARCHAR(100) NULL  
 ALTER TABLE #tmpDetailToCut ALTER COLUMN strRouteId VARCHAR(50) NULL  
 ALTER TABLE #tmpDetailToCut ALTER COLUMN strSequenceID VARCHAR(50) NULL  
 ALTER TABLE #tmpDetailToCut ALTER COLUMN strBetweenDlvry NVARCHAR(100) NULL  
 ALTER TABLE #tmpDetailToCut ALTER COLUMN dtmLastDeliveryDate DATETIME NULL  
 ALTER TABLE #tmpDetailToCut ALTER COLUMN intLastDeliveryDegreeDay INTEGER NULL  
 ALTER TABLE #tmpDetailToCut ALTER COLUMN dblLastDeliveredGal NUMERIC(18,6) NULL  
 ALTER TABLE #tmpDetailToCut ALTER COLUMN dtmForecastedDelivery DATETIME NULL  
 ALTER TABLE #tmpDetailToCut ALTER COLUMN strDriverID VARCHAR(100)  
 ALTER TABLE #tmpDetailToCut ALTER COLUMN strDriverName VARCHAR(500)  
 ALTER TABLE #tmpDetailToCut ALTER COLUMN dblDailyUse NUMERIC(18,6)  
 ALTER TABLE #tmpDetailToCut ALTER COLUMN SiteLabel VARCHAR(100)  
 ALTER TABLE #tmpDetailToCut ALTER COLUMN SiteDeliveryDD VARCHAR(100)  
 ALTER TABLE #tmpDetailToCut ALTER COLUMN intNextDeliveryDegreeDay INTEGER NULL  
 ALTER TABLE #tmpDetailToCut ALTER COLUMN dblEstimatedPercentLeft NUMERIC(18,6) NULL  
 ALTER TABLE #tmpDetailToCut ALTER COLUMN dblLastGalsInTank NUMERIC(18,6) NULL  
 ALTER TABLE #tmpDetailToCut ALTER COLUMN agcus_prc_lvl INTEGER NULL  
 ALTER TABLE #tmpDetailToCut ALTER COLUMN SiteAddress VARCHAR(500) NULL  
 ALTER TABLE #tmpDetailToCut ALTER COLUMN strLocation VARCHAR(100) NULL  
 ALTER TABLE #tmpDetailToCut ALTER COLUMN agcus_tax_state VARCHAR(100) NULL   
 ALTER TABLE #tmpDetailToCut ALTER COLUMN strSiteDescription VARCHAR(100) NULL  
 ALTER TABLE #tmpDetailToCut ALTER COLUMN agcus_cred_limit INTEGER NULL  
 ALTER TABLE #tmpDetailToCut ALTER COLUMN ARBalance NUMERIC(18,6) NULL  
 ALTER TABLE #tmpDetailToCut ALTER COLUMN agcus_ar_future NUMERIC(18,6) NULL  
 ALTER TABLE #tmpDetailToCut ALTER COLUMN agcus_ar_per1 NUMERIC(18,6) NULL  
 ALTER TABLE #tmpDetailToCut ALTER COLUMN TotalPast NUMERIC(18,6) NULL  
 ALTER TABLE #tmpDetailToCut ALTER COLUMN Credits NUMERIC(18,6) NULL  
 ALTER TABLE #tmpDetailToCut ALTER COLUMN strInstruction VARCHAR(2000) NULL  
 ALTER TABLE #tmpDetailToCut ALTER COLUMN strComment VARCHAR(2000) NULL  
 ALTER TABLE #tmpDetailToCut ALTER COLUMN idPhone VARCHAR(500) NULL  
 ALTER TABLE #tmpDetailToCut ALTER COLUMN FullName VARCHAR(500) NULL  
 ALTER TABLE #tmpDetailToCut ALTER COLUMN strFillGroupCode VARCHAR(100) NULL   
 ALTER TABLE #tmpDetailToCut ALTER COLUMN strHoldReason NVARCHAR(100) NULL   
 ALTER TABLE #tmpDetailToCut ALTER COLUMN strOnHold VARCHAR(20) NULL    
 -- Create another temporary table where the result will be generated.   
 SELECT *   
   ,strLine = CAST(NULL AS VARCHAR(MAX))  
   ,intLineNumber = CAST (0 AS INTEGER)   
   ,strPagePart = CAST(NULL AS VARCHAR(50))  
 INTO #tmpResult  
 FROM #tmpLoopQuery  
 WHERE 1 = 0  ORDER BY #tmpLoopQuery.agcus_key, #tmpLoopQuery.intSiteNumber  
   
 -- Allow NULLABLE on all non-primary columns in the temporary table.   
 ALTER TABLE #tmpResult ALTER COLUMN agcus_phone VARCHAR(100) NULL  
 ALTER TABLE #tmpResult ALTER COLUMN CustomerName VARCHAR(500) NULL  
 ALTER TABLE #tmpResult ALTER COLUMN strProductID VARCHAR(100) NULL  
 ALTER TABLE #tmpResult ALTER COLUMN strProductDescription VARCHAR(500) NULL  
 ALTER TABLE #tmpResult ALTER COLUMN dblTotalCapacity NUMERIC(18,6) NULL  
 ALTER TABLE #tmpResult ALTER COLUMN dblTotalReserve NUMERIC(18,6) NULL  
 ALTER TABLE #tmpResult ALTER COLUMN dblProductCost NUMERIC(18,6) NULL  
 ALTER TABLE #tmpResult ALTER COLUMN strFillMethod VARCHAR(100) NULL  
 ALTER TABLE #tmpResult ALTER COLUMN TermDesc NVARCHAR(100) NULL  
 ALTER TABLE #tmpResult ALTER COLUMN RTE_SQID VARCHAR(100) NULL  
 ALTER TABLE #tmpResult ALTER COLUMN strRouteId VARCHAR(50) NULL  
 ALTER TABLE #tmpResult ALTER COLUMN strSequenceID VARCHAR(50) NULL  
 ALTER TABLE #tmpResult ALTER COLUMN strBetweenDlvry NVARCHAR(100) NULL  
 ALTER TABLE #tmpResult ALTER COLUMN dtmLastDeliveryDate DATETIME NULL  
 ALTER TABLE #tmpResult ALTER COLUMN intLastDeliveryDegreeDay INTEGER NULL  
 ALTER TABLE #tmpResult ALTER COLUMN dblLastDeliveredGal NUMERIC(18,6) NULL  
 ALTER TABLE #tmpResult ALTER COLUMN dtmForecastedDelivery DATETIME NULL  
 ALTER TABLE #tmpResult ALTER COLUMN strDriverID VARCHAR(100)  
 ALTER TABLE #tmpResult ALTER COLUMN strDriverName VARCHAR(500)  
 ALTER TABLE #tmpResult ALTER COLUMN dblDailyUse NUMERIC(18,6)  
 ALTER TABLE #tmpResult ALTER COLUMN SiteLabel VARCHAR(100)  
 ALTER TABLE #tmpResult ALTER COLUMN SiteDeliveryDD VARCHAR(100)  
 ALTER TABLE #tmpResult ALTER COLUMN intNextDeliveryDegreeDay INTEGER NULL  
 ALTER TABLE #tmpResult ALTER COLUMN dblEstimatedPercentLeft NUMERIC(18,6) NULL  
 ALTER TABLE #tmpResult ALTER COLUMN dblLastGalsInTank NUMERIC(18,6) NULL  
 ALTER TABLE #tmpResult ALTER COLUMN agcus_prc_lvl INTEGER NULL  
 ALTER TABLE #tmpResult ALTER COLUMN SiteAddress VARCHAR(500) NULL  
 ALTER TABLE #tmpResult ALTER COLUMN strLocation VARCHAR(100) NULL  
 ALTER TABLE #tmpResult ALTER COLUMN agcus_tax_state VARCHAR(100) NULL   
 ALTER TABLE #tmpResult ALTER COLUMN strSiteDescription VARCHAR(100) NULL  
 ALTER TABLE #tmpResult ALTER COLUMN agcus_cred_limit INTEGER NULL  
 ALTER TABLE #tmpResult ALTER COLUMN ARBalance NUMERIC(18,6) NULL  
 ALTER TABLE #tmpResult ALTER COLUMN agcus_ar_future NUMERIC(18,6) NULL  
 ALTER TABLE #tmpResult ALTER COLUMN agcus_ar_per1 NUMERIC(18,6) NULL  
 ALTER TABLE #tmpResult ALTER COLUMN TotalPast NUMERIC(18,6) NULL  
 ALTER TABLE #tmpResult ALTER COLUMN Credits NUMERIC(18,6) NULL  
 ALTER TABLE #tmpResult ALTER COLUMN strInstruction VARCHAR(2000) NULL  
 ALTER TABLE #tmpResult ALTER COLUMN strComment VARCHAR(2000) NULL  
 ALTER TABLE #tmpResult ALTER COLUMN idPhone VARCHAR(500) NULL  
 ALTER TABLE #tmpResult ALTER COLUMN FullName VARCHAR(500) NULL  
 ALTER TABLE #tmpResult ALTER COLUMN strFillGroupCode VARCHAR(100) NULL  
 ALTER TABLE #tmpResult ALTER COLUMN strHoldReason VARCHAR(100) NULL   
 ALTER TABLE #tmpResult ALTER COLUMN strOnHold VARCHAR(100) NULL  
 -- Optimize the loop table by adding indexes  
 IF OBJECT_ID('tempdb..#tmpResult') IS NOT NULL  
 BEGIN  
  CREATE CLUSTERED INDEX IDX_tmpResult_intSiteNumber ON #tmpResult(intSiteNumber)  
  CREATE INDEX IDX_tmpResult_agcus_key ON #tmpResult(agcus_key)  
  CREATE INDEX IDX_tmpResult_intLineNumber ON #tmpResult(intLineNumber)  
 END    
  
 -- This is Root Loop.   
 WHILE EXISTS (SELECT TOP 1 1 FROM #tmpLoopQuery)  
 BEGIN   
  SELECT TOP 1  
    @agcus_key = agcus_key  
    ,@agcus_phone = agcus_phone  
    ,@CustomerName = CustomerName  
    ,@strProductID = strProductID  
    ,@strProductDescription = strProductDescription  
    ,@intSiteNumber = intSiteNumber  
    ,@dblTotalCapacity = dblTotalCapacity  
    ,@dblTotalReserve = dblTotalReserve  
    ,@dblProductCost = dblProductCost  
    ,@strFillMethod = strFillMethod  
    ,@TermDesc = TermDesc  
    ,@RTE_SQID = RTE_SQID  
    ,@strRouteId = strRouteId  
    ,@strSequenceID = strSequenceID  
    ,@strBetweenDlvry = strBetweenDlvry  
    ,@dtmLastDeliveryDate = dtmLastDeliveryDate  
    ,@intLastDeliveryDegreeDay = intLastDeliveryDegreeDay  
    ,@dblLastDeliveredGal = dblLastDeliveredGal  
    ,@dtmForecastedDelivery = dtmForecastedDelivery  
    ,@strDriverID = strDriverID  
    ,@strDriverName = strDriverName  
    ,@dblDailyUse = dblDailyUse  
    ,@SiteLabel = SiteLabel  
    ,@SiteDeliveryDD = SiteDeliveryDD  
    ,@intNextDeliveryDegreeDay = intNextDeliveryDegreeDay  
    ,@dblEstimatedPercentLeft = dblEstimatedPercentLeft  
    ,@dblLastGalsInTank = dblLastGalsInTank  
    ,@agcus_prc_lvl = agcus_prc_lvl  
    ,@SiteAddress = SiteAddress  
    ,@strLocation = strLocation  
    ,@agcus_tax_state = agcus_tax_state  
    ,@strSiteDescription = strSiteDescription  
    ,@agcus_cred_limit = agcus_cred_limit  
    ,@ARBalance = ARBalance  
    ,@agcus_ar_future = agcus_ar_future  
    ,@agcus_ar_per1 = agcus_ar_per1  
    ,@TotalPast = TotalPast  
    ,@Credits = Credits  
    ,@strInstruction = strInstruction  
    ,@strComment = strComment  
    ,@idPhone = idPhone  
    ,@FullName = FullName     
    ,@strFillGroupCode = strFillGroupCode   
    ,@strHoldReason = strHoldReason  
    ,@strOnHold = strOnHold   
  FROM #tmpLoopQuery   
    
  IF @ListTotals = 'True'  
  BEGIN  
  INSERT INTO #tmpDetailToCut (  
    agcus_key   
    ,intSiteNumber   
    ,strLine   
  )  
  SELECT  @agcus_key   
    ,@intSiteNumber   
    ,strLine =   
     '<font face="courier new" size="1"> ' +   
      REPLACE(  
        '<b>' + ' ' +  '</b>' +  
        CAST( '' AS CHAR(10) ) +   
        '<b>' + @Gaps + ' ' + '</b>' +  
        CAST( '' AS CHAR(5) )   
       , ' '  
       ,'&#160;'   
      ) +   
     '</font>'  
  END  
    
    
    
  --On Hold  
  IF (SELECT COUNT(agcus_key) FROM #tmpDetailToCut  Where strLine Like '%Hold%' ) != 1 AND  @OnHold = 'True'  
  BEGIN   
  INSERT INTO #tmpDetailToCut (  
    agcus_key   
    ,intSiteNumber   
    ,strLine   
  )  
  SELECT  TOP(1) @agcus_key   
    ,@intSiteNumber   
    ,strLine =   
     '<font face="courier new" size="1"> ' +   
      REPLACE(  
        '<b>' + 'On Hold: ' +  '</b>' +  
        CAST( ISNULL(strOnHold, '') AS CHAR(10) ) +   
        '<b>' + @Gaps + 'On Hold Reason: ' + '</b>' +  
        CAST( ISNULL(strHoldReason, '') AS CHAR(50) )   
       , ' '  
       ,'&#160;'   
      ) +   
     '</font>'  
  FROM #tmpLoopQuery  
  WHERE agcus_key = @agcus_key AND intSiteNumber = @intSiteNumber   
  END  
  IF (SELECT COUNT(agcus_key) FROM #tmpDetailToCut  Where strLine Like '%Hold%' )= 0 AND @OnHold = 'True'  
  BEGIN  
  INSERT INTO #tmpDetailToCut (  
    agcus_key   
    ,intSiteNumber   
    ,strLine   
  )  
  SELECT  @agcus_key   
    ,@intSiteNumber   
    ,strLine =   
     '<font face="courier new" size="1"> ' +   
      REPLACE(  
        '<b>' + 'On Hold: ' +  '</b>' +  
        CAST( '' AS CHAR(10) ) +   
        '<b>' + @Gaps + 'On Hold Reason: ' + '</b>' +  
        CAST( '' AS CHAR(5) )   
       , ' '  
       ,'&#160;'   
      ) +   
     '</font>'  
  END  
  
  -- 1. Gather the Tank Information associated to the site.  
  IF @TankInfo = 'True'  
  BEGIN  
  INSERT INTO #tmpDetailToCut (  
    agcus_key   
    ,intSiteNumber   
    ,strLine   
  )  
  SELECT  @agcus_key   
    ,@intSiteNumber   
    ,strLine =        
     '<font face="courier new" size="1"> ' +   
      REPLACE(  
        '<b>' + 'Tank Serial Number: ' +  '</b>' +  
        CAST( ISNULL(E.strSerialNumber, '') AS CHAR(20) ) +   
        '<b>' + @Gaps + 'Type: ' + '</b>' +  
        CAST( ISNULL((SELECT TOP 1 ISNULL(tt.strTankType, '') From tblTMTankType tt Where tt.intTankTypeId = E.intTankTypeId),'') AS CHAR(23) ) +  
        '<b>' + @Gaps + 'Capacity: '+ '</b>' +  
        CAST( ISNULL(CAST(CONVERT(VARCHAR,CONVERT(MONEY,ISNULL(E.dblTankCapacity, 0)),1) AS VARCHAR(50)), '') AS CHAR(10) )  
       , ' '  
       ,'&#160;'   
      ) +   
     '</font>'  
  FROM  tblTMCustomer A INNER JOIN vwcusmst B   
     ON A.intCustomerNumber = B.A4GLIdentity   
    LEFT JOIN tblTMSite C   
     ON A.intCustomerID = C.intCustomerID  
    LEFT JOIN tblTMSiteDevice D   
     ON C.intSiteID =D.intSiteID   
    LEFT JOIN tblTMDevice E   
     ON D.intDeviceId = E.intDeviceId AND ysnAppliance = 0    
    LEFT JOIN tblTMDeviceType F   
     ON E.intDeviceTypeId = F.intDeviceTypeId  
  WHERE E.intDeviceId IS NOT NULL   
    AND F.strDeviceType IN ('Tank','TANK')  
    AND B.vwcus_key = @agcus_key  
    AND C.intSiteNumber = @intSiteNumber   
  END  
  IF (SELECT COUNT(agcus_key) FROM #tmpDetailToCut  Where strLine Like '%Tank%' )= 0 AND @TankInfo = 'True'  
  BEGIN  
  INSERT INTO #tmpDetailToCut (  
    agcus_key   
    ,intSiteNumber   
    ,strLine   
  )  
  SELECT  @agcus_key   
    ,@intSiteNumber   
    ,strLine =        
     '<font face="courier new" size="1"> ' +   
      REPLACE(  
        '<b>' + 'Tank Serial Number: ' +  '</b>' +  
        CAST( '' AS CHAR(20) ) +   
        '<b>' + @Gaps + 'Type: ' + '</b>' +  
        CAST('' AS CHAR(23) ) +  
        '<b>' + @Gaps + 'Capacity: '+ '</b>' +  
        CAST( '' AS CHAR(10) )  
       , ' '  
       ,'&#160;'   
      ) +   
     '</font>'  
  END  
    
  -- 2. Gather the Customer Contract associated to the site.  
  IF @CustomerContract = 'True'  
  BEGIN  
  INSERT INTO #tmpDetailToCut (  
    agcus_key   
    ,intSiteNumber   
    ,strLine   
  )  
  SELECT  @agcus_key   
    ,@intSiteNumber   
    ,strLine =   
     '<font face="courier new" size="1"> ' +   
      REPLACE(  
        '<b>' + 'Contract Number: ' + '</b>' + CAST( ISNULL(vwcnt_cnt_no, '') AS CHAR(23) ) +   
        '<b>' + @Gaps + 'Balance: ' + '</b>' + CAST( CONVERT(DECIMAL(10,2), ISNULL(vwcnt_un_bal, 0)) AS CHAR(20) ) +   
        '<b>' + @Gaps + 'Unit Price: </b>' + CAST(CONVERT(VARCHAR,CONVERT(MONEY,ISNULL(vwcnt_un_prc, 0)),1) AS CHAR(20))   
       , ' '   
       ,'&#160;'   
      ) +   
     '</font>'  
   FROM vwcntmst   
   WHERE vwcntmst.vwcnt_cus_no = @agcus_key  
  END  
  IF @CustomerContract = 'True' AND (SELECT COUNT(agcus_key) FROM #tmpDetailToCut Where strLine Like '%Contract%' )= 0  
  BEGIN  
   INSERT INTO #tmpDetailToCut (  
    agcus_key   
    ,intSiteNumber   
    ,strLine   
  )  
  SELECT  @agcus_key   
    ,@intSiteNumber   
    ,strLine =   
     '<font face="courier new" size="1"> ' +   
      REPLACE(  
        '<b>' + 'Contract Number: ' + '</b>' + CAST(  '' AS CHAR(23) ) +   
        '<b>' + @Gaps + 'Balance: ' + '</b>' + CAST( '' AS CHAR(20) ) +   
        '<b>' + @Gaps + 'Unit Price: </b>' + CAST( '' AS CHAR(20))   
       , ' '   
       ,'&#160;'   
      ) +   
     '</font>'  
  END  
  -- 3. Gather the Regulator Information associated to the site.  
  IF @RegulatorInfo = 'True'  
  BEGIN  
  INSERT INTO #tmpDetailToCut (  
    agcus_key   
    ,intSiteNumber   
    ,strLine   
  )  
  SELECT  @agcus_key   
    ,@intSiteNumber   
    ,strLine =   
     '<font face="courier new" size="1"> ' +   
      REPLACE(  
        '<b>' + 'Regulator Mfr: ' + '</b>' + CAST( ISNULL(E.strManufacturerID, '') AS CHAR(25) ) +   
        '<b>' + @Gaps + 'Name: ' + '</b>' + CAST ( ISNULL(E.strManufacturerName, '') AS CHAR(23) ) +  
        '<b>' + @Gaps + 'Description: ' + '</b>' + CAST (ISNULL(E.strDescription, '') AS CHAR(40) ) +  
        '<b>' + @Gaps + 'Date Mfd: ' + '</b>' + CAST( ISNULL(CONVERT(VARCHAR(50), E.dtmManufacturedDate, 101), '') AS CHAR(12) )   
       , ' '  
       , '&#160;'  
      ) +   
     '</font>'  
    FROM tblTMCustomer A INNER JOIN vwcusmst B   
      ON A.intCustomerNumber = B.A4GLIdentity   
     LEFT JOIN tblTMSite C   
      ON A.intCustomerID = C.intCustomerID  
     LEFT JOIN tblTMSiteDevice D   
      ON C.intSiteID =D.intSiteID   
     LEFT JOIN tblTMDevice E   
      ON D.intDeviceId = E.intDeviceId   
      AND ysnAppliance = 0  
     LEFT JOIN tblTMDeviceType F   
      ON E.intDeviceTypeId = F.intDeviceTypeId
    WHERE E.intDeviceId IS NOT NULL   
      AND UPPER(F.strDeviceType) = 'REGULATOR'  
      AND B.vwcus_key = @agcus_key   
      AND C.intSiteNumber = @intSiteNumber      
  END   
  IF @RegulatorInfo = 'True' AND (SELECT COUNT(agcus_key) FROM #tmpDetailToCut Where strLine Like '%Regulator%' )= 0  
  BEGIN  
  INSERT INTO #tmpDetailToCut (  
    agcus_key   
    ,intSiteNumber   
    ,strLine   
  )  
  SELECT  @agcus_key   
    ,@intSiteNumber   
    ,strLine =   
     '<font face="courier new" size="1"> ' +   
      REPLACE(  
        '<b>' + 'Regulator Mfr: ' + '</b>' + CAST('' AS CHAR(25) ) +   
        '<b>' + @Gaps + 'Name: ' + '</b>' + CAST ( '' AS CHAR(23) ) +  
        '<b>' + @Gaps + 'Description: ' + '</b>' + CAST ('' AS CHAR(40) ) +  
        '<b>' + @Gaps + 'Date Mfd: ' + '</b>' + CAST( '' AS CHAR(12) )   
       , ' '  
       , '&#160;'  
      ) +   
     '</font>'  
  END  
  
  -- 4. Gather the Delivery Fill Group associated to the site.  
  IF @FillGroup = 'True'  
  BEGIN  
       
  IF EXISTS(SELECT * FROM tempdb.dbo.sysobjects WHERE ID = OBJECT_ID(N'tempdb..#tmpDeliveryFillGroup')) BEGIN DROP TABLE #tmpDeliveryFillGroup END  
  
  SELECT agcus_key = a.vwcus_key   
    ,agcus_first_name = a.vwcus_first_name   
    ,agcus_last_name = a.vwcus_last_name  
    ,REPLACE((Case WHEN a.vwcus_first_name IS NULL OR a.vwcus_first_name = ''  THEN  
     RTRIM(a.vwcus_last_name)  
     ELSE  
     RTRIM(a.vwcus_last_name) + ', ' + RTRIM(a.vwcus_first_name)  
     END),CHAR(38),'and') as CustomerName  
    ,c.intSiteNumber  
    ,c.strSiteAddress  
    ,strSiteDescription = c.strDescription   
    ,strFillGroupCode = ISNULL(d.strFillGroupCode, '')   
    ,d.intFillGroupId   
    ,d.strDescription  
    ,ysnActive =   
      CASE d.ysnActive  
        WHEN 1 THEN 'Yes'  
        WHEN 0 THEN 'No'  
      END  
    ,intLineNumber = IDENTITY(INT,1,1)  
  INTO #tmpDeliveryFillGroup  
  FROM vwcusmst a INNER JOIN tblTMCustomer b   
     ON a.A4GLIdentity = b.intCustomerNumber   
    LEFT JOIN tblTMSite c   
     ON b.intCustomerID = c.intCustomerID   
    LEFT JOIN tblTMFillGroup d   
     ON d.intFillGroupId = c.intFillGroupId 
  WHERE c.intFillGroupId IS NOT NULL   
    AND c.ysnActive   = 1   
    AND a.vwcus_active_yn = 'Y'   
    AND (ysnOnHold = 0 OR dtmOnHoldEndDate < GETDATE())   
    AND d.strFillGroupCode = @strFillGroupCode  
  GROUP BY   
    a.vwcus_key  
    ,a.vwcus_first_name  
    ,a.vwcus_last_name  
    ,c.intSiteNumber  
    ,c.strSiteAddress  
    ,c.strDescription  
    ,d.strFillGroupCode  
    ,d.intFillGroupId   
    ,d.ysnActive  
    ,d.strDescription    
    
  IF EXISTS (SELECT TOP 1 1 FROM #tmpDeliveryFillGroup)  
  BEGIN       
   -- Insert the header column captions.   
   INSERT INTO #tmpDetailToCut (  
    agcus_key   
    ,intSiteNumber   
    ,strLine   
   )  
   SELECT    
    @agcus_key   
    ,@intSiteNumber   
    ,strLine =   
     '<font face="courier new" size="1"> <b>' +   
      REPLACE(  
        CAST('Fill Group Code' AS CHAR(15))  + @Gaps +  
        CAST('Description' AS CHAR(50)) + @Gaps +   
        CAST('Active' AS CHAR(6))  
       , ' '  
       , '&#160;'  
      ) +  
     '</b></font>'  
     
   -- Insert the data for the header  
   UNION ALL  
   SELECT  TOP 1  
    @agcus_key   
    ,@intSiteNumber   
    ,strLine =   
     '<font face="courier new" size="1">' +   
      REPLACE(  
        CAST( ISNULL(strFillGroupCode, '') AS CHAR(15)) + @Gaps +  
        CAST(ISNULL(strDescription, '') AS CHAR(50)) + @Gaps +   
        CAST(ISNULL(CAST(ysnActive AS VARCHAR(10)), '') AS CHAR(6))   
       , ' '  
       , '&#160;'  
      ) +   
     '</font>'  
   FROM #tmpDeliveryFillGroup  
     
   -- Insert the detail column captions.   
   UNION ALL  
   SELECT    
    @agcus_key   
    ,@intSiteNumber   
    ,strLine =   
     '<font face="courier new" size="1"> <b>' +   
      REPLACE(  
        @Gaps + @Gaps +   
        CAST('   Customer Number' AS CHAR(18)) + @Gaps + @Gaps +  
        CAST('Customer Name' AS CHAR(20)) + @Gaps +   
        CAST('Site No' AS CHAR(10)) + @Gaps +  
        CAST('Site Address' AS CHAR(40)) + @Gaps +   
        CAST('Description' AS CHAR(40))   
       , ' '   
       , '&#160;'  
      ) +   
     '</b></font>'       
   -- Insert the details of the Delivery Fill Group  
   UNION ALL   
   SELECT  @agcus_key   
     ,@intSiteNumber   
     ,strLine =   
      '<font face="courier new" size="1">' +   
       REPLACE(  
         @Gaps +  
         CAST(intLineNumber AS CHAR(3)) + @Gaps +  
         CAST(LTRIM(RTRIM(ISNULL(agcus_key, ''))) AS CHAR(17)) + @Gaps +  
           
         CAST((Case When LEN(RTRIM(LTRIM(CustomerName))) > 20 THEN SUBSTRING(CustomerName,1,16) + ' ...' ELSE ISNULL(CustomerName,'') end)as CHAR(20)) + @Gaps +  
         CAST('000'+ ISNULL(CAST(intSiteNumber AS VARCHAR(10)), '') AS CHAR(10)) + @Gaps +  
         CAST(LTRIM(RTRIM(ISNULL(REPLACE(strSiteAddress,CHAR(13),''), ''))) AS CHAR(40)) + @Gaps +  
         CAST(LTRIM(RTRIM(ISNULL(strSiteDescription, ''))) AS CHAR(40))   
        , ' '   
        , '&#160;'  
       ) +   
      '</font>'  
   FROM #tmpDeliveryFillGroup    
  END   
  END    
   
  ---SELECT * FROM #tmpDetailToCut -- DEBUG  
   
  -- Cut the detail based number records the paper can hold per half page.   
  -- There are 2 variants to cut the detail:   
    
  -- 1. If there are NO details to cut, insert only blank lines.   
  IF NOT EXISTS (SELECT TOP 1 1 FROM #tmpDetailToCut)  
  BEGIN   
   SET @intCounter = (@HalfPageLimit + @GapAfterHalfPage)  
     
    
     
     
   -- Insert Blank Lines  
   WHILE (@intCounter > 0)  
   BEGIN  
    -- Insert X number of blank lines.   
    INSERT INTO #tmpResult (  
     agcus_key  
     ,intSiteNumber   
     ,strLine  
     ,intLineNumber  
    )  
    SELECT @agcus_key  
      ,@intSiteNumber   
      ,@BlankLine    
      ,@BlankLineNumber  
      
    -- Count down counter.   
    SET @intCounter -= 1     
   END   
  END     
    
  -- 2. If there are details to cut, insert the details and if insert any possible filler blank lines.   
  DECLARE @LineLimit AS INT  
  SET @LineLimit = @HalfPageLimit     
   
  WHILE EXISTS (SELECT TOP 1 1 FROM #tmpDetailToCut)  
  BEGIN  
   DECLARE @MinLineNumber AS INT  
   DECLARE @MaxLineNumber AS INT     
     
   -- Insert a maximum of x lines before a blank line.   
   IF @LineLimit = @HalfPageLimit  
   BEGIN  
    INSERT INTO #tmpResult (  
      agcus_key  
      ,intSiteNumber   
      ,strLine   
      ,intLineNumber  
       
    )  
    SELECT TOP 7 -- If you change # in the TOP clause, make sure you update the @HalfPageLimit with the same number as well.   
      agcus_key  
      ,intSiteNumber   
      ,strLine    
      ,intLineNumber  
    FROM #tmpDetailToCut  
    ORDER BY #tmpDetailToCut.intLineNumber ASC  
   END  
     
   IF @LineLimit = @FullPageLimit  
   BEGIN  
    INSERT INTO #tmpResult (  
      agcus_key  
      ,intSiteNumber   
      ,strLine   
      ,intLineNumber   
    )  
    SELECT TOP 17-- If you change # in the TOP clause, make sure you update the @FullPageLimit with the same number as well.   
      agcus_key  
      ,intSiteNumber   
      ,strLine    
      ,intLineNumber  
    FROM #tmpDetailToCut  
    ORDER BY #tmpDetailToCut.intLineNumber ASC  
   END  
     
   --SELECT * FROM #tmpDetailToCut -- DEBUG  
     
   -- Determine how many times to loop when inserting the blank lines.   
   SELECT @MinLineNumber = MIN(intLineNumber)  
     ,@MaxLineNumber = MAX(intLineNumber)   
   FROM #tmpDetailToCut  
        
   SET @intCounter = @MaxLineNumber - @MinLineNumber  
     
   IF @intCounter < @LineLimit    
   BEGIN      
    SET @intCounter = (@LineLimit) - @intCounter - 1  
      
    -- Insert Blank Lines  
    WHILE (@intCounter > 0)  
    BEGIN  
     -- Insert X number of blank lines.   
     INSERT INTO #tmpResult (  
      agcus_key  
      ,intSiteNumber   
      ,strLine  
      ,intLineNumber  
     )  
     SELECT @agcus_key  
       ,@intSiteNumber   
       ,@BlankLine    
       ,@MaxLineNumber  
       
     -- Count down counter.   
     SET @intCounter -= 1     
    END   
   END  
     
     
   -- Remove the records from #tmpDetailToCut if it is already inserted to #tmpResult  
   SELECT @MaxLineNumber = MAX(intLineNumber)  
   FROM #tmpResult  
   WHERE intLineNumber <> @BlankLineNumber  
     
   DELETE FROM #tmpDetailToCut   
   WHERE intLineNumber <= @MaxLineNumber   
   
   -- Insert X blank lines as page border.   
   IF @BlankLimitSuppressor = 0   
   BEGIN          
    SET @intCounter = @GapAfterHalfPage   
      
    -- Insert Blank Lines  
    WHILE (@intCounter > 0)  
    BEGIN  
     -- Insert X number of blank lines.   
     INSERT INTO #tmpResult (  
      agcus_key  
      ,intSiteNumber   
      ,strLine  
      ,intLineNumber  
        
     )  
     SELECT @agcus_key  
       ,@intSiteNumber   
       ,@BlankLine    
       ,@MaxLineNumber  
         
         
       
     -- Count down counter.   
     SET @intCounter -= 1     
    END   
      
    -- Turn on the suppressor  
    --SET @BlankLimitSuppressor = 1   
   END  
   ELSE  
   BEGIN  
    ---- Insert one blank line.   
    --INSERT INTO #tmpResult (  
    -- agcus_key  
    -- ,intSiteNumber   
    -- ,strLine  
    -- ,intLineNumber  
    --)  
    --SELECT @agcus_key  
    --  ,@intSiteNumber   
    --  ,@BlankLine    
    --  ,@MaxLineNumber  
     
    -- Turn off the suppressor  
    SET @BlankLimitSuppressor = 0     
   END   
     
     
   -- Check if there are still records to process:  
   IF EXISTS (SELECT TOP 1 1 FROM #tmpDetailToCut)  
   BEGIN  
    -- Change the line limit to a full page limit.   
    SET @LineLimit = @FullPageLimit   
   END    
  END  
    
  -- Wrap-up the record for a particular customer and site.  
  
  BEGIN   
  UPDATE #tmpResult  
  SET  agcus_phone = @agcus_phone  
    ,CustomerName = @CustomerName  
    ,strProductID = @strProductID  
    ,strProductDescription = @strProductDescription  
    ,dblTotalCapacity = @dblTotalCapacity  
    ,dblTotalReserve = @dblTotalReserve  
    ,dblProductCost = @dblProductCost  
    ,strFillMethod = @strFillMethod  
    ,TermDesc = @TermDesc  
    ,RTE_SQID = ISNULL(@RTE_SQID,'')  
    ,strRouteId = ISNULL(@strRouteId,'')  
    ,strSequenceID = @strSequenceID  
    ,strBetweenDlvry = (CASE WHEN ISNUMERIC(@strBetweenDlvry) = 1 THEN CONVERT(VARCHAR,CONVERT(MONEY,ISNULL(@strBetweenDlvry,0)),1) ELSE ISNULL(@strBetweenDlvry,'') END)  
    ,dtmLastDeliveryDate = ISNULL(@dtmLastDeliveryDate,'')  
    ,intLastDeliveryDegreeDay = @intLastDeliveryDegreeDay  
    ,dblLastDeliveredGal = @dblLastDeliveredGal  
    ,dtmForecastedDelivery = ISNULL(@dtmForecastedDelivery,'')  
    ,strDriverID = @strDriverID  
    ,strDriverName = @strDriverName  
    ,dblDailyUse = @dblDailyUse  
    ,SiteLabel = @SiteLabel  
    ,SiteDeliveryDD = (CASE WHEN ISNUMERIC(@SiteDeliveryDD) = 1 THEN CONVERT(VARCHAR,CONVERT(MONEY,ISNULL(@SiteDeliveryDD,0)),1) ELSE @SiteDeliveryDD END)  
    ,intNextDeliveryDegreeDay = @intNextDeliveryDegreeDay  
    ,dblEstimatedPercentLeft = @dblEstimatedPercentLeft  
    ,dblLastGalsInTank = @dblLastGalsInTank  
    ,agcus_prc_lvl = @agcus_prc_lvl  
    ,SiteAddress = Replace(@SiteAddress,CHAR(13),' ')  
    ,strLocation = @strLocation  
    ,agcus_tax_state = @agcus_tax_state  
    ,strSiteDescription = @strSiteDescription  
    ,agcus_cred_limit = @agcus_cred_limit  
    ,ARBalance = @ARBalance  
    ,agcus_ar_future = @agcus_ar_future  
    ,agcus_ar_per1 = @agcus_ar_per1  
    ,TotalPast = @TotalPast  
    ,Credits = @Credits  
    ,strInstruction = @strInstruction   
    ,strComment = @strComment  
    ,idPhone = @idPhone  
    ,FullName = @FullName  
    ,strFillGroupCode = @strFillGroupCode  
    ,strHoldReason = @strHoldReason  
    ,strOnHold = @strOnHold  
    
  WHERE agcus_key = @agcus_key  
    AND intSiteNumber = @intSiteNumber    
      
   
  END   
   
  -- Delete the record we just finished processing.  
  DELETE FROM #tmpLoopQuery   
  WHERE agcus_key = @agcus_key  
    AND intSiteNumber = @intSiteNumber   
    
  
  
   
 END  
   
 --DECLARE @Counter AS INT  
 --DECLARE @Part AS BIT  
 --SET @Part = 0  
 --SET @Counter = 0  
 SELECT  * INTO #tmpResultClone  FROM #tmpResult order by agcus_key, intSiteNumber  
   
 -- Optimize the loop table by adding indexes  
 IF OBJECT_ID('tempdb..#tmpResultClone') IS NOT NULL  
 BEGIN  
  CREATE CLUSTERED INDEX IDX_tmpResult_intSiteNumber ON #tmpResultClone(intSiteNumber)  
  CREATE INDEX IDX_tmpResult_agcus_key ON #tmpResultClone(agcus_key)  
  CREATE INDEX IDX_tmpResult_intLineNumber ON #tmpResultClone(intLineNumber)  
 END    
   
 DECLARE @CurrentLineNumber as INT  
 DECLARE @PreviousLineNumber as INT  
 DECLARE @CurrentAgcus_key as nvarchar(50)  
 DECLARE @PreviousAgcus_key as nvarchar(50)  
 DECLARE @CurrentIntSiteNumber as INT  
 DECLARE @PreviousIntSiteNumber as INT  
 DECLARE @CurrentTopLineNumber as INT  
 DECLARE @Char1 as varchar(3)  
 DECLARE @Char2 as varchar(3)  
 DECLARE @Flag as BIT  
 DECLARE @DetailCount as INT  
 DECLARE @PartBCount as INT  
   
 SET @Char1 = 'A'  
 SET @Char2 = 'B'  
 SET @Flag = 0  
 SET @DetailCount = 0  
 SET @PartBCount = 0  
   
 --WHILE (@PageCounter <= 8)  
 --select * from #tmpResultClone  
   
 WHILE EXISTS (SELECT TOP 1 1 FROM #tmpResultClone)  
 BEGIN  
   
  SELECT TOP 1 @CurrentLineNumber =  intLineNumber FROM #tmpResultClone order by agcus_key, intSiteNumber  
  SELECT TOP 1 @CurrentAgcus_key =  agcus_key FROM #tmpResultClone order by agcus_key, intSiteNumber  
  SELECT TOP 1 @CurrentIntSiteNumber =  intSiteNumber FROM #tmpResultClone order by agcus_key, intSiteNumber  
  SELECT TOP 1 @CurrentTopLineNumber = intLineNumber FROM #tmpResult where agcus_key =@CurrentAgcus_key and intSiteNumber = @CurrentIntSiteNumber order by intLineNumber DESC  
  SELECT @DetailCount = COUNT(intLineNumber) FROM #tmpResult WHERE agcus_key = @CurrentAgcus_key and intSiteNumber = @CurrentIntSiteNumber  
  SELECT @PartBCount = COUNT(intLineNumber) FROM #tmpResult WHERE agcus_key = @CurrentAgcus_key and intSiteNumber = @CurrentIntSiteNumber AND strPagePart = 'B'  
    
  PRINT @PartBCount  
  IF (@CurrentAgcus_key != @PreviousAgcus_key)  
  BEGIN  
  IF @PageCounter <= 7  
  BEGIN  
   IF @Flag = 0 BEGIN  
   SET @Char1 = 'B'  
   SET @Char2 = 'A'  
   SET @Flag = 1  
     
   END  
   ELSE BEGIN  
   SET @Char1 = 'A'  
   SET @Char2 = 'B'  
   SET @Flag = 0  
   END  
  END  
   
  SET @PageCounter = 1  
  END  
    
    
  ---------------
  --IF @CurrentAgcus_key = @PreviousAgcus_key AND @CurrentIntSiteNumber = @PreviousIntSiteNumber  
  --BEGIN  
  --IF @PageCounter > 7  
  --BEGIN  
  -- IF @Flag = 0 BEGIN  
  -- SET @Char1 = 'A'  
  -- SET @Char2 = 'B'  
  -- SET @Flag = 1  
     
  -- END  
  -- ELSE BEGIN  
  -- SET @Char1 = 'B'  
  -- SET @Char2 = 'A'  
  -- SET @Flag = 0  
  -- END  
  --END  
    
  --SET @PageCounter = 1  
  --END  
  -------------------------
  
  IF @CurrentAgcus_key = @PreviousAgcus_key AND @CurrentIntSiteNumber != @PreviousIntSiteNumber  
  BEGIN  
	  IF @PageCounter <= 7  
		  BEGIN  
			   IF @Flag = 0 
					BEGIN  
					   SET @Char1 = 'B'  
					   SET @Char2 = 'A'  
					   SET @Flag = 1  
			     
					END  
				ELSE 
					BEGIN  
					   SET @Char1 = 'A'  
					   SET @Char2 = 'B'  
					   SET @Flag = 0  
					END  
			END  
    
		SET @PageCounter = 1  
  END
    
  

    
    
  IF (@CurrentAgcus_key = @PreviousAgcus_key)   
  BEGIN     IF (@CurrentIntSiteNumber != @PreviousIntSiteNumber)  
   BEGIN  
   SET @PageCounter = 1  
   END  
   IF (@CurrentIntSiteNumber = @PreviousIntSiteNumber)  
   BEGIN  
   SET @PageCounter = @PageCounter + 1  
   END  
  END  
    
  IF @PageCounter <= 7 
  BEGIN  
  UPDATE #tmpResult set strPagePart = @Char1 WHERE intLineNumber = @CurrentLineNumber  
  IF @Char1 = 'B'  
  BEGIN  
  DELETE TOP(1)FROM #tmpResult WHERE strPagePart = 'B' AND strLine = '' AND intLineNumber = @CurrentLineNumber  
  Update #tmpResult set strPagePart = 'A', intLineNumber = @CurrentTopLineNumber  WHERE strPagePart = 'B' AND strLine = '' AND intLineNumber = @CurrentLineNumber  
   IF @DetailCount = 11  
   BEGIN  
    DELETE FROM #tmpResult WHERE strPagePart = 'A' AND strLine = '' AND intLineNumber = @CurrentLineNumber  
   END  
  END   
  END  
    
  DECLARE @DetailPageCounter AS INT
  IF @PageCounter > 7  
  BEGIN  
  UPDATE #tmpResult set strPagePart = @Char2 WHERE intLineNumber = @CurrentLineNumber  
  --SET @DetailPageCounter = @PageCounter + 18
  END
  --IF @PageCounter > 21  
  --BEGIN  
  --UPDATE #tmpResult set strPagePart = @Char1 WHERE intLineNumber = @CurrentLineNumber  
  --END
  --  IF @PageCounter > 40  
  --BEGIN  
  --UPDATE #tmpResult set strPagePart = @Char2 WHERE intLineNumber = @CurrentLineNumber  
  --END
    
    
  
  SET @PreviousAgcus_key = @CurrentAgcus_key  
  SET @PreviousIntSiteNumber = @CurrentIntSiteNumber  
  SET @PreviousLineNumber = @CurrentLineNumber  
  DELETE FROM #tmpResultClone  WHERE intLineNumber = @CurrentLineNumber  
   
 END   
   
  
   
 -- Return the data back to the calling application.   
 SELECT *   
 FROM #tmpResult  
 ORDER BY agcus_key, intSiteNumber, intLineNumber ,strLine DESC