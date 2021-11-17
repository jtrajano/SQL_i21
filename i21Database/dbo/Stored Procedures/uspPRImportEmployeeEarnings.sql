CREATE PROCEDURE dbo.uspPRImportEmployeeEarnings(
    @guiApiUniqueId UNIQUEIDENTIFIER,
    @guiLogId UNIQUEIDENTIFIER 
)

AS

BEGIN
--DECLARE @guiApiUniqueId UNIQUEIDENTIFIER = N''
--DECLARE @guiLogId UNIQUEIDENTIFIER = NEWID()
DECLARE @NewId AS INT

DECLARE @EmployeeEntityNo AS INT
DECLARE @intEntityNo AS INT
DECLARE @strEarningDesc AS NVARCHAR(50)
DECLARE @dblEarningAmount AS FLOAT(50)
DECLARE @ysnEarningDefault AS NVARCHAR(50)
DECLARE @strPayGroup AS NVARCHAR(50)
DECLARE @strCalculationType	 AS NVARCHAR(50)
DECLARE @strLinkedEarning AS NVARCHAR(50)
DECLARE @dblAmount AS FLOAT(50)
DECLARE @dblDefaultHours AS FLOAT(50)
DECLARE @strAccrueTimeOff AS NVARCHAR(50)
DECLARE @strDeductTimeOff AS NVARCHAR(50)
DECLARE @strTaxCalculation AS NVARCHAR(50)
DECLARE @strAccountID AS NVARCHAR(50)
DECLARE @ysnUseGLSplit AS NVARCHAR(50)
DECLARE @strTaxID AS NVARCHAR(50)
DECLARE @strTaxDescription	AS NVARCHAR(50)
DECLARE @strTaxType	AS NVARCHAR(50)
DECLARE @strTaxPaidBy AS NVARCHAR(50)

	IF EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#TempEmployeeTaxes')) 
	DROP TABLE #TempEmployeeTaxes

	SELECT * INTO #TempEmployeeEarnings FROM tblApiSchemaEmployeeEarnings where guiApiUniqueId = @guiApiUniqueId
	WHILE EXISTS(SELECT TOP 1 NULL FROM #TempEmployeeEarnings)
	BEGIN
		SELECT TOP 1 
			 @intEntityNo
			,@strEarningDesc 
			,@dblEarningAmount
			,@ysnEarningDefault 
			,@strPayGroup 
			,@strCalculationType	 
			,@strLinkedEarning 
			,@dblAmount
			,@dblDefaultHours
			,@strAccrueTimeOff 
			,@strDeductTimeOff 
			,@strTaxCalculation 
			,@strAccountID 
			,@ysnUseGLSplit 
			,@strTaxID 
			,@strTaxDescription	
			,@strTaxType	
			,@strTaxPaidBy 
		FROM #TempEmployeeEarnings

		SELECT TOP 1 
			@EmployeeEntityNo = intEntityEmployeeId 
		FROM tblPREmployeeEarning 
		WHERE intEntityEmployeeId = @intEntityNo
		  AND intTypeEarningId = (SELECT TOP 1 intTypeEarningId FROM tblPRTypeEarning WHERE strDescription = @strEarningDesc)

		IF @EmployeeEntityNo IS NULL
		BEGIN
			INSERT INTO tblPREmployeeEarning
			(
				 intEntityEmployeeId
				,intTypeEarningId
				,strCalculationType
				,dblAmount
				,dblRateAmount
				,dblDefaultHours
				,dblHoursToProcess
				,intAccountId
				,ysnUseLocationDistribution
				,intTaxCalculationType
				,strW2Code
				,intEmployeeTimeOffId
				,intEmployeeAccrueTimeOffId
				,intEmployeeEarningLinkId
				,intPayGroupId
				,ysnDefault
				,intSort
				,intConcurrencyId

			)
			SELECT
			    intEntityNo
			   ,(SELECT TOP 1 intTypeEarningId FROM tblPRTypeEarning where strDescription = strEarningDesc)
			   ,(SELECT TOP 1 strCalculationType FROM tblPRTypeEarning where strDescription = strEarningDesc)
			   ,dblAmount
			   ,dblAmount --dblRateAmount test
			   ,dblDefaultHours
			   ,dblDefaultHours -- dblHoursToProcess test
			   ,(SELECT TOP 1 intAccountId FROM tblGLAccount WHERE strAccountId = strAccountId)
			   ,1
			   ,0 --intTaxCalculationType test only
			   ,'' --strW2Code for test only
			   ,null --intEmployeeTimeOffId for test
			   ,null --intEmployeeAccrueTimeOffId for test only
			   ,null --intEmployeeEarningLinkId for test only
			   ,CASE WHEN strPayGroup = 'Holiday' THEN 1
					 WHEN strPayGroup = 'BI 2' THEN 2
					 WHEN strPayGroup = 'MO 2' THEN 3
					 WHEN strPayGroup = 'WK 2' THEN 4
					 WHEN strPayGroup = 'TE 2' THEN 5
					 WHEN strPayGroup = 'Semi-Monthly' THEN 6
					 WHEN strPayGroup = 'Time Entry' THEN 7
					 WHEN strPayGroup = 'Weekly' THEN 8
					 WHEN strPayGroup = 'Commissions' THEN 9
					 WHEN strPayGroup = 'Monthly' THEN 10
					 WHEN strPayGroup = 'Bi-Weekly' THEN 11 END
				,ysnDefault
				,1
				,1
			FROM #TempEmployeeEarnings
			WHERE intEntityNo = @intEntityNo

			SET @NewId = SCOPE_IDENTITY()
			DELETE FROM #TempEmployeeEarnings WHERE intEntityNo = @intEntityNo

		END


	END

	IF EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#TempEmployeeTaxes')) 
	DROP TABLE #TempEmployeeTaxes
END


GO