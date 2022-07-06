CREATE PROCEDURE [dbo].[uspFRDGenerateCurrenciesPrintEach]            
 @intRowId   AS INT          
AS            
            
SET QUOTED_IDENTIFIER OFF            
SET ANSI_NULLS ON            
SET NOCOUNT ON            
SET XACT_ABORT ON            
          
DECLARE @queryString NVARCHAR(MAX)              
DECLARE @deleteQueryString NVARCHAR(MAX)              
DECLARE @filterString NVARCHAR(MAX)            
DECLARE @filterID NVARCHAR(MAX)            
          
CREATE TABLE #TMPFILTER (          
 [intRowDetailId] [INT],          
 [strFilter] [nvarchar](max)           
);           
          
CREATE TABLE #TMPCURRENCIES (            
 [intRowDetailId]  [INT],            
 [intCurrencyID]  [INT],            
 [strCurrency] [nvarchar](50)           
);           
            
DELETE tblFRRowDesignCurrencies WHERE intRowId = @intRowId          
        
INSERT INTO tblFRRowDesignCurrencies        
SELECT intRowId,intRefNo,strDescription,strRowType,strBalanceSide,strSource,strRelatedRows,strAccountsUsed,strPercentage,strAccountsType,          
NULL as strDateOverride,ysnShowCredit,ysnShowDebit,ysnShowOthers,ysnLinktoGL,ysnPrintEach,ysnHidden,dblHeight,strFontName,strFontStyle,strFontColor,intFontSize,strOverrideFormatMask,          
ysnForceReversedExpense,ysnOverrideFormula,ysnOverrideColumnFormula,intSort,intConcurrencyId,ysnShowCurrencies,'0' intCurrencyID,strCurrency          
FROM tblFRRowDesignDrillDown          
WHERE intRowId = @intRowId AND ysnShowCurrencies = 1        
          
BEGIN            
 INSERT INTO #TMPFILTER           
 SELECT intRowDetailId,REPLACE(REPLACE(REPLACE(REPLACE(strAccountsUsed,'[ID]','strAccountId'),'[Group]','strAccountGroup'),'[Type]','strAccountType'),'[Description]','strDescription')[strFilter] FROM tblFRRowDesignDrillDown WHERE ysnShowCurrencies  = 1 AND intRowId = @intRowId  
          
 WHILE EXISTS(SELECT 1 FROM #TMPFILTER)                 
  BEGIN             
   SELECT TOP 1 @filterID = [intRowDetailId] From #TMPFILTER               
   SELECT TOP 1 @filterString = [strFilter] From #TMPFILTER               
          
   SET @queryString = 'SELECT DISTINCT '+@filterID+',intCurrencyId,strCurrency FROM vyuGLSummary WHERE '+@filterString+''          
   INSERT INTO #TMPCURRENCIES                   
   EXEC (@queryString)                
               
   SET @deleteQueryString = 'DELETE #TMPFILTER WHERE  [intRowDetailId] = '+@filterID+''          
   EXEC (@deleteQueryString)           
  END          
          
 --Final Query          
 INSERT INTO tblFRRowDesignCurrencies          
 SELECT T0.intRowId,intRefNo,strDescription + ' - ' + T1.strCurrency collate SQL_Latin1_General_CP1_CI_AS,strRowType,strBalanceSide,strSource,strRelatedRows,strAccountsUsed,strPercentage,strAccountsType,          
 NULL as strDateOverride,ysnShowCredit,ysnShowDebit,ysnShowOthers,ysnLinktoGL,ysnPrintEach,ysnHidden,dblHeight,strFontName,strFontStyle,strFontColor,intFontSize,strOverrideFormatMask,          
 ysnForceReversedExpense,ysnOverrideFormula,ysnOverrideColumnFormula,intSort,intConcurrencyId,ysnShowCurrencies,T1.intCurrencyID,T1.strCurrency  
 FROM tblFRRowDesignDrillDown T0          
 INNER JOIN #TMPCURRENCIES T1           
 ON T0.intRowDetailId = T1.intRowDetailId          
           
 DROP TABLE #TMPCURRENCIES          
END