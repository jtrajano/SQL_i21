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
DECLARE @strEmployeeId AS NVARCHAR(50)
DECLARE @strEarningId AS NVARCHAR(50)
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
	   ,strMessage		= 'Cannot find the Employee Entity No: '+ CAST(ISNULL(SE.intEntityNo, '') AS NVARCHAR(100)) + '.'
	   FROM tblApiSchemaEmployeeEarnings SE
	   LEFT JOIN tblPREmployeeEarning E ON E.intEntityEmployeeId = SE.intEntityNo
	   WHERE SE.guiApiUniqueId = @guiApiUniqueId
	   AND SE.intEntityNo IS NULL

	IF EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#TempEmployeeEarnings')) 
	DROP TABLE #TempEmployeeEarnings

	SELECT * INTO #TempEmployeeEarnings FROM tblApiSchemaEmployeeEarnings where guiApiUniqueId = @guiApiUniqueId
	WHILE EXISTS(SELECT TOP 1 NULL FROM #TempEmployeeEarnings)
	BEGIN
		SELECT TOP 1 
			 @strEmployeeId				= intEntityNo
			,@intEntityNo				= (SELECT TOP 1 intEntityId FROM tblPREmployee WHERE strEmployeeId = intEntityNo) 
			,@strEarningId				= strEarningDesc
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
		  AND intTypeEarningId = (SELECT TOP 1 intTypeEarningId FROM tblPRTypeEarning WHERE strEarning = @strEarningId)

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
					(SELECT TOP 1 intEntityId FROM tblPREmployee WHERE intEntityId = intEntityNo)  
				   ,(SELECT TOP 1 intTypeEarningId FROM tblPRTypeEarning WHERE strEarning = strEarningDesc)
				   ,strCalculationType
				   ,CASE WHEN strCalculationType = 'Shift Differential' OR strCalculationType = 'Overtime' OR strCalculationType = 'Rate Factor'
							THEN dblEarningAmount --this is rate factor
						 ELSE dblAmount END
				   ,CASE WHEN strCalculationType = 'Shift Differential' OR strCalculationType = 'Overtime' OR strCalculationType = 'Rate Factor'
							THEN (
								SELECT TOP 1 dblAmount FROM tblPREmployeeEarning 
									WHERE intEntityEmployeeId = @intEntityNo 
									AND intTypeEarningId = (SELECT TOP 1 intTypeEarningId FROM tblPRTypeEarning WHERE strEarning = @strLinkedEarning)
							) * dblEarningAmount --this is rate factor
						 ELSE dblAmount END
				   ,dblDefaultHours
				   ,dblDefaultHours -- dblHoursToProcess test
				   ,(SELECT TOP 1 intAccountId FROM tblGLAccount WHERE strAccountId = @strAccountID)
				   ,@ysnUseGLSplit
				   ,0
				   ,'' --strW2Code for test only
				   ,(SELECT TOP 1 intTypeTimeOffId FROM tblPRTypeTimeOff WHERE strTimeOff = strDeductTimeOff)
				   ,(SELECT TOP 1 intTypeTimeOffId FROM tblPRTypeTimeOff WHERE strTimeOff = strAccrueTimeOff)
				   ,(SELECT TOP 1 intTypeEarningId FROM tblPRTypeEarning WHERE strEarning = strLinkedEarning)
				   ,(SELECT TOP 1 intPayGroupId FROM tblPRPayGroup WHERE strPayGroup = @strPayGroup)
					,ysnEarningDefault
					,1
					,1
				FROM #TempEmployeeEarnings
				WHERE intEntityNo = @strEmployeeId
					AND strEarningDesc = (SELECT TOP 1 strEarning FROM tblPRTypeEarning WHERE strEarning = @strEarningId)

				SET @NewId = SCOPE_IDENTITY()

				IF @strTaxID1 IS NOT NULL
					BEGIN
						IF EXISTS (SELECT TOP 1 * FROM tblPRTypeTax WHERE strTax = @strTaxID1 AND strDescription = @strTaxDescription1)
						BEGIN
							IF NOT EXISTS (SELECT TOP 1 * FROM tblPREmployeeEarningTax 
								WHERE intTypeTaxId = (SELECT TOP 1 intTypeTaxId FROM tblPRTypeTax WHERE strTax = @strTaxID1 AND strDescription = @strTaxDescription1) 
								and intEmployeeEarningId = @NewId)
							BEGIN
								INSERT INTO tblPREmployeeEarningTax (intEmployeeEarningId,intTypeTaxId,intSort,intConcurrencyId)
								VALUES ((SELECT TOP 1 intEmployeeEarningId FROM tblPREmployeeEarning WHERE intEmployeeEarningId = @NewId),(SELECT TOP 1 intTypeTaxId FROM tblPRTypeTax WHERE strTax = @strTaxID1 AND strDescription = @strTaxDescription1),1,1)
							END
						END
					END

				IF @strTaxID2 IS NOT NULL
					BEGIN
						IF EXISTS (SELECT TOP 1 * FROM tblPRTypeTax WHERE strTax = @strTaxID2 AND strDescription = @strTaxDescription2)
						BEGIN
							IF NOT EXISTS (SELECT TOP 1 * FROM tblPREmployeeEarningTax 
								WHERE intTypeTaxId = (SELECT TOP 1 intTypeTaxId FROM tblPRTypeTax WHERE strTax = @strTaxID2 AND strDescription = @strTaxDescription2) 
								and intEmployeeEarningId = @NewId)
							BEGIN
								INSERT INTO tblPREmployeeEarningTax (intEmployeeEarningId,intTypeTaxId,intSort,intConcurrencyId)
								VALUES ((SELECT TOP 1 intEmployeeEarningId FROM tblPREmployeeEarning WHERE intEmployeeEarningId = @NewId),(SELECT TOP 1 intTypeTaxId FROM tblPRTypeTax WHERE strTax = @strTaxID2 AND strDescription = @strTaxDescription2),1,1)
							END
						END
					END

				IF @strTaxID3 IS NOT NULL
					BEGIN
						IF EXISTS (SELECT TOP 1 * FROM tblPRTypeTax WHERE strTax = @strTaxID3 AND strDescription = @strTaxDescription3)
						BEGIN
							IF NOT EXISTS (SELECT TOP 1 * FROM tblPREmployeeEarningTax 
								WHERE intTypeTaxId = (SELECT TOP 1 intTypeTaxId FROM tblPRTypeTax WHERE strTax = @strTaxID3 AND strDescription = @strTaxDescription3) 
								and intEmployeeEarningId = @NewId)
							BEGIN
								INSERT INTO tblPREmployeeEarningTax (intEmployeeEarningId,intTypeTaxId,intSort,intConcurrencyId)
								VALUES ((SELECT TOP 1 intEmployeeEarningId FROM tblPREmployeeEarning WHERE intEmployeeEarningId = @NewId),(SELECT TOP 1 intTypeTaxId FROM tblPRTypeTax WHERE strTax = @strTaxID3 AND strDescription = @strTaxDescription3),1,1)
							END
						END
					END

				IF @strTaxID4 IS NOT NULL
					BEGIN
						IF EXISTS (SELECT TOP 1 * FROM tblPRTypeTax WHERE strTax = @strTaxID1 AND strDescription = @strTaxDescription1)
						BEGIN
							IF NOT EXISTS (SELECT TOP 1 * FROM tblPREmployeeEarningTax 
								WHERE intTypeTaxId = (SELECT TOP 1 intTypeTaxId FROM tblPRTypeTax WHERE strTax = @strTaxID4 AND strDescription = @strTaxDescription4) 
								and intEmployeeEarningId = @NewId)
							BEGIN
								INSERT INTO tblPREmployeeEarningTax (intEmployeeEarningId,intTypeTaxId,intSort,intConcurrencyId)
							VALUES ((SELECT TOP 1 intEmployeeEarningId FROM tblPREmployeeEarning WHERE intEmployeeEarningId = @NewId),(SELECT TOP 1 intTypeTaxId FROM tblPRTypeTax WHERE strTax = @strTaxID4 AND strDescription = @strTaxDescription4),1,1)
							END
						END
					END

				IF @strTaxID5 IS NOT NULL
					BEGIN
						IF EXISTS (SELECT TOP 1 * FROM tblPRTypeTax WHERE strTax = @strTaxID5 AND strDescription = @strTaxDescription5)
						BEGIN
							IF NOT EXISTS (SELECT TOP 1 * FROM tblPREmployeeEarningTax 
								WHERE intTypeTaxId = (SELECT TOP 1 intTypeTaxId FROM tblPRTypeTax WHERE strTax = @strTaxID5 AND strDescription = @strTaxDescription5) 
								and intEmployeeEarningId = @NewId)
							BEGIN
								INSERT INTO tblPREmployeeEarningTax (intEmployeeEarningId,intTypeTaxId,intSort,intConcurrencyId)
								VALUES ((SELECT TOP 1 intEmployeeEarningId FROM tblPREmployeeEarning WHERE intEmployeeEarningId = @NewId),(SELECT TOP 1 intTypeTaxId FROM tblPRTypeTax WHERE strTax = @strTaxID5 AND strDescription = @strTaxDescription5),1,1)
							END
						END
					END

				IF @strTaxID6 IS NOT NULL
					BEGIN
						IF EXISTS (SELECT TOP 1 * FROM tblPRTypeTax WHERE strTax = @strTaxID6 AND strDescription = @strTaxDescription6)
						BEGIN
							IF NOT EXISTS (SELECT TOP 1 * FROM tblPREmployeeEarningTax 
								WHERE intTypeTaxId = (SELECT TOP 1 intTypeTaxId FROM tblPRTypeTax WHERE strTax = @strTaxID6 AND strDescription = @strTaxDescription6) 
								and intEmployeeEarningId = @NewId)
							BEGIN
								INSERT INTO tblPREmployeeEarningTax (intEmployeeEarningId,intTypeTaxId,intSort,intConcurrencyId)
								VALUES ((SELECT TOP 1 intEmployeeEarningId FROM tblPREmployeeEarning WHERE intEmployeeEarningId = @NewId),(SELECT TOP 1 intTypeTaxId FROM tblPRTypeTax WHERE strTax = @strTaxID6 AND strDescription = @strTaxDescription6),1,1)
							END
						END
					END

				DELETE FROM #TempEmployeeEarnings WHERE intEntityNo = @strEmployeeId AND strEarningDesc = @strEarningId

			END
		
		ELSE
			BEGIN
				UPDATE tblPREmployeeEarning SET
					 intTypeEarningId				= (SELECT TOP 1 intTypeEarningId FROM tblPRTypeEarning where strEarning = @strEarningId)
					,strCalculationType				= strCalculationType
					,dblAmount						= CASE WHEN strCalculationType = 'Shift Differential' OR strCalculationType = 'Overtime' OR strCalculationType = 'Rate Factor'
														THEN @dblEarningAmount
													  ELSE @dblAmount END
					,dblRateAmount					= CASE WHEN strCalculationType = 'Shift Differential' OR strCalculationType = 'Overtime' OR strCalculationType = 'Rate Factor'
														THEN 
														(
															SELECT TOP 1 dblAmount FROM tblPREmployeeEarning 
																WHERE intEntityEmployeeId = @intEntityNo 
																AND intTypeEarningId = (SELECT TOP 1 intTypeEarningId FROM tblPRTypeEarning WHERE strEarning = @strLinkedEarning)
														) * @dblEarningAmount 
													  ELSE dblAmount END
					,dblDefaultHours				= @dblDefaultHours
					,dblHoursToProcess				= @dblDefaultHours -- dblHoursToProcess test
					,intAccountId					= (SELECT TOP 1 intAccountId FROM tblGLAccount WHERE strAccountId = @strAccountID)
					,intTaxCalculationType			= (SELECT TOP 1 intTaxCalculationType FROM tblPRTypeEarning where strEarning = @strEarningId)
					,strW2Code						= '' --strW2Code for test only
					,intEmployeeTimeOffId			= (SELECT TOP 1 intTypeTimeOffId FROM tblPRTypeTimeOff WHERE strTimeOff = @strDeductTimeOff)
					,intEmployeeAccrueTimeOffId		= (SELECT TOP 1 intTypeTimeOffId FROM tblPRTypeTimeOff WHERE strTimeOff = @strAccrueTimeOff)
					,intEmployeeEarningLinkId		= (SELECT TOP 1 intTypeEarningId FROM tblPRTypeEarning WHERE strEarning = @strLinkedEarning)
					,intPayGroupId					= (SELECT TOP 1 intPayGroupId FROM tblPRPayGroup WHERE strPayGroup = @strPayGroup)
					,ysnDefault						= @ysnEarningDefault
					WHERE intEntityEmployeeId = @EmployeeEntityNo
						AND intTypeEarningId = (SELECT TOP 1 intTypeEarningId FROM tblPRTypeEarning where strEarning = @strEarningId)

					IF @strTaxID1 IS NOT NULL
					BEGIN
						IF EXISTS (SELECT TOP 1 * FROM tblPRTypeTax WHERE strTax = @strTaxID1 AND strDescription = @strTaxDescription1)
						BEGIN
							IF NOT EXISTS (
								SELECT TOP 1 * FROM tblPREmployeeEarningTax 
									WHERE intTypeTaxId = (SELECT TOP 1 intTypeTaxId FROM tblPRTypeTax WHERE  strTax = @strTaxID1 AND strDescription = @strTaxDescription1)
									AND intEmployeeEarningId = (SELECT TOP 1 intEmployeeEarningId FROM tblPREmployeeEarning where intEntityEmployeeId = @intEntityNo)
							)
							BEGIN
								INSERT INTO tblPREmployeeEarningTax (intEmployeeEarningId,intTypeTaxId,intSort,intConcurrencyId)
								VALUES (
								 (SELECT TOP 1 intEmployeeEarningId FROM tblPREmployeeEarning WHERE intEntityEmployeeId = @EmployeeEntityNo AND intTypeEarningId = (SELECT TOP 1 intTypeEarningId FROM tblPRTypeEarning where strEarning = @strEarningId))
								,(SELECT TOP 1 intTypeTaxId FROM tblPRTypeTax WHERE strTax = @strTaxID1 AND strDescription = @strTaxDescription1),1,1)
							END
							
						END
					END

					IF @strTaxID2 IS NOT NULL
						BEGIN
							IF EXISTS (SELECT TOP 1 * FROM tblPRTypeTax WHERE strTax = @strTaxID2 AND strDescription = @strTaxDescription2)
							BEGIN
								IF NOT EXISTS (
								SELECT TOP 1 * FROM tblPREmployeeEarningTax 
									WHERE intTypeTaxId = (SELECT TOP 1 intTypeTaxId FROM tblPRTypeTax WHERE  strTax = @strTaxID2 AND strDescription = @strTaxDescription2)
									AND intEmployeeEarningId = (SELECT TOP 1 intEmployeeEarningId FROM tblPREmployeeEarning where intEntityEmployeeId = @intEntityNo)
								)
								BEGIN
									INSERT INTO tblPREmployeeEarningTax (intEmployeeEarningId,intTypeTaxId,intSort,intConcurrencyId)
									VALUES (
									 (SELECT TOP 1 intEmployeeEarningId FROM tblPREmployeeEarning WHERE intEntityEmployeeId = @EmployeeEntityNo AND intTypeEarningId = (SELECT TOP 1 intTypeEarningId FROM tblPRTypeEarning where strEarning = @strEarningId))
									,(SELECT TOP 1 intTypeTaxId FROM tblPRTypeTax WHERE strTax = @strTaxID2 AND strDescription = @strTaxDescription2),1,1)
								END
								
							END
						END

					IF @strTaxID3 IS NOT NULL
						BEGIN
							IF EXISTS (SELECT TOP 1 * FROM tblPRTypeTax WHERE strTax = @strTaxID3 AND strDescription = @strTaxDescription3)
							BEGIN
								IF NOT EXISTS (
								SELECT TOP 1 * FROM tblPREmployeeEarningTax 
									WHERE intTypeTaxId = (SELECT TOP 1 intTypeTaxId FROM tblPRTypeTax WHERE  strTax = @strTaxID3 AND strDescription = @strTaxDescription3)
									AND intEmployeeEarningId = (SELECT TOP 1 intEmployeeEarningId FROM tblPREmployeeEarning where intEntityEmployeeId = @intEntityNo)
								)
								BEGIN
									INSERT INTO tblPREmployeeEarningTax (intEmployeeEarningId,intTypeTaxId,intSort,intConcurrencyId)
									VALUES (
									 (SELECT TOP 1 intEmployeeEarningId FROM tblPREmployeeEarning WHERE intEntityEmployeeId = @EmployeeEntityNo AND intTypeEarningId = (SELECT TOP 1 intTypeEarningId FROM tblPRTypeEarning where strEarning = @strEarningId))
									,(SELECT TOP 1 intTypeTaxId FROM tblPRTypeTax WHERE strTax = @strTaxID3 AND strDescription = @strTaxDescription3),1,1)
								END
								
							END
						END

					IF @strTaxID4 IS NOT NULL
						BEGIN
							IF EXISTS (SELECT TOP 1 * FROM tblPRTypeTax WHERE strTax = @strTaxID1 AND strDescription = @strTaxDescription1)
							BEGIN
								IF NOT EXISTS (
								SELECT TOP 1 * FROM tblPREmployeeEarningTax 
									WHERE intTypeTaxId = (SELECT TOP 1 intTypeTaxId FROM tblPRTypeTax WHERE  strTax = @strTaxID4 AND strDescription = @strTaxDescription4)
									AND intEmployeeEarningId = (SELECT TOP 1 intEmployeeEarningId FROM tblPREmployeeEarning where intEntityEmployeeId = @intEntityNo)
								)
								BEGIN
									INSERT INTO tblPREmployeeEarningTax (intEmployeeEarningId,intTypeTaxId,intSort,intConcurrencyId)
									VALUES (
									 (SELECT TOP 1 intEmployeeEarningId FROM tblPREmployeeEarning WHERE intEntityEmployeeId = @EmployeeEntityNo AND intTypeEarningId = (SELECT TOP 1 intTypeEarningId FROM tblPRTypeEarning where strEarning = @strEarningId))
									,(SELECT TOP 1 intTypeTaxId FROM tblPRTypeTax WHERE strTax = @strTaxID4 AND strDescription = @strTaxDescription4),1,1)
								END
								
							END
						END

					IF @strTaxID5 IS NOT NULL
						BEGIN
							IF EXISTS (SELECT TOP 1 * FROM tblPRTypeTax WHERE strTax = @strTaxID5 AND strDescription = @strTaxDescription5)
							BEGIN
								IF NOT EXISTS (
									SELECT TOP 1 * FROM tblPREmployeeEarningTax 
										WHERE intTypeTaxId = (SELECT TOP 1 intTypeTaxId FROM tblPRTypeTax WHERE  strTax = @strTaxID5 AND strDescription = @strTaxDescription5)
										AND intEmployeeEarningId = (SELECT TOP 1 intEmployeeEarningId FROM tblPREmployeeEarning where intEntityEmployeeId = @intEntityNo)
								)
								BEGIN
									INSERT INTO tblPREmployeeEarningTax (intEmployeeEarningId,intTypeTaxId,intSort,intConcurrencyId)
									VALUES (
									 (SELECT TOP 1 intEmployeeEarningId FROM tblPREmployeeEarning WHERE intEntityEmployeeId = @EmployeeEntityNo AND intTypeEarningId = (SELECT TOP 1 intTypeEarningId FROM tblPRTypeEarning where strEarning = @strEarningId))
									,(SELECT TOP 1 intTypeTaxId FROM tblPRTypeTax WHERE strTax = @strTaxID5 AND strDescription = @strTaxDescription5),1,1)
								END
								
							END
						END

					IF @strTaxID6 IS NOT NULL
						BEGIN
							IF EXISTS (SELECT TOP 1 * FROM tblPRTypeTax WHERE strTax = @strTaxID6 AND strDescription = @strTaxDescription6)
							BEGIN
							IF NOT EXISTS (
								SELECT TOP 1 * FROM tblPREmployeeEarningTax 
									WHERE intTypeTaxId = (SELECT TOP 1 intTypeTaxId FROM tblPRTypeTax WHERE  strTax = @strTaxID6 AND strDescription = @strTaxDescription6)
									AND intEmployeeEarningId = (SELECT TOP 1 intEmployeeEarningId FROM tblPREmployeeEarning where intEntityEmployeeId = @intEntityNo)
								)
								BEGIN
									INSERT INTO tblPREmployeeEarningTax (intEmployeeEarningId,intTypeTaxId,intSort,intConcurrencyId)
									VALUES (
									 (SELECT TOP 1 intEmployeeEarningId FROM tblPREmployeeEarning WHERE intEntityEmployeeId = @EmployeeEntityNo AND intTypeEarningId = (SELECT TOP 1 intTypeEarningId FROM tblPRTypeEarning where strEarning = @strEarningId))
									,(SELECT TOP 1 intTypeTaxId FROM tblPRTypeTax WHERE strTax = @strTaxID6 AND strDescription = @strTaxDescription6),1,1)
								END
								
							END
						END

					DELETE FROM #TempEmployeeEarnings WHERE intEntityNo = @strEmployeeId AND strEarningDesc = @strEarningId
			END

		INSERT INTO tblApiImportLogDetail (guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage)
		SELECT TOP 1
			  NEWID()
			, guiApiImportLogId = @guiLogId
			, strField = 'Employee Earnings'
			, strValue = SE.strEarningDesc
			, strLogLevel = 'Info'
			, strStatus = 'Success'
			, intRowNo = SE.intRowNumber
			, strMessage = 'The employee earnings has been successfully imported.'
		FROM tblApiSchemaEmployeeEarnings SE
		   LEFT JOIN tblPREmployeeEarning E ON E.intEntityEmployeeId = SE.intEntityNo
		   WHERE SE.guiApiUniqueId = @guiApiUniqueId
		AND SE.strEarningDesc = @strEarningId


	END

	IF EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#TempEmployeeEarnings')) 
	DROP TABLE #TempEmployeeEarnings
END
GO