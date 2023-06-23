CREATE PROCEDURE [dbo].[uspGLGetBeginningBalanceOverrideFiscal] (
    @dtmDate DATETIME = NULL,  
    @dtmOverrideFiscalEndDate DATETIME = NULL, -- end date should be a day after the last fiscal end date or have 23:59:59  time  
    @strAccountWhere NVARCHAR(MAX),  
    @strType NVARCHAR(10) ,
	@strFormula NVARCHAR(MAX),
	@strField NVARCHAR(MAX),      
	@strSegmentFilter NVARCHAR(MAX)
    )  AS  
  BEGIN  
       DECLARE @intAccountId INT  
	   DECLARE @execQueryString NVARCHAR(MAX) = ''
       DECLARE @whereParam NVARCHAR(MAX) = 'SELECT intAccountId,strAccountId FROM vyuGLAccountDetail where ' + @strAccountWhere  + @strSegmentFilter
	   CREATE TABLE #tblAccount ( intAccountId INT, strAccountId NVARCHAR(40) COLLATE Latin1_General_CI_AS NOT NULL  );
	   INSERT INTO #tblAccount EXEC(@whereParam)  
       DECLARE @dtmOverrideFiscalStartDate DATETIME  
	   print(@whereParam)
	   
		CREATE TABLE #TempTable ( intAccountId INT, strAccountId NVARCHAR(40) COLLATE Latin1_General_CI_AS NOT NULL  );
		INSERT INTO #TempTable EXEC(@whereParam)  

       IF @dtmOverrideFiscalEndDate  IS NOT NULL  
              SELECT @dtmOverrideFiscalStartDate = CAST ( DATEADD(YEAR, -1, @dtmOverrideFiscalEndDate) AS DATE)  
              IF @dtmDate < @dtmOverrideFiscalStartDate  
              BEGIN  
                     DECLARE @error NVARCHAR(500) = 'Date parameter should be later than ' + CONVERT( NVARCHAR(10), @dtmOverrideFiscalStartDate , 101)  
                     RAISERROR ( @error, 11,1)  
                     RETURN  
              END  
       ELSE  
       BEGIN  
              SELECT TOP 1 @dtmOverrideFiscalStartDate = dtmDateFrom,@dtmOverrideFiscalEndDate = dtmDateTo   
              FROM tblGLFiscalYear where @dtmDate >= dtmDateFrom AND @dtmDate <= dtmDateTo  
       END  
  
       IF ( @strType= 'RE')-- get balance before fiscal start date  
       BEGIN  
			  SET @execQueryString = '
              ;WITH cte AS(  
              SELECT   
                    '+ @strFormula +' AS  '+ @strField +'
              FROM   tblGLDetail C JOIN #tblAccount A ON A.intAccountId = C.intAccountId  
              AND dtmDate < ''' + CAST(@dtmDate AS NVARCHAR(100)) + '''
              AND ysnIsUnposted = 0  
              AND ISNULL(strCode, '''') <> ''''  
              UNION ALL  
              SELECT   
                    '+ @strFormula +' AS  '+ @strField +'
              FROM   vyuGLDetail C   
              WHERE   
              dtmDate < ''' + CAST(@dtmOverrideFiscalStartDate AS NVARCHAR(100)) + '''
              AND ysnIsUnposted = 0  
              AND ISNULL(strCode,  '''') <>  ''''  
              AND strAccountType IN (''Expense'', ''Revenue'')  
              )  
              SELECT  SUM('+ @strField +') AS '+ @strField +' 
              FROM cte '

       END  
  
       ELSE  
       IF ( @strType= 'CY')-- get balance before fiscal start date  
       BEGIN       
	        
              SET @execQueryString = 'SELECT 
				'+ @strFormula +' AS  '+ @strField +'
               FROM   tblGLDetail C JOIN #tblAccount A ON A.intAccountId = C.intAccountId  
               AND dtmDate BETWEEN  ''' + CAST(@dtmOverrideFiscalStartDate AS NVARCHAR(100)) + '''  AND  ''' + CAST(@dtmDate AS NVARCHAR(100)) + '''
               AND ysnIsUnposted = 0  
               AND ISNULL(strCode, '''') <> '''' '

			   			   
       END  
       ELSE  
       BEGIN  
				SET @execQueryString = 'SELECT   
					'+ @strFormula +' AS  '+ @strField +'
				   FROM   tblGLDetail C JOIN  #tblAccount A ON A.intAccountId = C.intAccountId  
				   AND dtmDate < ''' + CAST(@dtmDate AS NVARCHAR(100)) + '''
				   AND ysnIsUnposted = 0  
				   AND ISNULL(strCode, '''') <> '''' '								
				
       END  
	   EXEC(@execQueryString)
	   DROP TABLE #TempTable
 END
