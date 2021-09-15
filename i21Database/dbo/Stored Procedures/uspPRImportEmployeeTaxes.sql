CREATE PROCEDURE dbo.uspPRImportEmployeeTaxes(
    @guiApiUniqueId UNIQUEIDENTIFIER,
    @guiLogId UNIQUEIDENTIFIER 
)

AS

BEGIN

--DECLARE @guiApiUniqueId AS UNIQUEIDENTIFIER = N'6703E376-141D-4C67-B14A-B2CA86B3F502'
--DECLARE @guiLogId AS UNIQUEIDENTIFIER = NEWID()
DECLARE @EntityNo AS INT
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
DECLARE @intAllowance AS INT
DECLARE @strPaidBy  AS NVARCHAR(100)
DECLARE @ysnDefault AS NVARCHAR(100)
DECLARE @intSort AS INT
DECLARE @ysnW42020 AS NVARCHAR(100)
DECLARE @ysnW4Step2c AS NVARCHAR(100)
DECLARE @dblW4ClaimDependents AS FLOAT(50)
DECLARE @dblW4OtherIncome  AS FLOAT(50)
DECLARE @dblW4Deductions  AS FLOAT(50)



SELECT * INTO #TempEmployeeTaxes FROM tblApiSchemaEmployeeTaxes where guiApiUniqueId = @guiApiUniqueId
	WHILE EXISTS(SELECT TOP 1 NULL FROM #TempEmployeeTaxes)
	BEGIN

	SELECT TOP 1 
			 @EntityNo = intEntityNo 
			,@TaxId = strTaxId
			,@TaxTaxDesc = strTaxDescription
			,@intEntityEmployeeId = intEntityNo
			,@strCalculationType  = strCalculationType
			,@strFilingStatus  = strFilingStatus
			,@intSupplementalCalc = strSupplimentalCalc
			,@dblAmount = dblAmount
			,@dblExtraWithholding = dblExtraWithholding
			,@dblLimit = dblLimit
			,@intAccountId = (SELECT TOP 1 intAccountId FROM tblGLAccount WHERE strAccountId = strAccountId)
			,@intExpenseAccountId = (SELECT TOP 1 intAccountId FROM tblGLAccount WHERE strAccountId = strExpenseAccount)
			,@intAllowance = dblFederalAllowance
			,@strPaidBy  = strPaidBy
			,@ysnDefault = CASE WHEN ysnDefault = 'Y' THEN 1 ELSE 0 END
			,@ysnW42020 =  CASE WHEN ysn2020W4 = 'Y' THEN 1 ELSE 0 END
			,@ysnW4Step2c =  CASE WHEN ysnStep2c = 'Y' THEN 1 ELSE 0 END
			,@dblW4ClaimDependents = dblClaimDependents
			,@dblW4OtherIncome  = dblotherIncome
			,@dblW4Deductions = 0.00
		FROM #TempEmployeeTaxes

		SELECT TOP 1 
				@TypeTaxId= T.intTypeTaxId
				,@TaxStateId = T.intTypeTaxStateId
				,@TaxLocalId = T.intTypeTaxLocalId
				,@EmployeeTaxId = PRTE.intEmployeeTaxId
				
			FROM tblPRTypeTax T 
		left join tblPREmployeeTax PRTE
		on T.intTypeTaxId = PRTE.intTypeTaxId
			AND PRTE.intEntityEmployeeId = @EntityNo
		WHERE strTax = @TaxId and strDescription = @TaxTaxDesc

		IF @EmployeeTaxId IS NULL
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
					SELECT 
						 EMT.intEntityNo
						,(SELECT TOP 1 intTypeTaxId FROM tblPRTypeTax WHERE strTax = @TaxId and strDescription = @TaxTaxDesc)
						,EMT.strCalculationType
						,EMT.strFilingStatus
						,@TaxStateId
						,@TaxLocalId
						,(CASE WHEN EMT.strSupplimentalCalc = 'Flat Rate' THEN 0 ELSE 1 END)
						,EMT.dblAmount
						,EMT.dblExtraWithholding
						,EMT.dblLimit
						,(SELECT TOP 1 intAccountId FROM tblGLAccount WHERE strAccountId = strAccountId)
						,(SELECT TOP 1 intAccountId FROM tblGLAccount WHERE strAccountId = strExpenseAccount)
						,1
						,1
						,EMT.dblFederalAllowance
						,EMT.strPaidBy
						,CASE WHEN EMT.ysnDefault = 'Y' THEN 1 ELSE 0 END
						,1
						,CASE WHEN EMT.ysn2020W4 = 'Y' THEN 1 ELSE 0 END
						,CASE WHEN EMT.ysnStep2c = 'Y' THEN 1 ELSE 0 END
						,EMT.dblClaimDependents
						,0
						,0
						,1
						FROM #TempEmployeeTaxes EMT
					WHERE EMT.intEntityNo = @EntityNo
					SET @NewId = SCOPE_IDENTITY()
					DELETE FROM #TempEmployeeTaxes WHERE intEntityNo = @EntityNo

			END
		ELSE
			BEGIN
				UPDATE tblPREmployeeTax SET
					intTypeTaxId = (SELECT TOP 1 intTypeTaxId FROM tblPRTypeTax WHERE strTax = @TaxId and strDescription = @TaxTaxDesc)
					,strCalculationType = @strCalculationType
					,strFilingStatus = @strFilingStatus
					,intTypeTaxStateId = @TaxStateId
					,intTypeTaxLocalId  = @TaxLocalId
					,intSupplementalCalc = @strCalculationType
					,dblAmount = @dblAmount
					,dblExtraWithholding  = @dblExtraWithholding
					,dblLimit = @dblLimit
					,intAccountId = @intAccountId
					,intExpenseAccountId = @intExpenseAccountId
					,intAllowance = @intAllowance
					,strPaidBy = @strPaidBy
					,ysnDefault = @ysnDefault
					,ysnW42020 = @ysnW42020
					,ysnW4Step2c = @ysnW4Step2c
					,dblW4ClaimDependents = @dblW4ClaimDependents
					,dblW4OtherIncome  = @dblW4OtherIncome
					,dblW4Deductions  = @dblW4Deductions
				WHERE intEmployeeTaxId = @NewId
			END
	END

	IF EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#TempEmployeeTaxes')) 
	DROP TABLE #TempEmployeeTaxes
END
GO