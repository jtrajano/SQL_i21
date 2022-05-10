CREATE PROCEDURE  [dbo].[uspFRDUnnaturalAccoutAmount]    
	@strFormula AS VARCHAR(max),  
	@intRowDetailId AS INT,  
	@dtmBeginDate AS VARCHAR(max),  
	@dtmEndDate AS VARCHAR(max),    
	@intReportType AS INT,  
	@strLocation AS NVARCHAR(max) = null,            
	@intCurrencyID AS INT,            
	@totalAmount AS NUMERIC(20,6) = 0 OUTPUT  
AS    
  
SET QUOTED_IDENTIFIER OFF            
SET ANSI_NULLS ON            
SET NOCOUNT ON            
SET XACT_ABORT ON         
  
  
BEGIN  
	DECLARE @queryString NVARCHAR(MAX)    
	DECLARE @strName NVARCHAR(MAX)    
	DECLARE @strNameAlt NVARCHAR(MAX)    
	DECLARE @strCondition NVARCHAR(MAX)    
	DECLARE @strCriteria NVARCHAR(MAX)    
	DECLARE @strCriteriaAlt NVARCHAR(MAX)  
	DECLARE @strCurrency NVARCHAR(MAX) 
	DECLARE @dblAmount NUMERIC(20,6)   
	DECLARE @intUnnaturalAccountId INT  
	DECLARE @intStart INT  
	DECLARE @intEnd INT  
   
	CREATE TABLE #tempFormula (        
		[intRowId]  INT,        
		[intRowDetailId]  INT,        
		[strName]  NVARCHAR(150),        
		[strCondition] NVARCHAR(MAX),        
		[strCriteria] NVARCHAR(MAX)        
	);     
  
	CREATE TABLE #tempFormula2 (        
		[intRowId]  INT,        
		[intRowDetailId]  INT,        
		[strName]  NVARCHAR(150),        
		[strCondition] NVARCHAR(MAX),        
		[strCriteria] NVARCHAR(MAX)        
	);     
    
	CREATE TABLE #tempAmount (        
		[Amount] NUMERIC(20,6),  
		[strCriteria] NVARCHAR(MAX),  
		[intUnnaturalAccountId] INT,  
		[strCriteriaToAdd] NVARCHAR(MAX)   
	);     
  
	CREATE TABLE #tempAmount2 (        
		[Amount] NUMERIC(20,6),  
		[intUnnaturalAccountId] INT  
	);     
  
	CREATE TABLE #tempFormulaConcat (        
		[Formula] NVARCHAR(MAX)      
	);     

	SET @strCurrency = CASE WHEN @intCurrencyID = 0 THEN '' ELSE ' AND [intCurrencyId] = '''+ CAST(@intCurrencyID AS VARCHAR(10))+'''' END       
  
	--MAIN REPORT  
	IF @intReportType = 0  
		BEGIN   
			INSERT INTO #tempFormula  
			SELECT intRowId,intRowDetailId,strName,strCondition,strCriteria FROM tblFRRowDesignFilterAccount WHERE  intRowDetailId = @intRowDetailId  
  
			INSERT INTO #tempFormula2  
			SELECT intRowId,intRowDetailId,strName,strCondition,strCriteria FROM tblFRRowDesignFilterAccount WHERE  intRowDetailId = @intRowDetailId  
		END  
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------  
	--DRILLDOWN REPORT  
	IF @intReportType = 1  
		BEGIN   
  
			INSERT INTO #tempFormulaConcat  
			SELECT * FROM dbo.splitstring((SELECT LTRIM(REPLACE(REPLACE(strAccountsUsed,'Or',','),'And',','))  FROM tblFRRowDesignDrillDown WHERE  intRowDetailId = @intRowDetailId  ))  
			WHILE EXISTS(SELECT 1 FROM #tempFormulaConcat)    
			BEGIN   
				SET @intStart = (SELECT CHARINDEX('[',(SELECT TOP 1 Formula FROM #tempFormulaConcat)))  
				SET @intEnd  = (SELECT CHARINDEX(']',(SELECT TOP 1 Formula FROM #tempFormulaConcat)))   
				SET @strName = (SELECT SUBSTRING((SELECT TOP 1 Formula FROM #tempFormulaConcat),@intStart,@intEnd))  
				SET @strCondition  =  '='  
				SET @strCriteria = REPLACE((SELECT TOP 1 Formula FROM #tempFormulaConcat),@strName,'')  
				SET @strCriteria = REPLACE(@strCriteria,'=' , '')  
				SET @strCriteria = REPLACE(@strCriteria,'''' , '')  
  
				INSERT INTO #tempFormula  
				SELECT TOP 1 intRowId,intRowDetailId,@strName,@strCondition,LTRIM(@strCriteria) FROM tblFRRowDesignDrillDown WHERE  intRowDetailId = @intRowDetailId  
  
				INSERT INTO #tempFormula2  
				SELECT TOP 1 intRowId,intRowDetailId,@strName,@strCondition,LTRIM(@strCriteria) FROM tblFRRowDesignDrillDown WHERE  intRowDetailId = @intRowDetailId  
				DELETE #tempFormulaConcat WHERE Formula = (SELECT TOP 1 Formula FROM #tempFormulaConcat)  
			END  
		DROP TABLE #tempFormulaConcat  
	END  
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------  
	--PRINTEACH REPORT  
	IF @intReportType = 2  
		BEGIN   
  
		INSERT INTO #tempFormulaConcat  
		SELECT * FROM dbo.splitstring((SELECT LTRIM(REPLACE(REPLACE(strAccountsUsed,'Or',','),'And',','))  FROM tblFRRowDesignPrintEach WHERE  intRowDetailId = @intRowDetailId  ))  
		WHILE EXISTS(SELECT 1 FROM #tempFormulaConcat)    
			BEGIN   
				SET @intStart = (SELECT CHARINDEX('[',(SELECT TOP 1 Formula FROM #tempFormulaConcat)))  
				SET @intEnd  = (SELECT CHARINDEX(']',(SELECT TOP 1 Formula FROM #tempFormulaConcat)))   
				SET @strName = (SELECT SUBSTRING((SELECT TOP 1 Formula FROM #tempFormulaConcat),@intStart,@intEnd))  
				SET @strCondition  =  '='  
				SET @strCriteria = REPLACE((SELECT TOP 1 Formula FROM #tempFormulaConcat),@strName,'')  
				SET @strCriteria = REPLACE(@strCriteria,'=' , '')  
				SET @strCriteria = REPLACE(@strCriteria,'''' , '')  
  
				INSERT INTO #tempFormula  
				SELECT TOP 1 intRowId,intRowDetailId,@strName,@strCondition,LTRIM(@strCriteria) FROM tblFRRowDesignPrintEach WHERE  intRowDetailId = @intRowDetailId  
  
				INSERT INTO #tempFormula2  
				SELECT TOP 1 intRowId,intRowDetailId,@strName,@strCondition,LTRIM(@strCriteria) FROM tblFRRowDesignPrintEach WHERE  intRowDetailId = @intRowDetailId  
				DELETE #tempFormulaConcat WHERE Formula = (SELECT TOP 1 Formula FROM #tempFormulaConcat)  
			END  
		DROP TABLE #tempFormulaConcat  
	END  
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------  
--CURRENCIES REPORT  
	IF @intReportType = 3  
		BEGIN   
  
		INSERT INTO #tempFormulaConcat  
		SELECT * FROM dbo.splitstring((SELECT LTRIM(REPLACE(REPLACE(strAccountsUsed,'Or',','),'And',','))  FROM tblFRRowDesignCurrencies WHERE  intRowDetailId = @intRowDetailId  ))  
		WHILE EXISTS(SELECT 1 FROM #tempFormulaConcat)    
			BEGIN   
				SET @intStart = (SELECT CHARINDEX('[',(SELECT TOP 1 Formula FROM #tempFormulaConcat)))  
				SET @intEnd  = (SELECT CHARINDEX(']',(SELECT TOP 1 Formula FROM #tempFormulaConcat)))   
				SET @strName = (SELECT SUBSTRING((SELECT TOP 1 Formula FROM #tempFormulaConcat),@intStart,@intEnd))  
				SET @strCondition  =  '='  
				SET @strCriteria = REPLACE((SELECT TOP 1 Formula FROM #tempFormulaConcat),@strName,'')  
				SET @strCriteria = REPLACE(@strCriteria,'=' , '')  
				SET @strCriteria = REPLACE(@strCriteria,'''' , '')  
  
				INSERT INTO #tempFormula  
				SELECT TOP 1 intRowId,intRowDetailId,@strName,@strCondition,LTRIM(@strCriteria) FROM tblFRRowDesignCurrencies WHERE  intRowDetailId = @intRowDetailId  
  
				INSERT INTO #tempFormula2  
				SELECT TOP 1 intRowId,intRowDetailId,@strName,@strCondition,LTRIM(@strCriteria) FROM tblFRRowDesignCurrencies WHERE  intRowDetailId = @intRowDetailId  
				DELETE #tempFormulaConcat WHERE Formula = (SELECT TOP 1 Formula FROM #tempFormulaConcat)  
			END  
		DROP TABLE #tempFormulaConcat  
	END  
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------    
--1ST ACCOUNT , SENDER
	WHILE EXISTS(SELECT 1 FROM #tempFormula)    
		BEGIN    
			SET @strName  = (SELECT TOP 1   
			CASE   
			WHEN (strName = 'Primary Account' OR  strName = '[Primary Account]') THEN '[Primary Account]'   
			WHEN (strName = 'Description' OR  strName = '[Description]')  THEN 'strDescription'   
			WHEN (strName = 'Type' OR strName = '[Type]') THEN 'strAccountType'   
			WHEN (strName = 'ID' OR  strName = '[ID]') THEN 'strAccountId'   
			WHEN (strName = 'Group' OR  strName = '[Group]')  THEN 'strAccountGroup'   
			WHEN (strName = 'Location' OR  strName = '[Location]')  THEN 'Location'   
			ELSE strName   
			END FROM #tempFormula)  
  
			SET @strCondition  = (SELECT TOP 1 strCondition FROM #tempFormula)  
			SET @strCriteria  = (SELECT TOP 1 strCriteria FROM #tempFormula)  
  
			INSERT INTO #tempAmount   
			SELECT 0,@strCriteria,0,0  
  
			SET @queryString = 'UPDATE #tempAmount SET Amount = (SELECT '+@strFormula+' FROM vyuGLSummary WHERE CAST(FLOOR(CAST(dtmDate AS float)) AS datetime)   
			BETWEEN '''+@dtmBeginDate+''' AND '''+@dtmEndDate+''' AND  ('+@strName+' '+@strCondition+' '''+@strCriteria+''' ) AND  strCode NOT IN (''CY'', ''RE'')  AND vyuGLSummary.strCode <> ''AA'' AND ISNULL(intUnnaturalAccountId,0) = 0 '+@strLocation+' '+@strCurrency+') ,  
			intUnnaturalAccountId = (SELECT TOP 1 intUnnaturalAccountId FROM vyuGLSummary   
			WHERE CAST(FLOOR(CAST(dtmDate AS float)) AS datetime) BETWEEN '''+@dtmBeginDate+''' AND '''+@dtmEndDate+'''   
			AND  ('+@strName+' '+@strCondition+' '''+@strCriteria+''' ) AND  strCode NOT IN (''CY'', ''RE'')  AND vyuGLSummary.strCode <> ''AA'')  
			WHERE strCriteria = '''+@strCriteria+''''    
			EXEC(@queryString)    
     
			DELETE #tempFormula WHERE intRowDetailId = @intRowDetailId and strCriteria = @strCriteria  
		END   
 ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------    
--2ND ACCOUNT , RECEIVER      
	WHILE EXISTS(SELECT 1 FROM #tempFormula2)    
		BEGIN  
			SET @strCriteria  = (SELECT TOP 1 strCriteria FROM #tempFormula2)  
			SET @dblAmount = (SELECT TOP 1 Amount FROM #tempAmount WHERE strCriteria = @strCriteria )  
			SET @intUnnaturalAccountId = (SELECT TOP 1 intUnnaturalAccountId FROM #tempAmount WHERE strCriteria = @strCriteria )  
  
			IF @dblAmount < 0 AND ISNULL(@intUnnaturalAccountId,0) <> 0  
				BEGIN   
					UPDATE #tempAmount SET Amount = 0 WHERE strCriteria = @strCriteria  
				END  

			IF @dblAmount >= 0  
				BEGIN   
      
					SET @strName  = (SELECT TOP 1   
						CASE   
						WHEN (strName = 'Primary Account' OR  strName = '[Primary Account]') THEN '[UnPrimary Account]'   
						WHEN (strName = 'Description' OR  strName = '[Description]')  THEN 'strUnDescription'   
						WHEN (strName = 'Type' OR strName = '[Type]') THEN 'strUnAccountType'   
						WHEN (strName = 'ID' OR  strName = '[ID]') THEN 'strUnAccountId'   
						WHEN (strName = 'Group' OR  strName = '[Group]')  THEN 'strUnAccountGroup'   
						WHEN (strName = 'Location' OR  strName = '[Location]')  THEN 'UnLocation'   
						ELSE strName   
						END FROM #tempFormula2)  
  
					SET @strCondition  = (SELECT TOP 1 strCondition FROM #tempFormula2)  
					SET @strCriteria  = (SELECT TOP 1 strCriteria FROM #tempFormula2)  
  
					SET @queryString = 'INSERT INTO #tempAmount2 SELECT '+@strFormula+',intUnnaturalAccountId FROM vyuGLSummary WHERE CAST(FLOOR(CAST(dtmDate AS float)) AS datetime)   
					BETWEEN '''+@dtmBeginDate+''' AND '''+@dtmEndDate+''' AND  ('+@strName+' '+@strCondition+' '''+@strCriteria+''' ) AND  strCode NOT IN (''CY'', ''RE'')  AND vyuGLSummary.strCode <> ''AA'' '+@strLocation+' '+@strCurrency+'   
					GROUP BY intUnnaturalAccountId  '  
					EXEC(@queryString)   
         
					SET @dblAmount  = (SELECT TOP 1 Amount FROM #tempAmount2)  
					SET @intUnnaturalAccountId  = (SELECT TOP 1 intUnnaturalAccountId FROM #tempAmount2)  
                
				IF ISNULL(@intUnnaturalAccountId,0) <> 0  
					BEGIN   
						UPDATE #tempAmount SET Amount = Amount + ABS(@dblAmount) WHERE strCriteria = @strCriteria   
					END                       
				TRUNCATE TABLE #tempAmount2  
			END  
			DELETE #tempFormula2 WHERE intRowDetailId = @intRowDetailId and strCriteria = @strCriteria  
		END
		
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------    
--SUM UP
	DROP TABLE #tempFormula    
	DROP TABLE #tempFormula2  
	SET @totalAmount = (SELECT SUM(Amount) FROM #tempAmount)     
	DROP TABLE #tempAmount       
END    
