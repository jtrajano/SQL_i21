CREATE PROCEDURE dbo.uspPRImportEmployeeDeductions(
    @guiApiUniqueId UNIQUEIDENTIFIER,
    @guiLogId UNIQUEIDENTIFIER 
)

AS

BEGIN

--DECLARE @guiApiUniqueId UNIQUEIDENTIFIER = N'44B3F44B-95A9-4528-B2F9-432B5F32EC57'
--DECLARE @guiLogId UNIQUEIDENTIFIER = NEWID()
DECLARE @NewId AS INT
DECLARE @EmployeeEntityNo AS INT

DECLARE @intEntityNo AS INT
DECLARE @strDeductionDesc  AS NVARCHAR(50)
DECLARE @strDeductionId AS NVARCHAR(50)
DECLARE @ysnDefault  AS BIT
DECLARE @strCategory  AS NVARCHAR(50)
DECLARE @strPaidBy  AS NVARCHAR(50)
DECLARE @dblRateCalc AS FLOAT(50)
DECLARE @strRateCalcType  AS NVARCHAR(50)
DECLARE @dblDeductFrom AS FLOAT(50)
DECLARE @strDeductFromType  AS NVARCHAR(50)
DECLARE @dblAnnualLimit	 AS FLOAT(50)
DECLARE @dtmBeginDate AS NVARCHAR(50)
DECLARE @dtmEndDate	AS NVARCHAR(50)
DECLARE @strAccountId  AS NVARCHAR(50)
DECLARE @ysnAccountGLSplit  AS BIT
DECLARE @strExpenseAccountId  AS NVARCHAR(50)
DECLARE @ysnExpenseGLSplit  AS BIT
DECLARE @strDeductionTaxId1	 AS NVARCHAR(50)
DECLARE @strDeductionTaxDesc1  AS NVARCHAR(50)
DECLARE @strDeductionTaxId2  AS NVARCHAR(50)
DECLARE @strDeductionTaxDesc2  AS NVARCHAR(50)
DECLARE @strDeductionTaxId3  AS NVARCHAR(50)
DECLARE @strDeductionTaxDesc3  AS NVARCHAR(50)
DECLARE @strDeductionTaxId4  AS NVARCHAR(50)
DECLARE @strDeductionTaxDesc4  AS NVARCHAR(50)
DECLARE @strDeductionTaxId5  AS NVARCHAR(50)
DECLARE @strDeductionTaxDesc5  AS NVARCHAR(50)
DECLARE @strDeductionTaxId6  AS NVARCHAR(50)
DECLARE @strDeductionTaxDesc6  AS NVARCHAR(50)
DECLARE @strDeductionTaxId7  AS NVARCHAR(50)
DECLARE @strDeductionTaxDesc7  AS NVARCHAR(50)

INSERT INTO tblApiImportLogDetail(guiApiImportLogDetailId,guiApiImportLogId, strField,strValue,strLogLevel,strStatus,intRowNo,strMessage)
SELECT
	guiApiImportLogDetailId = NEWID()
   ,guiApiImportLogId = @guiLogId
   ,strField		= 'Employee ID'
   ,strValue		= SE.intEntityNo
   ,strLogLevel		= 'Error'
   ,strStatus		= 'Failed'
   ,intRowNo		= SE.intRowNumber
   ,strMessage		= 'Cannot find the Employee Entity No: '+ CAST(ISNULL(SE.intEntityNo, '') AS NVARCHAR(50)) + '.'
   FROM tblApiSchemaEmployeeDeduction SE
   LEFT JOIN tblPREmployeeDeduction E ON E.intEmployeeDeductionId = SE.intEntityNo
   WHERE SE.guiApiUniqueId = @guiApiUniqueId

IF EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#TempEmployeeDeductions')) 
DROP TABLE #TempEmployeeDeductions

SELECT * INTO #TempEmployeeDeductions FROM tblApiSchemaEmployeeDeduction where guiApiUniqueId = @guiApiUniqueId
	
	WHILE EXISTS(SELECT TOP 1 NULL FROM #TempEmployeeDeductions)
	BEGIN
		SELECT TOP 1 
			 @intEntityNo = intEntityNo
			,@strDeductionDesc  = strDeductionDesc
			,@strDeductionId = strDeductionId
			,@ysnDefault  = ysnDefault
			,@strCategory  = strCategory
			,@strPaidBy  = strPaidBy
			,@dblRateCalc = dblRateCalc
			,@strRateCalcType  = strRateCalcType
			,@dblDeductFrom = dblDeductFrom
			,@strDeductFromType  = strDeductFromType
			,@dblAnnualLimit	 = dblAnnualLimit
			,@dtmBeginDate = dtmBeginDate
			,@dtmEndDate	= dtmEndDate
			,@strAccountId  = strAccountId
			,@ysnAccountGLSplit  = ysnAccountGLSplit
			,@strExpenseAccountId  = strExpenseAccountId
			,@ysnExpenseGLSplit  = ysnExpenseGLSplit
			,@strDeductionTaxId1	 = strDeductionTaxId1
			,@strDeductionTaxDesc1  = strDeductionTaxDesc1
			,@strDeductionTaxId2  = strDeductionTaxId2
			,@strDeductionTaxDesc2  = strDeductionTaxDesc2
			,@strDeductionTaxId3  = strDeductionTaxId3
			,@strDeductionTaxDesc3  = strDeductionTaxDesc3
			,@strDeductionTaxId4  = strDeductionTaxId4
			,@strDeductionTaxDesc4  = strDeductionTaxDesc4
			,@strDeductionTaxId5  = strDeductionTaxId5
			,@strDeductionTaxDesc5  = strDeductionTaxDesc5
			,@strDeductionTaxId6  = strDeductionTaxId6
			,@strDeductionTaxDesc6  = strDeductionTaxDesc6
			,@strDeductionTaxId7  = strDeductionTaxId7
			,@strDeductionTaxDesc7  = strDeductionTaxDesc7
		FROM #TempEmployeeDeductions

		SELECT TOP 1 
			@EmployeeEntityNo = intEntityEmployeeId 
		FROM tblPREmployeeDeduction
		WHERE intEntityEmployeeId = @intEntityNo
		  AND intTypeDeductionId = (SELECT TOP 1 intTypeDeductionId FROM tblPRTypeDeduction WHERE strDescription = @strDeductionDesc)

		IF @EmployeeEntityNo IS NULL
			BEGIN
				INSERT INTO tblPREmployeeDeduction
				(
					 intEntityEmployeeId
					,intTypeDeductionId
					,strDeductFrom
					,strCalculationType
					,dblAmount
					,dblLimit
					,dblPaycheckMax
					,dtmBeginDate
					,dtmEndDate
					,intAccountId
					,intExpenseAccountId
					,ysnUseLocationDistribution
					,ysnUseLocationDistributionExpense
					,strPaidBy
					,ysnDefault
					,intSort
					,intConcurrencyId

				)
				SELECT
					 @intEntityNo
					,(SELECT TOP 1 intTypeDeductionId FROM tblPRTypeDeduction WHERE strDeduction = @strDeductionId AND strDescription = @strDeductionDesc)
					,(SELECT TOP 1 strDeductFrom FROM tblPRTypeDeduction WHERE strDeduction = @strDeductionId AND strDescription = @strDeductionDesc)
					,(SELECT TOP 1 strCalculationType FROM tblPRTypeDeduction WHERE strDeduction = @strDeductionId AND strDescription = @strDeductionDesc)
					,dblRateCalc
					,dblAnnualLimit
					,100.00
					,@dtmBeginDate
					,@dtmEndDate
					,(SELECT TOP 1 intAccountId FROM tblGLAccount WHERE strAccountId = @strAccountId)
					,(SELECT TOP 1 intAccountId FROM tblGLAccount WHERE strAccountId = @strExpenseAccountId)
					,1
					,1
					,(SELECT TOP 1 strPaidBy FROM tblPRTypeDeduction WHERE strDeduction = @strDeductionId AND strDescription = @strDeductionDesc)
					,ysnDefault
					,1
					,1
				FROM #TempEmployeeDeductions
				WHERE intEntityNo = @intEntityNo
				AND strDeductionDesc = (SELECT TOP 1 strDescription FROM tblPRTypeDeduction WHERE strDeduction = @strDeductionId AND strDescription = @strDeductionDesc)

				SET @NewId = SCOPE_IDENTITY()

				IF @strDeductionTaxId1 IS NOT NULL
					BEGIN
						IF EXISTS (SELECT TOP 1 * FROM tblPRTypeTax WHERE strTax = @strDeductionTaxId1 AND strDescription = @strDeductionTaxDesc1)
						BEGIN
							INSERT INTO tblPREmployeeDeductionTax(intEmployeeDeductionId,intTypeTaxId,intSort,intConcurrencyId)
							VALUES (@NewId,(SELECT TOP 1 intTypeTaxId FROM tblPRTypeTax WHERE strTax = @strDeductionTaxId1 AND strDescription = @strDeductionTaxDesc1),1,1)
						END
					END

				IF @strDeductionTaxId2 IS NOT NULL
					BEGIN
						IF EXISTS (SELECT TOP 1 * FROM tblPRTypeTax WHERE strTax = @strDeductionTaxId2 AND strDescription = @strDeductionTaxDesc2)
						BEGIN
							INSERT INTO tblPREmployeeDeductionTax(intEmployeeDeductionId,intTypeTaxId,intSort,intConcurrencyId)
							VALUES (@NewId,(SELECT TOP 1 intTypeTaxId FROM tblPRTypeTax WHERE strTax = @strDeductionTaxId2 AND strDescription = @strDeductionTaxDesc2),1,1)
						END
					END

				IF @strDeductionTaxId3 IS NOT NULL
					BEGIN
						IF EXISTS (SELECT TOP 1 * FROM tblPRTypeTax WHERE strTax = @strDeductionTaxId3 AND strDescription = @strDeductionTaxDesc3)
						BEGIN
							INSERT INTO tblPREmployeeDeductionTax(intEmployeeDeductionId,intTypeTaxId,intSort,intConcurrencyId)
							VALUES (@NewId,(SELECT TOP 1 intTypeTaxId FROM tblPRTypeTax WHERE strTax = @strDeductionTaxId3 AND strDescription = @strDeductionTaxDesc3),1,1)
						END
					END

				IF @strDeductionTaxId4 IS NOT NULL
					BEGIN
						IF EXISTS (SELECT TOP 1 * FROM tblPRTypeTax WHERE strTax = @strDeductionTaxId4 AND strDescription = @strDeductionTaxDesc4)
						BEGIN
							INSERT INTO tblPREmployeeDeductionTax(intEmployeeDeductionId,intTypeTaxId,intSort,intConcurrencyId)
							VALUES (@NewId,(SELECT TOP 1 intTypeTaxId FROM tblPRTypeTax WHERE strTax = @strDeductionTaxId4 AND strDescription = @strDeductionTaxDesc4),1,1)
						END
					END

				IF @strDeductionTaxId5 IS NOT NULL
					BEGIN
						IF EXISTS (SELECT TOP 1 * FROM tblPRTypeTax WHERE strTax = @strDeductionTaxId5 AND strDescription = @strDeductionTaxDesc5)
						BEGIN
							INSERT INTO tblPREmployeeDeductionTax(intEmployeeDeductionId,intTypeTaxId,intSort,intConcurrencyId)
							VALUES (@NewId,(SELECT TOP 1 intTypeTaxId FROM tblPRTypeTax WHERE strTax = @strDeductionTaxId5 AND strDescription = @strDeductionTaxDesc5),1,1)
						END
					END

				IF @strDeductionTaxId6 IS NOT NULL
					BEGIN
						IF EXISTS (SELECT TOP 1 * FROM tblPRTypeTax WHERE strTax = @strDeductionTaxId6 AND strDescription = @strDeductionTaxDesc6)
						BEGIN
							INSERT INTO tblPREmployeeDeductionTax(intEmployeeDeductionId,intTypeTaxId,intSort,intConcurrencyId)
							VALUES (@NewId,(SELECT TOP 1 intTypeTaxId FROM tblPRTypeTax WHERE strTax = @strDeductionTaxId6 AND strDescription = @strDeductionTaxDesc6),1,1)
						END
					END

				IF @strDeductionTaxId7 IS NOT NULL
					BEGIN
						IF EXISTS (SELECT TOP 1 * FROM tblPRTypeTax WHERE strTax = @strDeductionTaxId7 AND strDescription = @strDeductionTaxDesc7)
						BEGIN
							INSERT INTO tblPREmployeeDeductionTax(intEmployeeDeductionId,intTypeTaxId,intSort,intConcurrencyId)
							VALUES (@NewId,(SELECT TOP 1 intTypeTaxId FROM tblPRTypeTax WHERE strTax = @strDeductionTaxId7 AND strDescription = @strDeductionTaxDesc7),1,1)
						END
					END

				DELETE FROM #TempEmployeeDeductions WHERE intEntityNo = @intEntityNo

			END
		ELSE
			BEGIN

				UPDATE tblPREmployeeDeduction SET 
					 intEntityEmployeeId				= @intEntityNo
					,intTypeDeductionId					= (SELECT TOP 1 intTypeDeductionId FROM tblPRTypeDeduction WHERE strDeduction = @strDeductionId AND strDescription = @strDeductionDesc)
					,strDeductFrom						= (SELECT TOP 1 strDeductFrom FROM tblPRTypeDeduction WHERE strDeduction = @strDeductionId AND strDescription = @strDeductionDesc)
					,strCalculationType					= (SELECT TOP 1 strCalculationType FROM tblPRTypeDeduction WHERE strDeduction = @strDeductionId AND strDescription = @strDeductionDesc)
					,dblAmount							= @dblRateCalc
					,dblLimit							= @dblAnnualLimit
					,dblPaycheckMax						= 100.00
					,dtmBeginDate						= @dtmBeginDate
					,dtmEndDate							= @dtmEndDate
					,intAccountId						= (SELECT TOP 1 intAccountId FROM tblGLAccount WHERE strAccountId = @strAccountId)
					,intExpenseAccountId				= (SELECT TOP 1 intAccountId FROM tblGLAccount WHERE strAccountId = @strExpenseAccountId)
					,strPaidBy							= (SELECT TOP 1 strPaidBy FROM tblPRTypeTax WHERE strDescription = @strDeductionDesc)
					,ysnDefault							= @ysnDefault
				WHERE intEmployeeDeductionId = @intEntityNo
				AND intTypeDeductionId = (SELECT TOP 1 intTypeDeductionId FROM tblPRTypeDeduction WHERE strDeduction = @strDeductionId AND strDescription = @strDeductionDesc)

				IF @strDeductionTaxId1 IS NOT NULL
					BEGIN
						IF EXISTS (SELECT TOP 1 * FROM tblPRTypeTax WHERE strTax = @strDeductionTaxId1 AND strDescription = @strDeductionTaxDesc1)
						BEGIN
							INSERT INTO tblPREmployeeDeductionTax(intEmployeeDeductionId,intTypeTaxId,intSort,intConcurrencyId)
							VALUES (@NewId,(SELECT TOP 1 intTypeTaxId FROM tblPRTypeTax WHERE strTax = @strDeductionTaxId1 AND strDescription = @strDeductionTaxDesc1),1,1)
						END
					END

				IF @strDeductionTaxId2 IS NOT NULL
					BEGIN
						IF EXISTS (SELECT TOP 1 * FROM tblPRTypeTax WHERE strTax = @strDeductionTaxId2 AND strDescription = @strDeductionTaxDesc2)
						BEGIN
							INSERT INTO tblPREmployeeDeductionTax(intEmployeeDeductionId,intTypeTaxId,intSort,intConcurrencyId)
							VALUES (@NewId,(SELECT TOP 1 intTypeTaxId FROM tblPRTypeTax WHERE strTax = @strDeductionTaxId2 AND strDescription = @strDeductionTaxDesc2),1,1)
						END
					END

				IF @strDeductionTaxId3 IS NOT NULL
					BEGIN
						IF EXISTS (SELECT TOP 1 * FROM tblPRTypeTax WHERE strTax = @strDeductionTaxId3 AND strDescription = @strDeductionTaxDesc3)
						BEGIN
							INSERT INTO tblPREmployeeDeductionTax(intEmployeeDeductionId,intTypeTaxId,intSort,intConcurrencyId)
							VALUES (@NewId,(SELECT TOP 1 intTypeTaxId FROM tblPRTypeTax WHERE strTax = @strDeductionTaxId3 AND strDescription = @strDeductionTaxDesc3),1,1)
						END
					END

				IF @strDeductionTaxId4 IS NOT NULL
					BEGIN
						IF EXISTS (SELECT TOP 1 * FROM tblPRTypeTax WHERE strTax = @strDeductionTaxId4 AND strDescription = @strDeductionTaxDesc4)
						BEGIN
							INSERT INTO tblPREmployeeDeductionTax(intEmployeeDeductionId,intTypeTaxId,intSort,intConcurrencyId)
							VALUES (@NewId,(SELECT TOP 1 intTypeTaxId FROM tblPRTypeTax WHERE strTax = @strDeductionTaxId4 AND strDescription = @strDeductionTaxDesc4),1,1)
						END
					END

				IF @strDeductionTaxId5 IS NOT NULL
					BEGIN
						IF EXISTS (SELECT TOP 1 * FROM tblPRTypeTax WHERE strTax = @strDeductionTaxId5 AND strDescription = @strDeductionTaxDesc5)
						BEGIN
							INSERT INTO tblPREmployeeDeductionTax(intEmployeeDeductionId,intTypeTaxId,intSort,intConcurrencyId)
							VALUES (@NewId,(SELECT TOP 1 intTypeTaxId FROM tblPRTypeTax WHERE strTax = @strDeductionTaxId5 AND strDescription = @strDeductionTaxDesc5),1,1)
						END
					END

				IF @strDeductionTaxId6 IS NOT NULL
					BEGIN
						IF EXISTS (SELECT TOP 1 * FROM tblPRTypeTax WHERE strTax = @strDeductionTaxId6 AND strDescription = @strDeductionTaxDesc6)
						BEGIN
							INSERT INTO tblPREmployeeDeductionTax(intEmployeeDeductionId,intTypeTaxId,intSort,intConcurrencyId)
							VALUES (@NewId,(SELECT TOP 1 intTypeTaxId FROM tblPRTypeTax WHERE strTax = @strDeductionTaxId6 AND strDescription = @strDeductionTaxDesc6),1,1)
						END
					END

				IF @strDeductionTaxId7 IS NOT NULL
					BEGIN
						IF EXISTS (SELECT TOP 1 * FROM tblPRTypeTax WHERE strTax = @strDeductionTaxId7 AND strDescription = @strDeductionTaxDesc7)
						BEGIN
							INSERT INTO tblPREmployeeDeductionTax(intEmployeeDeductionId,intTypeTaxId,intSort,intConcurrencyId)
							VALUES (@NewId,(SELECT TOP 1 intTypeTaxId FROM tblPRTypeTax WHERE strTax = @strDeductionTaxId7 AND strDescription = @strDeductionTaxDesc7),1,1)
						END
					END

				DELETE FROM #TempEmployeeDeductions WHERE intEntityNo = @intEntityNo
			END


	END
END


GO