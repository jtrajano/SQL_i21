CREATE PROCEDURE [dbo].[uspFRDGenerateCurrenciesRows]            
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
strDateOverride,ysnShowCredit,ysnShowDebit,ysnShowOthers,ysnLinktoGL,ysnPrintEach,ysnHidden,dblHeight,strFontName,strFontStyle,strFontColor,intFontSize,strOverrideFormatMask,          
ysnForceReversedExpense,ysnOverrideFormula,ysnOverrideColumnFormula,intSort,intConcurrencyId,ysnShowCurrencies,'0' intCurrencyID,strCurrency          
FROM tblFRRowDesign          
WHERE intRowId = @intRowId AND ysnShowCurrencies = 1        
          
BEGIN            
 INSERT INTO #TMPFILTER           
 SELECT intRowDetailId,REPLACE(REPLACE(REPLACE(REPLACE(strAccountsUsed,'[ID]','strAccountId'),'[Group]','strAccountGroup'),'[Type]','strAccountType'),'[Description]','strDescription')[strFilter] FROM tblFRRowDesign WHERE ysnShowCurrencies  = 1 AND intRowId = @intRowId          
          
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
 SELECT intRowId,intRefNo,strDescription + ' - ' + T1.strCurrency collate SQL_Latin1_General_CP1_CI_AS,strRowType,strBalanceSide,strSource,strRelatedRows,strAccountsUsed,strPercentage,strAccountsType,          
 strDateOverride,ysnShowCredit,ysnShowDebit,ysnShowOthers,ysnLinktoGL,ysnPrintEach,ysnHidden,dblHeight,strFontName,strFontStyle,strFontColor,intFontSize,strOverrideFormatMask,          
 ysnForceReversedExpense,ysnOverrideFormula,ysnOverrideColumnFormula,intSort,intConcurrencyId,ysnShowCurrencies,T1.intCurrencyId,T1.strCurrency          
 FROM tblFRRowDesign T0          
 INNER JOIN #TMPCURRENCIES T1           
 ON T0.intRowDetailId = T1.intRowDetailId          
          
 DROP TABLE #TMPCURRENCIES          
END  