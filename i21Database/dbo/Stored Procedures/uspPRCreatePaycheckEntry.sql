CREATE PROCEDURE [dbo].[uspPRCreatePaycheckEntry]      
 @intEmployeeId    INT       
 ,@dtmBeginDate    DATETIME      
 ,@dtmEndDate    DATETIME      
 ,@dtmPayDate    DATETIME      
 ,@strPayGroupIds   NVARCHAR(MAX) = ''      
 ,@strDepartmentIds   NVARCHAR(MAX) = ''      
 ,@ysnUseStandardHours  BIT = 1      
 ,@ysnOverrideDirectDeposit BIT = 0      
 ,@intUserId     INT = NULL      
 ,@strExcludeDeductions  NVARCHAR(MAX) = ''      
 ,@intPaycheckId    INT = NULL OUTPUT      
AS      
BEGIN      

DECLARE @intEmployee INT      
    ,@dtmBegin DATETIME      
    ,@dtmEnd DATETIME      
    ,@dtmPay DATETIME      
    ,@xmlPayGroups XML      
    ,@ysnUseStandard BIT      
    ,@ysnOverrideDD BIT      
    ,@xmlDepartments XML      
    ,@xmlExcludeDeductions XML      
      
/* Localize Parameters for Optimal Performance */      
SELECT @intEmployee  = @intEmployeeId      
   ,@dtmBegin  = @dtmBeginDate      
   ,@dtmEnd   = @dtmEndDate      
   ,@dtmPay   = @dtmPayDate      
   ,@ysnUseStandard = @ysnUseStandardHours      
   ,@ysnOverrideDD = @ysnOverrideDirectDeposit      
   ,@xmlPayGroups = CAST('<A>'+ REPLACE(@strPayGroupIds, ',', '</A><A>')+ '</A>' AS XML)       
   ,@xmlDepartments  = CAST('<A>'+ REPLACE(@strDepartmentIds, ',', '</A><A>')+ '</A>' AS XML)       
   ,@xmlExcludeDeductions = CAST('<A>'+ REPLACE(@strExcludeDeductions, ',', '</A><A>')+ '</A>' AS XML)      
      
--Parse the Departments Parameter to Temporary Table      
SELECT RTRIM(LTRIM(T.value('.', 'INT'))) AS intDepartmentId      
INTO #tmpDepartments      
FROM @xmlDepartments.nodes('/A') AS X(T)       
WHERE RTRIM(LTRIM(T.value('.', 'INT'))) > 0      
      
IF NOT EXISTS(SELECT TOP 1 1 FROM #tmpDepartments)       
BEGIN      
 INSERT INTO #tmpDepartments (intDepartmentId) SELECT intDepartmentId FROM tblPRDepartment      
END      
      
--Parse the Pay Groups Parameter to Temporary Table      
SELECT RTRIM(LTRIM(T.value('.', 'INT'))) AS intPayGroupId      
INTO #tmpPayGroups      
FROM @xmlPayGroups.nodes('/A') AS X(T)       
WHERE RTRIM(LTRIM(T.value('.', 'INT'))) > 0      
      
IF NOT EXISTS(SELECT TOP 1 1 FROM #tmpPayGroups)       
BEGIN      
 INSERT INTO #tmpPayGroups (intPayGroupId) SELECT intPayGroupId FROM tblPRPayGroup      
END      
      
/* Get Paycheck Starting Number */      
DECLARE @strPaycheckId NVARCHAR(50)      
EXEC uspSMGetStartingNumber 32, @strPaycheckId OUT      
      
/* Create Paycheck Header */      
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
SELECT      
 @strPaycheckId      
 ,@intEmployee      
 ,@dtmPay      
 ,tblPREmployee.strPayPeriod      
 ,@dtmBegin      
 ,@dtmEnd      
 ,(SELECT TOP 1 intBankAccountId FROM tblPRPayGroup WHERE intPayGroupId IN (SELECT intPayGroupId FROM #tmpPayGroups))      
 ,''      
 ,0      
 ,0      
 ,0      
 ,0      
 ,0      
 ,0      
 ,0      
 ,NULL      
 ,0      
 ,0      
 ,0      
 ,CASE WHEN EXISTS (SELECT TOP 1 1 FROM [tblEMEntityEFTInformation] WHERE ysnActive = 1 AND intEntityId = tblPREmployee.[intEntityId] AND @ysnOverrideDD = 0) THEN 1 ELSE 0 END      
 ,@intUserId      
 ,GETDATE()      
 ,@intUserId      
 ,GETDATE()      
 ,1      
FROM [dbo].[tblPREmployee]      
WHERE [intEntityId] = @intEmployee      
      
/* Get the Created Paycheck Id*/      
SELECT @intPaycheckId = @@IDENTITY      
      
/* Create Paycheck Taxes */      
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
 @intPaycheckId      
 ,[intTypeTaxId]      
 ,[strCalculationType]      
 ,[strFilingStatus]      
 ,[intTypeTaxStateId]      
 ,[intTypeTaxLocalId]      
 ,[dblAmount]      
 ,[dblExtraWithholding]      
 ,[dblLimit]      
 ,0      
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
 ,0      
 ,[intSort]      
 ,[ysnW42020]  
 ,[ysnW4Step2c]  
 ,[dblW4ClaimDependents]  
 ,[dblW4OtherIncome]  
 ,[dblW4Deductions]  
 ,1      
FROM [dbo].[tblPREmployeeTax]      
WHERE [intEntityEmployeeId] = @intEmployee      
  AND [ysnDefault] = 1      
      
/* Create Paycheck Earnings and Taxes*/      
DECLARE @intPaycheckEarningId INT      
DECLARE @intEmployeeEarningId INT      
DECLARE @intPayGroupDetailId INT      
DECLARE @udtPRPaycheckEarningIn TABLE(intPaycheckEarningId INT, intPaygroupDetailId INT)      
      
	SELECT      
		@intPaycheckId PCId    
		,P.intEmployeeEarningId      
		,P.intTypeEarningId      
		,P.strCalculationType      
		,ISNULL(P.dblHoursToProcess, 0) dblHoursToProcess  
		,ISNULL(P.dblAmount, 0)  dblAmount    
		,ISNULL(P.dblTotal, 0)  dblTotal  
		,E.strW2Code      
		,P.intDepartmentId      
		,P.intWorkersCompensationId      
		,E.intEmployeeTimeOffId      
		,E.intEmployeeEarningLinkId      
		,E.intAccountId      
		,E.intTaxCalculationType      
		,T.intTimeOffRequestId      
		,P.intCommissionId      
		,P.intSort      
		,1 [intConcurrencyId]      
		,E.ysnDefault  
		,P.intEntityEmployeeId  
		,P.intPayGroupDetailId  
	INTO #tmpPayGroupDetailEarnings  
	FROM tblPRPayGroupDetail P       
		INNER JOIN tblPREmployeeEarning E ON P.intEmployeeEarningId = E.intEmployeeEarningId      
		LEFT JOIN tblPRTimeOffRequest T ON P.intPayGroupDetailId = T.intPayGroupDetailId      
    WHERE ISNULL(P.dblTotal, 0) <> 0 AND P.intEntityEmployeeId = @intEmployeeId  
  
  
 SELECT   
   EET.intTypeTaxId      
     ,1   [intConcurrencyId]   
  ,intEmployeeEarningId  
  INTO #tmpEmployeeEarningTax  
   FROM tblPREmployeeEarningTax EET  
   INNER JOIN tblPREmployeeTax ET ON EET.intTypeTaxId = ET.intTypeTaxId      
    WHERE ET.intEntityEmployeeId = @intEmployeeId  
  
/* CUSROR EARNINGS*/  
  DECLARE #tmpEarningsLoop CURSOR LOCAL FAST_FORWARD  
  FOR  
  
	SELECT PGD.intPayGroupDetailId, PGD.intEmployeeEarningId      
	FROM tblPRPayGroupDetail PGD      
		LEFT JOIN tblPRPayGroup PG ON PGD.intPayGroupId = PG.intPayGroupId      
	WHERE intEntityEmployeeId = @intEmployee      
		AND PGD.intPayGroupId IN (SELECT intPayGroupId FROM #tmpPayGroups)      
		AND ISNULL(PGD.dtmDateFrom, PG.dtmBeginDate) >= PG.dtmBeginDate AND ISNULL(PGD.dtmDateFrom, PG.dtmBeginDate) <= PG.dtmEndDate      
		AND PGD.dblTotal  <> 0  
  
	 OPEN #tmpEarningsLoop  
	 FETCH NEXT FROM #tmpEarningsLoop INTO @intPayGroupDetailId,@intEmployeeEarningId  
	 WHILE @@FETCH_STATUS = 0   
	 BEGIN   
  
		  /* Insert Paycheck Earning */      
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
			,[intTimeOffRequestId]      
			,[intCommissionId]      
			,[intSort]      
			,[intConcurrencyId])      
		   OUTPUT      
			Inserted.intPaycheckEarningId , @intPayGroupDetailId  
		   INTO       
			@udtPRPaycheckEarningIn       
    
		   SELECT      
			@intPaycheckId      
			,P.intEmployeeEarningId      
			,P.intTypeEarningId      
			,P.strCalculationType      
			,ISNULL(P.dblHoursToProcess, 0)    
			,ISNULL(P.dblAmount, 0)      
			,ISNULL(P.dblTotal, 0)    
			,P.strW2Code      
			,P.intDepartmentId      
			,P.intWorkersCompensationId      
			,P.intEmployeeTimeOffId      
			,P.intEmployeeEarningLinkId      
			,P.intAccountId      
			,P.intTaxCalculationType      
			,P.intTimeOffRequestId      
			,P.intCommissionId      
			,P.intSort      
			,1     
		   FROM #tmpPayGroupDetailEarnings P  
		   WHERE P.intEntityEmployeeId = @intEmployee      
			  AND P.intPayGroupDetailId = @intPayGroupDetailId      
			  AND P.intEmployeeEarningId = @intEmployeeEarningId      
			  AND (P.dblTotal <> 0 OR P.ysnDefault = 1)    
  
		/* Get the Created Paycheck Earning Id*/      
		SET @intPaycheckEarningId = SCOPE_IDENTITY()  
	  
		 IF(@intPaycheckEarningId IS NOT NULL)  
		   BEGIN      
			/* Insert Paycheck Earning Taxes */      
			INSERT INTO tblPRPaycheckEarningTax      
			 (intPaycheckEarningId      
			 ,intTypeTaxId      
			 ,intConcurrencyId)      
		  SELECT       
			 @intPaycheckEarningId      
			 ,EET.intTypeTaxId      
			 ,1      
			FROM #tmpEmployeeEarningTax EET   
			WHERE EET.intEmployeeEarningId = @intEmployeeEarningId      
			AND @intPaycheckEarningId NOT IN (SELECT PET.intPaycheckEarningId       
					 FROM tblPRPaycheckEarningTax PET  
			INNER JOIN tblPRPaycheckEarning PE ON PET.intPaycheckEarningId = PE.intPaycheckEarningId  
			WHERE intTypeTaxId = EET.intTypeTaxId  
			AND PE.intPaycheckId = @intPaycheckId ) 
		   END      
  
		 FETCH NEXT FROM #tmpEarningsLoop INTO @intPayGroupDetailId,@intEmployeeEarningId  
		 END  
  
	 CLOSE #tmpEarningsLoop;  
	 DEALLOCATE #tmpEarningsLoop;  
 /* CUSROR EARNINGS END*/  
  
      
/* Create Paycheck Deductions and Taxes*/      
DECLARE @intPaycheckDeductionId INT      
DECLARE @intEmployeeDeductionId INT      
DECLARE @udtPRPaycheckDeductionIn TABLE(intPaycheckDeductionId INT)      
      
--Parse the Excluded Deductions Parameter to Temporary Table      
SELECT RTRIM(LTRIM(T.value('.', 'INT'))) AS intTypeDeductionId      
INTO #tmpExcludeDeductions      
FROM @xmlExcludeDeductions.nodes('/A') AS X(T)       
WHERE RTRIM(LTRIM(T.value('.', 'INT'))) > 0      
      
/* Insert Deductions to Temp Table for iteration */      
SELECT tblPREmployeeDeduction.intEmployeeDeductionId      
 ,tblPREmployeeDeduction.intTypeDeductionId      
INTO #tmpDeductions FROM tblPREmployeeDeduction       
WHERE [intEntityEmployeeId] = @intEmployee      
 AND [intTypeDeductionId] NOT IN (SELECT intTypeDeductionId FROM #tmpExcludeDeductions)      
      
/* Add Each Deduction to Paycheck */      
WHILE EXISTS(SELECT TOP 1 1 FROM #tmpDeductions)      
 BEGIN      
  /* Select Employee Deduction to Add */      
  SELECT TOP 1 @intEmployeeDeductionId = intEmployeeDeductionId, @intPaycheckDeductionId = NULL FROM #tmpDeductions      
       
  /* Insert Paycheck Deduction */      
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
  OUTPUT      
   Inserted.intPaycheckDeductionId      
  INTO      
   @udtPRPaycheckDeductionIn      
  SELECT      
   @intPaycheckId      
   ,@intEmployeeDeductionId      
   ,[intTypeDeductionId]      
   ,[dblPaycheckMax]      
   ,[strDeductFrom]      
   ,[strCalculationType]      
   ,[dblAmount]      
   ,[dblLimit]      
   ,0      
   ,[dtmBeginDate]      
   ,[dtmEndDate]      
   ,[intAccountId]      
   ,[intExpenseAccountId]      
   ,[strPaidBy]      
   ,[intSort]      
   ,1      
  FROM tblPREmployeeDeduction      
  WHERE [intEntityEmployeeId] = @intEmployee      
    AND intEmployeeDeductionId = @intEmployeeDeductionId      
    AND ysnDefault = 1      
      
  /* Get the Created Paycheck Deduction Id*/      
  SELECT TOP 1 @intPaycheckDeductionId = intPaycheckDeductionId FROM @udtPRPaycheckDeductionIn      
      
  IF EXISTS(SELECT TOP 1 1 FROM tblPREmployeeDeduction WHERE intEmployeeDeductionId = @intEmployeeDeductionId AND ysnDefault = 1 AND @intPaycheckDeductionId IS NOT NULL)      
   BEGIN      
    /* Insert Paycheck Deduction Taxes */      
    INSERT INTO tblPRPaycheckDeductionTax      
     (intPaycheckDeductionId      
     ,intTypeTaxId      
     ,intConcurrencyId)      
    SELECT       
     @intPaycheckDeductionId      
     ,intTypeTaxId      
     ,1      
    FROM tblPREmployeeDeductionTax      
    WHERE intEmployeeDeductionId = @intEmployeeDeductionId      
    AND @intPaycheckDeductionId NOT IN (SELECT intPaycheckDeductionId       
             FROM tblPRPaycheckDeductionTax       
             WHERE intTypeTaxId = tblPREmployeeDeductionTax.intTypeTaxId)      
   END      
      
  DELETE FROM @udtPRPaycheckDeductionIn      
  DELETE FROM #tmpDeductions WHERE intEmployeeDeductionId = @intEmployeeDeductionId      
 END      
      
      
 ----/* Insert Pay Group Details for Deletion */      
--SELECT intPayGroupDetailId INTO #tmpPayGroupDetail FROM #tmpEarnings    
SELECT intPayGroupDetailId INTO #tmpPayGroupDetail FROM @udtPRPaycheckEarningIn    
  
 /* Associate Timecards to created Paycheck */      
 UPDATE tblPRTimecard       
 SET intPaycheckId = @intPaycheckId      
 WHERE ysnApproved = 1 AND intPaycheckId IS NULL      
 AND intEntityEmployeeId = @intEmployee AND intEmployeeDepartmentId IN (SELECT intDepartmentId FROM #tmpDepartments)      
 AND intPayGroupDetailId IN (SELECT intPayGroupDetailId FROM #tmpPayGroupDetail)      
      
 /* Associate Time Off Requests to created Paycheck */      
 UPDATE tblPRTimeOffRequest       
 SET intPaycheckId = @intPaycheckId      
 WHERE ysnPostedToCalendar = 1 AND intPaycheckId IS NULL      
 AND intEntityEmployeeId = @intEmployee AND intPayGroupDetailId IN (SELECT intPayGroupDetailId FROM #tmpPayGroupDetail)      
      
 /* Update Commission Paycheck Id*/      
 UPDATE tblARCommission       
 SET intPaycheckId = @intPaycheckId       
 WHERE intCommissionId IN (SELECT intCommissionId FROM tblPRPayGroupDetail WHERE intPayGroupDetailId IN (SELECT intPayGroupDetailId FROM #tmpPayGroupDetail))      
      
 /* Delete Processed Pay Group Details */      
 DELETE FROM tblPRPayGroupDetail WHERE intPayGroupDetailId IN (SELECT intPayGroupDetailId FROM #tmpPayGroupDetail)      
      
 IF EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#tmpDepartments')) DROP TABLE #tmpDepartments      
 IF EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#tmpPayGroups')) DROP TABLE #tmpPayGroups      
 IF EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#tmpPayGroupDetail')) DROP TABLE #tmpPayGroupDetail      
 IF EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#tmpEarnings')) DROP TABLE #tmpEarnings      
 IF EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#tmpExcludeDeductions')) DROP TABLE #tmpExcludeDeductions       
END