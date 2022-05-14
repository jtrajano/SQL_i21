CREATE PROCEDURE  [dbo].[uspFRDGetLedger]          
 @strFilterString AS NVARCHAR(MAX),  
 @strLedger AS NVARCHAR(MAX)= '' OUTPUT      
AS          
        
SET QUOTED_IDENTIFIER OFF                  
SET ANSI_NULLS ON                  
SET NOCOUNT ON                  
SET XACT_ABORT ON                     
        
BEGIN        
	DECLARE @queryString NVARCHAR(MAX)          
       
	CREATE TABLE #tempLedger(              
		[intLedgerId]  INT,                        
	);     

	SET @strFilterString = REPLACE(REPLACE(REPLACE(REPLACE(@strFilterString,'[ID]','strAccountId'),'[Group]','strAccountGroup'),'[Type]','strAccountType'),'[Description]','strDescription')
	SET @queryString = 'INSERT INTO #tempLedger SELECT TOP 1 intLedgerId FROM vyuGLSummary WHERE  '+@strFilterString+' AND intLedgerId <> 0'         
	EXEC(@queryString)    

	WHILE EXISTS(SELECT 1 FROM #tempLedger)          
	BEGIN    	   
		SET @strLedger = (SELECT strLedgerName FROM tblGLLedger WHERE intLedgerId = (SELECT TOP 1 intLedgerId FROM #tempLedger))
		DELETE #tempLedger WHERE intLedgerId = (SELECT TOP 1 intLedgerId FROM #tempLedger)
	END 
	DROP TABLE #tempLedger
END