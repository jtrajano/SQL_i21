CREATE PROCEDURE [dbo].[uspGRCalculateStorageCharge]  
    @intCustomerStorageId INT
	,@strProcessType NVARCHAR(30)
	,@StorageChargeDate DATETIME = NULL
	,@UserKey INT
	,@dblStorageDuePerUnit DECIMAL(24, 10) OUTPUT
	,@dblStorageDueAmount DECIMAL(24, 10) OUTPUT
	,@dblStorageDueTotalPerUnit DECIMAL(24, 10) OUTPUT
	,@dblStorageDueTotalAmount DECIMAL(24, 10) OUTPUT
	,@dblStorageBilledPerUnit DECIMAL(24, 10) OUTPUT
	,@dblStorageBilledAmount DECIMAL(24, 10) OUTPUT
AS
BEGIN TRY
	SET NOCOUNT ON

	IF @StorageChargeDate IS NULL
		SET @StorageChargeDate = GETDATE()

	DECLARE @ErrMsg NVARCHAR(MAX)
	DECLARE @UserName NVARCHAR(100)
	DECLARE @dblOldStoragePaid DECIMAL(24, 10)
	DECLARE @dblOpenBalance DECIMAL(24, 10)
	DECLARE @intStorageScheduleId INT
	DECLARE @intAllowanceDays INT
	DECLARE @strStorageRate NVARCHAR(50)
	DECLARE @dtmHEffectiveDate DATETIME
	DECLARE @dtmTerminationDate DATETIME
	DECLARE @dtmDeliveryDate DATETIME
	DECLARE @dtmLastStorageAccrueDate DATETIME
	DECLARE @intSchedulePeriodId INT
	DECLARE @strPeriodType NVARCHAR(50)
	DECLARE @dtmDEffectiveDate DATETIME
	DECLARE @dtmEndingDate DATETIME
	DECLARE @intNumberOfDays INT
	DECLARE @dblStorageRate DECIMAL(24, 10)
	DECLARE @dblNewStoragePaid DECIMAL(24, 10)
	DECLARE @TotalDaysApplicableForStorageCharge INT
	DECLARE @StorageChargeCalculationRequired BIT = 1
	
	DECLARE @tblGRStorageSchedulePeriod AS TABLE 
	(
		 [intSchedulePeriodId] INT IDENTITY(1, 1)
		,[strPeriodType] NVARCHAR(30) COLLATE Latin1_General_CI_AS NOT NULL
		,[dtmEffectiveDate] DATETIME NULL
		,[dtmEndingDate] DATETIME NULL
		,[intNumberOfDays] INT NULL
		,[dblStorageRate] NUMERIC(18, 6)
	)

	SELECT @dblOldStoragePaid = CS.dblStoragePaid
		,@dblOpenBalance = CS.dblOpenBalance
		,@intStorageScheduleId = CS.intStorageScheduleId
		,@intAllowanceDays = SR.intAllowanceDays
		,@strStorageRate = SR.strStorageRate
		,@dtmHEffectiveDate = SR.dtmEffectiveDate
		,@dtmTerminationDate = SR.dtmTerminationDate
		,@dtmDeliveryDate = CS.dtmDeliveryDate
		,@dtmLastStorageAccrueDate = CS.dtmLastStorageAccrueDate
	FROM tblGRCustomerStorage CS
	JOIN tblGRStorageScheduleRule SR ON SR.intStorageScheduleRuleId = CS.intStorageScheduleId
	WHERE CS.intCustomerStorageId = @intCustomerStorageId

	INSERT INTO @tblGRStorageSchedulePeriod 
	(
		[strPeriodType]
		,[dtmEffectiveDate]
		,[dtmEndingDate]
		,[intNumberOfDays]
		,[dblStorageRate]
	)
	SELECT [strPeriodType]
		,[dtmEffectiveDate]
		,[dtmEndingDate]
		,[intNumberOfDays]
		,[dblStorageRate]
	FROM tblGRStorageSchedulePeriod
	WHERE intStorageScheduleRule = @intStorageScheduleId
	ORDER BY intSort

	--Suppose Termination Date is not Blank and Storage Charge Date is later on Termination Date then Charge Upto Termination Date.    
	IF @StorageChargeDate > @dtmTerminationDate AND @dtmTerminationDate IS NOT NULL
		SET @StorageChargeDate = @dtmTerminationDate

	--Suppose Effective Date is not blank and Delivery Date is Prior to Effective Date then Charge From Effective Date.     
	IF @dtmDeliveryDate < @dtmHEffectiveDate AND @dtmHEffectiveDate IS NOT NULL
		SET @dtmDeliveryDate = @dtmHEffectiveDate

	SELECT @UserName = strUserName
	FROM tblSMUserSecurity
	WHERE [intEntityUserSecurityId] = @UserKey
	
	IF EXISTS
	(SELECT 1 FROM tblGRCustomerStorage WHERE intCustomerStorageId = @intCustomerStorageId AND dtmLastStorageAccrueDate IS NOT NULL 
	  AND (dtmLastStorageAccrueDate >= @StorageChargeDate))--1.Calculation Date less than or equal to Last Accrue Date.
		OR (@StorageChargeDate < @dtmDeliveryDate)--2.Calculation Date less than Delivery Date.
		OR (
			(@intAllowanceDays > 0) AND (@dtmLastStorageAccrueDate IS NULL) 
			 AND ((DATEDIFF(DAY, @dtmDeliveryDate, @StorageChargeDate) + 1) <= @intAllowanceDays)
		   )--3.Charge is not at all Accrued( Means at least once) and the No of Days between Dev.date to Calc. date less than or equal to Allowance Days.
	BEGIN
		SET @dblStorageDuePerUnit = 0
		SET @dblStorageDueAmount = 0
		SET @StorageChargeCalculationRequired = 0
	END

	IF @strProcessType = 'Unpaid'
	BEGIN
		SET @StorageChargeCalculationRequired = 0
	END

	SELECT @TotalDaysApplicableForStorageCharge = DATEDIFF(DAY, @dtmDeliveryDate, @StorageChargeDate) + 1

	--Total Storage Due from Deliverydate to StorageChargeDate    
	IF @strStorageRate = 'Daily' AND @StorageChargeCalculationRequired = 1
	BEGIN
		SELECT @intSchedulePeriodId = MIN(intSchedulePeriodId)
		FROM @tblGRStorageSchedulePeriod

		SET @strPeriodType = NULL
		SET @dtmDEffectiveDate = NULL
		SET @dtmEndingDate = NULL
		SET @intNumberOfDays = NULL
		SET @dblStorageRate = NULL

		WHILE @intSchedulePeriodId > 0 AND @TotalDaysApplicableForStorageCharge > 0
		BEGIN
			SELECT @strPeriodType = strPeriodType
				,@dtmDEffectiveDate = dtmEffectiveDate
				,@dtmEndingDate = dtmEndingDate
				,@intNumberOfDays = ISNULL(intNumberOfDays, 0)
				,@dblStorageRate = dblStorageRate
			FROM @tblGRStorageSchedulePeriod
			WHERE intSchedulePeriodId = @intSchedulePeriodId

			--Number Of Days  
			IF @strPeriodType = 'Number of Days'
			BEGIN
				--CASE 1. Start Date = Blank ,Ending Date = Blank 
				IF @dtmDEffectiveDate IS NULL AND @dtmEndingDate IS NULL
				BEGIN
					IF @intNumberOfDays <= @TotalDaysApplicableForStorageCharge
					BEGIN
						SELECT @dblStorageDuePerUnit = ISNULL(@dblStorageDuePerUnit, 0) + @dblStorageRate * @intNumberOfDays
						SET @TotalDaysApplicableForStorageCharge = @TotalDaysApplicableForStorageCharge - @intNumberOfDays
						SET @dtmDeliveryDate = @dtmDeliveryDate + @intNumberOfDays
					END
					ELSE
					BEGIN
						SELECT @dblStorageDuePerUnit = ISNULL(@dblStorageDuePerUnit, 0) + @dblStorageRate * @TotalDaysApplicableForStorageCharge
						SET @TotalDaysApplicableForStorageCharge = @TotalDaysApplicableForStorageCharge - @TotalDaysApplicableForStorageCharge
						SET @dtmDeliveryDate = @dtmDeliveryDate + @TotalDaysApplicableForStorageCharge
					END
				END
				
				--CASE 2. Start Date = Blank ,Ending Date < > Blank
				ELSE IF @dtmDEffectiveDate IS NULL AND @dtmEndingDate IS NOT NULL
				BEGIN
					IF @dtmEndingDate > @StorageChargeDate
						SET @dtmEndingDate = @StorageChargeDate

					IF @intNumberOfDays > @TotalDaysApplicableForStorageCharge
						SET @intNumberOfDays = @TotalDaysApplicableForStorageCharge

					IF (DATEDIFF(DAY, @dtmDeliveryDate, @dtmEndingDate) + 1) > 0
					BEGIN
						IF (DATEDIFF(DAY, @dtmDeliveryDate, @dtmEndingDate) + 1) <= @intNumberOfDays
						BEGIN
							SELECT @dblStorageDuePerUnit = ISNULL(@dblStorageDuePerUnit, 0) + @dblStorageRate * (DATEDIFF(DAY, @dtmDeliveryDate, @dtmEndingDate) + 1)
							SET @TotalDaysApplicableForStorageCharge = @TotalDaysApplicableForStorageCharge - (DATEDIFF(DAY, @dtmDeliveryDate, @dtmEndingDate) + 1)
							SET @dtmDeliveryDate = @dtmDeliveryDate + (DATEDIFF(DAY, @dtmDeliveryDate, @dtmEndingDate) + 1)
						END
						ELSE
						BEGIN
							SELECT @dblStorageDuePerUnit = ISNULL(@dblStorageDuePerUnit, 0) + @dblStorageRate * @intNumberOfDays
							SET @TotalDaysApplicableForStorageCharge = @TotalDaysApplicableForStorageCharge - @intNumberOfDays
							SET @dtmDeliveryDate = @dtmDeliveryDate + @intNumberOfDays
						END
					END
				END
				
				--CASE 3. Start Date < > Blank, Ending Date= Blank
				ELSE IF @dtmDEffectiveDate IS NOT NULL AND @dtmEndingDate IS NULL
				BEGIN
					IF @dtmDeliveryDate > @dtmDEffectiveDate
						SET @dtmDEffectiveDate = @dtmDeliveryDate
					ELSE
					BEGIN
						SET @TotalDaysApplicableForStorageCharge = 
								CASE 
									WHEN (@TotalDaysApplicableForStorageCharge - DATEDIFF(DAY, @dtmDeliveryDate, @dtmDEffectiveDate)) < 0 
										  THEN 0
									ELSE 
										 (@TotalDaysApplicableForStorageCharge - DATEDIFF(DAY, @dtmDeliveryDate, @dtmDEffectiveDate))
								END
						SET @dtmDeliveryDate = @dtmDeliveryDate + DATEDIFF(DAY, @dtmDeliveryDate, @dtmDEffectiveDate)
					END

					IF @intNumberOfDays > @TotalDaysApplicableForStorageCharge
						SET @intNumberOfDays = @TotalDaysApplicableForStorageCharge

					IF (DATEDIFF(DAY, @dtmDEffectiveDate, @StorageChargeDate) + 1) > 0 AND @TotalDaysApplicableForStorageCharge > 0
					BEGIN
						IF (DATEDIFF(DAY, @dtmDEffectiveDate, @StorageChargeDate) + 1) <= @intNumberOfDays
						BEGIN
							SELECT @dblStorageDuePerUnit = ISNULL(@dblStorageDuePerUnit, 0) + @dblStorageRate * (DATEDIFF(DAY, @dtmDEffectiveDate, @StorageChargeDate) + 1)
							SET @TotalDaysApplicableForStorageCharge = @TotalDaysApplicableForStorageCharge - (DATEDIFF(DAY, @dtmDEffectiveDate, @StorageChargeDate) + 1)
							SET @dtmDeliveryDate = @dtmDeliveryDate + (DATEDIFF(DAY, @dtmDEffectiveDate, @StorageChargeDate) + 1)
						END
						ELSE
						BEGIN
							SELECT @dblStorageDuePerUnit = ISNULL(@dblStorageDuePerUnit, 0) + @dblStorageRate * @intNumberOfDays
							SET @TotalDaysApplicableForStorageCharge = @TotalDaysApplicableForStorageCharge - @intNumberOfDays
							SET @dtmDeliveryDate = @dtmDeliveryDate + @intNumberOfDays
						END
					END
				END
			END

			--Date Range			
			IF @strPeriodType = 'Date Range'
			BEGIN
				--CASE 1.Start Date = Blank ,Ending Date < > Blank, No Of Days=0		
				IF @dtmDEffectiveDate IS NULL AND @dtmEndingDate IS NOT NULL AND @intNumberOfDays = 0
				BEGIN
					IF @dtmEndingDate > @StorageChargeDate
						SET @dtmEndingDate = @StorageChargeDate

					IF (DATEDIFF(DAY, @dtmDeliveryDate, @dtmEndingDate) + 1) > 0
					BEGIN
						IF (DATEDIFF(DAY, @dtmDeliveryDate, @dtmEndingDate) + 1) <= @TotalDaysApplicableForStorageCharge
						BEGIN
							SELECT @dblStorageDuePerUnit = ISNULL(@dblStorageDuePerUnit, 0) + @dblStorageRate * (DATEDIFF(DAY, @dtmDeliveryDate, @dtmEndingDate) + 1)
							SET @TotalDaysApplicableForStorageCharge = @TotalDaysApplicableForStorageCharge - (DATEDIFF(DAY, @dtmDeliveryDate, @dtmEndingDate) + 1)
							SET @dtmDeliveryDate = @dtmDeliveryDate + (DATEDIFF(DAY, @dtmDeliveryDate, @dtmEndingDate) + 1)
						END
						ELSE
						BEGIN
							SELECT @dblStorageDuePerUnit = ISNULL(@dblStorageDuePerUnit, 0) + @dblStorageRate * @TotalDaysApplicableForStorageCharge
							SET @TotalDaysApplicableForStorageCharge = @TotalDaysApplicableForStorageCharge - @TotalDaysApplicableForStorageCharge
							SET @dtmDeliveryDate = @dtmDeliveryDate + @TotalDaysApplicableForStorageCharge
						END
					END
				END
				
				--CASE 2.Start Date < > Blank, Ending Date = Blank , No Of Days > 0	
				ELSE IF @dtmDEffectiveDate IS NOT NULL AND @dtmEndingDate IS NULL AND @intNumberOfDays > 0
				BEGIN
				
					IF @dtmDeliveryDate > @dtmDEffectiveDate
						SET @dtmDEffectiveDate = @dtmDeliveryDate
					ELSE
					BEGIN
						SET @TotalDaysApplicableForStorageCharge = 
								CASE 
									WHEN (@TotalDaysApplicableForStorageCharge - DATEDIFF(DAY, @dtmDeliveryDate, @dtmDEffectiveDate)) < 0
										THEN 0
									ELSE 
									    (@TotalDaysApplicableForStorageCharge - DATEDIFF(DAY, @dtmDeliveryDate, @dtmDEffectiveDate))
								END
								
						SET @dtmDeliveryDate = @dtmDeliveryDate + DATEDIFF(DAY, @dtmDeliveryDate, @dtmDEffectiveDate)
					END

					IF @intNumberOfDays > @TotalDaysApplicableForStorageCharge
						SET @intNumberOfDays = @TotalDaysApplicableForStorageCharge

					IF (DATEDIFF(DAY, @dtmDEffectiveDate, @StorageChargeDate) + 1) > 0 AND @TotalDaysApplicableForStorageCharge > 0
					BEGIN
						IF (DATEDIFF(DAY, @dtmDEffectiveDate, @StorageChargeDate) + 1) <= @intNumberOfDays
						BEGIN
							SELECT @dblStorageDuePerUnit = ISNULL(@dblStorageDuePerUnit, 0) + @dblStorageRate * (DATEDIFF(DAY, @dtmDEffectiveDate, @StorageChargeDate) + 1)
							SET @TotalDaysApplicableForStorageCharge = @TotalDaysApplicableForStorageCharge - (DATEDIFF(DAY, @dtmDEffectiveDate, @StorageChargeDate) + 1)
							SET @dtmDeliveryDate = @dtmDeliveryDate + (DATEDIFF(DAY, @dtmDEffectiveDate, @StorageChargeDate) + 1)
						END
						ELSE
						BEGIN
							SELECT @dblStorageDuePerUnit = ISNULL(@dblStorageDuePerUnit, 0) + @dblStorageRate * @intNumberOfDays
							SET @TotalDaysApplicableForStorageCharge = @TotalDaysApplicableForStorageCharge - @intNumberOfDays
							SET @dtmDeliveryDate = @dtmDeliveryDate + @intNumberOfDays
						END
					END
				END
				
				--CASE 3.Start Date < > Blank, Ending Date < > Blank, No Of Days = 0				
				ELSE IF @dtmDEffectiveDate IS NOT NULL AND @dtmEndingDate IS NOT NULL AND @intNumberOfDays = 0
				BEGIN
					IF @dtmDeliveryDate > @dtmDEffectiveDate
						SET @dtmDEffectiveDate = @dtmDeliveryDate
					ELSE
					BEGIN
						SET @TotalDaysApplicableForStorageCharge = 
								CASE 
									WHEN (@TotalDaysApplicableForStorageCharge - DATEDIFF(DAY, @dtmDeliveryDate, @dtmDEffectiveDate)) < 0
										 THEN 0
									ELSE 
									    (@TotalDaysApplicableForStorageCharge - DATEDIFF(DAY, @dtmDeliveryDate, @dtmDEffectiveDate))
								END
						SET @dtmDeliveryDate = @dtmDeliveryDate + DATEDIFF(DAY, @dtmDeliveryDate, @dtmDEffectiveDate)						
					END

					IF @dtmEndingDate > @StorageChargeDate
						SET @dtmEndingDate = @StorageChargeDate

					IF (DATEDIFF(DAY, @dtmDEffectiveDate, @StorageChargeDate) + 1) > 0 AND ((DATEDIFF(DAY, @dtmDeliveryDate, @dtmEndingDate) + 1) > 0) AND @TotalDaysApplicableForStorageCharge > 0
					BEGIN
						IF (DATEDIFF(DAY, @dtmDEffectiveDate, @dtmEndingDate) + 1) <= @TotalDaysApplicableForStorageCharge
						BEGIN
							SELECT @dblStorageDuePerUnit = ISNULL(@dblStorageDuePerUnit, 0) + @dblStorageRate * (DATEDIFF(DAY, @dtmDEffectiveDate, @dtmEndingDate) + 1)
							SET @TotalDaysApplicableForStorageCharge = @TotalDaysApplicableForStorageCharge - (DATEDIFF(DAY, @dtmDEffectiveDate, @dtmEndingDate) + 1)
							SET @dtmDeliveryDate = @dtmDeliveryDate + (DATEDIFF(DAY, @dtmDEffectiveDate, @dtmEndingDate) + 1)
						END
						ELSE
						BEGIN
							SELECT @dblStorageDuePerUnit = ISNULL(@dblStorageDuePerUnit, 0) + @dblStorageRate * @TotalDaysApplicableForStorageCharge
							SET @TotalDaysApplicableForStorageCharge = @TotalDaysApplicableForStorageCharge - @TotalDaysApplicableForStorageCharge
							SET @dtmDeliveryDate = @dtmDeliveryDate + @TotalDaysApplicableForStorageCharge
						END
					END
				END
						
				--CASE 4.Start Date < > Blank, Ending Date < > Blank, No Of Days > 0	
				ELSE IF @dtmDEffectiveDate IS NOT NULL AND @dtmEndingDate IS NOT NULL AND @intNumberOfDays > 0
				BEGIN
					IF @dtmDeliveryDate > @dtmDEffectiveDate
						SET @dtmDEffectiveDate = @dtmDeliveryDate
					ELSE
					BEGIN
						SET @TotalDaysApplicableForStorageCharge = 
								CASE 
									WHEN (@TotalDaysApplicableForStorageCharge - DATEDIFF(DAY, @dtmDeliveryDate, @dtmDEffectiveDate)) < 0
										THEN 0
									ELSE 
										(@TotalDaysApplicableForStorageCharge - DATEDIFF(DAY, @dtmDeliveryDate, @dtmDEffectiveDate))
								END								
						SET @dtmDeliveryDate = @dtmDeliveryDate + DATEDIFF(DAY, @dtmDeliveryDate, @dtmDEffectiveDate)
					END

					IF @dtmEndingDate > @StorageChargeDate
						SET @dtmEndingDate = @StorageChargeDate

					IF @intNumberOfDays > @TotalDaysApplicableForStorageCharge
						SET @intNumberOfDays = @TotalDaysApplicableForStorageCharge

					IF (DATEDIFF(DAY, @dtmDEffectiveDate, @StorageChargeDate) + 1) > 0 AND ((DATEDIFF(DAY, @dtmDeliveryDate, @dtmEndingDate) + 1) > 0) AND @TotalDaysApplicableForStorageCharge > 0
					BEGIN
						IF (DATEDIFF(DAY, @dtmDEffectiveDate, @StorageChargeDate) + 1) <= @intNumberOfDays
						BEGIN
							SELECT @dblStorageDuePerUnit = ISNULL(@dblStorageDuePerUnit, 0) + @dblStorageRate * (DATEDIFF(DAY, @dtmDEffectiveDate, @StorageChargeDate) + 1)
							SET @TotalDaysApplicableForStorageCharge = @TotalDaysApplicableForStorageCharge - (DATEDIFF(DAY, @dtmDEffectiveDate, @StorageChargeDate) + 1)
							SET @dtmDeliveryDate = @dtmDeliveryDate + (DATEDIFF(DAY, @dtmDEffectiveDate, @StorageChargeDate) + 1)
						END
						ELSE
						BEGIN
							SELECT @dblStorageDuePerUnit = ISNULL(@dblStorageDuePerUnit, 0) + @dblStorageRate * @intNumberOfDays
							SET @TotalDaysApplicableForStorageCharge = @TotalDaysApplicableForStorageCharge - @intNumberOfDays
							SET @dtmDeliveryDate = @dtmDeliveryDate + @intNumberOfDays
						END
					END
				END
			END

			--There After			      
			IF @strPeriodType = 'Thereafter'
			BEGIN
				IF @dtmDEffectiveDate IS NULL
				BEGIN
					SET @dtmDeliveryDate = @dtmDeliveryDate + @TotalDaysApplicableForStorageCharge
					SET @dblStorageDuePerUnit = ISNULL(@dblStorageDuePerUnit, 0) + @dblStorageRate * @TotalDaysApplicableForStorageCharge
					SET @TotalDaysApplicableForStorageCharge = @TotalDaysApplicableForStorageCharge - @TotalDaysApplicableForStorageCharge
				END
				ELSE
				BEGIN
				
					IF @dtmDeliveryDate > @dtmDEffectiveDate
					BEGIN
						SET @dtmDEffectiveDate = @dtmDeliveryDate
						SET @TotalDaysApplicableForStorageCharge = @TotalDaysApplicableForStorageCharge - DATEDIFF(DAY, @dtmDEffectiveDate, @dtmDeliveryDate)

						IF @TotalDaysApplicableForStorageCharge > 0
						BEGIN
							SET @dtmDeliveryDate = @dtmDeliveryDate + @TotalDaysApplicableForStorageCharge
							SELECT @dblStorageDuePerUnit = ISNULL(@dblStorageDuePerUnit, 0) + @dblStorageRate * @TotalDaysApplicableForStorageCharge
							SET @TotalDaysApplicableForStorageCharge = @TotalDaysApplicableForStorageCharge - @TotalDaysApplicableForStorageCharge
						END
					END
					ELSE
					BEGIN
						SET @TotalDaysApplicableForStorageCharge = 
								CASE 
									WHEN (@TotalDaysApplicableForStorageCharge - DATEDIFF(DAY, @dtmDeliveryDate, @dtmDEffectiveDate)) < 0
										THEN 0
									ELSE 
										(@TotalDaysApplicableForStorageCharge - DATEDIFF(DAY, @dtmDeliveryDate, @dtmDEffectiveDate))
								END
								
						SET @dtmDeliveryDate = @dtmDEffectiveDate

						IF @TotalDaysApplicableForStorageCharge > 0
						BEGIN
							SET @dtmDeliveryDate = @dtmDeliveryDate + @TotalDaysApplicableForStorageCharge
							SELECT @dblStorageDuePerUnit = ISNULL(@dblStorageDuePerUnit, 0) + @dblStorageRate * @TotalDaysApplicableForStorageCharge
							SET @TotalDaysApplicableForStorageCharge = @TotalDaysApplicableForStorageCharge - @TotalDaysApplicableForStorageCharge
						END
					END
				END
			END

			SELECT @intSchedulePeriodId = MIN(intSchedulePeriodId)
			FROM @tblGRStorageSchedulePeriod
			WHERE intSchedulePeriodId > @intSchedulePeriodId
		END
	END

	---Total Storage Due from Deliverydate to LastStorageAccrueDate  
	IF @dtmLastStorageAccrueDate IS NOT NULL AND @StorageChargeDate > @dtmLastStorageAccrueDate AND @StorageChargeCalculationRequired = 1
	BEGIN
	
		SELECT @dtmDeliveryDate = dtmDeliveryDate
		FROM tblGRCustomerStorage
		WHERE intCustomerStorageId = @intCustomerStorageId

		SELECT @TotalDaysApplicableForStorageCharge = DATEDIFF(DAY, @dtmDeliveryDate, @dtmLastStorageAccrueDate) + 1

		IF @strStorageRate = 'Daily'
		BEGIN
			SELECT @intSchedulePeriodId = MIN(intSchedulePeriodId)
			FROM @tblGRStorageSchedulePeriod

			SET @strPeriodType = NULL
			SET @dtmDEffectiveDate = NULL
			SET @dtmEndingDate = NULL
			SET @intNumberOfDays = NULL
			SET @dblStorageRate = NULL

			WHILE @intSchedulePeriodId > 0 AND @TotalDaysApplicableForStorageCharge > 0
			BEGIN
				SELECT @strPeriodType = strPeriodType
					,@dtmDEffectiveDate = dtmEffectiveDate
					,@dtmEndingDate = dtmEndingDate
					,@intNumberOfDays = ISNULL(intNumberOfDays, 0)
					,@dblStorageRate = dblStorageRate
				FROM @tblGRStorageSchedulePeriod
				WHERE intSchedulePeriodId = @intSchedulePeriodId

				--Number Of Days  
				IF @strPeriodType = 'Number of Days' AND @TotalDaysApplicableForStorageCharge > 0
				BEGIN
					--CASE 1. Start Date = Blank ,Ending Date = Blank   
					IF @dtmDEffectiveDate IS NULL AND @dtmEndingDate IS NULL
					BEGIN
						IF @intNumberOfDays <= @TotalDaysApplicableForStorageCharge
						BEGIN
							SELECT @dblStorageDuePerUnit = ISNULL(@dblStorageDuePerUnit, 0) - @dblStorageRate * @intNumberOfDays
							SET @TotalDaysApplicableForStorageCharge = @TotalDaysApplicableForStorageCharge - @intNumberOfDays
							SET @dtmDeliveryDate = @dtmDeliveryDate + @intNumberOfDays
						END
						ELSE
						BEGIN
							SELECT @dblStorageDuePerUnit = ISNULL(@dblStorageDuePerUnit, 0) - @dblStorageRate * @TotalDaysApplicableForStorageCharge
							SET @TotalDaysApplicableForStorageCharge = @TotalDaysApplicableForStorageCharge - @TotalDaysApplicableForStorageCharge
							SET @dtmDeliveryDate = @dtmDeliveryDate + @TotalDaysApplicableForStorageCharge
						END
					END
					
					--CASE 2. Start Date = Blank ,Ending Date < > Blank  
					ELSE IF @dtmDEffectiveDate IS NULL AND @dtmEndingDate IS NOT NULL
					BEGIN
						IF @dtmEndingDate > @dtmLastStorageAccrueDate
							SET @dtmEndingDate = @dtmLastStorageAccrueDate

						IF @intNumberOfDays > @TotalDaysApplicableForStorageCharge
							SET @intNumberOfDays = @TotalDaysApplicableForStorageCharge

						IF (DATEDIFF(DAY, @dtmDeliveryDate, @dtmEndingDate) + 1) > 0
						BEGIN
							IF (DATEDIFF(DAY, @dtmDeliveryDate, @dtmEndingDate) + 1) <= @intNumberOfDays
							BEGIN
								SELECT @dblStorageDuePerUnit = ISNULL(@dblStorageDuePerUnit, 0) - @dblStorageRate * (DATEDIFF(DAY, @dtmDeliveryDate, @dtmEndingDate) + 1)
								SET @TotalDaysApplicableForStorageCharge = @TotalDaysApplicableForStorageCharge - (DATEDIFF(DAY, @dtmDeliveryDate, @dtmEndingDate) + 1)
								SET @dtmDeliveryDate = @dtmDeliveryDate + (DATEDIFF(DAY, @dtmDeliveryDate, @dtmEndingDate) + 1)
							END
							ELSE
							BEGIN
								SELECT @dblStorageDuePerUnit = ISNULL(@dblStorageDuePerUnit, 0) - @dblStorageRate * @intNumberOfDays
								SET @TotalDaysApplicableForStorageCharge = @TotalDaysApplicableForStorageCharge - @intNumberOfDays
								SET @dtmDeliveryDate = @dtmDeliveryDate + @intNumberOfDays
							END
						END
					END
					
					--CASE 3. Start Date < > Blank, Ending Date= Blank 
					ELSE IF @dtmDEffectiveDate IS NOT NULL AND @dtmEndingDate IS NULL
					BEGIN
						IF @dtmDeliveryDate > @dtmDEffectiveDate
							SET @dtmDEffectiveDate = @dtmDeliveryDate
						ELSE
						BEGIN
							SET @TotalDaysApplicableForStorageCharge = @TotalDaysApplicableForStorageCharge - DATEDIFF(DAY, @dtmDeliveryDate, @dtmDEffectiveDate)
							SET @dtmDeliveryDate = @dtmDeliveryDate + DATEDIFF(DAY, @dtmDeliveryDate, @dtmDEffectiveDate)
						END

						IF @intNumberOfDays > @TotalDaysApplicableForStorageCharge
							SET @intNumberOfDays = @TotalDaysApplicableForStorageCharge

						IF ((DATEDIFF(DAY, @dtmDEffectiveDate, @dtmLastStorageAccrueDate) + 1) > 0) AND (@TotalDaysApplicableForStorageCharge > 0)
						BEGIN
							IF (DATEDIFF(DAY, @dtmDEffectiveDate, @dtmLastStorageAccrueDate) + 1) <= @intNumberOfDays
							BEGIN
								SELECT @dblStorageDuePerUnit = ISNULL(@dblStorageDuePerUnit, 0) - @dblStorageRate * (DATEDIFF(DAY, @dtmDEffectiveDate, @dtmLastStorageAccrueDate) + 1)
								SET @TotalDaysApplicableForStorageCharge = @TotalDaysApplicableForStorageCharge - (DATEDIFF(DAY, @dtmDEffectiveDate, @dtmLastStorageAccrueDate) + 1)
								SET @dtmDeliveryDate = @dtmDeliveryDate + (DATEDIFF(DAY, @dtmDEffectiveDate, @dtmLastStorageAccrueDate) + 1)
							END
							ELSE
							BEGIN
								SELECT @dblStorageDuePerUnit = ISNULL(@dblStorageDuePerUnit, 0) - @dblStorageRate * @intNumberOfDays
								SET @TotalDaysApplicableForStorageCharge = @TotalDaysApplicableForStorageCharge - @intNumberOfDays
								SET @dtmDeliveryDate = @dtmDeliveryDate + @intNumberOfDays
							END
						END
					END
				END

				--Date Range			
				IF @strPeriodType = 'Date Range'
				BEGIN
					--CASE 1.Start Date = Blank ,Ending Date < > Blank, No Of Days=0
							
					IF @dtmDEffectiveDate IS NULL AND @dtmEndingDate IS NOT NULL AND @intNumberOfDays = 0
					BEGIN
						IF @dtmEndingDate > @StorageChargeDate
							SET @dtmEndingDate = @StorageChargeDate

						IF (DATEDIFF(DAY, @dtmDeliveryDate, @dtmEndingDate) + 1) > 0
						BEGIN
							IF (DATEDIFF(DAY, @dtmDeliveryDate, @dtmEndingDate) + 1) <= @TotalDaysApplicableForStorageCharge
							BEGIN
								SELECT @dblStorageDuePerUnit = ISNULL(@dblStorageDuePerUnit, 0) - @dblStorageRate * (DATEDIFF(DAY, @dtmDeliveryDate, @dtmEndingDate) + 1)
								SET @TotalDaysApplicableForStorageCharge = @TotalDaysApplicableForStorageCharge - (DATEDIFF(DAY, @dtmDeliveryDate, @dtmEndingDate) + 1)
								SET @dtmDeliveryDate = @dtmDeliveryDate + (DATEDIFF(DAY, @dtmDeliveryDate, @dtmEndingDate) + 1)
							END
							ELSE
							BEGIN
								SELECT @dblStorageDuePerUnit = ISNULL(@dblStorageDuePerUnit, 0) - @dblStorageRate * @TotalDaysApplicableForStorageCharge
								SET @TotalDaysApplicableForStorageCharge = @TotalDaysApplicableForStorageCharge - @TotalDaysApplicableForStorageCharge
								SET @dtmDeliveryDate = @dtmDeliveryDate + @TotalDaysApplicableForStorageCharge
							END
						END
					END
					
					--CASE 2.Start Date < > Blank, Ending Date = Blank , No Of Days > 0
					ELSE IF @dtmDEffectiveDate IS NOT NULL AND @dtmEndingDate IS NULL AND @intNumberOfDays > 0
					BEGIN
						IF @dtmDeliveryDate > @dtmDEffectiveDate
							SET @dtmDEffectiveDate = @dtmDeliveryDate
						ELSE
						BEGIN
							SET @TotalDaysApplicableForStorageCharge = @TotalDaysApplicableForStorageCharge - DATEDIFF(DAY, @dtmDeliveryDate, @dtmDEffectiveDate)
							SET @dtmDeliveryDate = @dtmDeliveryDate + DATEDIFF(DAY, @dtmDeliveryDate, @dtmDEffectiveDate)
						END

						IF @intNumberOfDays > @TotalDaysApplicableForStorageCharge
							SET @intNumberOfDays = @TotalDaysApplicableForStorageCharge

						IF ((DATEDIFF(DAY, @dtmDEffectiveDate, @StorageChargeDate) + 1) > 0) AND (@TotalDaysApplicableForStorageCharge > 0)
						BEGIN
							IF (DATEDIFF(DAY, @dtmDEffectiveDate, @StorageChargeDate) + 1) <= @intNumberOfDays
							BEGIN
								SELECT @dblStorageDuePerUnit = ISNULL(@dblStorageDuePerUnit, 0) - @dblStorageRate * (DATEDIFF(DAY, @dtmDEffectiveDate, @StorageChargeDate) + 1)
								SET @TotalDaysApplicableForStorageCharge = @TotalDaysApplicableForStorageCharge - (DATEDIFF(DAY, @dtmDEffectiveDate, @StorageChargeDate) + 1)
								SET @dtmDeliveryDate = @dtmDeliveryDate + (DATEDIFF(DAY, @dtmDEffectiveDate, @StorageChargeDate) + 1)
							END
							ELSE
							BEGIN
								SELECT @dblStorageDuePerUnit = ISNULL(@dblStorageDuePerUnit, 0) - @dblStorageRate * @intNumberOfDays
								SET @TotalDaysApplicableForStorageCharge = @TotalDaysApplicableForStorageCharge - @intNumberOfDays
								SET @dtmDeliveryDate = @dtmDeliveryDate + @intNumberOfDays
							END
						END
					END
					
					--CASE 3.Start Date < > Blank, Ending Date < > Blank, No Of Days = 0			
					ELSE IF @dtmDEffectiveDate IS NOT NULL AND @dtmEndingDate IS NOT NULL AND @intNumberOfDays = 0
					BEGIN
						IF @dtmDeliveryDate > @dtmDEffectiveDate
							SET @dtmDEffectiveDate = @dtmDeliveryDate
						ELSE
						BEGIN
							SET @TotalDaysApplicableForStorageCharge = @TotalDaysApplicableForStorageCharge - DATEDIFF(DAY, @dtmDeliveryDate, @dtmDEffectiveDate)
							SET @dtmDeliveryDate = @dtmDeliveryDate + DATEDIFF(DAY, @dtmDeliveryDate, @dtmDEffectiveDate)
						END

						IF @dtmEndingDate > @StorageChargeDate
							SET @dtmEndingDate = @StorageChargeDate

						IF ((DATEDIFF(DAY, @dtmDEffectiveDate, @StorageChargeDate) + 1) > 0) AND ((DATEDIFF(DAY, @dtmDeliveryDate, @dtmEndingDate) + 1) > 0) AND (@TotalDaysApplicableForStorageCharge > 0)
						BEGIN
							IF (DATEDIFF(DAY, @dtmDEffectiveDate, @dtmEndingDate) + 1) <= @TotalDaysApplicableForStorageCharge
							BEGIN
								SELECT @dblStorageDuePerUnit = ISNULL(@dblStorageDuePerUnit, 0) - @dblStorageRate * (DATEDIFF(DAY, @dtmDEffectiveDate, @dtmEndingDate) + 1)
								SET @TotalDaysApplicableForStorageCharge = @TotalDaysApplicableForStorageCharge - (DATEDIFF(DAY, @dtmDEffectiveDate, @dtmEndingDate) + 1)
								SET @dtmDeliveryDate = @dtmDeliveryDate + (DATEDIFF(DAY, @dtmDEffectiveDate, @dtmEndingDate) + 1)
							END
							ELSE
							BEGIN
								SELECT @dblStorageDuePerUnit = ISNULL(@dblStorageDuePerUnit, 0) - @dblStorageRate * @TotalDaysApplicableForStorageCharge
								SET @TotalDaysApplicableForStorageCharge = @TotalDaysApplicableForStorageCharge - @TotalDaysApplicableForStorageCharge
								SET @dtmDeliveryDate = @dtmDeliveryDate + @TotalDaysApplicableForStorageCharge
							END
						END
					END
					
					--CASE 4.Start Date < > Blank, Ending Date < > Blank, No Of Days > 0	
					ELSE IF @dtmDEffectiveDate IS NOT NULL AND @dtmEndingDate IS NOT NULL AND @intNumberOfDays > 0
					BEGIN
						IF @dtmDeliveryDate > @dtmDEffectiveDate
							SET @dtmDEffectiveDate = @dtmDeliveryDate
						ELSE
						BEGIN
							SET @TotalDaysApplicableForStorageCharge = @TotalDaysApplicableForStorageCharge - DATEDIFF(DAY, @dtmDeliveryDate, @dtmDEffectiveDate)
							SET @dtmDeliveryDate = @dtmDeliveryDate + DATEDIFF(DAY, @dtmDeliveryDate, @dtmDEffectiveDate)
						END

						IF @dtmEndingDate > @StorageChargeDate
							SET @dtmEndingDate = @StorageChargeDate

						IF @intNumberOfDays > @TotalDaysApplicableForStorageCharge
							SET @intNumberOfDays = @TotalDaysApplicableForStorageCharge

						IF ((DATEDIFF(DAY, @dtmDEffectiveDate, @StorageChargeDate) + 1) > 0) AND ((DATEDIFF(DAY, @dtmDeliveryDate, @dtmEndingDate) + 1) > 0) AND (@TotalDaysApplicableForStorageCharge > 0)
						BEGIN
							IF (DATEDIFF(DAY, @dtmDEffectiveDate, @StorageChargeDate) + 1) <= @intNumberOfDays
							BEGIN
								SELECT @dblStorageDuePerUnit = ISNULL(@dblStorageDuePerUnit, 0) - @dblStorageRate * (DATEDIFF(DAY, @dtmDEffectiveDate, @StorageChargeDate) + 1)
								SET @TotalDaysApplicableForStorageCharge = @TotalDaysApplicableForStorageCharge - (DATEDIFF(DAY, @dtmDEffectiveDate, @StorageChargeDate) + 1)
								SET @dtmDeliveryDate = @dtmDeliveryDate + (DATEDIFF(DAY, @dtmDEffectiveDate, @StorageChargeDate) + 1)
							END
							ELSE
							BEGIN
								SELECT @dblStorageDuePerUnit = ISNULL(@dblStorageDuePerUnit, 0) - @dblStorageRate * @intNumberOfDays
								SET @TotalDaysApplicableForStorageCharge = @TotalDaysApplicableForStorageCharge - @intNumberOfDays
								SET @dtmDeliveryDate = @dtmDeliveryDate + @intNumberOfDays
							END
						END
					END
				END

				--There After			      
				IF @strPeriodType = 'Thereafter'
				BEGIN
					IF @dtmDEffectiveDate IS NULL
					BEGIN
						SET @dtmDeliveryDate = @dtmDeliveryDate + @TotalDaysApplicableForStorageCharge
						SET @dblStorageDuePerUnit = ISNULL(@dblStorageDuePerUnit, 0) - @dblStorageRate * @TotalDaysApplicableForStorageCharge
						SET @TotalDaysApplicableForStorageCharge = @TotalDaysApplicableForStorageCharge - @TotalDaysApplicableForStorageCharge
					END
					ELSE
					BEGIN
						IF @dtmDeliveryDate > @dtmDEffectiveDate
						BEGIN
							SET @dtmDEffectiveDate = @dtmDeliveryDate
							SET @TotalDaysApplicableForStorageCharge = @TotalDaysApplicableForStorageCharge - DATEDIFF(DAY, @dtmDEffectiveDate, @dtmDeliveryDate)

							IF @TotalDaysApplicableForStorageCharge > 0
							BEGIN
								SET @dtmDeliveryDate = @dtmDeliveryDate + @TotalDaysApplicableForStorageCharge
								SELECT @dblStorageDuePerUnit = ISNULL(@dblStorageDuePerUnit, 0) - @dblStorageRate * @TotalDaysApplicableForStorageCharge
								SET @TotalDaysApplicableForStorageCharge = @TotalDaysApplicableForStorageCharge - @TotalDaysApplicableForStorageCharge
							END
						END
						ELSE
						BEGIN
							SET @TotalDaysApplicableForStorageCharge = @TotalDaysApplicableForStorageCharge - DATEDIFF(DAY, @dtmDeliveryDate, @dtmDEffectiveDate)
							SET @dtmDeliveryDate = @dtmDEffectiveDate

							IF @TotalDaysApplicableForStorageCharge > 0
							BEGIN
								SET @dtmDeliveryDate = @dtmDeliveryDate + @TotalDaysApplicableForStorageCharge
								SELECT @dblStorageDuePerUnit = ISNULL(@dblStorageDuePerUnit, 0) - @dblStorageRate * @TotalDaysApplicableForStorageCharge
								SET @TotalDaysApplicableForStorageCharge = @TotalDaysApplicableForStorageCharge - @TotalDaysApplicableForStorageCharge
							END
						END
					END
				END

				SELECT @intSchedulePeriodId = MIN(intSchedulePeriodId)
				FROM @tblGRStorageSchedulePeriod
				WHERE intSchedulePeriodId > @intSchedulePeriodId
			END
		END
	END

	---Updating Last Storage AccrueDate, Storage Due Field and Creating History.    
	IF @StorageChargeCalculationRequired = 1
	BEGIN
		IF @strProcessType = 'accrue' OR @strProcessType = 'Bill'
		BEGIN
			UPDATE tblGRCustomerStorage
			SET dtmLastStorageAccrueDate = @StorageChargeDate
			WHERE intCustomerStorageId = @intCustomerStorageId

			UPDATE tblGRCustomerStorage
			SET dblStorageDue = dblStorageDue + @dblStorageDuePerUnit
			WHERE intCustomerStorageId = @intCustomerStorageId

			INSERT INTO [dbo].[tblGRStorageHistory] 
			(
				[intConcurrencyId]
				,[intCustomerStorageId]
				,[intTicketId]
				,[intInventoryReceiptId]
				,[intInvoiceId]
				,[intContractHeaderId]
				,[dblUnits]
				,[dtmHistoryDate]
				,[dblPaidAmount]
				,[strPaidDescription]
				,[dblCurrencyRate]
				,[strType]
				,[strUserName]
				,[intTransactionTypeId]
				,[intEntityId]
				,[intCompanyLocationId]
			)
			
			VALUES 
			(
				1
				,@intCustomerStorageId
				,NULL
				,NULL
				,NULL
				,NULL
				,@dblOpenBalance
				,@StorageChargeDate
				,@dblStorageDuePerUnit
				,NULL
				,NULL
				,'Accrued Storage Due'
				,@UserName
				,NULL
				,NULL
				,NULL
			)
		END
	END

	IF @strProcessType = 'Bill'
	BEGIN
		UPDATE tblGRCustomerStorage
		SET dblStoragePaid = dblStorageDue
		WHERE intCustomerStorageId = @intCustomerStorageId

		SELECT @dblNewStoragePaid = dblStoragePaid
		FROM tblGRCustomerStorage
		WHERE intCustomerStorageId = @intCustomerStorageId

		INSERT INTO [dbo].[tblGRStorageHistory] 
		(
			[intConcurrencyId]
			,[intCustomerStorageId]
			,[intTicketId]
			,[intInventoryReceiptId]
			,[intInvoiceId]
			,[intContractHeaderId]
			,[dblUnits]
			,[dtmHistoryDate]
			,[dblPaidAmount]
			,[strPaidDescription]
			,[dblCurrencyRate]
			,[strType]
			,[strUserName]
			,[intTransactionTypeId]
			,[intEntityId]
			,[intCompanyLocationId]
		)
		VALUES 
		(
			1
			,@intCustomerStorageId
			,NULL
			,NULL
			,NULL
			,NULL
			,@dblOpenBalance
			,@StorageChargeDate
			,(@dblNewStoragePaid - @dblOldStoragePaid)
			,NULL
			,NULL
			,'Storage Paid'
			,@UserName
			,NULL
			,NULL
			,NULL
		)
	END

	SELECT @dblStorageDueTotalPerUnit = dblStorageDue - dblStoragePaid
		,@dblStorageBilledPerUnit = dblStoragePaid - @dblOldStoragePaid
	FROM tblGRCustomerStorage
	WHERE intCustomerStorageId = @intCustomerStorageId

	IF @strProcessType = 'Unpaid'
	BEGIN
		SET @dblStorageDuePerUnit = @dblStorageDueTotalPerUnit
	END

	SET @dblStorageDueAmount = @dblStorageDuePerUnit * @dblOpenBalance

	SELECT @dblStorageDueTotalAmount = @dblStorageDueTotalPerUnit * @dblOpenBalance

	SELECT @dblStorageBilledAmount = @dblStorageBilledPerUnit * @dblOpenBalance

END TRY

BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()
	SET @ErrMsg = 'uspGRCalculateStorageCharge: ' + @ErrMsg
	RAISERROR (@ErrMsg,16,1,'WITH NOWAIT')
END CATCH