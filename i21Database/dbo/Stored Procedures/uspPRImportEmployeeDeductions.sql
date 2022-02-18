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
DECLARE @strEmployeeId  AS NVARCHAR(50)
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
DECLARE @dtmBeginDate AS DATETIME
DECLARE @dtmEndDate	AS DATETIME
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
DECLARE @EmployeeCount AS INT

INSERT INTO tblApiImportLogDetail(guiApiImportLogDetailId,guiApiImportLogId, strField,strValue,strLogLevel,strStatus,intRowNo,strMessage)
SELECT
	guiApiImportLogDetailId = NEWID()
   ,guiApiImportLogId = @guiLogId
   ,strField		= 'Employee ID'
   ,strValue		= SE.intEntityNo
   ,strLogLevel		= 'Error'
   ,strStatus		= 'Failed'
   ,intRowNo		= SE.intRowNumber
   ,strMessage		= 'Cannot find the Employee Entity No: '+  CAST(ISNULL(SE.intEntityNo, '') AS NVARCHAR(100)) + '.'
   FROM tblApiSchemaEmployeeDeduction SE
   LEFT JOIN tblPREmployeeDeduction E ON E.intEmployeeDeductionId = (SELECT TOP 1 intEntityId FROM tblPREmployee WHERE strEmployeeId = SE.intEntityNo) 
   WHERE SE.guiApiUniqueId = @guiApiUniqueId
   AND SE.intEntityNo IS NULL

IF EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#TempEmployeeDeductions')) 
DROP TABLE #TempEmployeeDeductions

SELECT * INTO #TempEmployeeDeductions FROM tblApiSchemaEmployeeDeduction where guiApiUniqueId = @guiApiUniqueId
	
	WHILE EXISTS(SELECT TOP 1 NULL FROM #TempEmployeeDeductions)
	BEGIN
		SELECT TOP 1 
			 @strEmployeeId = LTRIM(RTRIM(intEntityNo))
			,@intEntityNo = (SELECT TOP 1 intEntityId FROM tblPREmployee WHERE strEmployeeId = LTRIM(RTRIM(intEntityNo)))
			,@strDeductionDesc  = LTRIM(RTRIM(strDeductionDesc))
			,@strDeductionId = LTRIM(RTRIM(strDeductionId))
			,@ysnDefault  = ysnDefault
			,@strCategory  = CASE WHEN strCategory <> '' AND strCategory 
								IN(
									'Child Support',
									'Federal Garnishment',
									'State Garnishment',
									'Retirement Plan Loan',
									'401(k)',
									'403(b)',
									'408(k) SEP',
									'408(p) SIMPLE',
									'457(b)',
									'501(c)',
									'Loan Repayment',
									'Dependent Care',
									'Pension Plan',
									'Archer MSA',
									'HSA',
									'Pre-Tax Insurance',
									'Post-Tax Insurance',
									'Roth 401(k)',
									'Roth 403(b)',
									'Special Tax',
									'Voluntary',
									'Union Dues'
								) THEN strCategory ELSE '' END
			,@strPaidBy  = strPaidBy
			,@dblRateCalc = dblRateCalc
			,@strRateCalcType  = CASE WHEN strRateCalcType <> '' AND strRateCalcType IN('Fixed Amount','Percent') THEN strRateCalcType ELSE '' END
			,@dblDeductFrom = dblDeductFrom
			,@strDeductFromType  = CASE WHEN strDeductFromType <> '' AND strDeductFromType IN('Net Pay','Gross Pay') THEN strDeductFromType ELSE '' END
			,@dblAnnualLimit	 = dblAnnualLimit
			,@dtmBeginDate = CAST(ISNULL(dtmBeginDate, null) AS DATETIME) 
			,@dtmEndDate	= CAST(ISNULL(dtmEndDate, null) AS DATETIME)  
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
			@EmployeeEntityNo = COUNT(intEntityEmployeeId) 
		FROM tblPREmployeeDeduction
		WHERE intEntityEmployeeId = @intEntityNo
		  AND intTypeDeductionId = (SELECT TOP 1 intTypeDeductionId FROM tblPRTypeDeduction WHERE strDeduction = @strDeductionId)

		IF(@strCategory IS NOT NULL OR @strCategory != '')
			BEGIN
				IF(@strRateCalcType IS NOT NULL OR @strRateCalcType != '')
					BEGIN
						IF(@strDeductFromType IS NOT NULL OR @strDeductFromType != '')
							BEGIN
								IF @EmployeeEntityNo = 0
									BEGIN
										SELECT TOP 1 @EmployeeCount = COUNT(intEntityId) FROM tblPREmployee WHERE strEmployeeId = @strEmployeeId

										IF(@EmployeeCount != 0)
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
													 ISNULL((SELECT TOP 1 intEntityId FROM tblPREmployee WHERE intEntityId = @intEntityNo),0)
													,(SELECT TOP 1 intTypeDeductionId FROM tblPRTypeDeduction WHERE strDeduction = @strDeductionId)
													,@strDeductFromType
													,@strRateCalcType
													,dblRateCalc
													,dblAnnualLimit
													,@dblDeductFrom
													,@dtmBeginDate
													,@dtmEndDate
													,(SELECT TOP 1 intAccountId FROM tblGLAccount WHERE strAccountId = @strAccountId)
													,(SELECT TOP 1 intAccountId FROM tblGLAccount WHERE strAccountId = @strExpenseAccountId)
													,ISNULL(@ysnAccountGLSplit,0)
													,ISNULL(@ysnExpenseGLSplit,0)
													,(SELECT TOP 1 strPaidBy FROM tblPRTypeDeduction WHERE strDeduction = @strDeductionId)
													,ysnDefault
													,1
													,1
												FROM #TempEmployeeDeductions
												WHERE intEntityNo = @strEmployeeId
												AND strDeductionDesc = (SELECT TOP 1 strDescription FROM tblPRTypeDeduction WHERE strDeduction = @strDeductionId)

												SET @NewId = SCOPE_IDENTITY()

												IF @strDeductionTaxId1 IS NOT NULL
													BEGIN
														IF EXISTS (SELECT TOP 1 * FROM tblPRTypeTax WHERE strTax = @strDeductionTaxId1)
														BEGIN
															IF NOT EXISTS (select * from tblPREmployeeDeductionTax where intEmployeeDeductionId = @NewId 
																and intTypeTaxId =  (SELECT TOP 1 intTypeTaxId FROM tblPRTypeTax WHERE strTax = @strDeductionTaxId1))
															BEGIN
																INSERT INTO tblPREmployeeDeductionTax(intEmployeeDeductionId,intTypeTaxId,intSort,intConcurrencyId)
																VALUES (
																(SELECT TOP 1 intEmployeeDeductionId FROM tblPREmployeeDeduction WHERE intEmployeeDeductionId = @NewId)
																,(SELECT TOP 1 intTypeTaxId FROM tblPRTypeTax WHERE strTax = @strDeductionTaxId1)
																,1
																,1)
															END
							
														END
													END

												IF @strDeductionTaxId2 IS NOT NULL
													BEGIN
														IF EXISTS (SELECT TOP 1 * FROM tblPRTypeTax WHERE strTax = @strDeductionTaxId2)
														BEGIN
															IF NOT EXISTS (select * from tblPREmployeeDeductionTax where intEmployeeDeductionId = @NewId 
																and intTypeTaxId =  (SELECT TOP 1 intTypeTaxId FROM tblPRTypeTax WHERE strTax = @strDeductionTaxId2))
															BEGIN
																INSERT INTO tblPREmployeeDeductionTax(intEmployeeDeductionId,intTypeTaxId,intSort,intConcurrencyId)
																VALUES ((SELECT TOP 1 intEmployeeDeductionId FROM tblPREmployeeDeduction WHERE intEmployeeDeductionId = @NewId),(SELECT TOP 1 intTypeTaxId FROM tblPRTypeTax WHERE strTax = @strDeductionTaxId2),1,1)
															END
														END
													END

												IF @strDeductionTaxId3 IS NOT NULL
													BEGIN
														IF EXISTS (SELECT TOP 1 * FROM tblPRTypeTax WHERE strTax = @strDeductionTaxId3)
														BEGIN
															IF NOT EXISTS (select * from tblPREmployeeDeductionTax where intEmployeeDeductionId = @NewId 
																and intTypeTaxId =  (SELECT TOP 1 intTypeTaxId FROM tblPRTypeTax WHERE strTax = @strDeductionTaxId3))
															BEGIN
																INSERT INTO tblPREmployeeDeductionTax(intEmployeeDeductionId,intTypeTaxId,intSort,intConcurrencyId)
																VALUES ((SELECT TOP 1 intEmployeeDeductionId FROM tblPREmployeeDeduction WHERE intEmployeeDeductionId = @NewId),(SELECT TOP 1 intTypeTaxId FROM tblPRTypeTax WHERE strTax = @strDeductionTaxId3),1,1)
															END
														END
													END

												IF @strDeductionTaxId4 IS NOT NULL
													BEGIN
														IF EXISTS (SELECT TOP 1 * FROM tblPRTypeTax WHERE strTax = @strDeductionTaxId4 )
														BEGIN
															IF NOT EXISTS (select * from tblPREmployeeDeductionTax where intEmployeeDeductionId = @NewId 
																and intTypeTaxId =  (SELECT TOP 1 intTypeTaxId FROM tblPRTypeTax WHERE strTax = @strDeductionTaxId4))
															BEGIN
																INSERT INTO tblPREmployeeDeductionTax(intEmployeeDeductionId,intTypeTaxId,intSort,intConcurrencyId)
																VALUES ((SELECT TOP 1 intEmployeeDeductionId FROM tblPREmployeeDeduction WHERE intEmployeeDeductionId = @NewId),(SELECT TOP 1 intTypeTaxId FROM tblPRTypeTax WHERE strTax = @strDeductionTaxId4),1,1)
															END
														END
													END

												IF @strDeductionTaxId5 IS NOT NULL
													BEGIN
														IF EXISTS (SELECT TOP 1 * FROM tblPRTypeTax WHERE strTax = @strDeductionTaxId5)
														BEGIN
															IF NOT EXISTS (select * from tblPREmployeeDeductionTax where intEmployeeDeductionId = @NewId 
																and intTypeTaxId =  (SELECT TOP 1 intTypeTaxId FROM tblPRTypeTax WHERE strTax = @strDeductionTaxId5))
															BEGIN
																INSERT INTO tblPREmployeeDeductionTax(intEmployeeDeductionId,intTypeTaxId,intSort,intConcurrencyId)
																VALUES ((SELECT TOP 1 intEmployeeDeductionId FROM tblPREmployeeDeduction WHERE intEmployeeDeductionId = @NewId),(SELECT TOP 1 intTypeTaxId FROM tblPRTypeTax WHERE strTax = @strDeductionTaxId5),1,1)
															END
														END
													END

												IF @strDeductionTaxId6 IS NOT NULL
													BEGIN
														IF EXISTS (SELECT TOP 1 * FROM tblPRTypeTax WHERE strTax = @strDeductionTaxId6)
														BEGIN
															IF NOT EXISTS (select * from tblPREmployeeDeductionTax where intEmployeeDeductionId = @NewId 
																and intTypeTaxId =  (SELECT TOP 1 intTypeTaxId FROM tblPRTypeTax WHERE strTax = @strDeductionTaxId6 ))
															BEGIN
																INSERT INTO tblPREmployeeDeductionTax(intEmployeeDeductionId,intTypeTaxId,intSort,intConcurrencyId)
																VALUES ((SELECT TOP 1 intEmployeeDeductionId FROM tblPREmployeeDeduction WHERE intEmployeeDeductionId = @NewId),(SELECT TOP 1 intTypeTaxId FROM tblPRTypeTax WHERE strTax = @strDeductionTaxId6),1,1)
															END
														END
													END

												IF @strDeductionTaxId7 IS NOT NULL
													BEGIN
														IF EXISTS (SELECT TOP 1 * FROM tblPRTypeTax WHERE strTax = @strDeductionTaxId7)
														BEGIN
															IF NOT EXISTS (select * from tblPREmployeeDeductionTax where intEmployeeDeductionId = @NewId 
																and intTypeTaxId =  (SELECT TOP 1 intTypeTaxId FROM tblPRTypeTax WHERE strTax = @strDeductionTaxId7))
															BEGIN
																INSERT INTO tblPREmployeeDeductionTax(intEmployeeDeductionId,intTypeTaxId,intSort,intConcurrencyId)
																VALUES ((SELECT TOP 1 intEmployeeDeductionId FROM tblPREmployeeDeduction WHERE intEmployeeDeductionId = @NewId),(SELECT TOP 1 intTypeTaxId FROM tblPRTypeTax WHERE strTax = @strDeductionTaxId7),1,1)
															END
														END
													END
											END

										DELETE FROM #TempEmployeeDeductions WHERE intEntityNo = @strEmployeeId AND strDeductionId = @strDeductionId AND strDeductionDesc = @strDeductionDesc

									END
								ELSE
									BEGIN
										UPDATE tblPREmployeeDeduction SET
											 intTypeDeductionId					= (SELECT TOP 1 intTypeDeductionId FROM tblPRTypeDeduction WHERE strDeduction = @strDeductionId)
											,strDeductFrom						= @strDeductFromType
											,strCalculationType					= @strRateCalcType
											,dblAmount							= @dblRateCalc
											,dblLimit							= @dblAnnualLimit
											,dblPaycheckMax						= @dblDeductFrom
											,dtmBeginDate						= @dtmBeginDate
											,dtmEndDate							= @dtmEndDate
											,intAccountId						= (SELECT TOP 1 intAccountId FROM tblGLAccount WHERE strAccountId = @strAccountId)
											,intExpenseAccountId				= (SELECT TOP 1 intAccountId FROM tblGLAccount WHERE strAccountId = @strExpenseAccountId)
											,strPaidBy							= (SELECT TOP 1 strPaidBy FROM tblPRTypeDeduction WHERE strDeduction = @strDeductionId)
											,ysnDefault							= @ysnDefault
											,ysnUseLocationDistribution			= ISNULL(@ysnAccountGLSplit,0)
											,ysnUseLocationDistributionExpense	= ISNULL(@ysnExpenseGLSplit,0)
										WHERE intEntityEmployeeId = @intEntityNo
											AND intTypeDeductionId = (SELECT TOP 1 intTypeDeductionId FROM tblPRTypeDeduction WHERE strDeduction = @strDeductionId )

										IF @strDeductionTaxId1 IS NOT NULL
											BEGIN
												IF EXISTS (SELECT TOP 1 * FROM tblPRTypeTax WHERE strTax = @strDeductionTaxId1)
												BEGIN
													IF NOT EXISTS (SELECT * FROM tblPREmployeeDeductionTax WHERE intEmployeeDeductionId = (SELECT TOP 1 intEmployeeDeductionId FROM tblPREmployeeDeduction WHERE intEntityEmployeeId = @intEntityNo AND intTypeDeductionId = (SELECT TOP 1 intTypeDeductionId FROM tblPRTypeDeduction WHERE strDeduction = @strDeductionId))  
														AND intTypeTaxId =  (SELECT TOP 1 intTypeTaxId FROM tblPRTypeTax WHERE strTax = @strDeductionTaxId1))
													BEGIN
														INSERT INTO tblPREmployeeDeductionTax(intEmployeeDeductionId,intTypeTaxId,intSort,intConcurrencyId)
														VALUES (
														(SELECT TOP 1 intEmployeeDeductionId FROM tblPREmployeeDeduction WHERE intEntityEmployeeId = @intEntityNo
															AND intTypeDeductionId = (SELECT TOP 1 intTypeDeductionId FROM tblPRTypeDeduction WHERE strDeduction = @strDeductionId))
														,(SELECT TOP 1 intTypeTaxId FROM tblPRTypeTax WHERE strTax = @strDeductionTaxId1 ),1,1)
													END
												END
											END

										IF @strDeductionTaxId2 IS NOT NULL
											BEGIN
												IF EXISTS (SELECT TOP 1 * FROM tblPRTypeTax WHERE strTax = @strDeductionTaxId2)
												BEGIN
													IF NOT EXISTS (SELECT * FROM tblPREmployeeDeductionTax WHERE intEmployeeDeductionId = (SELECT TOP 1 intEmployeeDeductionId FROM tblPREmployeeDeduction WHERE intEntityEmployeeId = @intEntityNo AND intTypeDeductionId = (SELECT TOP 1 intTypeDeductionId FROM tblPRTypeDeduction WHERE strDeduction = @strDeductionId))  
														AND intTypeTaxId =  (SELECT TOP 1 intTypeTaxId FROM tblPRTypeTax WHERE strTax = @strDeductionTaxId2))
													BEGIN
														INSERT INTO tblPREmployeeDeductionTax(intEmployeeDeductionId,intTypeTaxId,intSort,intConcurrencyId)
														VALUES ((SELECT TOP 1 intEmployeeDeductionId FROM tblPREmployeeDeduction WHERE intEntityEmployeeId = @intEntityNo
															AND intTypeDeductionId = (SELECT TOP 1 intTypeDeductionId FROM tblPRTypeDeduction WHERE strDeduction = @strDeductionId))
															,(SELECT TOP 1 intTypeTaxId FROM tblPRTypeTax WHERE strTax = @strDeductionTaxId2),1,1)
													END
												END
											END

										IF @strDeductionTaxId3 IS NOT NULL
											BEGIN
												IF EXISTS (SELECT TOP 1 * FROM tblPRTypeTax WHERE strTax = @strDeductionTaxId3)
												BEGIN
													IF NOT EXISTS (SELECT * FROM tblPREmployeeDeductionTax WHERE intEmployeeDeductionId = (SELECT TOP 1 intEmployeeDeductionId FROM tblPREmployeeDeduction WHERE intEntityEmployeeId = @intEntityNo AND intTypeDeductionId = (SELECT TOP 1 intTypeDeductionId FROM tblPRTypeDeduction WHERE strDeduction = @strDeductionId))  
														AND intTypeTaxId =  (SELECT TOP 1 intTypeTaxId FROM tblPRTypeTax WHERE strTax = @strDeductionTaxId3))
													BEGIN
														INSERT INTO tblPREmployeeDeductionTax(intEmployeeDeductionId,intTypeTaxId,intSort,intConcurrencyId)
														VALUES ((SELECT TOP 1 intEmployeeDeductionId FROM tblPREmployeeDeduction WHERE intEntityEmployeeId = @intEntityNo
															AND intTypeDeductionId = (SELECT TOP 1 intTypeDeductionId FROM tblPRTypeDeduction WHERE strDeduction = @strDeductionId))
															,(SELECT TOP 1 intTypeTaxId FROM tblPRTypeTax WHERE strTax = @strDeductionTaxId3),1,1)
													END
												END
											END

										IF @strDeductionTaxId4 IS NOT NULL
											BEGIN
												IF EXISTS (SELECT TOP 1 * FROM tblPRTypeTax WHERE strTax = @strDeductionTaxId4)
												BEGIN
													IF NOT EXISTS (SELECT * FROM tblPREmployeeDeductionTax WHERE intEmployeeDeductionId = (SELECT TOP 1 intEmployeeDeductionId FROM tblPREmployeeDeduction WHERE intEntityEmployeeId = @intEntityNo AND intTypeDeductionId = (SELECT TOP 1 intTypeDeductionId FROM tblPRTypeDeduction WHERE strDeduction = @strDeductionId))  
														AND intTypeTaxId =  (SELECT TOP 1 intTypeTaxId FROM tblPRTypeTax WHERE strTax = @strDeductionTaxId4))
													BEGIN
														INSERT INTO tblPREmployeeDeductionTax(intEmployeeDeductionId,intTypeTaxId,intSort,intConcurrencyId)
														VALUES ((SELECT TOP 1 intEmployeeDeductionId FROM tblPREmployeeDeduction WHERE intEntityEmployeeId = @intEntityNo
															AND intTypeDeductionId = (SELECT TOP 1 intTypeDeductionId FROM tblPRTypeDeduction WHERE strDeduction = @strDeductionId))
															,(SELECT TOP 1 intTypeTaxId FROM tblPRTypeTax WHERE strTax = @strDeductionTaxId4),1,1)
													END
												END
											END

										IF @strDeductionTaxId5 IS NOT NULL
											BEGIN
												IF EXISTS (SELECT TOP 1 * FROM tblPRTypeTax WHERE strTax = @strDeductionTaxId5)
												BEGIN
													IF NOT EXISTS (SELECT * FROM tblPREmployeeDeductionTax WHERE intEmployeeDeductionId = (SELECT TOP 1 intEmployeeDeductionId FROM tblPREmployeeDeduction WHERE intEntityEmployeeId = @intEntityNo AND intTypeDeductionId = (SELECT TOP 1 intTypeDeductionId FROM tblPRTypeDeduction WHERE strDeduction = @strDeductionId))  
														AND intTypeTaxId =  (SELECT TOP 1 intTypeTaxId FROM tblPRTypeTax WHERE strTax = @strDeductionTaxId5))
													BEGIN
														INSERT INTO tblPREmployeeDeductionTax(intEmployeeDeductionId,intTypeTaxId,intSort,intConcurrencyId)
														VALUES ((SELECT TOP 1 intEmployeeDeductionId FROM tblPREmployeeDeduction WHERE intEntityEmployeeId = @intEntityNo
															AND intTypeDeductionId = (SELECT TOP 1 intTypeDeductionId FROM tblPRTypeDeduction WHERE strDeduction = @strDeductionId))
															,(SELECT TOP 1 intTypeTaxId FROM tblPRTypeTax WHERE strTax = @strDeductionTaxId5),1,1)
													END
							
												END
											END

										IF @strDeductionTaxId6 IS NOT NULL
											BEGIN
												IF EXISTS (SELECT TOP 1 * FROM tblPRTypeTax WHERE strTax = @strDeductionTaxId6)
												BEGIN
													IF NOT EXISTS (SELECT * FROM tblPREmployeeDeductionTax WHERE intEmployeeDeductionId = (SELECT TOP 1 intEmployeeDeductionId FROM tblPREmployeeDeduction WHERE intEntityEmployeeId = @intEntityNo AND intTypeDeductionId = (SELECT TOP 1 intTypeDeductionId FROM tblPRTypeDeduction WHERE strDeduction = @strDeductionId))  
														AND intTypeTaxId =  (SELECT TOP 1 intTypeTaxId FROM tblPRTypeTax WHERE strTax = @strDeductionTaxId6))
													BEGIN
														INSERT INTO tblPREmployeeDeductionTax(intEmployeeDeductionId,intTypeTaxId,intSort,intConcurrencyId)
														VALUES ((SELECT TOP 1 intEmployeeDeductionId FROM tblPREmployeeDeduction WHERE intEntityEmployeeId = @intEntityNo
															AND intTypeDeductionId = (SELECT TOP 1 intTypeDeductionId FROM tblPRTypeDeduction WHERE strDeduction = @strDeductionId))
															,(SELECT TOP 1 intTypeTaxId FROM tblPRTypeTax WHERE strTax = @strDeductionTaxId6),1,1)
													END
							
												END
											END

										IF @strDeductionTaxId7 IS NOT NULL
											BEGIN
												IF EXISTS (SELECT TOP 1 * FROM tblPRTypeTax WHERE strTax = @strDeductionTaxId7)
												BEGIN
													IF NOT EXISTS (SELECT * FROM tblPREmployeeDeductionTax WHERE intEmployeeDeductionId = (SELECT TOP 1 intEmployeeDeductionId FROM tblPREmployeeDeduction WHERE intEntityEmployeeId = @intEntityNo AND intTypeDeductionId = (SELECT TOP 1 intTypeDeductionId FROM tblPRTypeDeduction WHERE strDeduction = @strDeductionId))  
														AND intTypeTaxId =  (SELECT TOP 1 intTypeTaxId FROM tblPRTypeTax WHERE strTax = @strDeductionTaxId7))
													BEGIN
														INSERT INTO tblPREmployeeDeductionTax(intEmployeeDeductionId,intTypeTaxId,intSort,intConcurrencyId)
														VALUES ((SELECT TOP 1 intEmployeeDeductionId FROM tblPREmployeeDeduction WHERE intEmployeeDeductionId = @intEntityNo
															AND intTypeDeductionId = (SELECT TOP 1 intTypeDeductionId FROM tblPRTypeDeduction WHERE strDeduction = @strDeductionId))
															,(SELECT TOP 1 intTypeTaxId FROM tblPRTypeTax WHERE strTax = @strDeductionTaxId7),1,1)
													END
												END
											END

										DELETE FROM #TempEmployeeDeductions WHERE intEntityNo = @strEmployeeId AND strDeductionId = @strDeductionId
									END

								INSERT INTO tblApiImportLogDetail (guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage)
								SELECT TOP 1
									  NEWID()
									, guiApiImportLogId = @guiLogId
									, strField = 'Employee Deductions'
									, strValue = SE.strDeductionId
									, strLogLevel = 'Info'
									, strStatus = 'Success'
									, intRowNo = SE.intRowNumber
									, strMessage = 'The employee deduction has been successfully imported.'
								FROM tblApiSchemaEmployeeDeduction SE
								LEFT JOIN tblPREmployeeDeduction E ON E.intEntityEmployeeId = @intEntityNo
								WHERE SE.guiApiUniqueId = @guiApiUniqueId
								AND SE.strDeductionId = @strDeductionId
								AND SE.strDeductionDesc = @strDeductionDesc
							END
						ELSE
							BEGIN
								INSERT INTO tblApiImportLogDetail (guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage)
								SELECT TOP 1
									  NEWID()
									, guiApiImportLogId = @guiLogId
									, strField = 'Employee Deductions'
									, strValue = @strDeductFromType
									, strLogLevel = 'Error'
									, strStatus = 'Failed'
									, intRowNo = SE.intRowNumber
									, strMessage = 'Cannot fint the value '+ @strDeductFromType +'. Please try again.'
								FROM tblApiSchemaEmployeeDeduction SE
								LEFT JOIN tblPREmployeeDeduction E ON E.intEntityEmployeeId = @intEntityNo
								WHERE SE.guiApiUniqueId = @guiApiUniqueId
								AND SE.strDeductionId = @strDeductionId
								AND SE.strDeductionDesc = @strDeductionDesc
							END
					END
				ELSE
					BEGIN
						INSERT INTO tblApiImportLogDetail (guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage)
						SELECT TOP 1
							  NEWID()
							, guiApiImportLogId = @guiLogId
							, strField = 'Employee Deductions'
							, strValue = @strRateCalcType
							, strLogLevel = 'Error'
							, strStatus = 'Failed'
							, intRowNo = SE.intRowNumber
							, strMessage = 'Cannot fint the value '+ @strRateCalcType +'. Please try again.'
						FROM tblApiSchemaEmployeeDeduction SE
						LEFT JOIN tblPREmployeeDeduction E ON E.intEntityEmployeeId = @intEntityNo
						WHERE SE.guiApiUniqueId = @guiApiUniqueId
						AND SE.strDeductionId = @strDeductionId
						AND SE.strDeductionDesc = @strDeductionDesc
					END
			END
		ELSE
			BEGIN
				INSERT INTO tblApiImportLogDetail (guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage)
				SELECT TOP 1
					  NEWID()
					, guiApiImportLogId = @guiLogId
					, strField = 'Employee Deductions'
					, strValue = @strCategory
					, strLogLevel = 'Error'
					, strStatus = 'Failed'
					, intRowNo = SE.intRowNumber
					, strMessage = 'Cannot fint the value '+ @strCategory +'. Please try again.'
				FROM tblApiSchemaEmployeeDeduction SE
				LEFT JOIN tblPREmployeeDeduction E ON E.intEntityEmployeeId = @intEntityNo
				WHERE SE.guiApiUniqueId = @guiApiUniqueId
				AND SE.strDeductionId = @strDeductionId
				AND SE.strDeductionDesc = @strDeductionDesc
			END


	END

IF EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#TempEmployeeDeductions')) 
DROP TABLE #TempEmployeeDeductions

END
GO