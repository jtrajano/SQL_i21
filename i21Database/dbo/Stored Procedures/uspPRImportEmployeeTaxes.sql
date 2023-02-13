CREATE PROCEDURE dbo.uspPRImportEmployeeTaxes(
    @guiApiUniqueId UNIQUEIDENTIFIER,
    @guiLogId UNIQUEIDENTIFIER 
)

AS

BEGIN

--DECLARE @guiApiUniqueId AS UNIQUEIDENTIFIER = N'6703E376-141D-4C67-B14A-B2CA86B3F502'
--DECLARE @guiLogId AS UNIQUEIDENTIFIER = NEWID()
DECLARE @EntityNo AS INT
DECLARE @strEmployeeId  AS NVARCHAR(100)
DECLARE @EmployeeTaxId AS INT
DECLARE @TypeTaxId AS INT
DECLARE @TaxId AS NVARCHAR(100)
DECLARE @TaxTaxDesc AS NVARCHAR(100)
DECLARE @TaxStateId as INT
DECLARE @TaxLocalId as INT
DECLARE @NewId AS INT

DECLARE @intEntityEmployeeId AS INT
DECLARE @strCalculationType  AS NVARCHAR(100)
DECLARE @strFilingStatus  AS NVARCHAR(100)
DECLARE @intTypeTaxStateId AS INT
DECLARE @intTypeTaxLocalId  AS INT
DECLARE @intSupplementalCalc AS INT
DECLARE @dblAmount AS FLOAT(50)
DECLARE @dblExtraWithholding  AS FLOAT(50)
DECLARE @dblLimit AS FLOAT(50)
DECLARE @intAccountId AS INT
DECLARE @intExpenseAccountId AS INT

DECLARE @strAccountId  AS NVARCHAR(100)
DECLARE @strExpenseAccountId  AS NVARCHAR(100)

DECLARE @intAllowance AS INT
DECLARE @strPaidBy  AS NVARCHAR(100)
DECLARE @ysnDefault AS BIT
DECLARE @intSort AS INT
DECLARE @ysnW42020 AS BIT
DECLARE @ysnW4Step2c AS BIT
DECLARE @dblW4ClaimDependents AS FLOAT(50)
DECLARE @dblW4OtherIncome  AS FLOAT(50)
DECLARE @dblW4Deductions  AS FLOAT(50)
DECLARE @ysnUseLocationDistribution AS BIT
DECLARE @ysnUseLocationDistributionExpense AS BIT
DECLARE @EmployeeCount AS INT
DECLARE @AccountCount AS INT
DECLARE @ExpenseAccountCount AS INT

INSERT INTO tblApiImportLogDetail(guiApiImportLogDetailId,guiApiImportLogId, strField,strValue,strLogLevel,strStatus,intRowNo,strMessage)
SELECT
	guiApiImportLogDetailId = NEWID()
	,guiApiImportLogId = @guiLogId
	,strField		= 'Employee ID'
	,strValue		= SE.intEntityNo
	,strLogLevel		= 'Error'
	,strStatus		= 'Failed'
	,intRowNo		= SE.intRowNumber
	,strMessage		= 'Cannot find the Employee Entity No: '+ CAST(ISNULL(SE.intEntityNo, '') AS NVARCHAR(100)) + '.'
	FROM tblApiSchemaEmployeeTaxes SE
	LEFT JOIN tblPREmployeeTax E 
		ON E.intEntityEmployeeId = (SELECT TOP 1 intEntityId FROM tblPREmployee WHERE strEmployeeId = SE.intEntityNo)
	WHERE SE.guiApiUniqueId = @guiApiUniqueId
	AND SE.intEntityNo IS NULL

SELECT * INTO #TempEmployeeTaxes FROM tblApiSchemaEmployeeTaxes where guiApiUniqueId = @guiApiUniqueId
	WHILE EXISTS(SELECT TOP 1 NULL FROM #TempEmployeeTaxes)
	BEGIN

	SELECT TOP 1 
			@strEmployeeId						= LTRIM(RTRIM(intEntityNo))
			,@EntityNo							= (SELECT TOP 1 intEntityId FROM tblPREmployee WHERE strEmployeeId = LTRIM(RTRIM(intEntityNo)))  
			,@TaxId								= LTRIM(RTRIM(strTaxId))
			,@TaxTaxDesc						= strTaxDescription
			,@intEntityEmployeeId				= (SELECT TOP 1 intEntityId FROM tblPREmployee WHERE strEmployeeId = LTRIM(RTRIM(intEntityNo))) 
			,@strCalculationType				= CASE WHEN strCalculationType <> '' AND strCalculationType 
													IN(
														'USA Social Security'
													   ,'USA Medicare'
													   ,'USA State Disability'
													   ,'USA FUTA','USA SUTA'
													   ,'USA Federal Tax'
													   ,'USA State'
													   ,'USA Local'
													   ,'Fixed Amount'
													   ,'Percent'
													   ,'Hourly Amount'
													   ,'Hourly Percent'
													) THEN strCalculationType ELSE '' END
			
			,@strFilingStatus					= CASE WHEN strFilingStatus <> '' AND strFilingStatus IN('Single','Married') THEN strFilingStatus ELSE '' END
			,@intSupplementalCalc				= (CASE WHEN strSupplimentalCalc = 'Flat Rate' THEN 0 WHEN strSupplimentalCalc = 'Normal Rate' THEN 1 ELSE 2 END)
			,@dblAmount							= dblAmount
			,@dblExtraWithholding				= ISNULL(dblExtraWithholding,0)
			,@dblLimit							= dblLimit
			,@intAccountId						= (SELECT TOP 1 intAccountId FROM tblGLAccount WHERE strAccountId = strLiabilityAccount)
			,@intExpenseAccountId				= (SELECT TOP 1 intAccountId FROM tblGLAccount WHERE strAccountId = strExpenseAccount)
			,@strAccountId						= strLiabilityAccount
			,@strExpenseAccountId				= strExpenseAccount
			,@intAllowance						= dblFederalAllowance
			,@strPaidBy							= strPaidBy
			,@ysnDefault						= ysnDefault
			,@ysnW42020							= ysn2020W4
			,@ysnW4Step2c						= ysnStep2c
			,@dblW4ClaimDependents				= dblClaimDependents
			,@dblW4OtherIncome					= dblotherIncome
			,@dblW4Deductions					= 0.00
			,@ysnUseLocationDistribution		= ysnLiabilityGlSplit
			,@ysnUseLocationDistributionExpense = ysnExpenseAccountGlSplit
		FROM #TempEmployeeTaxes

		SELECT TOP 1 
				 @TypeTaxId= T.intTypeTaxId
				,@TaxStateId = ISNULL(T.intTypeTaxStateId,0)
				,@TaxLocalId = ISNULL(T.intTypeTaxLocalId,0)
				,@EmployeeTaxId = COUNT(PRTE.intEmployeeTaxId)
			FROM tblPRTypeTax T 
		left join tblPREmployeeTax PRTE
		on T.intTypeTaxId = PRTE.intTypeTaxId
			AND PRTE.intEntityEmployeeId = @EntityNo
		WHERE strTax = @TaxId
		group by T.intTypeTaxId,T.intTypeTaxStateId,T.intTypeTaxLocalId,PRTE.intEmployeeTaxId

		IF(@strFilingStatus IS NOT NULL AND @strFilingStatus != '')
					BEGIN
						IF(@intSupplementalCalc IS NOT NULL AND @intSupplementalCalc != 2)
							BEGIN
								IF (@EmployeeTaxId = 0)
									BEGIN
										IF NOT EXISTS (SELECT TOP 1 * FROM tblPREmployeeTax WHERE intEntityEmployeeId = @EntityNo and intTypeTaxId = (SELECT TOP 1 intTypeTaxId FROM tblPRTypeTax WHERE strTax = @TaxId and strDescription = @TaxTaxDesc))
											BEGIN
												SELECT TOP 1 @EmployeeCount = COUNT(intEntityId) FROM tblPREmployee WHERE intEntityId = (SELECT TOP 1 intEntityId FROM tblPREmployee WHERE strEmployeeId = @strEmployeeId)
												IF(@EmployeeCount != 0)
													BEGIN
														SET @AccountCount = 0
														SET @ExpenseAccountCount = 0

														IF(@strAccountId IS NULL OR @strAccountId = '')
														BEGIN
															SET @AccountCount = 1
														END
														ELSE
														BEGIN
															SELECT @AccountCount = COUNT(intAccountId) FROM tblGLAccount WHERE strAccountId = @strAccountId
														END

														IF(@AccountCount != 0)
														BEGIN
															IF(@strExpenseAccountId IS NULL OR @strExpenseAccountId = '')
															BEGIN
																SET @ExpenseAccountCount = 1
															END
															ELSE
															BEGIN
																SELECT @ExpenseAccountCount = COUNT(intAccountId) FROM tblGLAccount WHERE strAccountId = @strExpenseAccountId
															END

															IF(@ExpenseAccountCount != 0)
															BEGIN
																INSERT INTO tblPREmployeeTax
																(
																 intEntityEmployeeId
																,intTypeTaxId
																,strCalculationType
																,strFilingStatus
																,intTypeTaxStateId
																,intTypeTaxLocalId 
																,intSupplementalCalc
																,dblAmount
																,dblExtraWithholding 
																,dblLimit
																,intAccountId
																,intExpenseAccountId
																,ysnUseLocationDistribution
																,ysnUseLocationDistributionExpense
																,intAllowance
																,strPaidBy
																,ysnDefault
																,intSort
																,ysnW42020
																,ysnW4Step2c
																,dblW4ClaimDependents
																,dblW4OtherIncome 
																,dblW4Deductions 
																,intConcurrencyId 
																)
																SELECT TOP 1
																	 (SELECT TOP 1 intEntityId FROM tblPREmployee WHERE strEmployeeId = EMT.intEntityNo)
																	,(SELECT TOP 1 intTypeTaxId FROM tblPRTypeTax WHERE strTax = EMT.strTaxId)
																	,@strCalculationType
																	,@strFilingStatus
																	,(SELECT TOP 1 intTypeTaxStateId FROM tblPRTypeTax WHERE strTax = EMT.strTaxId)
																	,(SELECT TOP 1 intTypeTaxLocalId FROM tblPRTypeTax WHERE strTax = EMT.strTaxId)
																	,(CASE WHEN EMT.strSupplimentalCalc = 'Flat Rate' THEN 0 WHEN EMT.strSupplimentalCalc = 'Normal Rate' THEN 1 ELSE 2 END)
																	,EMT.dblAmount
																	,EMT.dblExtraWithholding
																	,EMT.dblLimit
																	,@intAccountId
																	,@intExpenseAccountId
																	,EMT.ysnLiabilityGlSplit
																	,EMT.ysnExpenseAccountGlSplit
																	,EMT.dblFederalAllowance
																	,EMT.strPaidBy
																	,EMT.ysnDefault
																	,1
																	,ISNULL(EMT.ysn2020W4, 0)
																	,ISNULL(EMT.ysnStep2c,0)
																	,EMT.dblClaimDependents
																	,0
																	,0
																	,1
																	FROM #TempEmployeeTaxes EMT
																WHERE EMT.intEntityNo = @strEmployeeId AND EMT.strTaxId = @TaxId
																SET @NewId = SCOPE_IDENTITY()

																INSERT INTO tblApiImportLogDetail (guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage)
																SELECT TOP 1
																	  NEWID()
																	, guiApiImportLogId = @guiLogId
																	, strField = 'Employee Taxes'
																	, strValue = SE.strTaxId
																	, strLogLevel = 'Info'
																	, strStatus = 'Success'
																	, intRowNo = SE.intRowNumber
																	, strMessage = 'The employee taxes has been successfully imported.'
																FROM tblApiSchemaEmployeeTaxes SE
																LEFT JOIN tblPREmployeeTax E ON E.intEntityEmployeeId = (SELECT TOP 1 intEntityId FROM tblPREmployee WHERE strEmployeeId = SE.intEntityNo)
																WHERE SE.guiApiUniqueId = @guiApiUniqueId
																AND SE.strTaxId = @TaxId
															END
															
															ELSE
															BEGIN
																INSERT INTO tblApiImportLogDetail (guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage)
																SELECT TOP 1
																	  NEWID()
																	, guiApiImportLogId = @guiLogId
																	, strField = 'Employee Taxes'
																	, strValue = SE.strExpenseAccount
																	, strLogLevel = 'Error'
																	, strStatus = 'Failed'
																	, intRowNo = SE.intRowNumber
																	, strMessage = 'Expense Account Id does not exist or in wrong format. Please try again.'
																FROM tblApiSchemaEmployeeTaxes SE
																LEFT JOIN tblPREmployeeTax E ON E.intEntityEmployeeId = (SELECT TOP 1 intEntityId FROM tblPREmployee WHERE strEmployeeId = SE.intEntityNo)
																WHERE SE.guiApiUniqueId = @guiApiUniqueId
																AND SE.strTaxId = @TaxId
															END
															
														END


														ELSE
														BEGIN
															INSERT INTO tblApiImportLogDetail (guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage)
															SELECT TOP 1
																  NEWID()
																, guiApiImportLogId = @guiLogId
																, strField = 'Employee Taxes'
																, strValue = SE.strAccountId
																, strLogLevel = 'Error'
																, strStatus = 'Failed'
																, intRowNo = SE.intRowNumber
																, strMessage = 'Account Id does not exist or in wrong format. Please try again.'
															FROM tblApiSchemaEmployeeTaxes SE
															LEFT JOIN tblPREmployeeTax E ON E.intEntityEmployeeId = (SELECT TOP 1 intEntityId FROM tblPREmployee WHERE strEmployeeId = SE.intEntityNo)
															WHERE SE.guiApiUniqueId = @guiApiUniqueId
															AND SE.strTaxId = @TaxId
														END
														
													END
											END

										
				
										DELETE FROM #TempEmployeeTaxes WHERE LTRIM(RTRIM(intEntityNo)) = @strEmployeeId AND LTRIM(RTRIM(strTaxId)) = LTRIM(RTRIM(@TaxId))

									END
								ELSE
									BEGIN
										UPDATE tblPREmployeeTax SET
											intTypeTaxId = (SELECT TOP 1 intTypeTaxId FROM tblPRTypeTax WHERE strTax = @TaxId)
											,strCalculationType = @strCalculationType
											,strFilingStatus = @strFilingStatus
											,intTypeTaxStateId = (SELECT TOP 1 intTypeTaxStateId FROM tblPRTypeTax WHERE strTax = @TaxId)
											,intTypeTaxLocalId  = (SELECT TOP 1 intTypeTaxLocalId FROM tblPRTypeTax WHERE strTax = @TaxId)
											,intSupplementalCalc = @intSupplementalCalc
											,dblAmount = @dblAmount
											,dblExtraWithholding  = @dblExtraWithholding
											,dblLimit = @dblLimit
											,intAccountId = @intAccountId
											,intExpenseAccountId = @intExpenseAccountId
											,intAllowance = @intAllowance
											,strPaidBy = @strPaidBy
											,ysnUseLocationDistribution = @ysnUseLocationDistribution
											,ysnUseLocationDistributionExpense = @ysnUseLocationDistributionExpense
											,ysnDefault = @ysnDefault
											,ysnW42020 = @ysnW42020
											,ysnW4Step2c = @ysnW4Step2c
											,dblW4ClaimDependents = @dblW4ClaimDependents
											,dblW4OtherIncome  = @dblW4OtherIncome
											,dblW4Deductions  = @dblW4Deductions
										WHERE intEntityEmployeeId = @EntityNo
											AND intTypeTaxId = (SELECT TOP 1 intTypeTaxId FROM tblPRTypeTax WHERE strTax = @TaxId)

										DELETE FROM #TempEmployeeTaxes WHERE LTRIM(RTRIM(intEntityNo)) = @strEmployeeId AND LTRIM(RTRIM(strTaxId)) = LTRIM(RTRIM(@TaxId))
				
									END
							END
						ELSE
							BEGIN
								INSERT INTO tblApiImportLogDetail (guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage)
								SELECT TOP 1
									  NEWID()
									, guiApiImportLogId = @guiLogId
									, strField = 'Employee Taxes'
									, strValue = SE.strSupplimentalCalc
									, strLogLevel = 'Error'
									, strStatus = 'Failed'
									, intRowNo = SE.intRowNumber
									, strMessage = 'Wrong input/format for Supplemental Calculation. Please try again.'
								FROM tblApiSchemaEmployeeTaxes SE
								LEFT JOIN tblPREmployeeTax E ON E.intEntityEmployeeId = (SELECT TOP 1 intEntityId FROM tblPREmployee WHERE strEmployeeId = SE.intEntityNo)
								WHERE SE.guiApiUniqueId = @guiApiUniqueId
								AND SE.strTaxId = @TaxId

								DELETE FROM #TempEmployeeTaxes WHERE LTRIM(RTRIM(intEntityNo)) = @strEmployeeId AND LTRIM(RTRIM(strTaxId)) = LTRIM(RTRIM(@TaxId))
							END
					END
				ELSE
					BEGIN
						INSERT INTO tblApiImportLogDetail (guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage)
						SELECT TOP 1
							  NEWID()
							, guiApiImportLogId = @guiLogId
							, strField = 'Employee Taxes'
							, strValue = @strFilingStatus
							, strLogLevel = 'Error'
							, strStatus = 'Failed'
							, intRowNo = SE.intRowNumber
							, strMessage = 'Wrong input/format for Filling Status. Please try again.'
						FROM tblApiSchemaEmployeeTaxes SE
						LEFT JOIN tblPREmployeeTax E ON E.intEntityEmployeeId = (SELECT TOP 1 intEntityId FROM tblPREmployee WHERE strEmployeeId = SE.intEntityNo)
						WHERE SE.guiApiUniqueId = @guiApiUniqueId
						AND SE.strTaxId = @TaxId

						DELETE FROM #TempEmployeeTaxes WHERE LTRIM(RTRIM(intEntityNo)) = @strEmployeeId AND LTRIM(RTRIM(strTaxId)) = LTRIM(RTRIM(@TaxId))
					END
	END

	

	IF EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#TempEmployeeTaxes')) 
	DROP TABLE #TempEmployeeTaxes
END
GO