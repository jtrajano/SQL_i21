CREATE PROCEDURE [dbo].[uspPRImportEmployeePaycheck](        
    @guiApiUniqueId UNIQUEIDENTIFIER,        
    @guiLogId UNIQUEIDENTIFIER         
)        
        
AS        
        
BEGIN        
--DECLARE @guiApiUniqueId UNIQUEIDENTIFIER = N'30278E67-E6EB-4122-8F66-3251689D711F'        
--DECLARE @guiLogId UNIQUEIDENTIFIER = NEWID()        
DECLARE @NewId AS INT        
DECLARE @EmployeeEntityNo AS INT        
DECLARE @intEntityNo AS INT       
DECLARE @intEntityNoW2 AS INT      
DECLARE @intOriginalPaycheckId AS INT        
      
DECLARE @intTaxCount AS INT        
DECLARE @intEarningCount AS INT      
DECLARE @intEarningTaxToCount AS INT      
DECLARE @intDeductionCount AS INT        
DECLARE @intNewPaycheckId AS INT        
DECLARE @intEmployeeDeductionId AS INT      
DECLARE @intEmployeeEarningId AS INT     
DECLARE @intEmployeeEarningTaxId AS INT     
DECLARE @intEmployeeTaxId AS INT   
DECLARE @intW2Recompute AS INT    
DECLARE @intYear AS INT    
      
DECLARE @strEmployeeId AS NVARCHAR(100)        
DECLARE @strEmployeeIdW2 AS NVARCHAR(100)   
DECLARE @strRecordType AS NVARCHAR(100)        
DECLARE @strRecordId AS NVARCHAR(100)       
DECLARE @strAccountId AS NVARCHAR(100)        
DECLARE @strExpenseAccountId AS NVARCHAR(100)        
DECLARE @strBankAccountNumber AS NVARCHAR(100)        
DECLARE @strReferenceNumber AS NVARCHAR(100)        
DECLARE @strPaycheckId NVARCHAR(50)       
DECLARE @strPaycheckEarningId NVARCHAR(50)      
DECLARE @strPayGroupIds AS NVARCHAR(MAX)        
DECLARE @strDepartmentIds AS NVARCHAR(MAX)        
DECLARE @strExcludeDeductions AS NVARCHAR(MAX)        
      
DECLARE @dblEarningHour AS FLOAT(50)         
DECLARE @dblAmount AS FLOAT(50)         
DECLARE @dblTotal AS FLOAT(50)  
DECLARE @dblTaxableAmount AS FLOAT(50)  
  
      
DECLARE @dtmPayDate AS NVARCHAR(100)        
DECLARE @dtmPayFrom AS NVARCHAR(100)        
DECLARE @dtmPayTo AS NVARCHAR(100)        
      
DECLARE @EmployeeCount AS INT        
      
DECLARE @ysnPost AS BIT        
DECLARE @ysnImportEarning AS BIT        
DECLARE @ysnImportDeduction AS BIT        
DECLARE @ysnImportTax AS BIT        
DECLARE @ysnImportPaycheck AS BIT      
     
      
DECLARE @xmlDepartments XML         
DECLARE @xmlPayGroups XML          
DECLARE @xmlExcludeDeductions XML           
      
       
DECLARE @intUserId AS INT        
DECLARE @PaycheckGroupId AS INT        
      
        
INSERT INTO tblApiImportLogDetail(guiApiImportLogDetailId,guiApiImportLogId, strField,strValue,strLogLevel,strStatus,intRowNo,strMessage)        
SELECT        
 guiApiImportLogDetailId = NEWID()        
 ,guiApiImportLogId = @guiLogId        
 ,strField  = 'Employee ID'        
 ,strValue  = SE.strEntityNo        
 ,strLogLevel  = 'Error'        
 ,strStatus  = 'Failed'        
 ,intRowNo  = SE.intRowNumber        
 ,strMessage  = 'Cannot find the Employee Entity No: '+ CAST(ISNULL(SE.strEntityNo, '') AS NVARCHAR(100)) + '.'        
 FROM tblApiSchemaEmployeePaycheck SE        
 LEFT JOIN tblPRPaycheck E ON E.intEntityEmployeeId = (SELECT TOP 1 intEntityId FROM tblPREmployee WHERE strEmployeeId = SE.strEntityNo)        
 WHERE SE.guiApiUniqueId = @guiApiUniqueId        
 AND SE.strEntityNo IS NULL        
       
--GETING ALL DATA  
IF EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#TempEmployeePaycheck'))         
DROP TABLE #TempEmployeePaycheck         
        
SELECT * INTO #TempEmployeePaycheck FROM tblApiSchemaEmployeePaycheck where guiApiUniqueId = @guiApiUniqueId  
order by intOriginalPaycheckId ASC        
      
--GETTING ALL ORIGINAL ID  
IF EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#TempPaycheckGroupId'))         
DROP TABLE #TempPaycheckGroupId      
  
--GETTING ALL data and group in year  
IF EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#TempPaycheckGroupYear'))         
DROP TABLE #TempPaycheckGroupYear    
  
SELECT YEAR(dtmPayDate) AS intYear,strEntityNo INTO #TempPaycheckGroupYear FROM tblApiSchemaEmployeePaycheck 
GROUP BY YEAR(dtmPayDate),strEntityNo  
  
      
SELECT intOriginalPaycheckId INTO #TempPaycheckGroupId FROM tblApiSchemaEmployeePaycheck where guiApiUniqueId = @guiApiUniqueId       
GROUP BY intOriginalPaycheckId      
ORDER By intOriginalPaycheckId ASC    
    
WHILE EXISTS(SELECT TOP 1 NULL FROM #TempEmployeePaycheck)        
BEGIN      
 SELECT TOP 1 @PaycheckGroupId = intOriginalPaycheckId FROM #TempPaycheckGroupId    
  
 --GETTING ALL DATA FILTERED WITH ORIGINAL ID  
 IF EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#TempEmployeePaycheckPerGroup'))         
 DROP TABLE #TempEmployeePaycheckPerGroup   
  
 SELECT * INTO #TempEmployeePaycheckPerGroup FROM #TempEmployeePaycheck  
 WHERE intOriginalPaycheckId = @PaycheckGroupId  
  
 WHILE EXISTS(SELECT TOP 1 NULL FROM #TempEmployeePaycheckPerGroup)  
 BEGIN  
   --DECLARE @ysnImportPaycheck AS BIT      
   SELECT TOP 1   
   @ysnImportPaycheck = COUNT(strEntityNo)   
   FROM #TempEmployeePaycheckPerGroup WHERE intOriginalPaycheckId = @PaycheckGroupId AND strRecordType = 'PAYCHECK'    
  
   IF(@ysnImportPaycheck = 1)  
   BEGIN  
   EXEC uspSMGetStartingNumber 32, @strPaycheckId OUT  
  
   SELECT TOP 1         
     @strEmployeeId   = LTRIM(RTRIM(strEntityNo))        
    ,@intEntityNo   = (SELECT TOP 1 intEntityId FROM tblPREmployee WHERE strEmployeeId = LTRIM(RTRIM(strEntityNo)))        
    ,@intOriginalPaycheckId = intOriginalPaycheckId        
    ,@strRecordType   = CASE WHEN strRecordType <> '' AND strRecordType         
    IN(        
    'PAYCHECK',        
    'EARNING',     
    'EARNING TAX',   
    'DEDUCTION',        
    'TAX'        
    ) THEN strRecordType ELSE '' END        
    ,@strRecordId   = strRecordId        
    ,@dblEarningHour  = dblEarningHour        
    ,@dblAmount    = dblAmount        
    ,@dblTotal    = dblTotal       
    ,@dblTaxableAmount = dblTaxableAmount  
    ,@dtmPayDate   = CAST(dtmPayDate AS NVARCHAR)         
    ,@dtmPayFrom   = CAST(dtmPayFrom AS NVARCHAR)         
    ,@dtmPayTo    = CAST(dtmPayTo AS NVARCHAR)         
    ,@strAccountId   = LTRIM(RTRIM(strAccountId))        
    ,@strExpenseAccountId = LTRIM(RTRIM(strExpenseAccountId))        
    ,@strBankAccountNumber = LTRIM(RTRIM(strBankAccountNumber))        
    ,@strReferenceNumber = LTRIM(RTRIM(strReferenceNumber))        
   FROM #TempEmployeePaycheck       
   WHERE intOriginalPaycheckId = @PaycheckGroupId      
   AND strRecordType = 'PAYCHECK'   
  
   INSERT INTO [dbo].[tblPRPaycheck]              
    ([strPaycheckId]              
    ,[intEntityEmployeeId]              
    ,[dtmPayDate]              
    ,[strPayPeriod]              
    ,[dtmDateFrom]              
    ,[dtmDateTo]              
    ,[intBankAccountId]              
    ,[strReferenceNo]              
    ,[dblTotalHours]              
    ,[dblGross]              
    ,[dblAdjustedGross]              
    ,[dblTaxTotal]              
    ,[dblDeductionTotal]              
    ,[dblNetPayTotal]              
    ,[dblCompanyTaxTotal]              
    ,[dtmPosted]              
    ,[ysnPosted]              
    ,[ysnPrinted]              
    ,[ysnVoid]              
    ,[ysnDirectDeposit]              
    ,[intCreatedUserId]              
    ,[dtmCreated]              
    ,[intLastModifiedUserId]              
    ,[dtmLastModified]              
    ,[intConcurrencyId])              
   VALUES              
    (@strPaycheckId              
    ,@intEntityNo              
    ,CONVERT(DATE, @dtmPayDate)    
    ,(SELECT TOP 1 strPayPeriod FROM tblPREmployee WHERE intEntityId = @intEntityNo)              
    ,CONVERT(DATE, @dtmPayFrom)   
    ,CONVERT(DATE, @dtmPayTo)            
    ,(SELECT TOP 1 intBankAccountId FROM tblPRPayGroup WHERE strPayGroup = (SELECT TOP 1 strPayPeriod FROM tblPREmployee where intEntityId = @intEntityNo))           
    ,''              
    ,0              
    ,0              
    ,0              
    ,0              
    ,0              
    ,0              
    ,0              
    ,CONVERT(DATE, @dtmPayDate)               
    ,1              
    ,0              
    ,0    
    ,0          
    ,@intUserId      -- int user id temporary        
    ,GETDATE()              
    ,@intUserId      -- int user id temporary        
    ,GETDATE()              
    ,1 )  
   SET @intNewPaycheckId = SCOPE_IDENTITY()    
   --SET @ysnImportPaycheck = 0    
  
   INSERT INTO tblApiImportLogDetail (guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage)        
   SELECT TOP 1        
    NEWID()        
    , guiApiImportLogId = @guiLogId        
    , strField = 'Paycheck Record'        
    , strValue = @strRecordType        
    , strLogLevel = 'Info'        
    , strStatus = 'Success'        
    , intRowNo = SE.intRowNumber        
    , strMessage = 'The employee paycheck record ('+ @strPaycheckId +') has been successfully imported.'        
   FROM tblApiSchemaEmployeePaycheck SE        
   LEFT JOIN tblPRPaycheck E ON E.intEntityEmployeeId = (SELECT TOP 1 intEntityId FROM tblPREmployee WHERE strEmployeeId = @strEmployeeId)        
   WHERE SE.guiApiUniqueId = @guiApiUniqueId        
   AND SE.strRecordId = @strRecordId    
  
        
     
     
  
   DELETE FROM #TempEmployeePaycheckPerGroup WHERE intOriginalPaycheckId = @PaycheckGroupId AND strRecordType = @strRecordType and strEntityNo = @strEmployeeId AND strRecordId = @strRecordId  
   DELETE FROM #TempEmployeePaycheck WHERE intOriginalPaycheckId = @PaycheckGroupId AND strRecordType = @strRecordType and strEntityNo = @strEmployeeId AND strRecordId = @strRecordId  
   END  
   ELSE  
   BEGIN  
  
   SELECT TOP 1       
      @strEmployeeId   = LTRIM(RTRIM(strEntityNo))      
     ,@intEntityNo   = (SELECT TOP 1 intEntityId FROM tblPREmployee WHERE strEmployeeId = LTRIM(RTRIM(strEntityNo)))      
     ,@intOriginalPaycheckId = intOriginalPaycheckId      
     ,@strRecordType   = CASE WHEN strRecordType <> '' AND strRecordType       
      IN(      
    'PAYCHECK',      
    'EARNING',  
    'EARNING TAX',   
    'DEDUCTION',      
    'TAX'      
      ) THEN strRecordType ELSE '' END      
     ,@strRecordId   = strRecordId     
     ,@strPaycheckEarningId = strPaycheckEarningId  
     ,@dblEarningHour  = dblEarningHour      
     ,@dblAmount    = dblAmount      
     ,@dblTotal    = dblTotal     
     ,@dblTaxableAmount = dblTaxableAmount  
     ,@dtmPayDate   = CAST(dtmPayDate AS NVARCHAR)       
     ,@dtmPayFrom   = CAST(dtmPayFrom AS NVARCHAR)       
     ,@dtmPayTo    = CAST(dtmPayTo AS NVARCHAR)       
     ,@strAccountId   = LTRIM(RTRIM(strAccountId))      
     ,@strExpenseAccountId = LTRIM(RTRIM(strExpenseAccountId))      
     ,@strBankAccountNumber = LTRIM(RTRIM(strBankAccountNumber))      
     ,@strReferenceNumber = LTRIM(RTRIM(strReferenceNumber))      
    FROM #TempEmployeePaycheck    
    WHERE intOriginalPaycheckId = @PaycheckGroupId   
  
  
    --Categorization of record type  
    IF(@strRecordType = 'EARNING')  
    BEGIN  
    SELECT TOP 1 @intEarningCount = COUNT(intTypeEarningId) FROM tblPRTypeEarning WHERE strEarning = @strRecordId   
    IF(@intEarningCount != 0)  
     BEGIN  
      SELECT TOP 1 @intEmployeeEarningId = intTypeEarningId FROM tblPRTypeEarning WHERE LTRIM(RTRIM(strEarning)) = LTRIM(RTRIM(@strRecordId))  
      INSERT INTO tblPRPaycheckEarning          
         ([intPaycheckId]          
         ,[intEmployeeEarningId]          
         ,[intTypeEarningId]          
         ,[strCalculationType]          
         ,[dblHours]          
         ,[dblAmount]          
         ,[dblTotal]          
         ,[strW2Code]          
         ,[intEmployeeDepartmentId]          
         ,[intWorkersCompensationId]          
         ,[intEmployeeTimeOffId]          
         ,[intEmployeeEarningLinkId]          
         ,[intAccountId]          
         ,[intTaxCalculationType]            
         ,[intSort]          
         ,[intConcurrencyId])         
      SELECT          
          @intNewPaycheckId      
         ,P.intEmployeeEarningId          
         ,P.intTypeEarningId          
         ,P.strCalculationType                   ,ISNULL(@dblEarningHour,0)     
         ,ISNULL(@dblAmount,0)            
         ,ISNULL(@dblTotal,0)     
         ,P.strW2Code          
         ,(SELECT TOP 1 intDepartmentId from tblPREmployeeDepartment where intEntityEmployeeId = @intEntityNo)        
         ,(SELECT TOP 1 intWorkersCompensationId FROM tblPREmployee WHERE intEntityId = @intEntityNo)         
         ,P.intEmployeeTimeOffId          
         ,P.intEmployeeEarningLinkId          
         ,P.intAccountId          
         ,P.intTaxCalculationType      
         ,P.intSort          
         ,1         
        FROM tblPREmployeeEarning P      
        WHERE P.intEntityEmployeeId = @intEntityNo        
        AND P.intTypeEarningId = @intEmployeeEarningId          
        --AND P.ysnDefault = 1    
  
      INSERT INTO tblApiImportLogDetail (guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage)      
      SELECT TOP 1      
       NEWID()      
      , guiApiImportLogId = @guiLogId      
      , strField = 'Paycheck Earning Record'      
      , strValue = @strRecordType      
      , strLogLevel = 'Info'      
      , strStatus = 'Success'      
      , intRowNo = SE.intRowNumber      
      , strMessage = 'The paycheck earning record has been successfully imported.'      
      FROM tblApiSchemaEmployeePaycheck SE      
      LEFT JOIN tblPRPaycheck E ON E.intEntityEmployeeId = (SELECT TOP 1 intEntityId FROM tblPREmployee WHERE strEmployeeId = @strEmployeeId)      
      WHERE SE.guiApiUniqueId = @guiApiUniqueId      
      AND SE.strRecordId = @strRecordId    
  
     END  
    ELSE  
     BEGIN  
       INSERT INTO tblApiImportLogDetail (guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage)      
       SELECT TOP 1      
        NEWID()      
        , guiApiImportLogId = @guiLogId      
        , strField = 'Paycheck Earning'      
        , strValue = @strRecordType      
        , strLogLevel = 'Error'      
        , strStatus = 'Failed'      
        , intRowNo = SE.intRowNumber      
        , strMessage = 'Wrong input/format for Record Type. Please try again.'      
       FROM tblApiSchemaEmployeePaycheck SE      
       LEFT JOIN tblPRPaycheck E ON E.intEntityEmployeeId = (SELECT TOP 1 intEntityId FROM tblPREmployee WHERE strEmployeeId = @strEmployeeId)      
       WHERE SE.guiApiUniqueId = @guiApiUniqueId      
       AND SE.strRecordId = @strRecordId  
     END  
    END  
  
    IF(@strRecordType = 'DEDUCTION')  
    BEGIN  
    SELECT TOP 1 @intDeductionCount = COUNT(intTypeDeductionId) FROM tblPRTypeDeduction WHERE strDeduction = @strRecordId   
    IF(@intDeductionCount != 0)  
     BEGIN  
      SELECT TOP 1 @intEmployeeDeductionId = intTypeDeductionId FROM tblPRTypeDeduction WHERE LTRIM(RTRIM(strDeduction)) = LTRIM(RTRIM(@strRecordId))  
      INSERT INTO tblPRPaycheckDeduction          
        ([intPaycheckId]          
        ,[intEmployeeDeductionId]          
        ,[intTypeDeductionId]          
        ,[dblPaycheckMax]          
        ,[strDeductFrom]          
        ,[strCalculationType]          
        ,[dblAmount]          
        ,[dblLimit]          
        ,[dblTotal]          
        ,[dtmBeginDate]          
        ,[dtmEndDate]          
        ,[intAccountId]          
        ,[intExpenseAccountId]          
        ,[strPaidBy]          
        ,[intSort]          
        ,[intConcurrencyId])             
        SELECT          
       @intNewPaycheckId          
         ,intEmployeeDeductionId          
         ,[intTypeDeductionId]          
         ,[dblPaycheckMax]          
         ,[strDeductFrom]          
         ,[strCalculationType]          
         ,@dblAmount          
         ,[dblLimit]          
         ,@dblTotal       
         ,[dtmBeginDate]          
         ,[dtmEndDate]          
         ,[intAccountId]          
         ,[intExpenseAccountId]          
         ,[strPaidBy]          
         ,[intSort]          
       ,1          
         FROM tblPREmployeeDeduction          
         WHERE [intEntityEmployeeId] = @intEntityNo          
         AND intTypeDeductionId = @intEmployeeDeductionId          
         --AND ysnDefault = 1        
           
        INSERT INTO tblApiImportLogDetail (guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage)      
         SELECT TOP 1      
        NEWID()      
       , guiApiImportLogId = @guiLogId      
       , strField = 'Paycheck Deduction Record'      
       , strValue = @strRecordType      
       , strLogLevel = 'Info'      
       , strStatus = 'Success'      
       , intRowNo = SE.intRowNumber      
       , strMessage = 'The paycheck deduction record has been successfully imported.'      
         FROM tblApiSchemaEmployeePaycheck SE      
         LEFT JOIN tblPRPaycheck E ON E.intEntityEmployeeId = (SELECT TOP 1 intEntityId FROM tblPREmployee WHERE strEmployeeId = @strEmployeeId)      
         WHERE SE.guiApiUniqueId = @guiApiUniqueId      
         AND SE.strRecordId = @strRecordId    
     END  
    ELSE  
     BEGIN  
       INSERT INTO tblApiImportLogDetail (guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage)      
       SELECT TOP 1      
        NEWID()      
        , guiApiImportLogId = @guiLogId      
        , strField = 'Paycheck Deduction'      
        , strValue = @strRecordType      
        , strLogLevel = 'Error'      
        , strStatus = 'Failed'      
        , intRowNo = SE.intRowNumber      
        , strMessage = 'Wrong input/format for Record Type. Please try again.'      
       FROM tblApiSchemaEmployeePaycheck SE      
       LEFT JOIN tblPRPaycheck E ON E.intEntityEmployeeId = (SELECT TOP 1 intEntityId FROM tblPREmployee WHERE strEmployeeId = @strEmployeeId)      
       WHERE SE.guiApiUniqueId = @guiApiUniqueId      
       AND SE.strRecordId = @strRecordId   
     END  
    END  
  
    IF(@strRecordType = 'TAX')  
    BEGIN  
    SELECT TOP 1 @intTaxCount = COUNT(intTypeTaxId) FROM tblPRTypeTax WHERE strTax = @strRecordId  
    IF(@intTaxCount != 0)  
    BEGIN  
     SELECT TOP 1 @intEmployeeTaxId = intTypeTaxId FROM tblPRTypeTax WHERE LTRIM(RTRIM(strTax)) = LTRIM(RTRIM(@strRecordId))  
     INSERT INTO [dbo].[tblPRPaycheckTax]          
      ([intPaycheckId]          
      ,[intTypeTaxId]          
      ,[strCalculationType]          
      ,[strFilingStatus]          
      ,[intTypeTaxStateId]          
      ,[intTypeTaxLocalId]          
      ,[dblAmount]          
      ,[dblExtraWithholding]          
      ,[dblLimit]          
      ,[dblTotal]    
      ,dblTaxableAmount  
      ,[intAccountId]          
      ,[intExpenseAccountId]          
      ,[intAllowance]          
      ,[strPaidBy]          
      ,[strVal1]          
      ,[strVal2]          
      ,[strVal3]          
      ,[strVal4]          
      ,[strVal5]          
      ,[strVal6]          
      ,[ysnSet]          
      ,[intSort]          
      ,[ysnW42020]      
      ,[ysnW4Step2c]      
      ,[dblW4ClaimDependents]      
      ,[dblW4OtherIncome]      
      ,[dblW4Deductions]     
      ,[intConcurrencyId])          
     SELECT          
       @intNewPaycheckId          
      ,(SELECT TOP 1 intTypeTaxId FROM tblPRTypeTax WHERE strTax = @strRecordId)          
      ,[strCalculationType]          
      ,[strFilingStatus]          
      ,[intTypeTaxStateId]          
      ,[intTypeTaxLocalId]          
      ,@dblAmount          
      ,[dblExtraWithholding]          
      ,[dblLimit]          
      ,@dblTotal    
      ,@dblTaxableAmount  
      ,(SELECT TOP 1 intAccountId FROM tblGLAccount WHERE strAccountId = @strAccountId)      
      ,(SELECT TOP 1 intAccountId FROM tblGLAccount WHERE strAccountId = @strExpenseAccountId)      
      ,[intAllowance]          
      ,[strPaidBy]          
      ,[strVal1]          
      ,[strVal2]          
      ,[strVal3]          
      ,[strVal4]          
      ,[strVal5]          
      ,[strVal6]          
      ,0          
      ,[intSort]          
      ,[ysnW42020]      
      ,[ysnW4Step2c]      
      ,[dblW4ClaimDependents]      
      ,[dblW4OtherIncome]      
      ,[dblW4Deductions]      
      ,1          
        FROM [dbo].[tblPREmployeeTax]          
        WHERE [intEntityEmployeeId] = @intEntityNo       
        AND [intTypeTaxId] = @intEmployeeTaxId  
       --AND [ysnDefault] = 1      
    
     INSERT INTO tblApiImportLogDetail (guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage)      
     SELECT TOP 1      
      NEWID()      
     , guiApiImportLogId = @guiLogId      
     , strField = 'Paycheck Tax Record'      
     , strValue = @strRecordType      
     , strLogLevel = 'Info'      
     , strStatus = 'Success'      
     , intRowNo = SE.intRowNumber      
     , strMessage = 'The paycheck tax record has been successfully imported.'      
     FROM tblApiSchemaEmployeePaycheck SE      
     LEFT JOIN tblPRPaycheck E ON E.intEntityEmployeeId = (SELECT TOP 1 intEntityId FROM tblPREmployee WHERE strEmployeeId = @strEmployeeId)      
     WHERE SE.guiApiUniqueId = @guiApiUniqueId      
     AND SE.strRecordId = @strRecordId    
    END  
    ELSE  
    BEGIN  
      INSERT INTO tblApiImportLogDetail (guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage)      
      SELECT TOP 1      
       NEWID()      
       , guiApiImportLogId = @guiLogId      
       , strField = 'Paycheck Tax'      
       , strValue = @strRecordType      
       , strLogLevel = 'Error'      
       , strStatus = 'Failed'      
       , intRowNo = SE.intRowNumber      
       , strMessage = 'Wrong input/format for Record Type. Please try again.'      
      FROM tblApiSchemaEmployeePaycheck SE      
      LEFT JOIN tblPRPaycheck E ON E.intEntityEmployeeId = (SELECT TOP 1 intEntityId FROM tblPREmployee WHERE strEmployeeId = @strEmployeeId)      
      WHERE SE.guiApiUniqueId = @guiApiUniqueId      
      AND SE.strRecordId = @strRecordId    
    END  
    END  
  
    IF(@strRecordType = 'EARNING TAX')  
    BEGIN  
    SELECT TOP 1 @intTaxCount = COUNT(intTypeTaxId) FROM tblPRTypeTax WHERE strTax = @strRecordId  
    IF(@intTaxCount != 0)  
    BEGIN  
     SELECT TOP 1 @intEarningTaxToCount = COUNT(intTypeEarningId) FROM tblPRTypeEarning WHERE strEarning = @strPaycheckEarningId  
     IF(@intEarningTaxToCount != 0)  
     BEGIN  
      SELECT TOP 1 @intEmployeeEarningTaxId = intTypeEarningId FROM tblPRTypeEarning WHERE strEarning = @strPaycheckEarningId  
      INSERT INTO tblPRPaycheckEarningTax  
      (  
       intPaycheckEarningId  
       ,intTypeTaxId  
       ,intConcurrencyId  
      )  
      VALUES  
      (  
        (SELECT TOP 1 intPaycheckEarningId FROM tblPRPaycheckEarning where intPaycheckId = @intNewPaycheckId AND intTypeEarningId = @intEmployeeEarningTaxId)  
       ,(SELECT TOP 1  intTypeTaxId FROM tblPRTypeTax WHERE LTRIM(RTRIM(strTax)) = LTRIM(RTRIM(@strRecordId)))  
       ,1  
      ) 
      
      INSERT INTO tblApiImportLogDetail (guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage)    
	SELECT TOP 1    
		NEWID()    
	, guiApiImportLogId = @guiLogId    
	, strField = 'Paycheck Earning Tax Record'    
	, strValue = @strRecordType    
	, strLogLevel = 'Info'    
	, strStatus = 'Success'    
	, intRowNo = SE.intRowNumber    
	, strMessage = 'The paycheck earning tax record has been successfully imported.'    
	FROM tblApiSchemaEmployeePaycheck SE    
	LEFT JOIN tblPRPaycheck E ON E.intEntityEmployeeId = (SELECT TOP 1 intEntityId FROM tblPREmployee WHERE strEmployeeId = @strEmployeeId)    
	WHERE SE.guiApiUniqueId = @guiApiUniqueId    
	AND SE.strRecordId = @strRecordId  

     END  
     ELSE  
     BEGIN  
      INSERT INTO tblApiImportLogDetail (guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage)      
       SELECT TOP 1      
        NEWID()      
        , guiApiImportLogId = @guiLogId      
        , strField = 'Paycheck Earning Tax'      
        , strValue = @strRecordId      
        , strLogLevel = 'Error'      
        , strStatus = 'Failed'      
        , intRowNo = SE.intRowNumber      
        , strMessage = 'Wrong input/format for Record Type. Please try again.'      
       FROM tblApiSchemaEmployeePaycheck SE      
       LEFT JOIN tblPRPaycheck E ON E.intEntityEmployeeId = (SELECT TOP 1 intEntityId FROM tblPREmployee WHERE strEmployeeId = @strEmployeeId)      
       WHERE SE.guiApiUniqueId = @guiApiUniqueId      
       AND SE.strRecordId = @strRecordId   
     END  
  
       
    END  
    ELSE  
    BEGIN  
     INSERT INTO tblApiImportLogDetail (guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage)      
      SELECT TOP 1      
       NEWID()      
       , guiApiImportLogId = @guiLogId      
       , strField = 'Paycheck Earning Tax'      
       , strValue = @strRecordType      
       , strLogLevel = 'Error'      
       , strStatus = 'Failed'      
       , intRowNo = SE.intRowNumber      
       , strMessage = 'Wrong input/format for Record Type. Please try again.'      
      FROM tblApiSchemaEmployeePaycheck SE      
      LEFT JOIN tblPRPaycheck E ON E.intEntityEmployeeId = (SELECT TOP 1 intEntityId FROM tblPREmployee WHERE strEmployeeId = @strEmployeeId)      
      WHERE SE.guiApiUniqueId = @guiApiUniqueId      
      AND SE.strRecordId = @strRecordId    
    END  
    END  
  
    --SELECT @intW2Recompute = COUNT(strEntityNo) FROM #TempEmployeePaycheckPerGroup WHERE intOriginalPaycheckId = @PaycheckGroupId and strEntityNo = @strEmployeeId  
    --IF(@intW2Recompute = 1)  
    --BEGIN  
    --SET @intYear = YEAR(CONVERT(DATE, @dtmPayDate))  
    --EXEC uspPRUpdateInsertEmployeeW2 @intYear, @intEntityNo  
    --END  
  
  
   DELETE FROM #TempEmployeePaycheckPerGroup WHERE intOriginalPaycheckId = @PaycheckGroupId AND strRecordType = @strRecordType and strEntityNo = @strEmployeeId AND strRecordId = @strRecordId  
   DELETE FROM #TempEmployeePaycheck WHERE intOriginalPaycheckId = @PaycheckGroupId AND strRecordType = @strRecordType and strEntityNo = @strEmployeeId AND strRecordId = @strRecordId  
   END  
  
 END  
   
 --Recalculate    
  UPDATE tblPRPaycheck  
  SET dblTotalHours = PCS.dblTotalHours  
  ,dblGross = PCS.dblTotalEarning  
  ,dblAdjustedGross = PCS.dblAdjustedGross  
  ,dblTaxTotal = PCS.dblTotalTax  
  ,dblDeductionTotal = PCS.dblTotalDeduction  
  ,dblNetPayTotal = PCS.dblTotalNetPay  
  ,dblCompanyTaxTotal = PCS.dblTotalCompanyTax  
  FROM  
  (  
  SELECT   
   ISNULL(PCE.dblTotalHours ,0) AS dblTotalHours
  ,ISNULL(PCE.dblTotalEarning  ,0) AS dblTotalEarning
  ,(ISNULL(PCE.dblTotalEarning ,0)- ISNULL(PCD.dblTotalDeduction,0)) AS dblAdjustedGross  
  ,ISNULL(PCTE.dblTotalTax  ,0) AS dblTotalTax
  ,ISNULL(PCD.dblTotalDeduction,0) AS   dblTotalDeduction
  ,(ISNULL(PCE.dblTotalEarning,0) - (ISNULL(PCTE.dblTotalTax,0) + ISNULL(PCD.dblTotalDeduction,0))) AS dblTotalNetPay  
  ,ISNULL(PCTC.dblTotalTax,0) AS dblTotalCompanyTax  
 FROM tblPRPaycheck PC  
 LEFT JOIN   
 (  
  select intPaycheckId,SUM(dblHours) AS dblTotalHours, SUM(dblTotal) AS dblTotalEarning from tblPRPaycheckEarning  
  group by intPaycheckId  
 ) PCE  
 ON PC.intPaycheckId = PCE.intPaycheckId  
 LEFT JOIN   
 (  
  select intPaycheckId,SUM(dblTotal) AS dblTotalDeduction from tblPRPaycheckDeduction D  
  left join tblPRTypeDeduction TD  
  on TD.intTypeDeductionId = D.intTypeDeductionId  
  where TD.strPaidBy = 'Employee'  
  group by intPaycheckId  
 ) PCD  
 ON PC.intPaycheckId = PCD.intPaycheckId  
 LEFT JOIN   
 (  
  select intPaycheckId,SUM(dblTotal) AS dblTotalTax from tblPRPaycheckTax PCT   
  LEFT JOIN tblPRTypeTax T  
  ON T.intTypeTaxId = PCT.intTypeTaxId  
  where T.strPaidBy = 'Employee'  
  group BY intPaycheckId  
 ) PCTE  
 ON PC.intPaycheckId = PCTE.intPaycheckId  
 LEFT JOIN   
 (  
  select intPaycheckId,ISNULL(SUM(dblTotal),0) AS dblTotalTax from tblPRPaycheckTax PCT   
  LEFT JOIN tblPRTypeTax T  
  ON T.intTypeTaxId = PCT.intTypeTaxId  
  where T.strPaidBy = 'Company'  
  group BY intPaycheckId  
 ) PCTC  
 ON PC.intPaycheckId = PCTC.intPaycheckId  
 WHERE PC.intPaycheckId = @intNewPaycheckId  
 )PCS  
 WHERE tblPRPaycheck.intPaycheckId = @intNewPaycheckId
  
 --DELETE GROUPINGS      
 DELETE FROM #TempPaycheckGroupId WHERE intOriginalPaycheckId = @PaycheckGroupId      
  
END    
  
--WHILE EXISTS(SELECT TOP 1 NULL FROM #TempPaycheckGroupYear)  
--BEGIN  
-- SELECT TOP 1   
--   @intYear = PCY.intYear  
--  ,@intEntityNoW2 = (SELECT TOP 1 intEntityId FROM tblPREmployee where strEmployeeId = PCY.strEntityNo)  
--  ,@strEmployeeIdW2 = PCY.strEntityNo  
-- FROM #TempPaycheckGroupYear PCY  
  
-- EXEC uspPRUpdateInsertEmployeeW2 @intYear, @intEntityNoW2  
  
-- DELETE FROM #TempPaycheckGroupYear WHERE strEntityNo = @strEmployeeIdW2 and intYear = @intYear  
--END  
  
  
IF EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#TempPaycheckGroupYear'))         
DROP TABLE #TempPaycheckGroupYear    
      
IF EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#TempEmployeePaycheck'))         
DROP TABLE #TempEmployeePaycheck         
      
IF EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#TempPaycheckGroupId'))         
DROP TABLE #TempPaycheckGroupId      
    
IF EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#TempEmployeePaycheckPerGroup'))         
DROP TABLE #TempEmployeePaycheckPerGroup   
  
      
END 