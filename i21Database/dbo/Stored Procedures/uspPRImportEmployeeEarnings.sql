CREATE PROCEDURE dbo.uspPRImportEmployeeEarnings(
    @guiApiUniqueId UNIQUEIDENTIFIER,
    @guiLogId UNIQUEIDENTIFIER 
)

AS

BEGIN
--DECLARE @guiApiUniqueId UNIQUEIDENTIFIER = N'BD714385-2202-45BA-AD15-27707FDB5D1C'
--DECLARE @guiLogId UNIQUEIDENTIFIER = NEWID()
DECLARE @NewId AS INT

DECLARE @EmployeeEntityNo AS INT
DECLARE @intEntityNo AS INT
DECLARE @strEarningDesc AS NVARCHAR(50)
DECLARE @dblEarningAmount AS FLOAT(50)
DECLARE @ysnEarningDefault AS BIT
DECLARE @strPayGroup AS NVARCHAR(50)
DECLARE @strCalculationType	 AS NVARCHAR(50)
DECLARE @strLinkedEarning AS NVARCHAR(50)
DECLARE @dblAmount AS FLOAT(50)
DECLARE @dblDefaultHours AS FLOAT(50)
DECLARE @strAccrueTimeOff AS NVARCHAR(50)
DECLARE @strDeductTimeOff AS NVARCHAR(50)
DECLARE @strTaxCalculation AS NVARCHAR(50)
DECLARE @strAccountID AS NVARCHAR(50)
DECLARE @ysnUseGLSplit AS BIT
DECLARE @strTaxID1 AS NVARCHAR(50)
DECLARE @strTaxDescription1 AS NVARCHAR(50)
DECLARE @strTaxID2 AS NVARCHAR(50)
DECLARE @strTaxDescription2 AS NVARCHAR(50)
DECLARE @strTaxID3 AS NVARCHAR(50)
DECLARE @strTaxDescription3 AS NVARCHAR(50)
DECLARE @strTaxID4 AS NVARCHAR(50)
DECLARE @strTaxDescription4 AS NVARCHAR(50)
DECLARE @strTaxID5 AS NVARCHAR(50)
DECLARE @strTaxDescription5 AS NVARCHAR(50)
DECLARE @strTaxID6 AS NVARCHAR(50)
DECLARE @strTaxDescription6 AS NVARCHAR(50)


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
	   FROM tblApiSchemaEmployeeEarnings SE
	   LEFT JOIN tblPREmployeeEarning E ON E.intEntityEmployeeId = SE.intEntityNo
	   WHERE SE.guiApiUniqueId = @guiApiUniqueId

	IF EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#TempEmployeeEarnings')) 
	DROP TABLE #TempEmployeeEarnings

	SELECT * INTO #TempEmployeeEarnings FROM tblApiSchemaEmployeeEarnings where guiApiUniqueId = @guiApiUniqueId
	WHILE EXISTS(SELECT TOP 1 NULL FROM #TempEmployeeEarnings)
	BEGIN
		SELECT TOP 1 
			 @intEntityNo				= intEntityNo
			,@strEarningDesc			= strEarningDesc
			,@dblEarningAmount			= dblEarningAmount
			,@ysnEarningDefault			= ysnEarningDefault
			,@strPayGroup				= strPayGroup
			,@strCalculationType		= strCalculationType
			,@strLinkedEarning			= strLinkedEarning
			,@dblAmount					= dblAmount
			,@dblDefaultHours			= dblDefaultHours
			,@strAccrueTimeOff			= strAccrueTimeOff
			,@strDeductTimeOff			= strDeductTimeOff
			,@strTaxCalculation			= strTaxCalculation
			,@strAccountID				= strAccountID
			,@ysnUseGLSplit				= ysnUseGLSplit
			,@strTaxID1					= strTaxID1
			,@strTaxDescription1		= strTaxDescription1
			,@strTaxID2					= strTaxID2
			,@strTaxDescription2		= strTaxDescription2
			,@strTaxID3					= strTaxID3
			,@strTaxDescription3		= strTaxDescription3
			,@strTaxID4					= strTaxID4
			,@strTaxDescription4		= strTaxDescription4
			,@strTaxID5					= strTaxID5
			,@strTaxDescription5		= strTaxDescription5
			,@strTaxID6					= strTaxID6
			,@strTaxDescription6		= strTaxDescription6
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
				   ,(SELECT TOP 1 intTypeEarningId FROM tblPRTypeEarning WHERE strDescription = strEarningDesc)
				   ,(SELECT TOP 1 strCalculationType FROM tblPRTypeEarning WHERE strDescription = strEarningDesc AND strCalculationType = strTaxCalculation)
				   ,dblAmount
				   ,dblAmount --dblRateAmount test
				   ,dblDefaultHours
				   ,dblDefaultHours -- dblHoursToProcess test
				   ,(SELECT TOP 1 intAccountId FROM tblGLAccount WHERE strAccountId = strAccountId)
				   ,1
				   ,(SELECT TOP 1 intTaxCalculationType FROM tblPRTypeEarning WHERE strDescription = strEarningDesc)
				   ,'' --strW2Code for test only
				   ,(SELECT TOP 1 intTypeTimeOffId FROM tblPRTypeTimeOff WHERE strTimeOff = strDeductTimeOff)
				   ,(SELECT TOP 1 intTypeTimeOffId FROM tblPRTypeTimeOff WHERE strTimeOff = strAccrueTimeOff)
				   ,(SELECT TOP 1 intTypeEarningId FROM tblPRTypeEarning WHERE strDescription = strEarningDesc)
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
					,ysnEarningDefault
					,1
					,1
				FROM #TempEmployeeEarnings
				WHERE intEntityNo = @intEntityNo
					AND strEarningDesc = (SELECT TOP 1 strDescription FROM tblPRTypeEarning WHERE strDescription = @strEarningDesc)

				SET @NewId = SCOPE_IDENTITY()

				IF @strTaxID1 IS NOT NULL
					BEGIN
						IF EXISTS (SELECT TOP 1 * FROM tblPRTypeTax WHERE strTax = @strTaxID1 AND strDescription = @strTaxDescription1)
						BEGIN
							INSERT INTO tblPREmployeeEarningTax (intEmployeeEarningId,intTypeTaxId,intSort,intConcurrencyId)
							VALUES (@NewId,(SELECT TOP 1 intTypeTaxId FROM tblPRTypeTax WHERE strTax = @strTaxID1 AND strDescription = @strTaxDescription1),1,1)
						END
					END

				IF @strTaxID2 IS NOT NULL
					BEGIN
						IF EXISTS (SELECT TOP 1 * FROM tblPRTypeTax WHERE strTax = @strTaxID2 AND strDescription = @strTaxDescription2)
						BEGIN
							INSERT INTO tblPREmployeeEarningTax (intEmployeeEarningId,intTypeTaxId,intSort,intConcurrencyId)
							VALUES (@NewId,(SELECT TOP 1 intTypeTaxId FROM tblPRTypeTax WHERE strTax = @strTaxID2 AND strDescription = @strTaxDescription2),1,1)
						END
					END

				IF @strTaxID3 IS NOT NULL
					BEGIN
						IF EXISTS (SELECT TOP 1 * FROM tblPRTypeTax WHERE strTax = @strTaxID3 AND strDescription = @strTaxDescription3)
						BEGIN
							INSERT INTO tblPREmployeeEarningTax (intEmployeeEarningId,intTypeTaxId,intSort,intConcurrencyId)
							VALUES (@NewId,(SELECT TOP 1 intTypeTaxId FROM tblPRTypeTax WHERE strTax = @strTaxID3 AND strDescription = @strTaxDescription3),1,1)
						END
					END

				IF @strTaxID4 IS NOT NULL
					BEGIN
						IF EXISTS (SELECT TOP 1 * FROM tblPRTypeTax WHERE strTax = @strTaxID1 AND strDescription = @strTaxDescription1)
						BEGIN
							INSERT INTO tblPREmployeeEarningTax (intEmployeeEarningId,intTypeTaxId,intSort,intConcurrencyId)
							VALUES (@NewId,(SELECT TOP 1 intTypeTaxId FROM tblPRTypeTax WHERE strTax = @strTaxID4 AND strDescription = @strTaxDescription4),1,1)
						END
					END

				IF @strTaxID5 IS NOT NULL
					BEGIN
						IF EXISTS (SELECT TOP 1 * FROM tblPRTypeTax WHERE strTax = @strTaxID5 AND strDescription = @strTaxDescription5)
						BEGIN
							INSERT INTO tblPREmployeeEarningTax (intEmployeeEarningId,intTypeTaxId,intSort,intConcurrencyId)
							VALUES (@NewId,(SELECT TOP 1 intTypeTaxId FROM tblPRTypeTax WHERE strTax = @strTaxID5 AND strDescription = @strTaxDescription5),1,1)
						END
					END

				IF @strTaxID6 IS NOT NULL
					BEGIN
						IF EXISTS (SELECT TOP 1 * FROM tblPRTypeTax WHERE strTax = @strTaxID6 AND strDescription = @strTaxDescription6)
						BEGIN
							INSERT INTO tblPREmployeeEarningTax (intEmployeeEarningId,intTypeTaxId,intSort,intConcurrencyId)
							VALUES (@NewId,(SELECT TOP 1 intTypeTaxId FROM tblPRTypeTax WHERE strTax = @strTaxID6 AND strDescription = @strTaxDescription6),1,1)
						END
					END

				DELETE FROM #TempEmployeeEarnings WHERE intEntityNo = @intEntityNo

			END
		
		ELSE
			BEGIN
				UPDATE tblPREmployeeEarning SET
					 intTypeEarningId				= (SELECT TOP 1 intTypeEarningId FROM tblPRTypeEarning where strDescription = @strEarningDesc)
					,strCalculationType				= (SELECT TOP 1 strCalculationType FROM tblPRTypeEarning where strDescription = @strEarningDesc AND strCalculationType = @strTaxCalculation)
					,dblAmount						= @dblAmount
					,dblRateAmount					= @dblAmount  --dblRateAmount test
					,dblDefaultHours				= @dblDefaultHours
					,dblHoursToProcess				= @dblDefaultHours -- dblHoursToProcess test
					,intAccountId					= (SELECT TOP 1 intAccountId FROM tblGLAccount WHERE strAccountId = @strAccountID)
					,intTaxCalculationType			= (SELECT TOP 1 intTaxCalculationType FROM tblPRTypeEarning where strDescription = @strEarningDesc)
					,strW2Code						= '' --strW2Code for test only
					,intEmployeeTimeOffId			= (SELECT TOP 1 intTypeTimeOffId FROM tblPRTypeTimeOff WHERE strTimeOff = @strDeductTimeOff)
					,intEmployeeAccrueTimeOffId		= (SELECT TOP 1 intTypeTimeOffId FROM tblPRTypeTimeOff WHERE strTimeOff = @strAccrueTimeOff)
					,intEmployeeEarningLinkId		= (SELECT TOP 1 intTypeEarningId FROM tblPRTypeEarning where strDescription = @strEarningDesc)
					,intPayGroupId					= CASE WHEN @strPayGroup = 'Holiday' THEN 1
														 WHEN @strPayGroup = 'BI 2' THEN 2
														 WHEN @strPayGroup = 'MO 2' THEN 3
														 WHEN @strPayGroup = 'WK 2' THEN 4
														 WHEN @strPayGroup = 'TE 2' THEN 5
														 WHEN @strPayGroup = 'Semi-Monthly' THEN 6
														 WHEN @strPayGroup = 'Time Entry' THEN 7
														 WHEN @strPayGroup = 'Weekly' THEN 8
														 WHEN @strPayGroup = 'Commissions' THEN 9
														 WHEN @strPayGroup = 'Monthly' THEN 10
														 WHEN @strPayGroup = 'Bi-Weekly' THEN 11 END
					,ysnDefault						= @ysnEarningDefault
					WHERE intEntityEmployeeId = @EmployeeEntityNo
						AND intTypeEarningId = (SELECT TOP 1 intTypeEarningId FROM tblPRTypeEarning where strDescription = @strEarningDesc)

					IF @strTaxID1 IS NOT NULL
					BEGIN
						IF EXISTS (SELECT TOP 1 * FROM tblPRTypeTax WHERE strTax = @strTaxID1 AND strDescription = @strTaxDescription1)
						BEGIN
							INSERT INTO tblPREmployeeEarningTax (intEmployeeEarningId,intTypeTaxId,intSort,intConcurrencyId)
							VALUES (@NewId,(SELECT TOP 1 intTypeTaxId FROM tblPRTypeTax WHERE strTax = @strTaxID1 AND strDescription = @strTaxDescription1),1,1)
						END
					END

					IF @strTaxID2 IS NOT NULL
						BEGIN
							IF EXISTS (SELECT TOP 1 * FROM tblPRTypeTax WHERE strTax = @strTaxID2 AND strDescription = @strTaxDescription2)
							BEGIN
								INSERT INTO tblPREmployeeEarningTax (intEmployeeEarningId,intTypeTaxId,intSort,intConcurrencyId)
								VALUES (@NewId,(SELECT TOP 1 intTypeTaxId FROM tblPRTypeTax WHERE strTax = @strTaxID2 AND strDescription = @strTaxDescription2),1,1)
							END
						END

					IF @strTaxID3 IS NOT NULL
						BEGIN
							IF EXISTS (SELECT TOP 1 * FROM tblPRTypeTax WHERE strTax = @strTaxID3 AND strDescription = @strTaxDescription3)
							BEGIN
								INSERT INTO tblPREmployeeEarningTax (intEmployeeEarningId,intTypeTaxId,intSort,intConcurrencyId)
								VALUES (@NewId,(SELECT TOP 1 intTypeTaxId FROM tblPRTypeTax WHERE strTax = @strTaxID3 AND strDescription = @strTaxDescription3),1,1)
							END
						END

					IF @strTaxID4 IS NOT NULL
						BEGIN
							IF EXISTS (SELECT TOP 1 * FROM tblPRTypeTax WHERE strTax = @strTaxID1 AND strDescription = @strTaxDescription1)
							BEGIN
								INSERT INTO tblPREmployeeEarningTax (intEmployeeEarningId,intTypeTaxId,intSort,intConcurrencyId)
								VALUES (@NewId,(SELECT TOP 1 intTypeTaxId FROM tblPRTypeTax WHERE strTax = @strTaxID4 AND strDescription = @strTaxDescription4),1,1)
							END
						END

					IF @strTaxID5 IS NOT NULL
						BEGIN
							IF EXISTS (SELECT TOP 1 * FROM tblPRTypeTax WHERE strTax = @strTaxID5 AND strDescription = @strTaxDescription5)
							BEGIN
								INSERT INTO tblPREmployeeEarningTax (intEmployeeEarningId,intTypeTaxId,intSort,intConcurrencyId)
								VALUES (@NewId,(SELECT TOP 1 intTypeTaxId FROM tblPRTypeTax WHERE strTax = @strTaxID5 AND strDescription = @strTaxDescription5),1,1)
							END
						END

					IF @strTaxID6 IS NOT NULL
						BEGIN
							IF EXISTS (SELECT TOP 1 * FROM tblPRTypeTax WHERE strTax = @strTaxID6 AND strDescription = @strTaxDescription6)
							BEGIN
								INSERT INTO tblPREmployeeEarningTax (intEmployeeEarningId,intTypeTaxId,intSort,intConcurrencyId)
								VALUES (@NewId,(SELECT TOP 1 intTypeTaxId FROM tblPRTypeTax WHERE strTax = @strTaxID6 AND strDescription = @strTaxDescription6),1,1)
							END
						END

					DELETE FROM #TempEmployeeEarnings WHERE intEntityNo = @intEntityNo
			END


	END

	IF EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#TempEmployeeEarnings')) 
	DROP TABLE #TempEmployeeEarnings
END

GO