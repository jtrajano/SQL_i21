CREATE FUNCTION [dbo].[fnGRCalculateStorageCharge]
(
	@intCustomerStorageId			INT
	,@dblUnits						DECIMAL(38,20)
	,@dtmCalculationDate			DATETIME
	,@StorageSchedulePeriods		StorageSchedulePeriodTableType READONLY
)
RETURNS @returnTable TABLE
(
	intCustomerStorageId			INT
	,dblStorageDuePerUnit			DECIMAL(18,6)	NOT NULL DEFAULT 0
	,dblStorageDueAmount			DECIMAL(18,6)	NOT NULL DEFAULT 0
	,dblStorageDueTotalPerUnit		DECIMAL(18,6)	NOT NULL DEFAULT 0
	,dblStorageDueTotalAmount		DECIMAL(18,6)	NOT NULL DEFAULT 0
	,dblStorageBilledPerUnit		DECIMAL(18,6)	NOT NULL DEFAULT 0
	,dblStorageBilledAmount			DECIMAL(18,6)	NOT NULL DEFAULT 0
	,dblFlatFeeTotal				DECIMAL(18,6)	NOT NULL DEFAULT 0
)
AS
BEGIN
	DECLARE @dblOldStoragePaid								DECIMAL(38,20)
	DECLARE @intAllowanceDays								INT
	DECLARE @strStorageRate									NVARCHAR(50)
	DECLARE @strFirstMonth									NVARCHAR(50)
	DECLARE @strLastMonth									NVARCHAR(50)
	DECLARE @dtmEffectiveDate								DATETIME
	DECLARE @dtmTerminationDate								DATETIME
	DECLARE @dtmDeliveryDate								DATETIME
	DECLARE @dtmOrigDeliveryDate							DATETIME
	DECLARE @dtmLastStorageAccrueDate						DATETIME
	DECLARE @intSchedulePeriodId							INT
	DECLARE @strPeriodType									NVARCHAR(50)
	DECLARE @dtmStartDate									DATETIME
	DECLARE @dtmEndingDate									DATETIME
	DECLARE @intNumberOfDays								INT
	DECLARE @intPeriodNumber								INT
	DECLARE @dblStorageRate									DECIMAL(38,20)
	DECLARE @dblFeeRate										DECIMAL(38,20)
	DECLARE	@strFeeType									    NVARCHAR(100)
	DECLARE @intTotalDaysApplicableForStorageCharge			INT
	DECLARE @intTotalMonthsApplicableForStorageCharge		INT
	DECLARE @intTotalOrigMonthsApplicableForStorageCharge  INT
	DECLARE @ysnCalculateStorageCharge						BIT = 1
	DECLARE @intCalculatedNumberOfDays						INT = 0
	DECLARE @ysnFirstMonthFullChargeApplicable				BIT
	
	DECLARE @strAllowancePeriod								NVARCHAR(50)
	DECLARE @dtmAllowancePeriodFrom							DATETIME
	DECLARE @dtmAllowancePeriodTo							DATETIME
	DECLARE @dtmOrigCalculationDate							DATETIME
	DECLARE @dtmFlatFeeCalcFromDate							DATETIME

	DECLARE @dblStorageDuePerUnit							DECIMAL(18,6) = 0
	DECLARE @dblStorageDueAmount							DECIMAL(18,6) = 0
	DECLARE @dblStorageDueTotalPerUnit						DECIMAL(18,6) = 0
	DECLARE @dblStorageDueTotalAmount						DECIMAL(18,6) = 0
	DECLARE @dblStorageBilledPerUnit						DECIMAL(18,6) = 0
	DECLARE @dblStorageBilledAmount							DECIMAL(18,6) = 0
	DECLARE @dblFlatFeeTotal								DECIMAL(18,6) = 0

	SET @dtmOrigCalculationDate = @dtmCalculationDate

	IF @intCustomerStorageId > 0
	BEGIN
		SELECT 
			 @dblOldStoragePaid        = ISNULL(CS.dblStoragePaid,0)
			,@intAllowanceDays         = SR.intAllowanceDays
			,@strStorageRate           = SR.strStorageRate
			,@strFirstMonth            = SR.strFirstMonth
			,@strLastMonth             = SR.strLastMonth
			,@dtmEffectiveDate		   = dbo.fnRemoveTimeOnDate(SR.dtmEffectiveDate)
			,@dtmTerminationDate       = dbo.fnRemoveTimeOnDate(SR.dtmTerminationDate)
			,@strAllowancePeriod       = SR.strAllowancePeriod
			,@dtmAllowancePeriodFrom   = dbo.fnRemoveTimeOnDate(SR.dtmAllowancePeriodFrom)
			,@dtmAllowancePeriodTo     = dbo.fnRemoveTimeOnDate(SR.dtmAllowancePeriodTo)
			,@dtmDeliveryDate		   = dbo.fnRemoveTimeOnDate(CS.dtmDeliveryDate)
			,@dtmLastStorageAccrueDate = dbo.fnRemoveTimeOnDate(CS.dtmLastStorageAccrueDate)
		FROM tblGRCustomerStorage CS
		INNER JOIN tblGRStorageScheduleRule SR 
			ON SR.intStorageScheduleRuleId = CS.intStorageScheduleId
		WHERE CS.intCustomerStorageId = @intCustomerStorageId
		
		SET @dtmOrigDeliveryDate = @dtmDeliveryDate

		SELECT @dtmFlatFeeCalcFromDate = MAX(dbo.fnRemoveTimeOnDate(dtmHistoryDate)) 
		FROM 
		(
			SELECT TOP 1 dbo.fnRemoveTimeOnDate(dtmHistoryDate) dtmHistoryDate
			FROM tblGRStorageHistory 
			WHERE intCustomerStorageId = @intCustomerStorageId 
				AND strType = 'Settlement' 
				AND intBillId IS NOT NULL
			ORDER BY 1 DESC
			UNION			
			SELECT TOP 1 dbo.fnRemoveTimeOnDate(dtmHistoryDate) dtmHistoryDate
			FROM tblGRStorageHistory 
			WHERE intCustomerStorageId = @intCustomerStorageId 
				AND (strType = 'Generated Storage Invoice' OR strPaidDescription = 'Generated Storage Invoice')
				AND intInvoiceId IS NOT NULL
			ORDER BY 1 DESC
			UNION
			SELECT TOP 1 dbo.fnRemoveTimeOnDate(SH.dtmHistoryDate)
			FROM tblGRStorageHistory SH
			LEFT JOIN (
						SELECT 
							intCustomerStorageId
							,intInvoiceId
							,ISNULL(SUM(dblUnits), 0) dblDepletedUnits
						FROM tblGRStorageHistory
						WHERE strType = 'Reduced By Invoice' 
							AND intCustomerStorageId = @intCustomerStorageId
						GROUP BY intCustomerStorageId, intInvoiceId
				       ) Depleted ON Depleted.intCustomerStorageId = SH.intCustomerStorageId
			
			LEFT JOIN (
						SELECT 
							 intCustomerStorageId
							,intInvoiceId
							,ISNULL(SUM(dblUnits), 0) dblReversedUnits
						 FROM tblGRStorageHistory
						 WHERE strType = 'Reverse By Invoice' 
							AND intCustomerStorageId = @intCustomerStorageId
						 GROUP BY intCustomerStorageId, intInvoiceId
					 ) ReverseInvoice ON ReverseInvoice.intCustomerStorageId = SH.intCustomerStorageId
			WHERE ISNULL(Depleted.dblDepletedUnits, 0) <> ISNULL(ReverseInvoice.dblReversedUnits, 0)
				AND Depleted.intInvoiceId = ReverseInvoice.intInvoiceId
				AND SH.strType = 'Reduced By Invoice'
				AND SH.intInvoiceId IS NOT NULL 
				AND SH.intCustomerStorageId = @intCustomerStorageId
			ORDER BY 1 DESC
		) t

	    IF (@dtmFlatFeeCalcFromDate IS NULL AND @dtmLastStorageAccrueDate IS NOT NULL)
			OR
			((@dtmFlatFeeCalcFromDate IS NOT NULL AND @dtmLastStorageAccrueDate IS NOT NULL) AND (@dtmFlatFeeCalcFromDate < @dtmLastStorageAccrueDate))
	    BEGIN
		 	SET @dtmFlatFeeCalcFromDate = @dtmLastStorageAccrueDate
	    END
	END
	
	--If Termination Date is not blank and Calculation date is greather than the Termination Date then charge only up to Termination date
	IF @dtmCalculationDate > @dtmTerminationDate AND @dtmTerminationDate IS NOT NULL
	BEGIN
		SET @dtmCalculationDate = @dtmTerminationDate
	END

	--If Effective Date is not blank and Delivery date is earlier than the Effective Date then start charging only from the Effective date
	IF @dtmDeliveryDate < @dtmEffectiveDate AND @dtmEffectiveDate IS NOT NULL
	BEGIN
		SET @dtmDeliveryDate = @dtmEffectiveDate
	END
	
	IF (@dtmLastStorageAccrueDate >= @dtmCalculationDate) --if the Calculation Date is less than or equal to Last Accrue Date.  
		OR 
		(@dtmCalculationDate < @dtmDeliveryDate) --if the Calculation Date less than the Delivery Date.
		OR 
		(
			(@intAllowanceDays > 0) AND (@dtmLastStorageAccrueDate IS NULL)
			AND ((DATEDIFF(DAY, @dtmDeliveryDate, @dtmCalculationDate) + 1) <= @intAllowanceDays)
		 ) --if charge is not at all Accrued( Means at least once) yet and the difference between the calculation date and delivery date is less than or equal to Allowance Days.		
		OR
		(@dtmCalculationDate < @dtmDeliveryDate) --if the Calculation Date is less than Delivery date.
		OR 
		(
			@dtmLastStorageAccrueDate IS NOT NULL 
			AND (@dtmLastStorageAccrueDate >= @dtmCalculationDate)
		) --if the Last Storage Accrue date is greather than or equal to Calculation Date.
		OR 
		(
			@strAllowancePeriod = 'Date(s)' 
			AND @dtmDeliveryDate >= @dtmAllowancePeriodFrom
			AND @dtmCalculationDate <= @dtmAllowancePeriodTo
		)
	BEGIN
		SET @dblStorageDuePerUnit = 0
		SET @dblStorageDueAmount = 0
		SET @ysnCalculateStorageCharge = 0
	END
	
	IF @strAllowancePeriod = 'Date(s)' AND (@dtmDeliveryDate < @dtmAllowancePeriodFrom)
		AND ((@dtmCalculationDate >= @dtmAllowancePeriodFrom)
				AND (@dtmCalculationDate <= @dtmAllowancePeriodTo))
	BEGIN
		SET @dtmCalculationDate = @dtmAllowancePeriodFrom - 1
	END

	SELECT @intTotalDaysApplicableForStorageCharge = DATEDIFF(DAY, @dtmDeliveryDate, @dtmCalculationDate) + 1
	
	SELECT @intTotalMonthsApplicableForStorageCharge = DATEDIFF(MONTH, @dtmDeliveryDate, @dtmCalculationDate) + 1
	SET @intTotalOrigMonthsApplicableForStorageCharge = @intTotalMonthsApplicableForStorageCharge	

	SET @ysnFirstMonthFullChargeApplicable = CASE 
												WHEN ((@intTotalOrigMonthsApplicableForStorageCharge = 1) AND (@strFirstMonth <> @strLastMonth)) OR (@strFirstMonth = 'Full Month' AND @strLastMonth = 'Full Month') THEN 1
												WHEN ((@intTotalOrigMonthsApplicableForStorageCharge > 1) AND (@strFirstMonth = 'Full Month')) THEN 1
												ELSE 0
											END	
	IF @ysnCalculateStorageCharge = 1
	BEGIN
		---------------Start Of Daily----------------------
		--Due from Deliverydate to Calculation Date.	
		IF @strStorageRate = 'Daily'
		BEGIN
			SELECT @intSchedulePeriodId = MIN(intSchedulePeriodId)
			FROM @StorageSchedulePeriods
		
			WHILE @intSchedulePeriodId > 0 AND @intTotalDaysApplicableForStorageCharge > 0
			BEGIN			
				SET @intPeriodNumber			= NULL	    
				SET @strPeriodType				= NULL
				SET @dtmStartDate				= NULL
				SET @dtmEndingDate				= NULL
				SET @intNumberOfDays			= NULL
				SET @dblStorageRate				= NULL
				SET @dblFeeRate					= NULL
				SET @strFeeType					= NULL
				SET @intCalculatedNumberOfDays	= NULL

				SELECT
					 @intPeriodNumber       = intPeriodNumber 
					,@strPeriodType			= strPeriodType
					,@dtmStartDate			= dtmStartDate
					,@dtmEndingDate         = dtmEndingDate
					,@intNumberOfDays       = ISNULL(intNumberOfDays, 0)
					,@dblStorageRate        = dblStorageRate
					,@dblFeeRate		    = dblFeeRate
					,@strFeeType			= strFeeType
				FROM @StorageSchedulePeriods
				WHERE intSchedulePeriodId = @intSchedulePeriodId

				IF @strPeriodType = 'Number of Days'
				BEGIN				
					IF @dtmStartDate IS NULL AND @dtmEndingDate IS NULL --CASE 1. Start Date = Blank, Ending Date = Blank
					BEGIN
						SET @intCalculatedNumberOfDays = CASE WHEN @intNumberOfDays <= @intTotalDaysApplicableForStorageCharge THEN @intNumberOfDays ELSE @intTotalDaysApplicableForStorageCharge END
					END								
					ELSE IF @dtmStartDate IS NULL AND @dtmEndingDate IS NOT NULL --CASE 2. Start Date = Blank, Ending Date < > Blank
					BEGIN
						SET @dtmEndingDate = CASE WHEN @dtmEndingDate > @dtmCalculationDate THEN @dtmCalculationDate ELSE @dtmEndingDate END
						SET @intNumberOfDays = CASE WHEN @intNumberOfDays > @intTotalDaysApplicableForStorageCharge THEN @intTotalDaysApplicableForStorageCharge ELSE @intNumberOfDays END

						SET @intCalculatedNumberOfDays = CASE
															WHEN ((DATEDIFF(DAY, @dtmDeliveryDate, @dtmEndingDate) + 1) > 0) THEN
																CASE
																	WHEN (DATEDIFF(DAY, @dtmDeliveryDate, @dtmEndingDate) + 1) <= @intNumberOfDays THEN (DATEDIFF(DAY, @dtmDeliveryDate, @dtmEndingDate) + 1)
																	ELSE @intNumberOfDays
																END
														END
					END				
					ELSE IF @dtmStartDate IS NOT NULL AND @dtmEndingDate IS NULL --CASE 3. Start Date < > Blank, Ending Date = Blank
					BEGIN
						SET @dtmStartDate = CASE WHEN @dtmDeliveryDate > @dtmStartDate THEN @dtmDeliveryDate ELSE @dtmStartDate END
						SET @intTotalDaysApplicableForStorageCharge = CASE 
																		WHEN (@intTotalDaysApplicableForStorageCharge - DATEDIFF(DAY, @dtmDeliveryDate, @dtmStartDate)) < 0 THEN 0
																		ELSE (@intTotalDaysApplicableForStorageCharge - DATEDIFF(DAY, @dtmDeliveryDate, @dtmStartDate))
																	END
						SET @dtmDeliveryDate = @dtmDeliveryDate + DATEDIFF(DAY, @dtmDeliveryDate, @dtmStartDate)
						SET @intNumberOfDays = CASE WHEN @intNumberOfDays > @intTotalDaysApplicableForStorageCharge THEN @intTotalDaysApplicableForStorageCharge ELSE @intNumberOfDays END

						SET @intCalculatedNumberOfDays = CASE
															WHEN ((DATEDIFF(DAY, @dtmStartDate, @dtmCalculationDate) + 1) > 0 AND @intTotalDaysApplicableForStorageCharge > 0) THEN
																CASE
																	WHEN ((DATEDIFF(DAY, @dtmStartDate, @dtmCalculationDate) + 1) <= @intNumberOfDays) THEN (DATEDIFF(DAY, @dtmStartDate, @dtmCalculationDate) + 1)
																	ELSE @intNumberOfDays
																END
														END
					END
				END

				IF @strPeriodType = 'Date Range'
				BEGIN				
					IF @dtmStartDate IS NULL AND @dtmEndingDate IS NOT NULL AND @intNumberOfDays = 0 --CASE 1.Start Date = Blank ,Ending Date < > Blank, No Of Days=0
					BEGIN
						SET @dtmEndingDate = CASE WHEN @dtmEndingDate > @dtmCalculationDate THEN @dtmCalculationDate ELSE @dtmEndingDate END					
						SET @intCalculatedNumberOfDays = CASE
															WHEN (DATEDIFF(DAY, @dtmDeliveryDate, @dtmEndingDate) + 1) > 0 THEN
																CASE
																	 WHEN (DATEDIFF(DAY, @dtmDeliveryDate, @dtmEndingDate) + 1) <= @intTotalDaysApplicableForStorageCharge 
																		THEN (DATEDIFF(DAY, @dtmDeliveryDate, @dtmEndingDate) + 1)
																	 ELSE @intTotalDaysApplicableForStorageCharge
																END
														END				
					END				
					ELSE IF @dtmStartDate IS NOT NULL AND @dtmEndingDate IS NULL AND @intNumberOfDays > 0 --CASE 2.Start Date < > Blank, Ending Date = Blank , No Of Days > 0	
					BEGIN
						SET @dtmStartDate = CASE WHEN @dtmDeliveryDate > @dtmStartDate THEN @dtmDeliveryDate ELSE @dtmStartDate END
						SET @intTotalDaysApplicableForStorageCharge = CASE 
																		WHEN (@intTotalDaysApplicableForStorageCharge - DATEDIFF(DAY, @dtmDeliveryDate, @dtmStartDate)) < 0 THEN 0
																		ELSE (@intTotalDaysApplicableForStorageCharge - DATEDIFF(DAY, @dtmDeliveryDate, @dtmStartDate))
																	END
						SET @dtmDeliveryDate = @dtmDeliveryDate + DATEDIFF(DAY, @dtmDeliveryDate, @dtmStartDate)
						SET @intNumberOfDays = CASE WHEN @intNumberOfDays > @intTotalDaysApplicableForStorageCharge THEN @intTotalDaysApplicableForStorageCharge ELSE @intNumberOfDays END

						SET @intCalculatedNumberOfDays = CASE 
															WHEN (DATEDIFF(DAY, @dtmStartDate, @dtmCalculationDate) + 1) > 0 AND @intTotalDaysApplicableForStorageCharge > 0 THEN 
																CASE
																	WHEN (DATEDIFF(DAY, @dtmStartDate, @dtmCalculationDate) + 1) <= @intNumberOfDays
																		THEN (DATEDIFF(DAY, @dtmStartDate, @dtmCalculationDate) + 1)
																	ELSE @intNumberOfDays
																END
														END
					END			
					ELSE IF @dtmStartDate IS NOT NULL AND @dtmEndingDate IS NOT NULL AND @intNumberOfDays = 0 --CASE 3.Start Date < > Blank, Ending Date < > Blank, No Of Days = 0
					BEGIN				     
						SET @dtmStartDate = CASE WHEN @dtmDeliveryDate > @dtmStartDate THEN @dtmDeliveryDate ELSE @dtmStartDate END
						SET @intTotalDaysApplicableForStorageCharge = CASE 
																		WHEN (@intTotalDaysApplicableForStorageCharge - DATEDIFF(DAY, @dtmDeliveryDate, @dtmStartDate)) < 0 THEN 0
																		ELSE (@intTotalDaysApplicableForStorageCharge - DATEDIFF(DAY, @dtmDeliveryDate, @dtmStartDate))
																	END
						SET @dtmDeliveryDate = @dtmDeliveryDate + DATEDIFF(DAY, @dtmDeliveryDate, @dtmStartDate)
						SET @dtmEndingDate = CASE WHEN @dtmEndingDate > @dtmCalculationDate THEN @dtmCalculationDate ELSE @dtmEndingDate END

						SET @intCalculatedNumberOfDays = CASE
															WHEN (DATEDIFF(DAY, @dtmStartDate, @dtmCalculationDate) + 1) > 0 AND ((DATEDIFF(DAY, @dtmDeliveryDate, @dtmEndingDate) + 1) > 0) AND @intTotalDaysApplicableForStorageCharge > 0 THEN
																CASE
																	WHEN (DATEDIFF(DAY, @dtmStartDate, @dtmEndingDate) + 1) <= @intTotalDaysApplicableForStorageCharge
																		THEN (DATEDIFF(DAY, @dtmStartDate, @dtmEndingDate) + 1) 
																	ELSE @intTotalDaysApplicableForStorageCharge
																END
														END
					END
					ELSE IF @dtmStartDate IS NOT NULL AND @dtmEndingDate IS NOT NULL AND @intNumberOfDays > 0 --CASE 4.Start Date < > Blank, Ending Date < > Blank, No Of Days > 0
					BEGIN
						SET @dtmStartDate = CASE WHEN @dtmDeliveryDate > @dtmStartDate THEN @dtmDeliveryDate ELSE @dtmStartDate END					
						SET @intTotalDaysApplicableForStorageCharge = CASE 
																		WHEN (@intTotalDaysApplicableForStorageCharge - DATEDIFF(DAY, @dtmDeliveryDate, @dtmStartDate)) < 0 THEN 0
																		ELSE (@intTotalDaysApplicableForStorageCharge - DATEDIFF(DAY, @dtmDeliveryDate, @dtmStartDate))
																	END
						SET @dtmDeliveryDate = @dtmDeliveryDate + DATEDIFF(DAY, @dtmDeliveryDate, @dtmStartDate)
						SET @dtmEndingDate = CASE WHEN @dtmEndingDate > @dtmCalculationDate THEN @dtmCalculationDate ELSE @dtmEndingDate END
						SET @intNumberOfDays = CASE WHEN @intNumberOfDays > @intTotalDaysApplicableForStorageCharge THEN @intTotalDaysApplicableForStorageCharge ELSE @intNumberOfDays END

						SET @intCalculatedNumberOfDays = CASE
															WHEN (DATEDIFF(DAY, @dtmStartDate, @dtmCalculationDate) + 1) > 0 AND ((DATEDIFF(DAY, @dtmDeliveryDate, @dtmEndingDate) + 1) > 0) AND @intTotalDaysApplicableForStorageCharge > 0 THEN
																CASE 
																	WHEN (DATEDIFF(DAY, @dtmStartDate, @dtmCalculationDate) + 1) <= @intNumberOfDays 
																		THEN (DATEDIFF(DAY, @dtmStartDate, @dtmCalculationDate) + 1)
																	ELSE @intNumberOfDays
																END
														END
					END
				END

				IF @strPeriodType = 'Thereafter'
				BEGIN
					SET @intCalculatedNumberOfDays = CASE WHEN @dtmStartDate IS NULL THEN @intTotalDaysApplicableForStorageCharge ELSE @intCalculatedNumberOfDays END

					IF @dtmDeliveryDate > @dtmStartDate
					BEGIN
						SET @dtmStartDate = @dtmDeliveryDate
					
						SET @intCalculatedNumberOfDays = CASE WHEN @intTotalDaysApplicableForStorageCharge > 0 THEN @intTotalDaysApplicableForStorageCharge ELSE @intCalculatedNumberOfDays END
					END
					ELSE
					BEGIN
						SET @intTotalDaysApplicableForStorageCharge =  CASE 
																		WHEN (@intTotalDaysApplicableForStorageCharge - DATEDIFF(DAY, @dtmDeliveryDate, @dtmStartDate)) < 0 THEN 0
																		ELSE (@intTotalDaysApplicableForStorageCharge - DATEDIFF(DAY, @dtmDeliveryDate, @dtmStartDate))
																	END
						SET @dtmDeliveryDate = @dtmStartDate

						SET @intCalculatedNumberOfDays = CASE WHEN @intTotalDaysApplicableForStorageCharge > 0 THEN @intTotalDaysApplicableForStorageCharge ELSE @intCalculatedNumberOfDays END
					END
				END
			
				IF @strFeeType = 'Flat' 
				BEGIN				   
					SET @dblFlatFeeTotal = CASE 
												WHEN (@dtmFlatFeeCalcFromDate IS NULL) OR (@dtmDeliveryDate > @dtmFlatFeeCalcFromDate) THEN ISNULL(@dblFlatFeeTotal, 0) + @dblFeeRate
												ELSE 0
											END
				END

				SET @dblStorageDuePerUnit = ISNULL(@dblStorageDuePerUnit, 0) + @dblStorageRate * ISNULL(@intCalculatedNumberOfDays,0)
																								+ CASE WHEN @strFeeType = 'Per Unit' THEN @dblFeeRate ELSE 0 END
				SET @intTotalDaysApplicableForStorageCharge = @intTotalDaysApplicableForStorageCharge - ISNULL(@intCalculatedNumberOfDays,0)
				SET @dtmDeliveryDate = @dtmDeliveryDate + ISNULL(@intCalculatedNumberOfDays,0)			
			
				SELECT 
					@intSchedulePeriodId = MIN(intSchedulePeriodId)
				FROM @StorageSchedulePeriods
				WHERE intSchedulePeriodId > @intSchedulePeriodId
			END
		END		
		
		IF @dtmLastStorageAccrueDate IS NOT NULL AND @dtmCalculationDate > @dtmLastStorageAccrueDate ---Due from Deliverydate to Last Storage Accrue Date  
		BEGIN
			SET @dtmDeliveryDate = @dtmOrigDeliveryDate
			SELECT @intTotalDaysApplicableForStorageCharge = DATEDIFF(DAY, @dtmDeliveryDate, @dtmLastStorageAccrueDate) + 1

			IF @strStorageRate = 'Daily'
			BEGIN
				SELECT @intSchedulePeriodId = MIN(intSchedulePeriodId)
				FROM @StorageSchedulePeriods
			
				WHILE @intSchedulePeriodId > 0 AND @intTotalDaysApplicableForStorageCharge > 0
				BEGIN			
					SET @intPeriodNumber			= NULL
					SET @strPeriodType				= NULL
					SET @dtmStartDate				= NULL
					SET @dtmEndingDate				= NULL
					SET @intNumberOfDays			= NULL
					SET @dblStorageRate				= NULL
					SET @intCalculatedNumberOfDays	= NULL
			
					SELECT 
						 @intPeriodNumber			= intPeriodNumber 
						,@strPeriodType				= strPeriodType
						,@dtmStartDate				= dtmStartDate
						,@dtmEndingDate				= dtmEndingDate
						,@intNumberOfDays			= ISNULL(intNumberOfDays, 0)
						,@dblStorageRate			= dblStorageRate
					FROM @StorageSchedulePeriods
					WHERE intSchedulePeriodId = @intSchedulePeriodId

					IF @strPeriodType = 'Number of Days' AND @intTotalDaysApplicableForStorageCharge > 0
					BEGIN											
						IF @dtmStartDate IS NULL AND @dtmEndingDate IS NULL --CASE 1. Start Date = Blank ,Ending Date = Blank   
						BEGIN
							SET @intCalculatedNumberOfDays = CASE WHEN @intNumberOfDays <= @intTotalDaysApplicableForStorageCharge THEN @intNumberOfDays ELSE @intTotalDaysApplicableForStorageCharge END
						END				
						ELSE IF @dtmStartDate IS NULL AND @dtmEndingDate IS NOT NULL --CASE 2. Start Date = Blank ,Ending Date <> Blank  
						BEGIN
							SET @dtmEndingDate = CASE WHEN @dtmEndingDate > @dtmLastStorageAccrueDate THEN @dtmLastStorageAccrueDate ELSE @dtmEndingDate END
							SET @intNumberOfDays = CASE WHEN @intNumberOfDays > @intTotalDaysApplicableForStorageCharge THEN @intTotalDaysApplicableForStorageCharge ELSE @intNumberOfDays END

							SET @intCalculatedNumberOfDays = CASE 
																WHEN (DATEDIFF(DAY, @dtmDeliveryDate, @dtmEndingDate) + 1) > 0 THEN
																	CASE 
																		WHEN (DATEDIFF(DAY, @dtmDeliveryDate, @dtmEndingDate) + 1) <= @intNumberOfDays THEN (DATEDIFF(DAY, @dtmDeliveryDate, @dtmEndingDate) + 1)
																		ELSE @intNumberOfDays
																	END
															END
						END
						ELSE IF @dtmStartDate IS NOT NULL AND @dtmEndingDate IS NULL --CASE 3. Start Date < > Blank, Ending Date= Blank 
						BEGIN
							SET @dtmStartDate = CASE WHEN @dtmDeliveryDate > @dtmStartDate THEN @dtmDeliveryDate ELSE @dtmStartDate END
							SET @intTotalDaysApplicableForStorageCharge = @intTotalDaysApplicableForStorageCharge - DATEDIFF(DAY, @dtmDeliveryDate, @dtmStartDate)
							SET @dtmDeliveryDate = @dtmDeliveryDate + DATEDIFF(DAY, @dtmDeliveryDate, @dtmStartDate)
							SET @intNumberOfDays = CASE WHEN @intNumberOfDays > @intTotalDaysApplicableForStorageCharge THEN @intTotalDaysApplicableForStorageCharge ELSE @intNumberOfDays END
							
							SET @intCalculatedNumberOfDays = CASE 
																WHEN ((DATEDIFF(DAY, @dtmStartDate, @dtmLastStorageAccrueDate) + 1) > 0) AND (@intTotalDaysApplicableForStorageCharge > 0) THEN
																	CASE
																		WHEN (DATEDIFF(DAY, @dtmStartDate, @dtmLastStorageAccrueDate) + 1) <= @intNumberOfDays
																			THEN (DATEDIFF(DAY, @dtmStartDate, @dtmLastStorageAccrueDate) + 1)
																		ELSE @intNumberOfDays
																	END
															END
						END
					END

					IF @strPeriodType = 'Date Range'
					BEGIN						
						IF @dtmStartDate IS NULL AND @dtmEndingDate IS NOT NULL AND @intNumberOfDays = 0 --CASE 1.Start Date = Blank ,Ending Date < > Blank, No Of Days=0
						BEGIN
							SET @dtmEndingDate = CASE WHEN @dtmEndingDate > @dtmLastStorageAccrueDate THEN @dtmLastStorageAccrueDate ELSE @dtmEndingDate END
							
							SET @intCalculatedNumberOfDays = CASE 
																WHEN (DATEDIFF(DAY, @dtmDeliveryDate, @dtmEndingDate) + 1) > 0 THEN 
																	CASE 
																		WHEN (DATEDIFF(DAY, @dtmDeliveryDate, @dtmEndingDate) + 1) <= @intTotalDaysApplicableForStorageCharge 
																			THEN (DATEDIFF(DAY, @dtmDeliveryDate, @dtmEndingDate) + 1) 
																		ELSE @intTotalDaysApplicableForStorageCharge 
																	END
															END
						END						
						ELSE IF @dtmStartDate IS NOT NULL AND @dtmEndingDate IS NULL AND @intNumberOfDays > 0 --CASE 2.Start Date < > Blank, Ending Date = Blank , No Of Days > 0
						BEGIN
							SET @dtmStartDate = CASE WHEN @dtmDeliveryDate > @dtmStartDate THEN @dtmDeliveryDate ELSE @dtmStartDate END
							SET @intTotalDaysApplicableForStorageCharge = @intTotalDaysApplicableForStorageCharge - DATEDIFF(DAY, @dtmDeliveryDate, @dtmStartDate)
							SET @dtmDeliveryDate = @dtmDeliveryDate + DATEDIFF(DAY, @dtmDeliveryDate, @dtmStartDate)
							SET @intNumberOfDays = CASE WHEN @intNumberOfDays > @intTotalDaysApplicableForStorageCharge THEN @intTotalDaysApplicableForStorageCharge ELSE @intNumberOfDays END

							SET @intCalculatedNumberOfDays = CASE 
																WHEN ((DATEDIFF(DAY, @dtmStartDate, @dtmLastStorageAccrueDate) + 1) > 0) AND (@intTotalDaysApplicableForStorageCharge > 0) THEN 
																	CASE 
																		WHEN (DATEDIFF(DAY, @dtmStartDate, @dtmLastStorageAccrueDate) + 1) <= @intNumberOfDays 
																			THEN (DATEDIFF(DAY, @dtmStartDate, @dtmLastStorageAccrueDate) + 1) 
																		ELSE @intNumberOfDays 
																	END
															END
						END
						ELSE IF @dtmStartDate IS NOT NULL AND @dtmEndingDate IS NOT NULL AND @intNumberOfDays = 0 --CASE 3.Start Date < > Blank, Ending Date < > Blank, No Of Days = 0
						BEGIN							
							SET @dtmStartDate = CASE WHEN @dtmDeliveryDate > @dtmStartDate THEN @dtmDeliveryDate ELSE @dtmStartDate END
							SET @intTotalDaysApplicableForStorageCharge = @intTotalDaysApplicableForStorageCharge - DATEDIFF(DAY, @dtmDeliveryDate, @dtmStartDate)
							SET @dtmDeliveryDate = @dtmDeliveryDate + DATEDIFF(DAY, @dtmDeliveryDate, @dtmStartDate)
							SET @dtmEndingDate = CASE WHEN @dtmEndingDate > @dtmLastStorageAccrueDate THEN @dtmLastStorageAccrueDate ELSE @dtmEndingDate END

							SET @intCalculatedNumberOfDays = CASE 
																WHEN ((DATEDIFF(DAY, @dtmStartDate, @dtmLastStorageAccrueDate) + 1) > 0) AND ((DATEDIFF(DAY, @dtmDeliveryDate, @dtmEndingDate) + 1) > 0) AND (@intTotalDaysApplicableForStorageCharge > 0) THEN
																	CASE
																		WHEN (DATEDIFF(DAY, @dtmStartDate, @dtmEndingDate) + 1) <= @intTotalDaysApplicableForStorageCharge
																			THEN (DATEDIFF(DAY, @dtmStartDate, @dtmEndingDate) + 1)
																		ELSE @intTotalDaysApplicableForStorageCharge
																	END
															END
						END				
						ELSE IF @dtmStartDate IS NOT NULL AND @dtmEndingDate IS NOT NULL AND @intNumberOfDays > 0 --CASE 4.Start Date < > Blank, Ending Date < > Blank, No Of Days > 0
						BEGIN
							SET @dtmStartDate = CASE WHEN @dtmDeliveryDate > @dtmStartDate THEN @dtmDeliveryDate ELSE @dtmStartDate END
							SET @intTotalDaysApplicableForStorageCharge = @intTotalDaysApplicableForStorageCharge - DATEDIFF(DAY, @dtmDeliveryDate, @dtmStartDate)
							SET @dtmDeliveryDate = @dtmDeliveryDate + DATEDIFF(DAY, @dtmDeliveryDate, @dtmStartDate)
							SET @dtmEndingDate = CASE WHEN @dtmEndingDate > @dtmLastStorageAccrueDate THEN @dtmLastStorageAccrueDate ELSE @dtmEndingDate END 
							SET @intNumberOfDays = CASE WHEN @intNumberOfDays > @intTotalDaysApplicableForStorageCharge THEN @intTotalDaysApplicableForStorageCharge ELSE @intNumberOfDays END

							SET @intCalculatedNumberOfDays = CASE 
																WHEN ((DATEDIFF(DAY, @dtmStartDate, @dtmLastStorageAccrueDate) + 1) > 0) AND ((DATEDIFF(DAY, @dtmDeliveryDate, @dtmEndingDate) + 1) > 0) AND (@intTotalDaysApplicableForStorageCharge > 0) THEN
																	CASE
																		WHEN (DATEDIFF(DAY, @dtmStartDate, @dtmLastStorageAccrueDate) + 1) <= @intNumberOfDays
																			THEN (DATEDIFF(DAY, @dtmStartDate, @dtmLastStorageAccrueDate) + 1)
																		ELSE @intNumberOfDays
																	END
															END
						END
					END

					IF @strPeriodType = 'Thereafter'
					BEGIN						
						SET @intCalculatedNumberOfDays =  CASE WHEN @dtmStartDate IS NULL THEN @intTotalDaysApplicableForStorageCharge ELSE @intCalculatedNumberOfDays END						

						IF @dtmDeliveryDate > @dtmStartDate
						BEGIN
							SET @dtmStartDate = @dtmDeliveryDate

							SET @intCalculatedNumberOfDays = CASE WHEN @intTotalDaysApplicableForStorageCharge > 0 THEN @intTotalDaysApplicableForStorageCharge ELSE @intCalculatedNumberOfDays END
						END
						ELSE
						BEGIN
							SET @intTotalDaysApplicableForStorageCharge = @intTotalDaysApplicableForStorageCharge - DATEDIFF(DAY, @dtmDeliveryDate, @dtmStartDate)
							SET @dtmDeliveryDate = @dtmStartDate

							SET @intCalculatedNumberOfDays = CASE WHEN @intTotalDaysApplicableForStorageCharge > 0 THEN @intTotalDaysApplicableForStorageCharge ELSE @intCalculatedNumberOfDays END							
						END
					END			
				
					SELECT @dblStorageDuePerUnit = ISNULL(@dblStorageDuePerUnit, 0) - @dblStorageRate * ISNULL(@intCalculatedNumberOfDays,0)
																					- CASE WHEN @strFeeType = 'Per Unit' THEN @dblFeeRate ELSE 0 END

					SET @intTotalDaysApplicableForStorageCharge = @intTotalDaysApplicableForStorageCharge - ISNULL(@intCalculatedNumberOfDays,0)
					SET @dtmDeliveryDate = @dtmDeliveryDate + ISNULL(@intCalculatedNumberOfDays,0)				
				
					SELECT @intSchedulePeriodId = MIN(intSchedulePeriodId)
					FROM @StorageSchedulePeriods
					WHERE intSchedulePeriodId > @intSchedulePeriodId
				END
			END
		END
		---------------End Of Daily------------------------
	
		--------------Start Of Monthly---------------------
		---Due from Deliverydate to StorageCalculation Date.	
		IF @strStorageRate = 'Monthly'
		BEGIN
			SELECT @intSchedulePeriodId = MIN(intSchedulePeriodId)
			FROM @StorageSchedulePeriods
		
			WHILE @intSchedulePeriodId > 0 AND @intTotalMonthsApplicableForStorageCharge > 0
			BEGIN
				SET @intPeriodNumber= NULL
				SET @strPeriodType	= NULL
				SET @dtmStartDate	= NULL
				SET @dtmEndingDate	= NULL
				SET @intNumberOfDays= NULL
				SET @dblStorageRate	= NULL
				SET @dblFeeRate		= NULL
				SET @strFeeType		= NULL
		
				SELECT 
					 @intPeriodNumber		= intPeriodNumber
					,@strPeriodType			= strPeriodType
					,@dtmStartDate			= dtmStartDate
					,@dtmEndingDate			= dtmEndingDate
					,@intNumberOfDays		= ISNULL(intNumberOfDays, 0)
					,@dblStorageRate		= dblStorageRate
					,@dblFeeRate		    = dblFeeRate
					,@strFeeType			= ISNULL(strFeeType,'')
				FROM @StorageSchedulePeriods
				WHERE intSchedulePeriodId = @intSchedulePeriodId
			
				IF  @strFeeType = 'Flat' 
				BEGIN
					SET @dblFlatFeeTotal = CASE WHEN (@dtmFlatFeeCalcFromDate IS NULL) OR (@dtmDeliveryDate > @dtmFlatFeeCalcFromDate) THEN ISNULL(@dblFlatFeeTotal, 0) + @dblFeeRate END
				END

				IF @strPeriodType = 'Period Range'
				BEGIN					
					IF @dtmStartDate IS NULL AND @dtmEndingDate IS NOT NULL --CASE 1.Start Date = Blank ,Ending Date < > Blank	
					BEGIN
						SET @dtmEndingDate = CASE WHEN @dtmEndingDate > @dtmCalculationDate THEN @dtmCalculationDate ELSE @dtmEndingDate END

						IF (DATEDIFF(DAY, @dtmDeliveryDate, @dtmEndingDate) + 1) > 0
						BEGIN							
							IF @intTotalOrigMonthsApplicableForStorageCharge = 1 --When calculation Date is Same month of Delivery date.
							BEGIN
								SELECT @dblStorageDuePerUnit = ISNULL(@dblStorageDuePerUnit, 0)
																+ (CASE 
																		WHEN @ysnFirstMonthFullChargeApplicable = 1 THEN @dblStorageRate 
																		ELSE (@dblStorageRate / DATEDIFF(dd,@dtmDeliveryDate,DATEADD(m,1,@dtmDeliveryDate))) * (DATEDIFF(DAY, @dtmDeliveryDate, @dtmCalculationDate) + 1)
																   END)
																+ (CASE WHEN @strFeeType = 'Per Unit' THEN @dblFeeRate ELSE 0 END)

								SET @intTotalMonthsApplicableForStorageCharge = @intTotalMonthsApplicableForStorageCharge - 1					
								SET @dtmDeliveryDate = CASE 
														 WHEN @ysnFirstMonthFullChargeApplicable = 1 THEN DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmDeliveryDate) + 1, 0)) + 1 
														 ELSE @dtmCalculationDate + 1
													  END
							END
							ELSE
							BEGIN
								IF @intTotalOrigMonthsApplicableForStorageCharge = @intTotalMonthsApplicableForStorageCharge
								BEGIN
									---First Month Charge
									SELECT @dblStorageDuePerUnit = ISNULL(@dblStorageDuePerUnit, 0) 
																	+ (CASE 
																		  WHEN @ysnFirstMonthFullChargeApplicable = 1 THEN @dblStorageRate 
																		  ELSE (@dblStorageRate / DATEDIFF(dd,@dtmDeliveryDate,DATEADD(m,1,@dtmDeliveryDate))) * (DATEDIFF(DAY, @dtmDeliveryDate, DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmDeliveryDate) + 1, 0))) + 1)
																	   END)
																	+ (CASE WHEN @strFeeType = 'Per Unit' THEN @dblFeeRate ELSE 0 END)

									SET @intTotalMonthsApplicableForStorageCharge = @intTotalMonthsApplicableForStorageCharge - 1
									SET @dtmDeliveryDate = DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmDeliveryDate) + 1, 0)) + 1
													  
									IF (DATEDIFF(DAY, @dtmDeliveryDate, @dtmEndingDate) + 1) > 0
									BEGIN
										IF @dtmCalculationDate > @dtmEndingDate
										BEGIN
											---Intermediate Month Charges
											SELECT @dblStorageDuePerUnit = ISNULL(@dblStorageDuePerUnit, 0) 
																			+ (@dblStorageRate * (DATEDIFF(MONTH, @dtmDeliveryDate, @dtmEndingDate) + 1))
																			+ (CASE WHEN @strFeeType = 'Per Unit' THEN @dblFeeRate ELSE 0 END)
																	    																															
											SET @intTotalMonthsApplicableForStorageCharge = @intTotalMonthsApplicableForStorageCharge - (DATEDIFF(MONTH, @dtmDeliveryDate, @dtmEndingDate) + 1)
											SET @dtmDeliveryDate = DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmEndingDate) + 1, 0)) + 1
										END
										ELSE
										BEGIN
											--Intermediate Month charges
											SELECT @dblStorageDuePerUnit = ISNULL(@dblStorageDuePerUnit, 0)
																		   + (@dblStorageRate * (DATEDIFF(MONTH, @dtmDeliveryDate, DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmCalculationDate), 0))) + 1))
																		   + (CASE WHEN @strFeeType = 'Per Unit' THEN @dblFeeRate ELSE 0 END)
																	   
											SET @intTotalMonthsApplicableForStorageCharge = @intTotalMonthsApplicableForStorageCharge - (DATEDIFF(MONTH, @dtmDeliveryDate, DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmCalculationDate), 0))) + 1)
											SET @dtmDeliveryDate = DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmCalculationDate), 0)) + 1

											--Last Month Charge
											SELECT @dblStorageDuePerUnit = ISNULL(@dblStorageDuePerUnit, 0) 
																			+ (CASE 
																				WHEN @strLastMonth = 'Full Month' THEN @dblStorageRate 
																				ELSE (@dblStorageRate/DATEDIFF(dd,@dtmDeliveryDate,DATEADD(m,1,@dtmDeliveryDate))) * (DATEDIFF(DAY, @dtmDeliveryDate, @dtmCalculationDate) + 1)
																			END)
																		  + (CASE WHEN @strFeeType = 'Per Unit' THEN @dblFeeRate ELSE 0 END)
																										   
											SET @intTotalMonthsApplicableForStorageCharge = @intTotalMonthsApplicableForStorageCharge - 1
											SET @dtmDeliveryDate = CASE 
																	 WHEN @strLastMonth = 'Full Month' THEN  DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmCalculationDate) + 1, 0)) + 1 
																	 ELSE @dtmCalculationDate + 1
																  END														  											
										END
									END
								END
								ELSE
								BEGIN
									IF (DATEDIFF(DAY, @dtmDeliveryDate, @dtmEndingDate) + 1) > 0
									BEGIN
										IF @dtmCalculationDate > @dtmEndingDate
										BEGIN
											---Intermediate Month Charges
											SELECT @dblStorageDuePerUnit = ISNULL(@dblStorageDuePerUnit, 0) 
																			+ (@dblStorageRate * (DATEDIFF(MONTH, @dtmDeliveryDate, @dtmEndingDate) + 1))
																			+ (CASE WHEN @strFeeType = 'Per Unit' THEN @dblFeeRate ELSE 0 END)

											SET @intTotalMonthsApplicableForStorageCharge = @intTotalMonthsApplicableForStorageCharge - (DATEDIFF(MONTH, @dtmDeliveryDate, @dtmEndingDate) + 1)
											SET @dtmDeliveryDate = DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmEndingDate) + 1, 0)) + 1
										END
										ELSE
										BEGIN
											--Intermediate Month charges
											SELECT @dblStorageDuePerUnit = ISNULL(@dblStorageDuePerUnit, 0) 
																			+ (@dblStorageRate * (DATEDIFF(MONTH, @dtmDeliveryDate, DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmCalculationDate), 0))) + 1))
																			+ (CASE WHEN @strFeeType = 'Per Unit' THEN @dblFeeRate ELSE 0 END)
											
											SET @intTotalMonthsApplicableForStorageCharge = @intTotalMonthsApplicableForStorageCharge - (DATEDIFF(MONTH, @dtmDeliveryDate, DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmCalculationDate), 0))) + 1)
											SET @dtmDeliveryDate = DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmCalculationDate), 0)) + 1

											--Last Month Charge
											SELECT @dblStorageDuePerUnit = ISNULL(@dblStorageDuePerUnit, 0) 
																			+ (CASE 
																				WHEN @strLastMonth = 'Full Month' THEN @dblStorageRate 
																				ELSE (@dblStorageRate/DATEDIFF(dd,@dtmDeliveryDate,DATEADD(m,1,@dtmDeliveryDate))) * (DATEDIFF(DAY, @dtmDeliveryDate, @dtmCalculationDate) + 1)
																			END)
																			+ (CASE WHEN @strFeeType = 'Per Unit' THEN @dblFeeRate ELSE 0 END)

											SET @intTotalMonthsApplicableForStorageCharge = @intTotalMonthsApplicableForStorageCharge - 1										
											SET @dtmDeliveryDate = CASE 
																	 WHEN @strLastMonth = 'Full Month' THEN  DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmCalculationDate) + 1, 0)) + 1 
																	 ELSE @dtmCalculationDate + 1
																  END
										END
									END
								END
							END
						END
					END
				
					--CASE 2.Start Date < > Blank, Ending Date = Blank
					ELSE IF @dtmStartDate IS NOT NULL AND @dtmEndingDate IS NULL
					BEGIN
						IF @dtmDeliveryDate > @dtmStartDate
							SET @dtmStartDate = @dtmDeliveryDate
						ELSE
						BEGIN
							SET @intTotalMonthsApplicableForStorageCharge = CASE 
																			 WHEN (@intTotalMonthsApplicableForStorageCharge - DATEDIFF(MONTH, @dtmDeliveryDate, @dtmStartDate)) < 0 THEN 0
																			 ELSE (@intTotalMonthsApplicableForStorageCharge - DATEDIFF(MONTH, @dtmDeliveryDate, @dtmStartDate))
																		 END
							SET @dtmDeliveryDate = @dtmStartDate
						END
					
						IF (DATEDIFF(DAY, @dtmStartDate, @dtmCalculationDate) + 1) > 0 AND @intTotalMonthsApplicableForStorageCharge > 0
						BEGIN						
							--When Storage calculation Date is Same month of Delivery date.
							IF @intTotalOrigMonthsApplicableForStorageCharge = 1
							BEGIN
								SELECT @dblStorageDuePerUnit = ISNULL(@dblStorageDuePerUnit, 0)
																+ (CASE 
																	WHEN @ysnFirstMonthFullChargeApplicable=1 THEN @dblStorageRate 
																	ELSE (@dblStorageRate/DATEDIFF(dd,@dtmDeliveryDate,DATEADD(m,1,@dtmDeliveryDate))) * (DATEDIFF(DAY, @dtmDeliveryDate, @dtmCalculationDate) + 1)
																END)
															  + (CASE WHEN @strFeeType = 'Per Unit' THEN @dblFeeRate ELSE 0 END)
							
								SET @intTotalMonthsApplicableForStorageCharge = @intTotalMonthsApplicableForStorageCharge - 1
								SET @dtmDeliveryDate = CASE 
														 WHEN @ysnFirstMonthFullChargeApplicable=1 THEN  DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmDeliveryDate) + 1, 0)) + 1 
														 ELSE @dtmCalculationDate + 1
													  END
							END
							ELSE
							BEGIN
								IF @intTotalOrigMonthsApplicableForStorageCharge = @intTotalMonthsApplicableForStorageCharge
								BEGIN
									---First Month Charge
									IF @strFirstMonth = 'Full Month'
									BEGIN
										SELECT @dblStorageDuePerUnit = ISNULL(@dblStorageDuePerUnit, 0) + @dblStorageRate
																	  + (CASE WHEN @strFeeType = 'Per Unit' THEN @dblFeeRate ELSE 0 END)

										SET @intTotalMonthsApplicableForStorageCharge = @intTotalMonthsApplicableForStorageCharge - 1
										SET @dtmDeliveryDate = DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmDeliveryDate) + 1, 0)) + 1
									END
									ELSE
									BEGIN									
										SELECT @dblStorageDuePerUnit = ISNULL(@dblStorageDuePerUnit, 0) 
																		+ (@dblStorageRate / DATEDIFF(dd,@dtmDeliveryDate,DATEADD(m,1,@dtmDeliveryDate))) * (DATEDIFF(DAY, @dtmDeliveryDate, DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmDeliveryDate) + 1, 0))) + 1)
																		+ (CASE WHEN @strFeeType = 'Per Unit' THEN @dblFeeRate ELSE 0 END)

										SET @intTotalMonthsApplicableForStorageCharge = @intTotalMonthsApplicableForStorageCharge - 1
										SET @dtmDeliveryDate = DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmDeliveryDate) + 1, 0)) + 1
									END
								
									---Intermediate and Last Month Charges
									IF (DATEDIFF(DAY, @dtmDeliveryDate, @dtmCalculationDate) + 1) > 0
									BEGIN								
										IF @intTotalMonthsApplicableForStorageCharge > 1
										BEGIN									
											--Intermediate Month charges
											SELECT @dblStorageDuePerUnit = ISNULL(@dblStorageDuePerUnit, 0) 
																			+ (@dblStorageRate * (DATEDIFF(MONTH, @dtmDeliveryDate, DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmCalculationDate), 0))) + 1))
																			+ (CASE WHEN @strFeeType = 'Per Unit' THEN @dblFeeRate ELSE 0 END)

											SET @intTotalMonthsApplicableForStorageCharge = @intTotalMonthsApplicableForStorageCharge - (DATEDIFF(MONTH, @dtmDeliveryDate, DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmCalculationDate), 0))) + 1)
											SET @dtmDeliveryDate = DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmCalculationDate), 0)) + 1

											--Last Month Charge
											IF @strLastMonth = 'Full Month'
											BEGIN
												SELECT @dblStorageDuePerUnit = ISNULL(@dblStorageDuePerUnit, 0) + @dblStorageRate
																			  + (CASE WHEN @strFeeType = 'Per Unit' THEN @dblFeeRate ELSE 0 END)

												SET @intTotalMonthsApplicableForStorageCharge = @intTotalMonthsApplicableForStorageCharge - 1
												SET @dtmDeliveryDate = DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmCalculationDate) + 1, 0)) + 1
											END
											ELSE
											BEGIN
												SELECT @dblStorageDuePerUnit = ISNULL(@dblStorageDuePerUnit, 0) + (@dblStorageRate/DATEDIFF(dd,@dtmDeliveryDate,DATEADD(m,1,@dtmDeliveryDate))) * (DATEDIFF(DAY, @dtmDeliveryDate, @dtmCalculationDate) + 1)
																			  + (CASE WHEN @strFeeType = 'Per Unit' THEN @dblFeeRate ELSE 0 END)

												SET @intTotalMonthsApplicableForStorageCharge = @intTotalMonthsApplicableForStorageCharge - 1
												SET @dtmDeliveryDate = @dtmCalculationDate + 1
											END
										END
										ELSE
										BEGIN
											--Last Month Charge
											IF @strLastMonth = 'Full Month'
											BEGIN
												SELECT @dblStorageDuePerUnit = ISNULL(@dblStorageDuePerUnit, 0) + @dblStorageRate
																			  + (CASE WHEN @strFeeType = 'Per Unit' THEN @dblFeeRate ELSE 0 END)

												SET @intTotalMonthsApplicableForStorageCharge = @intTotalMonthsApplicableForStorageCharge - 1
												SET @dtmDeliveryDate = DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmCalculationDate) + 1, 0)) + 1
											END
											ELSE
											BEGIN
												SELECT @dblStorageDuePerUnit = ISNULL(@dblStorageDuePerUnit, 0) 
																				+ (@dblStorageRate/DATEDIFF(dd,@dtmDeliveryDate,DATEADD(m,1,@dtmDeliveryDate))) * (DATEDIFF(DAY, @dtmDeliveryDate, @dtmCalculationDate) + 1)
																				+ (CASE WHEN @strFeeType = 'Per Unit' THEN @dblFeeRate ELSE 0 END)

												SET @intTotalMonthsApplicableForStorageCharge = @intTotalMonthsApplicableForStorageCharge - 1
												SET @dtmDeliveryDate = @dtmCalculationDate + 1
											END	
										END	
									END
								END
								ELSE
								BEGIN
									---Intermediate and Last Month Charges
									IF (DATEDIFF(DAY, @dtmDeliveryDate, @dtmCalculationDate) + 1) > 0
									BEGIN
								
										IF @intTotalMonthsApplicableForStorageCharge > 1
										BEGIN									
											--Intermediate Month charges
											SELECT @dblStorageDuePerUnit = ISNULL(@dblStorageDuePerUnit, 0) 
																			+ (@dblStorageRate * (DATEDIFF(MONTH, @dtmDeliveryDate, DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmCalculationDate), 0))) + 1))
																			+ (CASE WHEN @strFeeType = 'Per Unit' THEN @dblFeeRate ELSE 0 END)

											SET @intTotalMonthsApplicableForStorageCharge = @intTotalMonthsApplicableForStorageCharge - (DATEDIFF(MONTH, @dtmDeliveryDate, DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmCalculationDate), 0))) + 1)
											SET @dtmDeliveryDate = DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmCalculationDate), 0)) + 1

											--Last Month Charge
											IF @strLastMonth = 'Full Month'
											BEGIN
												SELECT @dblStorageDuePerUnit = ISNULL(@dblStorageDuePerUnit, 0) + @dblStorageRate
																			  + CASE WHEN @strFeeType = 'Per Unit' THEN @dblFeeRate ELSE 0 END

												SET @intTotalMonthsApplicableForStorageCharge = @intTotalMonthsApplicableForStorageCharge - 1
												SET @dtmDeliveryDate = DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmCalculationDate) + 1, 0)) + 1
											END
											ELSE
											BEGIN
												SELECT @dblStorageDuePerUnit = ISNULL(@dblStorageDuePerUnit, 0) 
																				+ (@dblStorageRate/DATEDIFF(dd,@dtmDeliveryDate,DATEADD(m,1,@dtmDeliveryDate))) * (DATEDIFF(DAY, @dtmDeliveryDate, @dtmCalculationDate) + 1)
																				+ CASE WHEN @strFeeType = 'Per Unit' THEN @dblFeeRate ELSE 0 END

												SET @intTotalMonthsApplicableForStorageCharge = @intTotalMonthsApplicableForStorageCharge - 1
												SET @dtmDeliveryDate = @dtmCalculationDate + 1
											END
										END
										ELSE
										BEGIN
											--Last Month Charge
											IF @strLastMonth = 'Full Month'
											BEGIN
												SELECT @dblStorageDuePerUnit = ISNULL(@dblStorageDuePerUnit, 0) + @dblStorageRate
																			   + (CASE WHEN @strFeeType = 'Per Unit' THEN @dblFeeRate ELSE 0 END)

												SET @intTotalMonthsApplicableForStorageCharge = @intTotalMonthsApplicableForStorageCharge - 1
												SET @dtmDeliveryDate = DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmCalculationDate) + 1, 0)) + 1
											END
											ELSE
											BEGIN
												SELECT @dblStorageDuePerUnit = ISNULL(@dblStorageDuePerUnit, 0) 
																				+ (@dblStorageRate/DATEDIFF(dd,@dtmDeliveryDate,DATEADD(m,1,@dtmDeliveryDate))) * (DATEDIFF(DAY, @dtmDeliveryDate, @dtmCalculationDate) + 1)
																				+ (CASE WHEN @strFeeType = 'Per Unit' THEN @dblFeeRate ELSE 0 END)

												SET @intTotalMonthsApplicableForStorageCharge = @intTotalMonthsApplicableForStorageCharge - 1
												SET @dtmDeliveryDate = @dtmCalculationDate + 1
											END	
										END	
									END
								END
							END					
						END
				
					END
				
					--CASE 3.Start Date < > Blank, Ending Date < > Blank			
					ELSE IF @dtmStartDate IS NOT NULL AND @dtmEndingDate IS NOT NULL
					BEGIN
						IF @dtmDeliveryDate > @dtmStartDate
							SET @dtmStartDate = @dtmDeliveryDate
						ELSE
						BEGIN
							SET @intTotalMonthsApplicableForStorageCharge = CASE 
																			 WHEN (@intTotalMonthsApplicableForStorageCharge - DATEDIFF(MONTH, @dtmDeliveryDate, @dtmStartDate)) < 0 THEN 0
																			 ELSE (@intTotalMonthsApplicableForStorageCharge - DATEDIFF(MONTH, @dtmDeliveryDate, @dtmStartDate))
																		 END
							SET @dtmDeliveryDate = @dtmStartDate
						END
						
						SET @dtmEndingDate = CASE WHEN @dtmEndingDate > @dtmCalculationDate THEN @dtmCalculationDate ELSE @dtmEndingDate END

						IF (DATEDIFF(DAY, @dtmStartDate, @dtmCalculationDate) + 1) > 0 AND ((DATEDIFF(DAY, @dtmDeliveryDate, @dtmEndingDate) + 1) > 0) AND @intTotalMonthsApplicableForStorageCharge > 0
						BEGIN					
							--When Storage calculation Date is Same month of Delivery date.
							IF @intTotalOrigMonthsApplicableForStorageCharge = 1
							BEGIN
								--When FirstMonth and Last Month not are Matching then Charge Full month
								IF @strFirstMonth <> @strLastMonth
								BEGIN
									SELECT @dblStorageDuePerUnit = ISNULL(@dblStorageDuePerUnit, 0) + @dblStorageRate + (CASE WHEN @strFeeType = 'Per Unit' THEN @dblFeeRate ELSE 0 END)

									SET @intTotalMonthsApplicableForStorageCharge = @intTotalMonthsApplicableForStorageCharge - 1
									SET @dtmDeliveryDate = DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmDeliveryDate) + 1, 0)) + 1
								END
								ELSE
								BEGIN
									IF @strFirstMonth = 'Full Month' AND @strLastMonth = 'Full Month'
									BEGIN
										SELECT @dblStorageDuePerUnit = ISNULL(@dblStorageDuePerUnit, 0) + @dblStorageRate + (CASE WHEN @strFeeType = 'Per Unit' THEN @dblFeeRate ELSE 0 END)

										SET @intTotalMonthsApplicableForStorageCharge = @intTotalMonthsApplicableForStorageCharge - 1
										SET @dtmDeliveryDate = DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmDeliveryDate) + 1, 0)) + 1
									END
									ELSE
									BEGIN
										SELECT @dblStorageDuePerUnit = ISNULL(@dblStorageDuePerUnit, 0) 
																		+ (@dblStorageRate/DATEDIFF(dd,@dtmDeliveryDate,DATEADD(m,1,@dtmDeliveryDate))) * (DATEDIFF(DAY, @dtmDeliveryDate, @dtmCalculationDate) + 1)
																		+ (CASE WHEN @strFeeType = 'Per Unit' THEN @dblFeeRate ELSE 0 END)
										
										SET @intTotalMonthsApplicableForStorageCharge = @intTotalMonthsApplicableForStorageCharge - 1
										SET @dtmDeliveryDate = DATEDIFF(DAY, @dtmDeliveryDate, @dtmCalculationDate) + 1 									
									END
								END
							END
							ELSE
							BEGIN
								IF @intTotalOrigMonthsApplicableForStorageCharge = @intTotalMonthsApplicableForStorageCharge
								BEGIN
									---First Month Charge
									IF @strFirstMonth = 'Full Month'
									BEGIN
										SELECT @dblStorageDuePerUnit = ISNULL(@dblStorageDuePerUnit, 0) + @dblStorageRate + (CASE WHEN @strFeeType = 'Per Unit' THEN @dblFeeRate ELSE 0 END)
										
										SET @intTotalMonthsApplicableForStorageCharge = @intTotalMonthsApplicableForStorageCharge - 1
										SET @dtmDeliveryDate = DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmDeliveryDate) + 1, 0)) + 1
									END
									ELSE
									BEGIN																	
										SELECT @dblStorageDuePerUnit = ISNULL(@dblStorageDuePerUnit, 0) 
																		+ (@dblStorageRate/DATEDIFF(dd,@dtmDeliveryDate,DATEADD(m,1,@dtmDeliveryDate))) * (DATEDIFF(DAY, @dtmDeliveryDate, DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmDeliveryDate) + 1, 0))) + 1)
																		+ (CASE WHEN @strFeeType = 'Per Unit' THEN @dblFeeRate ELSE 0 END)

										SET @intTotalMonthsApplicableForStorageCharge = @intTotalMonthsApplicableForStorageCharge - 1
										SET @dtmDeliveryDate = DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmDeliveryDate) + 1, 0)) + 1
									END

									IF (DATEDIFF(DAY, @dtmDeliveryDate, @dtmEndingDate) + 1) > 0
									BEGIN
										IF @dtmCalculationDate > @dtmEndingDate
										BEGIN
											---Intermediate Month Charges
											SELECT @dblStorageDuePerUnit = ISNULL(@dblStorageDuePerUnit, 0) 
																			+ (@dblStorageRate * (DATEDIFF(MONTH, @dtmDeliveryDate, @dtmEndingDate) + 1))
																			+ (CASE WHEN @strFeeType = 'Per Unit' THEN @dblFeeRate ELSE 0 END)

											SET @intTotalMonthsApplicableForStorageCharge = @intTotalMonthsApplicableForStorageCharge - (DATEDIFF(MONTH, @dtmDeliveryDate, @dtmEndingDate) + 1)
																							+ (CASE WHEN @strFeeType = 'Per Unit' THEN @dblFeeRate ELSE 0 END)
										
										
											SET @dtmDeliveryDate = DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmEndingDate) + 1, 0)) + 1
										END
										ELSE
										BEGIN
											--Intermediate Month charges
											SELECT @dblStorageDuePerUnit = ISNULL(@dblStorageDuePerUnit, 0) 
																			+ (@dblStorageRate * (DATEDIFF(MONTH, @dtmDeliveryDate, DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmCalculationDate), 0))) + 1))
																			+ (CASE WHEN @strFeeType = 'Per Unit' THEN @dblFeeRate ELSE 0 END)

											SET @intTotalMonthsApplicableForStorageCharge = @intTotalMonthsApplicableForStorageCharge - (DATEDIFF(MONTH, @dtmDeliveryDate, DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmCalculationDate), 0))) + 1)
											SET @dtmDeliveryDate = DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmCalculationDate), 0)) + 1

											--Last Month Charge
											IF @strLastMonth = 'Full Month'
											BEGIN
												SELECT @dblStorageDuePerUnit = ISNULL(@dblStorageDuePerUnit, 0) + @dblStorageRate + (CASE WHEN @strFeeType = 'Per Unit' THEN @dblFeeRate ELSE 0 END)
												
												SET @intTotalMonthsApplicableForStorageCharge = @intTotalMonthsApplicableForStorageCharge - 1
												SET @dtmDeliveryDate = DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmCalculationDate) + 1, 0)) + 1										
											END
											ELSE
											BEGIN
												SELECT @dblStorageDuePerUnit = ISNULL(@dblStorageDuePerUnit, 0) 
																			   + (@dblStorageRate/DATEDIFF(dd,@dtmDeliveryDate,DATEADD(m,1,@dtmDeliveryDate))) * (DATEDIFF(DAY, @dtmDeliveryDate, @dtmCalculationDate) + 1)
																			   + (CASE WHEN @strFeeType = 'Per Unit' THEN @dblFeeRate ELSE 0 END)

												SET @intTotalMonthsApplicableForStorageCharge = @intTotalMonthsApplicableForStorageCharge - 1
												SET @dtmDeliveryDate = @dtmCalculationDate + 1
											END
										END
									END
								END
								ELSE
								BEGIN
									IF (DATEDIFF(DAY, @dtmDeliveryDate, @dtmEndingDate) + 1) > 0
									BEGIN								    
										IF @dtmCalculationDate > @dtmEndingDate
										BEGIN
											---Intermediate Month Charges
											SELECT @dblStorageDuePerUnit = ISNULL(@dblStorageDuePerUnit, 0) 
																			+ (@dblStorageRate * (DATEDIFF(MONTH, @dtmDeliveryDate, @dtmEndingDate) + 1))
																			+ (CASE WHEN @strFeeType = 'Per Unit' THEN @dblFeeRate ELSE 0 END)

											SET @intTotalMonthsApplicableForStorageCharge = @intTotalMonthsApplicableForStorageCharge - (DATEDIFF(MONTH, @dtmDeliveryDate, @dtmEndingDate) + 1)
											SET @dtmDeliveryDate = DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmEndingDate) + 1, 0)) + 1
										END
										ELSE
										BEGIN
											--Intermediate Month charges
											SELECT @dblStorageDuePerUnit = ISNULL(@dblStorageDuePerUnit, 0)	
																			+ (@dblStorageRate * (DATEDIFF(MONTH, @dtmDeliveryDate, DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmCalculationDate), 0))) + 1))
																			+ (CASE WHEN @strFeeType = 'Per Unit' THEN @dblFeeRate ELSE 0 END)

											SET @intTotalMonthsApplicableForStorageCharge = @intTotalMonthsApplicableForStorageCharge - (DATEDIFF(MONTH, @dtmDeliveryDate, DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmCalculationDate), 0))) + 1)
											SET @dtmDeliveryDate = DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmCalculationDate), 0)) + 1

											--Last Month Charge										
											IF @strLastMonth = 'Full Month'
											BEGIN
												SELECT @dblStorageDuePerUnit = ISNULL(@dblStorageDuePerUnit, 0) + @dblStorageRate + (CASE WHEN @strFeeType = 'Per Unit' THEN @dblFeeRate ELSE 0 END)

												SET @intTotalMonthsApplicableForStorageCharge = @intTotalMonthsApplicableForStorageCharge - 1
												SET @dtmDeliveryDate = DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmCalculationDate) + 1, 0)) + 1										
											END
											ELSE
											BEGIN										
												SELECT @dblStorageDuePerUnit = ISNULL(@dblStorageDuePerUnit, 0) 
																				+ (@dblStorageRate/DATEDIFF(dd,@dtmDeliveryDate,DATEADD(m,1,@dtmDeliveryDate))) * (DATEDIFF(DAY, @dtmDeliveryDate, @dtmCalculationDate) + 1)
																				+ (CASE WHEN @strFeeType = 'Per Unit' THEN @dblFeeRate ELSE 0 END)

												SET @intTotalMonthsApplicableForStorageCharge = @intTotalMonthsApplicableForStorageCharge - 1
												SET @dtmDeliveryDate = @dtmCalculationDate + 1
											END
										END
									END
								END
							END
						END
					END
				END

				IF @strPeriodType = 'Thereafter'
				BEGIN
					IF @dtmStartDate IS NULL
					BEGIN
						--When Storage calculation Date is Same month of Delivery date.
						IF @intTotalOrigMonthsApplicableForStorageCharge = 1
						BEGIN
							--When FirstMonth and Last Month not are Matching then Charge Full month
							IF @strFirstMonth <> @strLastMonth
							BEGIN
								SELECT @dblStorageDuePerUnit = ISNULL(@dblStorageDuePerUnit, 0) + @dblStorageRate + (CASE WHEN @strFeeType = 'Per Unit' THEN @dblFeeRate ELSE 0 END)

								SET @intTotalMonthsApplicableForStorageCharge = @intTotalMonthsApplicableForStorageCharge - 1
								SET @dtmDeliveryDate = DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmDeliveryDate) + 1, 0)) + 1
							END
							ELSE
							BEGIN
								IF @strFirstMonth = 'Full Month' AND @strLastMonth = 'Full Month'
								BEGIN
									SELECT @dblStorageDuePerUnit = ISNULL(@dblStorageDuePerUnit, 0) + @dblStorageRate + (CASE WHEN @strFeeType = 'Per Unit' THEN @dblFeeRate ELSE 0 END)
									
									SET @intTotalMonthsApplicableForStorageCharge = @intTotalMonthsApplicableForStorageCharge - 1
									SET @dtmDeliveryDate = DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmDeliveryDate) + 1, 0)) + 1
								END
								ELSE
								BEGIN
									SELECT @dblStorageDuePerUnit = ISNULL(@dblStorageDuePerUnit, 0) 
																	+ (@dblStorageRate/DATEDIFF(dd,@dtmDeliveryDate,DATEADD(m,1,@dtmDeliveryDate))) * (DATEDIFF(DAY, @dtmDeliveryDate, @dtmCalculationDate) + 1)
																	+ (CASE WHEN @strFeeType = 'Per Unit' THEN @dblFeeRate ELSE 0 END)

									SET @intTotalMonthsApplicableForStorageCharge = @intTotalMonthsApplicableForStorageCharge - 1
									SET @dtmDeliveryDate = @dtmCalculationDate + 1
								END
							END
						END
						ELSE
						BEGIN
							IF @intTotalOrigMonthsApplicableForStorageCharge = @intTotalMonthsApplicableForStorageCharge
							BEGIN
								---First Month Charge
								IF @strFirstMonth = 'Full Month'
								BEGIN
									SELECT @dblStorageDuePerUnit = ISNULL(@dblStorageDuePerUnit, 0) + @dblStorageRate + (CASE WHEN @strFeeType = 'Per Unit' THEN @dblFeeRate ELSE 0 END)
									
									SET @intTotalMonthsApplicableForStorageCharge = @intTotalMonthsApplicableForStorageCharge - 1
									SET @dtmDeliveryDate = DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmDeliveryDate) + 1, 0)) + 1
								END
								ELSE
								BEGIN
									SELECT @dblStorageDuePerUnit = ISNULL(@dblStorageDuePerUnit, 0) 
																	+ (@dblStorageRate/DATEDIFF(dd,@dtmDeliveryDate,DATEADD(m,1,@dtmDeliveryDate))) * (DATEDIFF(DAY, @dtmDeliveryDate, DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmDeliveryDate) + 1, 0))) + 1)
																	+ (CASE WHEN @strFeeType = 'Per Unit' THEN @dblFeeRate ELSE 0 END)

									SET @intTotalMonthsApplicableForStorageCharge = @intTotalMonthsApplicableForStorageCharge - 1
									SET @dtmDeliveryDate = DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmDeliveryDate) + 1, 0)) + 1
								END

								IF (DATEDIFF(DAY, @dtmDeliveryDate, @dtmCalculationDate) + 1) > 0 AND @intTotalMonthsApplicableForStorageCharge > 0
								BEGIN
									--Intermediate Month charges
									SELECT @dblStorageDuePerUnit = ISNULL(@dblStorageDuePerUnit, 0) + @dblStorageRate * (DATEDIFF(MONTH, @dtmDeliveryDate, DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmCalculationDate), 0))) + 1)
																  + CASE WHEN @strFeeType = 'Per Unit' THEN @dblFeeRate ELSE 0 END
									
									SET @intTotalMonthsApplicableForStorageCharge = @intTotalMonthsApplicableForStorageCharge - (DATEDIFF(MONTH, @dtmDeliveryDate, DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmCalculationDate), 0))) + 1)
									SET @dtmDeliveryDate = DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmCalculationDate), 0)) + 1

									--Last Month Charge
									IF @strLastMonth = 'Full Month'
									BEGIN
										SELECT @dblStorageDuePerUnit = ISNULL(@dblStorageDuePerUnit, 0) + @dblStorageRate + (CASE WHEN @strFeeType = 'Per Unit' THEN @dblFeeRate ELSE 0 END)
										
										SET @intTotalMonthsApplicableForStorageCharge = @intTotalMonthsApplicableForStorageCharge - 1
										SET @dtmDeliveryDate = DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmCalculationDate) + 1, 0)) + 1
									END
									ELSE
									BEGIN
										SELECT @dblStorageDuePerUnit = ISNULL(@dblStorageDuePerUnit, 0) 
																		+ (@dblStorageRate/DATEDIFF(dd,@dtmDeliveryDate,DATEADD(m,1,@dtmDeliveryDate))) * (DATEDIFF(DAY, @dtmDeliveryDate, @dtmCalculationDate) + 1)
																		+ (CASE WHEN @strFeeType = 'Per Unit' THEN @dblFeeRate ELSE 0 END)
										
										SET @intTotalMonthsApplicableForStorageCharge = @intTotalMonthsApplicableForStorageCharge - 1
										SET @dtmDeliveryDate = @dtmCalculationDate + 1
									END
								END
							END
							ELSE
							BEGIN
								IF (DATEDIFF(DAY, @dtmDeliveryDate, @dtmCalculationDate) + 1) > 0
								BEGIN
									--Intermediate Month charges
									SELECT @dblStorageDuePerUnit = ISNULL(@dblStorageDuePerUnit, 0) 
																	+ (@dblStorageRate * (DATEDIFF(MONTH, @dtmDeliveryDate, DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmCalculationDate), 0))) + 1))
																	+ (CASE WHEN @strFeeType = 'Per Unit' THEN @dblFeeRate ELSE 0 END)

									SET @intTotalMonthsApplicableForStorageCharge = @intTotalMonthsApplicableForStorageCharge - (DATEDIFF(MONTH, @dtmDeliveryDate, DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmCalculationDate), 0))) + 1)
									SET @dtmDeliveryDate = DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmCalculationDate), 0)) + 1

									--Last Month Charge									
									IF @strLastMonth = 'Full Month'
									BEGIN
										SELECT @dblStorageDuePerUnit = ISNULL(@dblStorageDuePerUnit, 0) + @dblStorageRate + (CASE WHEN @strFeeType = 'Per Unit' THEN @dblFeeRate ELSE 0 END)
										
										SET @intTotalMonthsApplicableForStorageCharge = @intTotalMonthsApplicableForStorageCharge - 1
										SET @dtmDeliveryDate = DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmCalculationDate) + 1, 0)) + 1
									END
									ELSE
									BEGIN
										SELECT @dblStorageDuePerUnit = ISNULL(@dblStorageDuePerUnit, 0) 
																		+ (@dblStorageRate/DATEDIFF(dd,@dtmDeliveryDate,DATEADD(m,1,@dtmDeliveryDate))) * (DATEDIFF(DAY, @dtmDeliveryDate, @dtmCalculationDate) + 1)
																		+ (CASE WHEN @strFeeType = 'Per Unit' THEN @dblFeeRate ELSE 0 END)

										SET @intTotalMonthsApplicableForStorageCharge = @intTotalMonthsApplicableForStorageCharge - 1
										SET @dtmDeliveryDate = @dtmCalculationDate + 1
									END
								END
							END
						END
					END
					ELSE
					BEGIN					
						IF @dtmDeliveryDate > @dtmStartDate
							SET @dtmStartDate = @dtmDeliveryDate
						ELSE
						BEGIN
							SET @intTotalMonthsApplicableForStorageCharge = CASE 
																			 WHEN (@intTotalMonthsApplicableForStorageCharge - DATEDIFF(MONTH, @dtmDeliveryDate, @dtmStartDate)) < 0 THEN 0
																			 ELSE (@intTotalMonthsApplicableForStorageCharge - DATEDIFF(MONTH, @dtmDeliveryDate, @dtmStartDate))
																		 END
							SET @dtmDeliveryDate = @dtmStartDate
						END				
								
						IF (DATEDIFF(DAY, @dtmStartDate, @dtmCalculationDate) + 1) > 0 AND @intTotalMonthsApplicableForStorageCharge > 0
						BEGIN
							--When Storage calculation Date is Same month of Delivery date.
							IF @intTotalOrigMonthsApplicableForStorageCharge = 1
							BEGIN
								--When FirstMonth and Last Month not are Matching then Charge Full month
								IF @strFirstMonth <> @strLastMonth
								BEGIN
									SELECT @dblStorageDuePerUnit = ISNULL(@dblStorageDuePerUnit, 0) + @dblStorageRate + (CASE WHEN @strFeeType = 'Per Unit' THEN @dblFeeRate ELSE 0 END)
									
									SET @intTotalMonthsApplicableForStorageCharge = @intTotalMonthsApplicableForStorageCharge - 1								
									SET @dtmDeliveryDate = DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmDeliveryDate) + 1, 0)) + 1
								END
								ELSE
								BEGIN
									IF @strFirstMonth = 'Full Month' AND @strLastMonth = 'Full Month'
									BEGIN
										SELECT @dblStorageDuePerUnit = ISNULL(@dblStorageDuePerUnit, 0) + @dblStorageRate + (CASE WHEN @strFeeType = 'Per Unit' THEN @dblFeeRate ELSE 0 END)
										
										SET @intTotalMonthsApplicableForStorageCharge = @intTotalMonthsApplicableForStorageCharge - 1
										SET @dtmDeliveryDate = DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmDeliveryDate) + 1, 0)) + 1
									END
									ELSE
									BEGIN
										SELECT @dblStorageDuePerUnit = ISNULL(@dblStorageDuePerUnit, 0) 
																		+ (@dblStorageRate/DATEDIFF(dd,@dtmDeliveryDate,DATEADD(m,1,@dtmDeliveryDate))) * (DATEDIFF(DAY, @dtmDeliveryDate, DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmDeliveryDate) + 1, 0))) + 1)
																		+ (CASE WHEN @strFeeType = 'Per Unit' THEN @dblFeeRate ELSE 0 END)

										SET @intTotalMonthsApplicableForStorageCharge = @intTotalMonthsApplicableForStorageCharge - 1
										SET @dtmDeliveryDate = @dtmCalculationDate + 1
									END
								END
							END
							ELSE
							BEGIN
								IF @intTotalOrigMonthsApplicableForStorageCharge = @intTotalMonthsApplicableForStorageCharge
								BEGIN
									---First Month Charge
									IF @strFirstMonth = 'Full Month'
									BEGIN
										SELECT @dblStorageDuePerUnit = ISNULL(@dblStorageDuePerUnit, 0) + @dblStorageRate + (CASE WHEN @strFeeType = 'Per Unit' THEN @dblFeeRate ELSE 0 END)
										
										SET @intTotalMonthsApplicableForStorageCharge = @intTotalMonthsApplicableForStorageCharge - 1
										SET @dtmDeliveryDate = DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmDeliveryDate) + 1, 0)) + 1
									END
									ELSE
									BEGIN
										SELECT @dblStorageDuePerUnit = ISNULL(@dblStorageDuePerUnit, 0) 
																		+ (@dblStorageRate/DATEDIFF(dd,@dtmDeliveryDate,DATEADD(m,1,@dtmDeliveryDate))) * (DATEDIFF(DAY, @dtmDeliveryDate, DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmDeliveryDate) + 1, 0))) + 1)
																		+ (CASE WHEN @strFeeType = 'Per Unit' THEN @dblFeeRate ELSE 0 END)
										
										SET @intTotalMonthsApplicableForStorageCharge = @intTotalMonthsApplicableForStorageCharge - 1
										SET @dtmDeliveryDate = DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmDeliveryDate) + 1, 0)) + 1
									END
																	
									---Intermediate and Last Month Charges
									IF (DATEDIFF(DAY, @dtmDeliveryDate, @dtmCalculationDate) + 1) > 0
									BEGIN								
										IF @intTotalMonthsApplicableForStorageCharge > 1
										BEGIN									
											--Intermediate Month charges
											SELECT @dblStorageDuePerUnit = ISNULL(@dblStorageDuePerUnit, 0) 
																			+ (@dblStorageRate * (DATEDIFF(MONTH, @dtmDeliveryDate, DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmCalculationDate), 0))) + 1))
																			+ (CASE WHEN @strFeeType = 'Per Unit' THEN @dblFeeRate ELSE 0 END)

											SET @intTotalMonthsApplicableForStorageCharge = @intTotalMonthsApplicableForStorageCharge - (DATEDIFF(MONTH, @dtmDeliveryDate, DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmCalculationDate), 0))) + 1)
											SET @dtmDeliveryDate = DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmCalculationDate), 0)) + 1

											--Last Month Charge
											IF @strLastMonth = 'Full Month'
											BEGIN
												SELECT @dblStorageDuePerUnit = ISNULL(@dblStorageDuePerUnit, 0) + @dblStorageRate + (CASE WHEN @strFeeType = 'Per Unit' THEN @dblFeeRate ELSE 0 END)
												
												SET @intTotalMonthsApplicableForStorageCharge = @intTotalMonthsApplicableForStorageCharge - 1										
												SET @dtmDeliveryDate = DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmCalculationDate) + 1, 0)) + 1
											END
											ELSE
											BEGIN
												SELECT @dblStorageDuePerUnit = ISNULL(@dblStorageDuePerUnit, 0) 
																				+ (@dblStorageRate/DATEDIFF(dd,@dtmDeliveryDate,DATEADD(m,1,@dtmDeliveryDate))) * (DATEDIFF(DAY, @dtmDeliveryDate, @dtmCalculationDate) + 1)
																				+ (CASE WHEN @strFeeType = 'Per Unit' THEN @dblFeeRate ELSE 0 END)
												
												SET @intTotalMonthsApplicableForStorageCharge = @intTotalMonthsApplicableForStorageCharge - 1
												SET @dtmDeliveryDate = @dtmCalculationDate + 1
											END
										END
										ELSE
										BEGIN
											--Last Month Charge
											IF @strLastMonth = 'Full Month'
											BEGIN
												SELECT @dblStorageDuePerUnit = ISNULL(@dblStorageDuePerUnit, 0) + @dblStorageRate + (CASE WHEN @strFeeType = 'Per Unit' THEN @dblFeeRate ELSE 0 END)
												
												SET @intTotalMonthsApplicableForStorageCharge = @intTotalMonthsApplicableForStorageCharge - 1
												SET @dtmDeliveryDate = DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmCalculationDate) + 1, 0)) + 1
											END
											ELSE
											BEGIN
												SELECT @dblStorageDuePerUnit = ISNULL(@dblStorageDuePerUnit, 0) 
																				+ (@dblStorageRate/DATEDIFF(dd,@dtmDeliveryDate,DATEADD(m,1,@dtmDeliveryDate))) * (DATEDIFF(DAY, @dtmDeliveryDate, @dtmCalculationDate) + 1)
																				+ CASE WHEN @strFeeType = 'Per Unit' THEN @dblFeeRate ELSE 0 END

												SET @intTotalMonthsApplicableForStorageCharge = @intTotalMonthsApplicableForStorageCharge - 1
												SET @dtmDeliveryDate = @dtmCalculationDate + 1
											END	
										END	
									END
								END
								ELSE
								BEGIN
									---Intermediate and Last Month Charges
									IF (DATEDIFF(DAY, @dtmDeliveryDate, @dtmCalculationDate) + 1) > 0
									BEGIN
								
										IF @intTotalMonthsApplicableForStorageCharge > 1
										BEGIN									
											--Intermediate Month charges
											SELECT @dblStorageDuePerUnit = ISNULL(@dblStorageDuePerUnit, 0) 
																			+ (@dblStorageRate * (DATEDIFF(MONTH, @dtmDeliveryDate, DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmCalculationDate), 0))) + 1))
																			+ (CASE WHEN @strFeeType = 'Per Unit' THEN @dblFeeRate ELSE 0 END)

											SET @intTotalMonthsApplicableForStorageCharge = @intTotalMonthsApplicableForStorageCharge - (DATEDIFF(MONTH, @dtmDeliveryDate, DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmCalculationDate), 0))) + 1)
											SET @dtmDeliveryDate = DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmCalculationDate), 0)) + 1

											--Last Month Charge
											IF @strLastMonth = 'Full Month'
											BEGIN
												SELECT @dblStorageDuePerUnit = ISNULL(@dblStorageDuePerUnit, 0) + @dblStorageRate +(CASE WHEN @strFeeType = 'Per Unit' THEN @dblFeeRate ELSE 0 END)
												
												SET @intTotalMonthsApplicableForStorageCharge = @intTotalMonthsApplicableForStorageCharge - 1
												SET @dtmDeliveryDate = DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmCalculationDate) + 1, 0)) + 1
											END
											ELSE
											BEGIN
												SELECT @dblStorageDuePerUnit = ISNULL(@dblStorageDuePerUnit, 0) 
																				+ (@dblStorageRate/DATEDIFF(dd,@dtmDeliveryDate,DATEADD(m,1,@dtmDeliveryDate))) * (DATEDIFF(DAY, @dtmDeliveryDate, @dtmCalculationDate) + 1)
																				+ (CASE WHEN @strFeeType = 'Per Unit' THEN @dblFeeRate ELSE 0 END)

												SET @intTotalMonthsApplicableForStorageCharge = @intTotalMonthsApplicableForStorageCharge - 1											
												SET @dtmDeliveryDate = @dtmCalculationDate + 1
											END
										END
										ELSE
										BEGIN
											--Last Month Charge
											IF @strLastMonth = 'Full Month'
											BEGIN
												SELECT @dblStorageDuePerUnit = ISNULL(@dblStorageDuePerUnit, 0) + @dblStorageRate + (CASE WHEN @strFeeType = 'Per Unit' THEN @dblFeeRate ELSE 0 END)

												SET @intTotalMonthsApplicableForStorageCharge = @intTotalMonthsApplicableForStorageCharge - 1
												SET @dtmDeliveryDate = DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmCalculationDate) + 1, 0)) + 1
											END
											ELSE
											BEGIN
												SELECT @dblStorageDuePerUnit = ISNULL(@dblStorageDuePerUnit, 0) 
																				+ (@dblStorageRate/DATEDIFF(dd,@dtmDeliveryDate,DATEADD(m,1,@dtmDeliveryDate))) * (DATEDIFF(DAY, @dtmDeliveryDate, @dtmCalculationDate) + 1)
																				+ (CASE WHEN @strFeeType = 'Per Unit' THEN @dblFeeRate ELSE 0 END)

												SET @intTotalMonthsApplicableForStorageCharge = @intTotalMonthsApplicableForStorageCharge - 1
												SET @dtmDeliveryDate = @dtmCalculationDate + 1
											END	
										END	
									END
								END
							END	
						END
					
					END
				END
			
				SELECT @intSchedulePeriodId = MIN(intSchedulePeriodId)
				FROM @StorageSchedulePeriods
				WHERE intSchedulePeriodId > @intSchedulePeriodId
			END
		END
		
		---Due from Deliverydate to Last Storage Accrue Date.
		IF @strStorageRate = 'Monthly'
		BEGIN
			SET @dtmDeliveryDate = @dtmOrigDeliveryDate
		
			SELECT @intTotalMonthsApplicableForStorageCharge = DATEDIFF(MONTH, @dtmDeliveryDate, @dtmLastStorageAccrueDate) + 1
			SET @intTotalOrigMonthsApplicableForStorageCharge = @intTotalMonthsApplicableForStorageCharge
		
			SELECT @intSchedulePeriodId = MIN(intSchedulePeriodId)
			FROM @StorageSchedulePeriods		

			WHILE @intSchedulePeriodId > 0 AND @intTotalMonthsApplicableForStorageCharge > 0
			BEGIN
				SET @intPeriodNumber    = NULL
				SET @strPeriodType      = NULL
				SET @dtmStartDate		= NULL
				SET @dtmEndingDate      = NULL
				SET @intNumberOfDays    = NULL
				SET @dblStorageRate     = NULL
		
				SELECT 
					 @intPeriodNumber	    = intPeriodNumber
					,@strPeriodType			= strPeriodType
					,@dtmStartDate			= dtmStartDate
					,@dtmEndingDate			= dtmEndingDate
					,@intNumberOfDays		= ISNULL(intNumberOfDays, 0)
					,@dblStorageRate		= CASE 
									  			WHEN ISNULL(strFeeType,'')='Flat'      THEN dblStorageRate 
									  			WHEN ISNULL(strFeeType,'')='Per Unit'  THEN dblStorageRate + dblFeeRate
											  END
				FROM @StorageSchedulePeriods
				WHERE intSchedulePeriodId = @intSchedulePeriodId
			
				--Period Range			
				IF @strPeriodType = 'Period Range'
				BEGIN
					--CASE 1.Start Date = Blank ,Ending Date < > Blank	
					IF @dtmStartDate IS NULL AND @dtmEndingDate IS NOT NULL
					BEGIN
						SET @dtmEndingDate = CASE WHEN @dtmEndingDate > @dtmLastStorageAccrueDate THEN @dtmLastStorageAccrueDate ELSE @dtmEndingDate END

						IF (DATEDIFF(DAY, @dtmDeliveryDate, @dtmEndingDate) + 1) > 0
						BEGIN
							--When Storage calculation Date is Same month of Delivery date.
							IF @intTotalOrigMonthsApplicableForStorageCharge = 1
							BEGIN						
								SELECT @dblStorageDuePerUnit = ISNULL(@dblStorageDuePerUnit, 0)
																- (CASE 
																	WHEN  @ysnFirstMonthFullChargeApplicable=1 THEN @dblStorageRate 
																	ELSE  (@dblStorageRate/DATEDIFF(dd,@dtmDeliveryDate,DATEADD(m,1,@dtmDeliveryDate))) * (DATEDIFF(DAY, @dtmDeliveryDate, DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmDeliveryDate) + 1, 0))) + 1)
																END)
																- (CASE WHEN @strFeeType = 'Per Unit' THEN @dblFeeRate ELSE 0 END)

								SET @intTotalMonthsApplicableForStorageCharge = @intTotalMonthsApplicableForStorageCharge - 1
								SET @dtmDeliveryDate = CASE 
														 WHEN @ysnFirstMonthFullChargeApplicable=1 THEN  DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmDeliveryDate) + 1, 0)) + 1 
														 ELSE @dtmLastStorageAccrueDate + 1
													  END							
							
							END
							ELSE
							BEGIN
								IF @intTotalOrigMonthsApplicableForStorageCharge = @intTotalMonthsApplicableForStorageCharge
								BEGIN
									---First Month Charge
									SELECT @dblStorageDuePerUnit = ISNULL(@dblStorageDuePerUnit, 0) 
																	- (CASE 
																			WHEN @ysnFirstMonthFullChargeApplicable=1 THEN @dblStorageRate 
																			ELSE (@dblStorageRate/DATEDIFF(dd,@dtmDeliveryDate,DATEADD(m,1,@dtmDeliveryDate))) * (DATEDIFF(DAY, @dtmDeliveryDate, DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmDeliveryDate) + 1, 0))) + 1)
																	  END)
																	- (CASE WHEN @strFeeType = 'Per Unit' THEN @dblFeeRate ELSE 0 END)
																  
									SET @intTotalMonthsApplicableForStorageCharge = @intTotalMonthsApplicableForStorageCharge - 1
									SET @dtmDeliveryDate =DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmDeliveryDate) + 1, 0)) + 1	
													  
									IF (DATEDIFF(DAY, @dtmDeliveryDate, @dtmEndingDate) + 1) > 0
									BEGIN
										IF @dtmLastStorageAccrueDate > @dtmEndingDate
										BEGIN
											---Intermediate Month Charges
											SELECT @dblStorageDuePerUnit = ISNULL(@dblStorageDuePerUnit, 0) 
																			- (@dblStorageRate * (DATEDIFF(MONTH, @dtmDeliveryDate, @dtmEndingDate) + 1))
																			- (CASE WHEN @strFeeType = 'Per Unit' THEN @dblFeeRate ELSE 0 END)

											SET @intTotalMonthsApplicableForStorageCharge = @intTotalMonthsApplicableForStorageCharge - (DATEDIFF(MONTH, @dtmDeliveryDate, @dtmEndingDate) + 1)										
											SET @dtmDeliveryDate = DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmEndingDate) + 1, 0)) + 1
										END
										ELSE
										BEGIN
											--Intermediate Month charges
											SELECT @dblStorageDuePerUnit = ISNULL(@dblStorageDuePerUnit, 0) 
																			- (@dblStorageRate * (DATEDIFF(MONTH, @dtmDeliveryDate, DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmLastStorageAccrueDate), 0))) + 1))
																			- (CASE WHEN @strFeeType = 'Per Unit' THEN @dblFeeRate ELSE 0 END)

											SET @intTotalMonthsApplicableForStorageCharge = @intTotalMonthsApplicableForStorageCharge - (DATEDIFF(MONTH, @dtmDeliveryDate, DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmLastStorageAccrueDate), 0))) + 1)
											SET @dtmDeliveryDate = DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmLastStorageAccrueDate), 0)) + 1

											--Last Month Charge
											SELECT @dblStorageDuePerUnit = ISNULL(@dblStorageDuePerUnit, 0) 
																			- (CASE 
																				WHEN @strLastMonth = 'Full Month' THEN  @dblStorageRate 
																				ELSE  (@dblStorageRate/DATEDIFF(dd,@dtmDeliveryDate,DATEADD(m,1,@dtmDeliveryDate))) * (DATEDIFF(DAY, @dtmDeliveryDate, @dtmLastStorageAccrueDate) + 1)
																			END)
																		  - (CASE WHEN @strFeeType = 'Per Unit' THEN @dblFeeRate ELSE 0 END)
																										  
											SET @intTotalMonthsApplicableForStorageCharge = @intTotalMonthsApplicableForStorageCharge - 1
											SET @dtmDeliveryDate = CASE 
																	 WHEN @strLastMonth = 'Full Month' THEN  DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmLastStorageAccrueDate) + 1, 0)) + 1 
																	 ELSE @dtmLastStorageAccrueDate + 1
																  END
															  											
										END
									END
								END
								ELSE
								BEGIN
									IF (DATEDIFF(DAY, @dtmDeliveryDate, @dtmEndingDate) + 1) > 0
									BEGIN
										IF @dtmLastStorageAccrueDate > @dtmEndingDate
										BEGIN
											---Intermediate Month Charges
											SELECT @dblStorageDuePerUnit = ISNULL(@dblStorageDuePerUnit, 0) 
																			- (@dblStorageRate * (DATEDIFF(MONTH, @dtmDeliveryDate, @dtmEndingDate) + 1))
																			- (CASE WHEN @strFeeType = 'Per Unit' THEN @dblFeeRate ELSE 0 END)

											SET @intTotalMonthsApplicableForStorageCharge = @intTotalMonthsApplicableForStorageCharge - (DATEDIFF(MONTH, @dtmDeliveryDate, @dtmEndingDate) + 1)
											SET @dtmDeliveryDate = DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmEndingDate) + 1, 0)) + 1
										END
										ELSE
										BEGIN
											--Intermediate Month charges
											SELECT @dblStorageDuePerUnit = ISNULL(@dblStorageDuePerUnit, 0) 
																			- (@dblStorageRate * (DATEDIFF(MONTH, @dtmDeliveryDate, DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmLastStorageAccrueDate), 0))) + 1))
																			- (CASE WHEN @strFeeType = 'Per Unit' THEN @dblFeeRate ELSE 0 END)

											SET @intTotalMonthsApplicableForStorageCharge = @intTotalMonthsApplicableForStorageCharge - (DATEDIFF(MONTH, @dtmDeliveryDate, DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmLastStorageAccrueDate), 0))) + 1)
											SET @dtmDeliveryDate = DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmLastStorageAccrueDate), 0)) + 1

											--Last Month Charge
											SELECT @dblStorageDuePerUnit = ISNULL(@dblStorageDuePerUnit, 0) 
																			- (CASE 
																				WHEN @strLastMonth = 'Full Month' THEN @dblStorageRate 
																				ELSE (@dblStorageRate/DATEDIFF(dd,@dtmDeliveryDate,DATEADD(m,1,@dtmDeliveryDate))) * (DATEDIFF(DAY, @dtmDeliveryDate, @dtmLastStorageAccrueDate) + 1)
																			END)
																		 - (CASE WHEN @strFeeType = 'Per Unit' THEN @dblFeeRate ELSE 0 END)

											SET @intTotalMonthsApplicableForStorageCharge = @intTotalMonthsApplicableForStorageCharge - 1										
											SET @dtmDeliveryDate = CASE 
																	 WHEN @strLastMonth = 'Full Month' THEN  DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmLastStorageAccrueDate) + 1, 0)) + 1 
																	 ELSE @dtmLastStorageAccrueDate + 1
																  END
										END
									END
								END
							END
						END
					END
				
					--CASE 2.Start Date < > Blank, Ending Date = Blank
					ELSE IF @dtmStartDate IS NOT NULL AND @dtmEndingDate IS NULL
					BEGIN
						IF @dtmDeliveryDate > @dtmStartDate
							SET @dtmStartDate = @dtmDeliveryDate
						ELSE
						BEGIN
							SET @intTotalMonthsApplicableForStorageCharge = CASE 
																			 WHEN (@intTotalMonthsApplicableForStorageCharge - DATEDIFF(MONTH, @dtmDeliveryDate, @dtmStartDate)) < 0 THEN 0
																			 ELSE (@intTotalMonthsApplicableForStorageCharge - DATEDIFF(MONTH, @dtmDeliveryDate, @dtmStartDate))
																		 END
							SET @dtmDeliveryDate = @dtmStartDate
						END
					
						IF (DATEDIFF(DAY, @dtmStartDate, @dtmLastStorageAccrueDate) + 1) > 0 AND @intTotalMonthsApplicableForStorageCharge > 0
						BEGIN						
							--When Storage calculation Date is Same month of Delivery date.
							IF @intTotalOrigMonthsApplicableForStorageCharge = 1
							BEGIN
								SELECT @dblStorageDuePerUnit = ISNULL(@dblStorageDuePerUnit, 0) 
																- (CASE 
																	  WHEN @ysnFirstMonthFullChargeApplicable=1 THEN @dblStorageRate 
																	  ELSE (@dblStorageRate/DATEDIFF(dd,@dtmDeliveryDate,DATEADD(m,1,@dtmDeliveryDate))) * (DATEDIFF(DAY, @dtmDeliveryDate, DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmDeliveryDate) + 1, 0))) + 1)
																  END)
																- (CASE WHEN @strFeeType = 'Per Unit' THEN @dblFeeRate ELSE 0 END)
							
								SET @intTotalMonthsApplicableForStorageCharge = @intTotalMonthsApplicableForStorageCharge - 1
								SET @dtmDeliveryDate = CASE 
														 WHEN @ysnFirstMonthFullChargeApplicable=1 THEN  DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmDeliveryDate) + 1, 0)) + 1 
														 ELSE @dtmLastStorageAccrueDate + 1
													  END
							END
							ELSE
							BEGIN
								IF @intTotalOrigMonthsApplicableForStorageCharge = @intTotalMonthsApplicableForStorageCharge
								BEGIN
									---First Month Charge
									IF @strFirstMonth = 'Full Month'
									BEGIN
										SELECT @dblStorageDuePerUnit = ISNULL(@dblStorageDuePerUnit, 0) - @dblStorageRate - (CASE WHEN @strFeeType = 'Per Unit' THEN @dblFeeRate ELSE 0 END)
										
										SET @intTotalMonthsApplicableForStorageCharge = @intTotalMonthsApplicableForStorageCharge - 1
										SET @dtmDeliveryDate = DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmDeliveryDate) + 1, 0)) + 1
									END
									ELSE
									BEGIN
										SELECT @dblStorageDuePerUnit = ISNULL(@dblStorageDuePerUnit, 0) 
																		- (@dblStorageRate/DATEDIFF(dd,@dtmDeliveryDate,DATEADD(m,1,@dtmDeliveryDate))) * (DATEDIFF(DAY, @dtmDeliveryDate, DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmDeliveryDate) + 1, 0))) + 1)
																		- (CASE WHEN @strFeeType = 'Per Unit' THEN @dblFeeRate ELSE 0 END)

										SET @intTotalMonthsApplicableForStorageCharge = @intTotalMonthsApplicableForStorageCharge - 1
										SET @dtmDeliveryDate = DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmDeliveryDate) + 1, 0)) + 1
									END
								
									---Intermediate and Last Month Charges
									IF (DATEDIFF(DAY, @dtmDeliveryDate, @dtmLastStorageAccrueDate) + 1) > 0
									BEGIN
								
										IF @intTotalMonthsApplicableForStorageCharge > 1
										BEGIN
											--Intermediate Month charges
											SELECT @dblStorageDuePerUnit = ISNULL(@dblStorageDuePerUnit, 0) 
																			- (@dblStorageRate * (DATEDIFF(MONTH, @dtmDeliveryDate, DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmLastStorageAccrueDate), 0))) + 1))
																			- (CASE WHEN @strFeeType = 'Per Unit' THEN @dblFeeRate ELSE 0 END)

											SET @intTotalMonthsApplicableForStorageCharge = @intTotalMonthsApplicableForStorageCharge - (DATEDIFF(MONTH, @dtmDeliveryDate, DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmLastStorageAccrueDate), 0))) + 1)
											SET @dtmDeliveryDate = DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmLastStorageAccrueDate), 0)) + 1

											--Last Month Charge
											IF @strLastMonth = 'Full Month'
											BEGIN
												SELECT @dblStorageDuePerUnit = ISNULL(@dblStorageDuePerUnit, 0) - @dblStorageRate - (CASE WHEN @strFeeType = 'Per Unit' THEN @dblFeeRate ELSE 0 END)

												SET @intTotalMonthsApplicableForStorageCharge = @intTotalMonthsApplicableForStorageCharge - 1
												SET @dtmDeliveryDate = DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmLastStorageAccrueDate) + 1, 0)) + 1
											END
											ELSE
											BEGIN
												SELECT @dblStorageDuePerUnit = ISNULL(@dblStorageDuePerUnit, 0) 
																				- (@dblStorageRate/DATEDIFF(dd,@dtmDeliveryDate,DATEADD(m,1,@dtmDeliveryDate))) * (DATEDIFF(DAY, @dtmDeliveryDate, @dtmLastStorageAccrueDate) + 1)
																				- (CASE WHEN @strFeeType = 'Per Unit' THEN @dblFeeRate ELSE 0 END)

												SET @intTotalMonthsApplicableForStorageCharge = @intTotalMonthsApplicableForStorageCharge - 1
												SET @dtmDeliveryDate = @dtmLastStorageAccrueDate + 1
											END
										END
										ELSE
										BEGIN
											--Last Month Charge
											IF @strLastMonth = 'Full Month'
											BEGIN
												SELECT @dblStorageDuePerUnit = ISNULL(@dblStorageDuePerUnit, 0) - @dblStorageRate - (CASE WHEN @strFeeType = 'Per Unit' THEN @dblFeeRate ELSE 0 END)
												
												SET @intTotalMonthsApplicableForStorageCharge = @intTotalMonthsApplicableForStorageCharge - 1
												SET @dtmDeliveryDate = DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmLastStorageAccrueDate) + 1, 0)) + 1
											END
											ELSE
											BEGIN
												SELECT @dblStorageDuePerUnit = ISNULL(@dblStorageDuePerUnit, 0)		
																				- (@dblStorageRate/DATEDIFF(dd,@dtmDeliveryDate,DATEADD(m,1,@dtmDeliveryDate))) * (DATEDIFF(DAY, @dtmDeliveryDate, @dtmLastStorageAccrueDate) + 1)
																				- (CASE WHEN @strFeeType = 'Per Unit' THEN @dblFeeRate ELSE 0 END)

												SET @intTotalMonthsApplicableForStorageCharge = @intTotalMonthsApplicableForStorageCharge - 1
												SET @dtmDeliveryDate = @dtmLastStorageAccrueDate + 1
											END	
										END	
									END
								END
								ELSE
								BEGIN
									---Intermediate and Last Month Charges
									IF (DATEDIFF(DAY, @dtmDeliveryDate, @dtmLastStorageAccrueDate) + 1) > 0
									BEGIN
								
										IF @intTotalMonthsApplicableForStorageCharge > 1
										BEGIN									
											--Intermediate Month charges
											SELECT @dblStorageDuePerUnit = ISNULL(@dblStorageDuePerUnit, 0) 
																			- (@dblStorageRate * (DATEDIFF(MONTH, @dtmDeliveryDate, DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmLastStorageAccrueDate), 0))) + 1))
																			- (CASE WHEN @strFeeType = 'Per Unit' THEN @dblFeeRate ELSE 0 END)

											SET @intTotalMonthsApplicableForStorageCharge = @intTotalMonthsApplicableForStorageCharge - (DATEDIFF(MONTH, @dtmDeliveryDate, DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmLastStorageAccrueDate), 0))) + 1)
											SET @dtmDeliveryDate = DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmLastStorageAccrueDate), 0)) + 1

											--Last Month Charge
											IF @strLastMonth = 'Full Month'
											BEGIN
												SELECT @dblStorageDuePerUnit = ISNULL(@dblStorageDuePerUnit, 0) - @dblStorageRate - (CASE WHEN @strFeeType = 'Per Unit' THEN @dblFeeRate ELSE 0 END)
												
												SET @intTotalMonthsApplicableForStorageCharge = @intTotalMonthsApplicableForStorageCharge - 1
												SET @dtmDeliveryDate = DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmLastStorageAccrueDate) + 1, 0)) + 1
											END
											ELSE
											BEGIN
												SELECT @dblStorageDuePerUnit = ISNULL(@dblStorageDuePerUnit, 0) 
																				- (@dblStorageRate/DATEDIFF(dd,@dtmDeliveryDate,DATEADD(m,1,@dtmDeliveryDate))) * (DATEDIFF(DAY, @dtmDeliveryDate, @dtmLastStorageAccrueDate) + 1)
																				- (CASE WHEN @strFeeType = 'Per Unit' THEN @dblFeeRate ELSE 0 END)

												SET @intTotalMonthsApplicableForStorageCharge = @intTotalMonthsApplicableForStorageCharge - 1
												SET @dtmDeliveryDate = @dtmLastStorageAccrueDate + 1
											END
										END
										ELSE
										BEGIN
											--Last Month Charge
											IF @strLastMonth = 'Full Month'
											BEGIN
												SELECT @dblStorageDuePerUnit = ISNULL(@dblStorageDuePerUnit, 0) - @dblStorageRate - (CASE WHEN @strFeeType = 'Per Unit' THEN @dblFeeRate ELSE 0 END)

												SET @intTotalMonthsApplicableForStorageCharge = @intTotalMonthsApplicableForStorageCharge - 1
												SET @dtmDeliveryDate = DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmLastStorageAccrueDate) + 1, 0)) + 1
											END
											ELSE
											BEGIN
												SELECT @dblStorageDuePerUnit = ISNULL(@dblStorageDuePerUnit, 0) 
																				- (@dblStorageRate/DATEDIFF(dd,@dtmDeliveryDate,DATEADD(m,1,@dtmDeliveryDate))) * (DATEDIFF(DAY, @dtmDeliveryDate, @dtmLastStorageAccrueDate) + 1)
																				- (CASE WHEN @strFeeType = 'Per Unit' THEN @dblFeeRate ELSE 0 END)

												SET @intTotalMonthsApplicableForStorageCharge = @intTotalMonthsApplicableForStorageCharge - 1
												SET @dtmDeliveryDate = @dtmLastStorageAccrueDate + 1
											END	
										END	
									END
								END
							END					
						END
				
					END
				
					--CASE 3.Start Date < > Blank, Ending Date < > Blank			
					ELSE IF @dtmStartDate IS NOT NULL AND @dtmEndingDate IS NOT NULL
					BEGIN
						IF @dtmDeliveryDate > @dtmStartDate
							SET @dtmStartDate = @dtmDeliveryDate
						ELSE
						BEGIN
							SET @intTotalMonthsApplicableForStorageCharge = CASE 
																			 WHEN (@intTotalMonthsApplicableForStorageCharge - DATEDIFF(MONTH, @dtmDeliveryDate, @dtmStartDate)) < 0 THEN 0
																			 ELSE (@intTotalMonthsApplicableForStorageCharge - DATEDIFF(MONTH, @dtmDeliveryDate, @dtmStartDate))
																		 END
							SET @dtmDeliveryDate = @dtmStartDate
						END

						SET @dtmEndingDate = CASE WHEN @dtmEndingDate > @dtmLastStorageAccrueDate THEN @dtmLastStorageAccrueDate ELSE @dtmEndingDate END

						IF (DATEDIFF(DAY, @dtmStartDate, @dtmLastStorageAccrueDate) + 1) > 0 AND ((DATEDIFF(DAY, @dtmDeliveryDate, @dtmEndingDate) + 1) > 0) AND @intTotalMonthsApplicableForStorageCharge > 0
						BEGIN
					
							--When Storage calculation Date is Same month of Delivery date.
							IF @intTotalOrigMonthsApplicableForStorageCharge = 1
							BEGIN
								--When FirstMonth and Last Month not are Matching then Charge Full month
								IF @strFirstMonth <> @strLastMonth
								BEGIN
									SELECT @dblStorageDuePerUnit = ISNULL(@dblStorageDuePerUnit, 0) - @dblStorageRate - (CASE WHEN @strFeeType = 'Per Unit' THEN @dblFeeRate ELSE 0 END)

									SET @intTotalMonthsApplicableForStorageCharge = @intTotalMonthsApplicableForStorageCharge - 1
									SET @dtmDeliveryDate = DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmDeliveryDate) + 1, 0)) + 1
								END
								ELSE
								BEGIN
									IF @strFirstMonth = 'Full Month' AND @strLastMonth = 'Full Month'
									BEGIN
										SELECT @dblStorageDuePerUnit = ISNULL(@dblStorageDuePerUnit, 0) - @dblStorageRate - (CASE WHEN @strFeeType = 'Per Unit' THEN @dblFeeRate ELSE 0 END)
										
										SET @intTotalMonthsApplicableForStorageCharge = @intTotalMonthsApplicableForStorageCharge - 1
										SET @dtmDeliveryDate = DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmDeliveryDate) + 1, 0)) + 1									
									END
									ELSE
									BEGIN
										SELECT @dblStorageDuePerUnit = ISNULL(@dblStorageDuePerUnit, 0) 
																		- (@dblStorageRate/DATEDIFF(dd,@dtmDeliveryDate,DATEADD(m,1,@dtmDeliveryDate))) * (DATEDIFF(DAY, @dtmDeliveryDate, @dtmLastStorageAccrueDate) + 1)
																		- (CASE WHEN @strFeeType = 'Per Unit' THEN @dblFeeRate ELSE 0 END)

										SET @intTotalMonthsApplicableForStorageCharge = @intTotalMonthsApplicableForStorageCharge - 1
										SET @dtmDeliveryDate = DATEDIFF(DAY, @dtmDeliveryDate, @dtmLastStorageAccrueDate) + 1 									
									END
								END
							END
							ELSE
							BEGIN
								IF @intTotalOrigMonthsApplicableForStorageCharge = @intTotalMonthsApplicableForStorageCharge
								BEGIN
									---First Month Charge
									IF @strFirstMonth = 'Full Month'
									BEGIN
										SELECT @dblStorageDuePerUnit = ISNULL(@dblStorageDuePerUnit, 0) - @dblStorageRate - (CASE WHEN @strFeeType = 'Per Unit' THEN @dblFeeRate ELSE 0 END)

										SET @intTotalMonthsApplicableForStorageCharge = @intTotalMonthsApplicableForStorageCharge - 1
										SET @dtmDeliveryDate = DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmDeliveryDate) + 1, 0)) + 1
									END
									ELSE
									BEGIN
																	
										SELECT @dblStorageDuePerUnit = ISNULL(@dblStorageDuePerUnit, 0) 
																		- (@dblStorageRate/DATEDIFF(dd,@dtmDeliveryDate,DATEADD(m,1,@dtmDeliveryDate))) * (DATEDIFF(DAY, @dtmDeliveryDate, DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmDeliveryDate) + 1, 0))) + 1)
																		- (CASE WHEN @strFeeType = 'Per Unit' THEN @dblFeeRate ELSE 0 END)

										SET @intTotalMonthsApplicableForStorageCharge = @intTotalMonthsApplicableForStorageCharge - 1
										SET @dtmDeliveryDate = DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmDeliveryDate) + 1, 0)) + 1
									END

									IF (DATEDIFF(DAY, @dtmDeliveryDate, @dtmEndingDate) + 1) > 0
									BEGIN
										IF @dtmLastStorageAccrueDate > @dtmEndingDate
										BEGIN
											---Intermediate Month Charges
											SELECT @dblStorageDuePerUnit = ISNULL(@dblStorageDuePerUnit, 0) 
																			- (@dblStorageRate * (DATEDIFF(MONTH, @dtmDeliveryDate, @dtmEndingDate) + 1))
																			- (CASE WHEN @strFeeType = 'Per Unit' THEN @dblFeeRate ELSE 0 END)

											SET @intTotalMonthsApplicableForStorageCharge = @intTotalMonthsApplicableForStorageCharge - (DATEDIFF(MONTH, @dtmDeliveryDate, @dtmEndingDate) + 1)
											SET @dtmDeliveryDate = DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmEndingDate) + 1, 0)) + 1
										END
										ELSE
										BEGIN
											--Intermediate Month charges
											SELECT @dblStorageDuePerUnit = ISNULL(@dblStorageDuePerUnit, 0) 
																			- (@dblStorageRate * (DATEDIFF(MONTH, @dtmDeliveryDate, DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmLastStorageAccrueDate), 0))) + 1))
																			- (CASE WHEN @strFeeType = 'Per Unit' THEN @dblFeeRate ELSE 0 END)

											SET @intTotalMonthsApplicableForStorageCharge = @intTotalMonthsApplicableForStorageCharge - (DATEDIFF(MONTH, @dtmDeliveryDate, DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmLastStorageAccrueDate), 0))) + 1)
											SET @dtmDeliveryDate = DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmLastStorageAccrueDate), 0)) + 1

											--Last Month Charge
											IF @strLastMonth = 'Full Month'
											BEGIN
												SELECT @dblStorageDuePerUnit = ISNULL(@dblStorageDuePerUnit, 0) - @dblStorageRate - (CASE WHEN @strFeeType = 'Per Unit' THEN @dblFeeRate ELSE 0 END)

												SET @intTotalMonthsApplicableForStorageCharge = @intTotalMonthsApplicableForStorageCharge - 1
												SET @dtmDeliveryDate = DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmLastStorageAccrueDate) + 1, 0)) + 1										
											END
											ELSE
											BEGIN
												SELECT @dblStorageDuePerUnit = ISNULL(@dblStorageDuePerUnit, 0) 
																				- (@dblStorageRate/DATEDIFF(dd,@dtmDeliveryDate,DATEADD(m,1,@dtmDeliveryDate))) * (DATEDIFF(DAY, @dtmDeliveryDate, @dtmLastStorageAccrueDate) + 1)
																				- (CASE WHEN @strFeeType = 'Per Unit' THEN @dblFeeRate ELSE 0 END)

												SET @intTotalMonthsApplicableForStorageCharge = @intTotalMonthsApplicableForStorageCharge - 1
												SET @dtmDeliveryDate = @dtmLastStorageAccrueDate + 1
											END
										END
									END
								END
								ELSE
								BEGIN
									IF (DATEDIFF(DAY, @dtmDeliveryDate, @dtmEndingDate) + 1) > 0
									BEGIN
										IF @dtmLastStorageAccrueDate > @dtmEndingDate
										BEGIN
											---Intermediate Month Charges
											SELECT @dblStorageDuePerUnit = ISNULL(@dblStorageDuePerUnit, 0) 
																			- (@dblStorageRate * (DATEDIFF(MONTH, @dtmDeliveryDate, @dtmEndingDate) + 1))
																			- (CASE WHEN @strFeeType = 'Per Unit' THEN @dblFeeRate ELSE 0 END)

											SET @intTotalMonthsApplicableForStorageCharge = @intTotalMonthsApplicableForStorageCharge - (DATEDIFF(MONTH, @dtmDeliveryDate, @dtmEndingDate) + 1)
											SET @dtmDeliveryDate = DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmEndingDate) + 1, 0)) + 1
										END
										ELSE
										BEGIN
											--Intermediate Month charges
											SELECT @dblStorageDuePerUnit = ISNULL(@dblStorageDuePerUnit, 0) 
																			- (@dblStorageRate * (DATEDIFF(MONTH, @dtmDeliveryDate, DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmLastStorageAccrueDate), 0))) + 1))
																			- (CASE WHEN @strFeeType = 'Per Unit' THEN @dblFeeRate ELSE 0 END)

											SET @intTotalMonthsApplicableForStorageCharge = @intTotalMonthsApplicableForStorageCharge - (DATEDIFF(MONTH, @dtmDeliveryDate, DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmLastStorageAccrueDate), 0))) + 1)
											SET @dtmDeliveryDate = DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmLastStorageAccrueDate), 0)) + 1

											--Last Month Charge										
											IF @strLastMonth = 'Full Month'
											BEGIN
												SELECT @dblStorageDuePerUnit = ISNULL(@dblStorageDuePerUnit, 0) - @dblStorageRate - (CASE WHEN @strFeeType = 'Per Unit' THEN @dblFeeRate ELSE 0 END)

												SET @intTotalMonthsApplicableForStorageCharge = @intTotalMonthsApplicableForStorageCharge - 1
												SET @dtmDeliveryDate = DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmLastStorageAccrueDate) + 1, 0)) + 1										
											END
											ELSE
											BEGIN										
												SELECT @dblStorageDuePerUnit = ISNULL(@dblStorageDuePerUnit, 0)		
																				- (@dblStorageRate/DATEDIFF(dd,@dtmDeliveryDate,DATEADD(m,1,@dtmDeliveryDate))) * (DATEDIFF(DAY, @dtmDeliveryDate, @dtmLastStorageAccrueDate) + 1)
																				- (CASE WHEN @strFeeType = 'Per Unit' THEN @dblFeeRate ELSE 0 END)

												SET @intTotalMonthsApplicableForStorageCharge = @intTotalMonthsApplicableForStorageCharge - 1
												SET @dtmDeliveryDate = @dtmLastStorageAccrueDate + 1
											END
										END
									END
								END
							END
						END
					END
				END

				--There After			      
				IF @strPeriodType = 'Thereafter'
				BEGIN
					IF @dtmStartDate IS NULL
					BEGIN
						--When Storage calculation Date is Same month of Delivery date.
						IF @intTotalOrigMonthsApplicableForStorageCharge = 1
						BEGIN
							--When FirstMonth and Last Month not are Matching then Charge Full month
							IF @strFirstMonth <> @strLastMonth
							BEGIN
								SELECT @dblStorageDuePerUnit = ISNULL(@dblStorageDuePerUnit, 0) - @dblStorageRate - (CASE WHEN @strFeeType = 'Per Unit' THEN @dblFeeRate ELSE 0 END)

								SET @intTotalMonthsApplicableForStorageCharge = @intTotalMonthsApplicableForStorageCharge - 1
								SET @dtmDeliveryDate = DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmDeliveryDate) + 1, 0)) + 1
							END
							ELSE
							BEGIN
								IF @strFirstMonth = 'Full Month' AND @strLastMonth = 'Full Month'
								BEGIN
									SELECT @dblStorageDuePerUnit = ISNULL(@dblStorageDuePerUnit, 0) - @dblStorageRate - (CASE WHEN @strFeeType = 'Per Unit' THEN @dblFeeRate ELSE 0 END)

									SET @intTotalMonthsApplicableForStorageCharge = @intTotalMonthsApplicableForStorageCharge - 1
									SET @dtmDeliveryDate = DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmDeliveryDate) + 1, 0)) + 1
								END
								ELSE
								BEGIN
									SELECT @dblStorageDuePerUnit = ISNULL(@dblStorageDuePerUnit, 0) 
																	- (@dblStorageRate/DATEDIFF(dd,@dtmDeliveryDate,DATEADD(m,1,@dtmDeliveryDate))) * (DATEDIFF(DAY, @dtmDeliveryDate, @dtmLastStorageAccrueDate) + 1)
																	- (CASE WHEN @strFeeType = 'Per Unit' THEN @dblFeeRate ELSE 0 END)

									SET @intTotalMonthsApplicableForStorageCharge = @intTotalMonthsApplicableForStorageCharge - 1
									SET @dtmDeliveryDate = @dtmLastStorageAccrueDate + 1
								END
							END
						END
						ELSE
						BEGIN
							IF @intTotalOrigMonthsApplicableForStorageCharge = @intTotalMonthsApplicableForStorageCharge
							BEGIN
								---First Month Charge
								IF @strFirstMonth = 'Full Month'
								BEGIN
									SELECT @dblStorageDuePerUnit = ISNULL(@dblStorageDuePerUnit, 0) - @dblStorageRate - (CASE WHEN @strFeeType = 'Per Unit' THEN @dblFeeRate ELSE 0 END)

									SET @intTotalMonthsApplicableForStorageCharge = @intTotalMonthsApplicableForStorageCharge - 1
									SET @dtmDeliveryDate = DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmDeliveryDate) + 1, 0)) + 1
								END
								ELSE
								BEGIN
									SELECT @dblStorageDuePerUnit = ISNULL(@dblStorageDuePerUnit, 0) 
																	- (@dblStorageRate/DATEDIFF(dd,@dtmDeliveryDate,DATEADD(m,1,@dtmDeliveryDate))) * (DATEDIFF(DAY, @dtmDeliveryDate, DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmDeliveryDate) + 1, 0))) + 1)
																	- (CASE WHEN @strFeeType = 'Per Unit' THEN @dblFeeRate ELSE 0 END)

									SET @intTotalMonthsApplicableForStorageCharge = @intTotalMonthsApplicableForStorageCharge - 1
									SET @dtmDeliveryDate = DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmDeliveryDate) + 1, 0)) + 1
								END

								IF (DATEDIFF(DAY, @dtmDeliveryDate, @dtmLastStorageAccrueDate) + 1) > 0 AND @intTotalMonthsApplicableForStorageCharge > 0
								BEGIN
									--Intermediate Month charges
									SELECT @dblStorageDuePerUnit = ISNULL(@dblStorageDuePerUnit, 0) 
																	- (@dblStorageRate * (DATEDIFF(MONTH, @dtmDeliveryDate, DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmLastStorageAccrueDate), 0))) + 1))
																	- (CASE WHEN @strFeeType = 'Per Unit' THEN @dblFeeRate ELSE 0 END)

									SET @intTotalMonthsApplicableForStorageCharge = @intTotalMonthsApplicableForStorageCharge - (DATEDIFF(MONTH, @dtmDeliveryDate, DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmLastStorageAccrueDate), 0))) + 1)
									SET @dtmDeliveryDate = DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmLastStorageAccrueDate), 0)) + 1

									--Last Month Charge
									IF @strLastMonth = 'Full Month'
									BEGIN
										SELECT @dblStorageDuePerUnit = ISNULL(@dblStorageDuePerUnit, 0) - @dblStorageRate - (CASE WHEN @strFeeType = 'Per Unit' THEN @dblFeeRate ELSE 0 END)

										SET @intTotalMonthsApplicableForStorageCharge = @intTotalMonthsApplicableForStorageCharge - 1
										SET @dtmDeliveryDate = DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmLastStorageAccrueDate) + 1, 0)) + 1
									END
									ELSE
									BEGIN
										SELECT @dblStorageDuePerUnit = ISNULL(@dblStorageDuePerUnit, 0) 
																		- (@dblStorageRate/DATEDIFF(dd,@dtmDeliveryDate,DATEADD(m,1,@dtmDeliveryDate))) * (DATEDIFF(DAY, @dtmDeliveryDate, @dtmLastStorageAccrueDate) + 1)
																		- (CASE WHEN @strFeeType = 'Per Unit' THEN @dblFeeRate ELSE 0 END)

										SET @intTotalMonthsApplicableForStorageCharge = @intTotalMonthsApplicableForStorageCharge - 1									
										SET @dtmDeliveryDate = @dtmLastStorageAccrueDate + 1
									END
								END
							END
							ELSE
							BEGIN
								IF (DATEDIFF(DAY, @dtmDeliveryDate, @dtmLastStorageAccrueDate) + 1) > 0
								BEGIN
									--Intermediate Month charges
									SELECT @dblStorageDuePerUnit = ISNULL(@dblStorageDuePerUnit, 0) 
																	- (@dblStorageRate * (DATEDIFF(MONTH, @dtmDeliveryDate, DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmLastStorageAccrueDate), 0))) + 1))
																	- (CASE WHEN @strFeeType = 'Per Unit' THEN @dblFeeRate ELSE 0 END)

									SET @intTotalMonthsApplicableForStorageCharge = @intTotalMonthsApplicableForStorageCharge - (DATEDIFF(MONTH, @dtmDeliveryDate, DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmLastStorageAccrueDate), 0))) + 1)
									SET @dtmDeliveryDate = DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmLastStorageAccrueDate), 0)) + 1

									--Last Month Charge									
									IF @strLastMonth = 'Full Month'
									BEGIN
										SELECT @dblStorageDuePerUnit = ISNULL(@dblStorageDuePerUnit, 0) - @dblStorageRate - (CASE WHEN @strFeeType = 'Per Unit' THEN @dblFeeRate ELSE 0 END)
										
										SET @intTotalMonthsApplicableForStorageCharge = @intTotalMonthsApplicableForStorageCharge - 1										
										SET @dtmDeliveryDate = DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmLastStorageAccrueDate) + 1, 0)) + 1
									END
									ELSE
									BEGIN
										SELECT @dblStorageDuePerUnit = ISNULL(@dblStorageDuePerUnit, 0) 
																		- (@dblStorageRate/DATEDIFF(dd,@dtmDeliveryDate,DATEADD(m,1,@dtmDeliveryDate))) * (DATEDIFF(DAY, @dtmDeliveryDate, @dtmLastStorageAccrueDate) + 1)
																		- (CASE WHEN @strFeeType = 'Per Unit' THEN @dblFeeRate ELSE 0 END)

										SET @intTotalMonthsApplicableForStorageCharge = @intTotalMonthsApplicableForStorageCharge - 1
										SET @dtmDeliveryDate = @dtmLastStorageAccrueDate + 1
									END
								END
							END
						END
					END
					ELSE
					BEGIN
					
						IF @dtmDeliveryDate > @dtmStartDate
							SET @dtmStartDate = @dtmDeliveryDate
						ELSE
						BEGIN
							SET @intTotalMonthsApplicableForStorageCharge = CASE 
																			 WHEN (@intTotalMonthsApplicableForStorageCharge - DATEDIFF(MONTH, @dtmDeliveryDate, @dtmStartDate)) < 0 THEN 0
																			 ELSE (@intTotalMonthsApplicableForStorageCharge - DATEDIFF(MONTH, @dtmDeliveryDate, @dtmStartDate))
																		END
							SET @dtmDeliveryDate = @dtmStartDate
						END
					
						IF (DATEDIFF(DAY, @dtmStartDate, @dtmLastStorageAccrueDate) + 1) > 0 AND @intTotalMonthsApplicableForStorageCharge > 0
						BEGIN
							--When Storage calculation Date is Same month of Delivery date.
							IF @intTotalOrigMonthsApplicableForStorageCharge = 1
							BEGIN
								--When FirstMonth and Last Month not are Matching then Charge Full month
								IF @strFirstMonth <> @strLastMonth
								BEGIN
									SELECT @dblStorageDuePerUnit = ISNULL(@dblStorageDuePerUnit, 0) - @dblStorageRate - (CASE WHEN @strFeeType = 'Per Unit' THEN @dblFeeRate ELSE 0 END)
									
									SET @intTotalMonthsApplicableForStorageCharge = @intTotalMonthsApplicableForStorageCharge - 1
									SET @dtmDeliveryDate = DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmDeliveryDate) + 1, 0)) + 1
								END
								ELSE
								BEGIN
									IF @strFirstMonth = 'Full Month' AND @strLastMonth = 'Full Month'
									BEGIN
										SELECT @dblStorageDuePerUnit = ISNULL(@dblStorageDuePerUnit, 0) - @dblStorageRate - (CASE WHEN @strFeeType = 'Per Unit' THEN @dblFeeRate ELSE 0 END)
										
										SET @intTotalMonthsApplicableForStorageCharge = @intTotalMonthsApplicableForStorageCharge - 1
										SET @dtmDeliveryDate = DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmDeliveryDate) + 1, 0)) + 1
									END
									ELSE
									BEGIN
										SELECT @dblStorageDuePerUnit = ISNULL(@dblStorageDuePerUnit, 0) 
																		- (@dblStorageRate/DATEDIFF(dd,@dtmDeliveryDate,DATEADD(m,1,@dtmDeliveryDate))) * (DATEDIFF(DAY, @dtmDeliveryDate, DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmDeliveryDate) + 1, 0))) + 1)
																		- (CASE WHEN @strFeeType = 'Per Unit' THEN @dblFeeRate ELSE 0 END)

										SET @intTotalMonthsApplicableForStorageCharge = @intTotalMonthsApplicableForStorageCharge - 1
										SET @dtmDeliveryDate = @dtmLastStorageAccrueDate + 1
									END
								END
							END
							ELSE
							BEGIN
								IF @intTotalOrigMonthsApplicableForStorageCharge = @intTotalMonthsApplicableForStorageCharge
								BEGIN
									---First Month Charge
									IF @strFirstMonth = 'Full Month'
									BEGIN
										SELECT @dblStorageDuePerUnit = ISNULL(@dblStorageDuePerUnit, 0) - @dblStorageRate - (CASE WHEN @strFeeType = 'Per Unit' THEN @dblFeeRate ELSE 0 END)

										SET @intTotalMonthsApplicableForStorageCharge = @intTotalMonthsApplicableForStorageCharge - 1
										SET @dtmDeliveryDate = DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmDeliveryDate) + 1, 0)) + 1
									END
									ELSE
									BEGIN
										SELECT @dblStorageDuePerUnit = ISNULL(@dblStorageDuePerUnit, 0) 
																		- (@dblStorageRate/DATEDIFF(dd,@dtmDeliveryDate,DATEADD(m,1,@dtmDeliveryDate))) * (DATEDIFF(DAY, @dtmDeliveryDate, DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmDeliveryDate) + 1, 0))) + 1)
																		- (CASE WHEN @strFeeType = 'Per Unit' THEN @dblFeeRate ELSE 0 END)

										SET @intTotalMonthsApplicableForStorageCharge = @intTotalMonthsApplicableForStorageCharge - 1
										SET @dtmDeliveryDate = DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmDeliveryDate) + 1, 0)) + 1
									END
								
									---Intermediate and Last Month Charges
									IF (DATEDIFF(DAY, @dtmDeliveryDate, @dtmLastStorageAccrueDate) + 1) > 0
									BEGIN
								
										IF @intTotalMonthsApplicableForStorageCharge > 1
										BEGIN									
											--Intermediate Month charges
											SELECT @dblStorageDuePerUnit = ISNULL(@dblStorageDuePerUnit, 0) 
																			- (@dblStorageRate * (DATEDIFF(MONTH, @dtmDeliveryDate, DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmLastStorageAccrueDate), 0))) + 1))
																			- (CASE WHEN @strFeeType = 'Per Unit' THEN @dblFeeRate ELSE 0 END)

											SET @intTotalMonthsApplicableForStorageCharge = @intTotalMonthsApplicableForStorageCharge - (DATEDIFF(MONTH, @dtmDeliveryDate, DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmLastStorageAccrueDate), 0))) + 1)
											SET @dtmDeliveryDate = DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmLastStorageAccrueDate), 0)) + 1

											--Last Month Charge
											IF @strLastMonth = 'Full Month'
											BEGIN
												SELECT @dblStorageDuePerUnit = ISNULL(@dblStorageDuePerUnit, 0) - @dblStorageRate - (CASE WHEN @strFeeType = 'Per Unit' THEN @dblFeeRate ELSE 0 END)
												
												SET @intTotalMonthsApplicableForStorageCharge = @intTotalMonthsApplicableForStorageCharge - 1
												SET @dtmDeliveryDate = DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmLastStorageAccrueDate) + 1, 0)) + 1
											END
											ELSE
											BEGIN
												SELECT @dblStorageDuePerUnit = ISNULL(@dblStorageDuePerUnit, 0) 
																				- (@dblStorageRate/DATEDIFF(dd,@dtmDeliveryDate,DATEADD(m,1,@dtmDeliveryDate))) * (DATEDIFF(DAY, @dtmDeliveryDate, @dtmLastStorageAccrueDate) + 1)
																				- (CASE WHEN @strFeeType = 'Per Unit' THEN @dblFeeRate ELSE 0 END)

												SET @intTotalMonthsApplicableForStorageCharge = @intTotalMonthsApplicableForStorageCharge - 1
												SET @dtmDeliveryDate = @dtmLastStorageAccrueDate + 1
											END
										END
										ELSE
										BEGIN
											--Last Month Charge
											IF @strLastMonth = 'Full Month'
											BEGIN
												SELECT @dblStorageDuePerUnit = ISNULL(@dblStorageDuePerUnit, 0) - @dblStorageRate - (CASE WHEN @strFeeType = 'Per Unit' THEN @dblFeeRate ELSE 0 END)
												
												SET @intTotalMonthsApplicableForStorageCharge = @intTotalMonthsApplicableForStorageCharge - 1
												SET @dtmDeliveryDate = DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmLastStorageAccrueDate) + 1, 0)) + 1
											END
											ELSE
											BEGIN
												SELECT @dblStorageDuePerUnit = ISNULL(@dblStorageDuePerUnit, 0)
																				- (@dblStorageRate/DATEDIFF(dd,@dtmDeliveryDate,DATEADD(m,1,@dtmDeliveryDate))) * (DATEDIFF(DAY, @dtmDeliveryDate, @dtmLastStorageAccrueDate) + 1)
																				- (CASE WHEN @strFeeType = 'Per Unit' THEN @dblFeeRate ELSE 0 END	)

												SET @intTotalMonthsApplicableForStorageCharge = @intTotalMonthsApplicableForStorageCharge - 1
												SET @dtmDeliveryDate = @dtmLastStorageAccrueDate + 1
											END	
										END	
									END
								END
								ELSE
								BEGIN
									---Intermediate and Last Month Charges
									IF (DATEDIFF(DAY, @dtmDeliveryDate, @dtmLastStorageAccrueDate) + 1) > 0
									BEGIN
								
										IF @intTotalMonthsApplicableForStorageCharge > 1
										BEGIN
									
											--Intermediate Month charges
											SELECT @dblStorageDuePerUnit = ISNULL(@dblStorageDuePerUnit, 0) 
																			- (@dblStorageRate * (DATEDIFF(MONTH, @dtmDeliveryDate, DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmLastStorageAccrueDate), 0))) + 1))
																			- (CASE WHEN @strFeeType = 'Per Unit' THEN @dblFeeRate ELSE 0 END)
											
											SET @intTotalMonthsApplicableForStorageCharge = @intTotalMonthsApplicableForStorageCharge - (DATEDIFF(MONTH, @dtmDeliveryDate, DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmLastStorageAccrueDate), 0))) + 1)
											SET @dtmDeliveryDate = DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmLastStorageAccrueDate), 0)) + 1

											--Last Month Charge
											IF @strLastMonth = 'Full Month'
											BEGIN
												SELECT @dblStorageDuePerUnit = ISNULL(@dblStorageDuePerUnit, 0) - @dblStorageRate - (CASE WHEN @strFeeType = 'Per Unit' THEN @dblFeeRate ELSE 0 END)

												SET @intTotalMonthsApplicableForStorageCharge = @intTotalMonthsApplicableForStorageCharge - 1
												SET @dtmDeliveryDate = DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmLastStorageAccrueDate) + 1, 0)) + 1
											END
											ELSE
											BEGIN
												SELECT @dblStorageDuePerUnit = ISNULL(@dblStorageDuePerUnit, 0) 
																				- (@dblStorageRate/DATEDIFF(dd,@dtmDeliveryDate,DATEADD(m,1,@dtmDeliveryDate))) * (DATEDIFF(DAY, @dtmDeliveryDate, @dtmLastStorageAccrueDate) + 1)
																				- (CASE WHEN @strFeeType = 'Per Unit' THEN @dblFeeRate ELSE 0 END)

												SET @intTotalMonthsApplicableForStorageCharge = @intTotalMonthsApplicableForStorageCharge - 1
												SET @dtmDeliveryDate = @dtmLastStorageAccrueDate + 1
											END
										END
										ELSE
										BEGIN
											--Last Month Charge
											IF @strLastMonth = 'Full Month'
											BEGIN
												SELECT @dblStorageDuePerUnit = ISNULL(@dblStorageDuePerUnit, 0) - @dblStorageRate - (CASE WHEN @strFeeType = 'Per Unit' THEN @dblFeeRate ELSE 0 END)
												
												SET @intTotalMonthsApplicableForStorageCharge = @intTotalMonthsApplicableForStorageCharge - 1
												SET @dtmDeliveryDate = DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmLastStorageAccrueDate) + 1, 0)) + 1
											END
											ELSE
											BEGIN
												SELECT @dblStorageDuePerUnit = ISNULL(@dblStorageDuePerUnit, 0) 
																				- (@dblStorageRate/DATEDIFF(dd,@dtmDeliveryDate,DATEADD(m,1,@dtmDeliveryDate))) * (DATEDIFF(DAY, @dtmDeliveryDate, @dtmLastStorageAccrueDate) + 1)
																				- (CASE WHEN @strFeeType = 'Per Unit' THEN @dblFeeRate ELSE 0 END)

												SET @intTotalMonthsApplicableForStorageCharge = @intTotalMonthsApplicableForStorageCharge - 1
												SET @dtmDeliveryDate = @dtmLastStorageAccrueDate + 1
											END	
										END	
									END
								END
							END	
						END
					
					END
				END
			
				SELECT @intSchedulePeriodId = MIN(intSchedulePeriodId)
				FROM @StorageSchedulePeriods
				WHERE intSchedulePeriodId > @intSchedulePeriodId
			END
		
		END
		---------End Of Monthly----------------------------
	END	
	
	SELECT 
		@dblStorageDueTotalPerUnit = ISNULL(dblStorageDue,0) - ISNULL(dblStoragePaid,0)
		,@dblStorageBilledPerUnit  = ISNULL(dblStoragePaid,0) - @dblOldStoragePaid
	FROM tblGRCustomerStorage
	WHERE intCustomerStorageId = @intCustomerStorageId

	INSERT INTO @returnTable
	SELECT	
		intCustomerStorageId	  	= @intCustomerStorageId
		,dblStorageDuePerUnit	  	= @dblStorageDuePerUnit
		,dblStorageDueAmount	  	= @dblStorageDuePerUnit * @dblUnits
		,dblStorageDueTotalPerUnit 	= @dblStorageDueTotalPerUnit
		,dblStorageDueTotalAmount 	= @dblStorageDueTotalPerUnit * @dblUnits
		,dblStorageBilledPerUnit 	= @dblStorageBilledPerUnit
		,dblStorageBilledAmount	 	= @dblStorageBilledPerUnit * @dblUnits
		,dblFlatFeeTotal		 	= ISNULL(@dblFlatFeeTotal,0)

	RETURN;
END