CREATE PROCEDURE  [dbo].[uspFRDCheckUnnatural]        
 @intRowDetailId AS INT,
 @successfulCount AS INT = 0 OUTPUT    
AS        
      
SET QUOTED_IDENTIFIER OFF                
SET ANSI_NULLS ON                
SET NOCOUNT ON                
SET XACT_ABORT ON             
      
      
BEGIN      
	DECLARE @queryString NVARCHAR(MAX)        
	DECLARE @strName NVARCHAR(MAX)    
	DECLARE @strCondition NVARCHAR(MAX)        
	DECLARE @strCriteria NVARCHAR(MAX)        
	DECLARE @intCnt int
	DECLARE @intCntTotal int = 0
       
 CREATE TABLE #tempFormula (            
  [intRowId]  INT,            
  [intRowDetailId]  INT,            
  [strName]  NVARCHAR(150),            
  [strCondition] NVARCHAR(MAX),            
  [strCriteria] NVARCHAR(MAX)            
 );     
 
 CREATE TABLE #tempcnt (            
  [intCnt]  INT,                      
 );  
 
 CREATE TABLE #tempcnt2 (            
  [intCnt]  INT,                      
 );  
        
 --MAIN REPORT      
 
	INSERT INTO #tempFormula      
	SELECT intRowId,intRowDetailId,strName,strCondition,strCriteria FROM tblFRRowDesignFilterAccount WHERE  intRowDetailId = @intRowDetailId      
      
--CREATE A PREDEFINED TABLE      
	WHILE EXISTS(SELECT 1 FROM #tempFormula)        
	BEGIN  
		
		SET @strCondition  = (SELECT TOP 1 strCondition FROM #tempFormula)      
		SET @strCriteria  = (SELECT TOP 1 strCriteria FROM #tempFormula)      

		SET @strName  = (SELECT TOP 1       
		CASE       
		WHEN (strName = 'Primary Account' OR  strName = '[Primary Account]') THEN '[Primary Account]'       
		WHEN (strName = 'Description' OR  strName = '[Description]')  THEN 'strDescription'       
		WHEN (strName = 'Type' OR strName = '[Type]') THEN 'strAccountType'       
		WHEN (strName = 'ID' OR  strName = '[ID]' OR strName = '[ID' ) THEN 'strAccountId'       
		WHEN (strName = 'Group' OR  strName = '[Group]')  THEN 'strAccountGroup'       
		WHEN (strName = 'Location' OR  strName = '[Location]')  THEN 'Location'       
		ELSE strName       
		END FROM #tempFormula)      

		SET @queryString = 'INSERT INTO #tempcnt SELECT count(0) FROM vyuGLSummary WHERE ('+@strName+' '+@strCondition+' '''+@strCriteria+''' ) AND  ISNULL(intUnnaturalAccountId,0) <> 0'       
		EXEC(@queryString)      

		SET @strName  = (SELECT TOP 1       
		CASE       
		WHEN (strName = 'Primary Account' OR  strName = '[Primary Account]') THEN '[UnPrimary Account]'       
		WHEN (strName = 'Description' OR  strName = '[Description]')  THEN 'strUnDescription'       
		WHEN (strName = 'Type' OR strName = '[Type]') THEN 'strUnAccountType'       
		WHEN (strName = 'ID' OR  strName = '[ID]') THEN 'strUnAccountId'       
		WHEN (strName = 'Group' OR  strName = '[Group]')  THEN 'strUnAccountGroup'       
		WHEN (strName = 'Location' OR  strName = '[Location]')  THEN 'UnLocation'       
		ELSE strName       
		END FROM #tempFormula)    

		SET @queryString = 'INSERT INTO #tempcnt2 SELECT count(0) FROM vyuGLSummary WHERE ('+@strName+' '+@strCondition+' '''+@strCriteria+''' ) AND  ISNULL(intUnnaturalAccountId,0) <> 0'       
		EXEC(@queryString)  

		Set @intCnt = 
				(SELECT SUM(intCnt) FROM (
				SELECT intCnt FROM #tempcnt
				UNION ALL 
				SELECT intCnt FROM #tempcnt2
				) A)
		
		SET @intCntTotal = @intCntTotal + @intCnt

		DELETE #tempFormula WHERE intRowDetailId = @intRowDetailId and strCriteria = @strCriteria      
		TRUNCATE TABLE #tempcnt
		TRUNCATE TABLE #tempcnt2
	END

	IF @intCntTotal <> 0
		BEGIN 
			UPDATE tblFRRowDesign set ysnUnnaturalAccount = 1 where intRowDetailId = @intRowDetailId
		END
	ELSE 
		BEGIN 
			UPDATE tblFRRowDesign set ysnUnnaturalAccount = 0 where intRowDetailId = @intRowDetailId
		END

	DROP TABLE #tempFormula
	DROP TABLE #tempcnt
	DROP TABLE #tempcnt2

	set @successfulCount = @intCntTotal

END