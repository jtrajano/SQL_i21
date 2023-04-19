  
CREATE  PROCEDURE [dbo].[uspFRDGenerateCurrenciesRows]                
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
DECLARE @filterAccountsType NVARCHAR(MAX)   
              
CREATE TABLE #TMPFILTER (              
 [intRowDetailId] [INT],              
 [strAccountsType] [nvarchar](50),  
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
ysnForceReversedExpense,ysnOverrideFormula,ysnOverrideColumnFormula,intSort,intConcurrencyId,ysnShowCurrencies,0 intCurrencyID,strCurrency,ysnUnnaturalAccount              
FROM tblFRRowDesign              
WHERE intRowId = @intRowId AND ysnShowCurrencies = 1            
              
BEGIN                
 INSERT INTO #TMPFILTER               
 SELECT intRowDetailId,strAccountsType,REPLACE(REPLACE(REPLACE(REPLACE(strAccountsUsed,'[ID]','strAccountId'),'[Group]','strAccountGroup'),'[Type]','strAccountType'),'[Description]','strDescription')[strFilter] FROM tblFRRowDesign WHERE ysnShowCurrencies 
 = 1 AND intRowId = @intRowId  
              
 WHILE EXISTS(SELECT 1 FROM #TMPFILTER)                     
  BEGIN                 
   SELECT TOP 1 @filterID = [intRowDetailId] From #TMPFILTER                   
   SELECT TOP 1 @filterString = [strFilter] From #TMPFILTER                   
   SELECT TOP 1 @filterAccountsType = [strAccountsType] From #TMPFILTER                   
     
   IF @filterAccountsType  = 'RE'  
    BEGIN   
   SET @queryString = 'SELECT DISTINCT '+@filterID+',intCurrencyId,strCurrency FROM vyuGLSummary WHERE ('+@filterString+' OR strAccountType = ''Revenue'' OR strAccountType = ''Expense'')'   
    END  
   ELSE  
       BEGIN   
   SET @queryString = 'SELECT DISTINCT '+@filterID+',intCurrencyId,strCurrency FROM vyuGLSummary WHERE '+@filterString+''              
    END  
                 
   INSERT INTO #TMPCURRENCIES                       
   EXEC (@queryString)                    
                   
   SET @deleteQueryString = 'DELETE #TMPFILTER WHERE  [intRowDetailId] = '+@filterID+''              
   EXEC (@deleteQueryString)               
  END              
              
 --Final Query              
 INSERT INTO tblFRRowDesignCurrencies              
 SELECT intRowId,intRefNo,strDescription + ' - ' + T1.strCurrency collate SQL_Latin1_General_CP1_CI_AS,strRowType,strBalanceSide,strSource,strRelatedRows,strAccountsUsed,strPercentage,strAccountsType,              
 strDateOverride,ysnShowCredit,ysnShowDebit,ysnShowOthers,ysnLinktoGL,ysnPrintEach,ysnHidden,dblHeight,strFontName,strFontStyle,strFontColor,intFontSize,strOverrideFormatMask,              
 ysnForceReversedExpense,ysnOverrideFormula,ysnOverrideColumnFormula,intSort,intConcurrencyId,ysnShowCurrencies,T1.intCurrencyID,T1.strCurrency,T0.ysnUnnaturalAccount              
 FROM tblFRRowDesign T0              
 INNER JOIN #TMPCURRENCIES T1               
 ON T0.intRowDetailId = T1.intRowDetailId              
              
 DROP TABLE #TMPCURRENCIES              
END  
  
  
  
  