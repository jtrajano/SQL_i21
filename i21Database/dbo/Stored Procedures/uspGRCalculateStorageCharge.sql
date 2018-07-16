CREATE PROCEDURE [dbo].[uspGRCalculateStorageCharge]  
     @strProcessType				NVARCHAR(30)
	,@strUpdateType					NVARCHAR(30)
	,@intCustomerStorageId			INT				= 0
	,@dtmOverrideDeliveryDate		DATETIME		= NULL
	,@intOverrideStorageScheduleId  INT				= NULL
	,@dblOverrideStorageUnits		DECIMAL(24, 10) = NULL
	,@StorageChargeDate				DATETIME		= NULL
	,@UserKey						INT
	,@returnChargeByPeriodWise		BIT				= 1
	,@strPeriodData					NVARCHAR(MAX)	= NULL
	,@dblStorageDuePerUnit			DECIMAL(24, 10)   OUTPUT
	,@dblStorageDueAmount			DECIMAL(24, 10)   OUTPUT
	,@dblStorageDueTotalPerUnit		DECIMAL(24, 10)   OUTPUT
	,@dblStorageDueTotalAmount		DECIMAL(24, 10)   OUTPUT
	,@dblStorageBilledPerUnit		DECIMAL(24, 10)   OUTPUT
	,@dblStorageBilledAmount		DECIMAL(24, 10)   OUTPUT
	,@dblFlatFeeTotal				DECIMAL(24, 10)   OUTPUT
		
AS
BEGIN TRY
	SET NOCOUNT ON

	IF @StorageChargeDate IS NULL
	   SET @StorageChargeDate = GETDATE()

	DECLARE @ErrMsg											NVARCHAR(MAX)
	DECLARE @UserName										NVARCHAR(100)
	DECLARE @dblOldStoragePaid								DECIMAL(24, 10)
	DECLARE @dblOpenBalance									DECIMAL(24, 10)
	DECLARE @intStorageScheduleId							INT
	DECLARE @intAllowanceDays								INT
	DECLARE @strStorageRate									NVARCHAR(50)
	DECLARE @strFirstMonth									NVARCHAR(50)
	DECLARE @strLastMonth									NVARCHAR(50)
	DECLARE @dtmHEffectiveDate								DATETIME
	DECLARE @dtmTerminationDate								DATETIME
	DECLARE @dtmDeliveryDate								DATETIME
	DECLARE @dtmLastStorageAccrueDate						DATETIME
	DECLARE @intSchedulePeriodId							INT
	DECLARE @strPeriodType									NVARCHAR(50)
	DECLARE @dtmDEffectiveDate								DATETIME
	DECLARE @dtmEndingDate									DATETIME
	DECLARE @intNumberOfDays								INT
	DECLARE @intPeriodKey									INT
	DECLARE @dblStorageRate									DECIMAL(24, 10)
	DECLARE @dblFeeRate										DECIMAL(24, 10)
	DECLARE	@strFeeType									    NVARCHAR(100)
	DECLARE @dblNewStoragePaid								DECIMAL(24, 10)
	DECLARE @TotalDaysApplicableForStorageCharge			INT
	DECLARE @TotalMonthsApplicableForStorageCharge			INT
	DECLARE @TotalOriginalMonthsApplicableForStorageCharge  INT
	DECLARE @StorageChargeCalculationRequired				BIT = 1
	DECLARE @CalculatedNumberOfDays							INT = 0
	DECLARE @FirstMonthFullChargeApplicable					BIT
	
	DECLARE @strAllowancePeriod								NVARCHAR(50)
	DECLARE @dtmAllowancePeriodFrom							DATETIME
	DECLARE @dtmAllowancePeriodTo							DATETIME
	DECLARE @ActualStorageChargeDate						DATETIME
	DECLARE @FlatFeeCalculationRequired						BIT = 1
	DECLARE @FlatFeeCalculatioFromDate						DATETIME

	DECLARE @idoc INT
	EXEC sp_xml_preparedocument @idoc OUTPUT,@strPeriodData
	
	SET @ActualStorageChargeDate=@StorageChargeDate	
	
	DECLARE @tblGRStorageSchedulePeriod AS TABLE 
	(
		 [intSchedulePeriodId] INT IDENTITY(1, 1)
		,[intPeriodKey]		   INT NULL
		,[strPeriodType]	   NVARCHAR(30) COLLATE Latin1_General_CI_AS NOT NULL
		,[dtmEffectiveDate]	   DATETIME NULL
		,[dtmEndingDate]       DATETIME NULL
		,[intNumberOfDays]     INT NULL
		,[dblStorageRate]      NUMERIC(18, 6)
		,[dblFeeRate]		   NUMERIC(18, 6) NULL 
		,[strFeeType]		   NVARCHAR(20) COLLATE Latin1_General_CI_AS NULL 
	)
	
	DECLARE @DailyStorageCharge AS TABLE 
	(
		 [intStorageChargeKey]				INT IDENTITY(1, 1)
		,[intPeriodKey]						INT NULL
		,[strPeriodType]					NVARCHAR(30) COLLATE Latin1_General_CI_AS NOT NULL
		,[dtmEffectiveDate]					DATETIME NULL
		,[dtmEndingDate]					DATETIME NULL
		,[intNumberOfDays]					INT NULL
		,[CalculatedNumberOfDays]			INT NULL		
		,[dblStorageRate]					NUMERIC(18, 6) NULL
		,[dblStorageDuePerUnit]				DECIMAL(24,10) NULL
		,[dblCummulativeStorageDuePerUnit]  DECIMAL(24,10) NULL		
	 )
	 
	DECLARE @StorageCharge AS TABLE 
	(
		 [intStorageChargeKey]				INT IDENTITY(1, 1)
		,[intPeriodKey]						INT NULL
		,[strPeriodType]					NVARCHAR(30) COLLATE Latin1_General_CI_AS NOT NULL
		,[dtmEffectiveDate]					DATETIME NULL
		,[dtmEndingDate]					DATETIME NULL
		,[dblStorageRate]					NUMERIC(18, 6)
		,[MonthType]						NVARCHAR(30) COLLATE Latin1_General_CI_AS NOT NULL
		,[ChargeType]						NVARCHAR(30) COLLATE Latin1_General_CI_AS NOT NULL
		,[ChargedNumberOfDays/Months]       INT NULL		
		,[dblStorageDuePerUnit]				DECIMAL(24,10) NULL
		,[dblCummulativeStorageDuePerUnit]  DECIMAL(24,10) NULL
		,[RemainingMonths]					INT NULL
	 )	
	
	IF @strProcessType = 'test' AND @strUpdateType < > 'estimate'
	BEGIN
		SET @ErrMsg = 'Estimate updatetype is only applicable for test ProcessType .'
		RAISERROR (@ErrMsg,16,1)
	END

	IF @strProcessType = 'test'
		AND (
				   @dtmOverrideDeliveryDate IS NULL
				OR ISNULL(@intOverrideStorageScheduleId, 0) = 0
				OR ISNULL(@dblOverrideStorageUnits, 0) = 0
			)
	BEGIN
		SET @ErrMsg = 'DeliveryDate, Schedule and StorageUnits must and should be supplied for test Processtype .'
		RAISERROR (@ErrMsg,16,1)
	END

	IF @strProcessType < > 'test' AND (@dtmOverrideDeliveryDate IS NOT NULL)
	BEGIN
		SET @ErrMsg = 'For test Processtype only, DeliveryDate must and should be supplied.'
		RAISERROR (@ErrMsg,16,1)
	END
	
	SET @dblFlatFeeTotal = ISNULL(@dblFlatFeeTotal, 0)

	IF @intCustomerStorageId > 0
	BEGIN
		SELECT 
			 @dblOldStoragePaid        = CS.dblStoragePaid

			,@dblOpenBalance	       = CASE 
								       	        WHEN ISNULL(@dblOverrideStorageUnits, 0) = 0 THEN CS.dblOpenBalance
								       	        ELSE @dblOverrideStorageUnits
								         END

			,@intStorageScheduleId     = CASE 
									   			WHEN ISNULL(@intOverrideStorageScheduleId, 0) = 0 THEN CS.intStorageScheduleId
									   			ELSE @intOverrideStorageScheduleId
									     END

			,@intAllowanceDays         = SR.intAllowanceDays
			,@strStorageRate           = SR.strStorageRate
			,@strFirstMonth            = SR.strFirstMonth
			,@strLastMonth             = SR.strLastMonth
			,@dtmHEffectiveDate        = SR.dtmEffectiveDate
			,@dtmTerminationDate       = SR.dtmTerminationDate
			,@strAllowancePeriod       = SR.strAllowancePeriod
			,@dtmAllowancePeriodFrom   = SR.dtmAllowancePeriodFrom
			,@dtmAllowancePeriodTo     = SR.dtmAllowancePeriodTo			
			,@dtmDeliveryDate		   = CS.dtmDeliveryDate
			,@dtmLastStorageAccrueDate = CASE 
											 WHEN @strProcessType < > 'recalculate' THEN CS.dtmLastStorageAccrueDate
											 ELSE NULL
										 END
		FROM tblGRCustomerStorage CS
		JOIN tblGRStorageScheduleRule SR ON SR.intStorageScheduleRuleId = CS.intStorageScheduleId
		WHERE CS.intCustomerStorageId = @intCustomerStorageId
		
		SELECT @FlatFeeCalculatioFromDate =MAX(dbo.fnRemoveTimeOnDate(dtmHistoryDate)) 
		FROM 
		(
			SELECT Top 1 dbo.fnRemoveTimeOnDate(dtmHistoryDate) dtmHistoryDate
			FROM tblGRStorageHistory 
			WHERE intCustomerStorageId =@intCustomerStorageId AND strType='Settlement' AND intBillId IS NOT NULL
			ORDER BY 1 DESC

			UNION
			
			SELECT Top 1 dbo.fnRemoveTimeOnDate(dtmHistoryDate) dtmHistoryDate
			FROM tblGRStorageHistory 
			WHERE intCustomerStorageId =@intCustomerStorageId AND strType='Generated Storage Invoice' AND intInvoiceId IS NOT NULL
			ORDER BY 1 DESC

			UNION

			SELECT  DISTINCT TOP 1   SH.dtmHistoryDate
			FROM tblGRStorageHistory SH
			LEFT JOIN (
						 SELECT 
						 intCustomerStorageId
						,intInvoiceId
						,ISNULL(SUM(dblUnits), 0) DepletedUnits
						 FROM tblGRStorageHistory
						 WHERE strType = 'Reduced By Invoice' AND intCustomerStorageId =@intCustomerStorageId
						 GROUP BY intCustomerStorageId ,intInvoiceId
				       ) Deplete ON Deplete.intCustomerStorageId = SH.intCustomerStorageId
			
			LEFT JOIN (
						SELECT 
						 intCustomerStorageId
						,intInvoiceId
					    ,ISNULL(SUM(dblUnits), 0) ReversedUnits
						 FROM tblGRStorageHistory
						 WHERE strType = 'Reverse By Invoice' AND intCustomerStorageId =@intCustomerStorageId
						 GROUP BY intCustomerStorageId ,intInvoiceId
					 ) Reverse ON Reverse.intCustomerStorageId = SH.intCustomerStorageId
			WHERE ISNULL(Deplete.DepletedUnits, 0) <> ISNULL(Reverse.ReversedUnits, 0)
				AND Deplete.intInvoiceId = Reverse.intInvoiceId
				AND SH.strType = 'Reduced By Invoice'
				AND SH.intInvoiceId IS NOT NULL 
				AND SH.intCustomerStorageId =@intCustomerStorageId
			ORDER BY 1 DESC
		)t

	    IF @FlatFeeCalculatioFromDate IS NULL AND @dtmLastStorageAccrueDate IS NOT NULL
	    BEGIN
		 	SET @FlatFeeCalculatioFromDate = @dtmLastStorageAccrueDate
	    END
	    ELSE IF @FlatFeeCalculatioFromDate IS NOT NULL AND @dtmLastStorageAccrueDate IS NOT NULL
	    BEGIN
	          IF @FlatFeeCalculatioFromDate < @dtmLastStorageAccrueDate
		 	  BEGIN
		 			SET @FlatFeeCalculatioFromDate = @dtmLastStorageAccrueDate
		 	  END
	    END
	END
	ELSE ---For ProcessType ='Test'     
	BEGIN
		SET @dblOpenBalance		       = @dblOverrideStorageUnits
		SET @intStorageScheduleId      = @intOverrideStorageScheduleId
		SET @dtmDeliveryDate	       = @dtmOverrideDeliveryDate
		SET @dtmLastStorageAccrueDate  = NULL

		SELECT @intAllowanceDays	   = intAllowanceDays
			,@strStorageRate		   = strStorageRate
			,@strFirstMonth			   = strFirstMonth
			,@strLastMonth			   = strLastMonth
			,@dtmHEffectiveDate		   = dtmEffectiveDate
			,@dtmTerminationDate	   = dtmTerminationDate
			,@strAllowancePeriod	   = strAllowancePeriod
			,@dtmAllowancePeriodFrom   = dtmAllowancePeriodFrom
			,@dtmAllowancePeriodTo     = dtmAllowancePeriodTo
		FROM tblGRStorageScheduleRule
		WHERE intStorageScheduleRuleId = @intStorageScheduleId
	END

	IF @strPeriodData IS NULL
	BEGIN
		INSERT INTO @tblGRStorageSchedulePeriod 
		(
			 [intPeriodKey]
			,[strPeriodType]
			,[dtmEffectiveDate]
			,[dtmEndingDate]
			,[intNumberOfDays]
			,[dblStorageRate]
			,[dblFeeRate]
			,[strFeeType]
		)
		SELECT
			 [intPeriodKey]     = RANK() OVER (ORDER BY intSort)
			,[strPeriodType]    = [strPeriodType]
			,[dtmEffectiveDate] = [dtmEffectiveDate]
			,[dtmEndingDate]    = [dtmEndingDate]
			,[intNumberOfDays]  = [intNumberOfDays]
			,[dblStorageRate]   = [dblStorageRate]
			,[dblFeeRate]		= [dblFeeRate]
		    ,[strFeeType]		= [strFeeType]
		FROM tblGRStorageSchedulePeriod
		WHERE intStorageScheduleRule = @intStorageScheduleId
		ORDER BY intSort
	END
	ELSE
	BEGIN
		INSERT INTO @tblGRStorageSchedulePeriod 
		(
			 [intPeriodKey]
			,[strPeriodType]
			,[dtmEffectiveDate]
			,[dtmEndingDate]
			,[intNumberOfDays]
			,[dblStorageRate]
			,[dblFeeRate]
			,[strFeeType]
		)
		 SELECT 
		  [intPeriodKey]          =  RANK() OVER (ORDER BY intSort)
		, [strPeriodType]         =  [strPeriodType]
		, [dtmEffectiveDate]      =  (CASE WHEN CONVERT(DATE, [dtmEffectiveDate]) = '1900-01-01' THEN NULL ELSE [dtmEffectiveDate] END)
		, [dtmEndingDate]         =  (CASE WHEN CONVERT(DATE, [dtmEndingDate])    = '1900-01-01' THEN NULL ELSE [dtmEndingDate]    END)
		, [intNumberOfDays]       =  [intNumberOfDays]
		, [dblStorageRate]        =  [dblStorageRate]
		, [dblFeeRate]			  =  [dblFeeRate]  
		, [strFeeType]			  =  [strFeeType]
		FROM OPENXML(@idoc, 'root/Period', 2) WITH 
		(
			 intCustomerStorageId   INT
			,strPeriodType			Nvarchar(30)
			,dtmEffectiveDate		DATETIME
			,dtmEndingDate			DATETIME
			,intNumberOfDays		INT
			,dblStorageRate			NUMERIC(18,6)
			,dblFeeRate				NUMERIC(18,6)
			,strFeeType				Nvarchar(30)
			,intSort				INT
		)
		ORDER BY intSort
	END
	
	--Suppose Termination Date is not Blank and Storage Charge Date is later on Termination Date then Charge Upto Termination Date.    
	IF @StorageChargeDate > @dtmTerminationDate AND @dtmTerminationDate IS NOT NULL
		SET @StorageChargeDate = @dtmTerminationDate

	--Suppose Effective Date is not blank and Delivery Date is Prior to Effective Date then Charge From Effective Date.     
	IF @dtmDeliveryDate < @dtmHEffectiveDate AND @dtmHEffectiveDate IS NOT NULL
		SET @dtmDeliveryDate = @dtmHEffectiveDate

	SELECT @UserName = strUserName
	FROM tblSMUserSecurity
	WHERE [intEntityId] = @UserKey
	
	IF EXISTS(
					SELECT 1 FROM tblGRCustomerStorage WHERE intCustomerStorageId = @intCustomerStorageId
				AND dtmLastStorageAccrueDate IS NOT NULL
				AND (dbo.fnRemoveTimeOnDate(dtmLastStorageAccrueDate) >= dbo.fnRemoveTimeOnDate(@StorageChargeDate))
				AND (@strProcessType < > 'recalculate')
			  ) --1.Calculation Date less than or equal to Last Accrue Date.
			  
		OR (dbo.fnRemoveTimeOnDate(@StorageChargeDate) < dbo.fnRemoveTimeOnDate(@dtmDeliveryDate)) --2.Calculation Date less than Delivery Date.
		OR (
				  (@intAllowanceDays > 0)
			  AND (@dtmLastStorageAccrueDate IS NULL)
			  AND ((DATEDIFF(DAY, dbo.fnRemoveTimeOnDate(@dtmDeliveryDate), dbo.fnRemoveTimeOnDate(@StorageChargeDate)) + 1) <= @intAllowanceDays)
		    ) --3.Charge is not at all Accrued( Means at least once) and the No of Days between Dev.date to Calc. date less than or equal to Allowance Days.		
	BEGIN
		SET @dblStorageDuePerUnit = 0
		SET @dblStorageDueAmount = 0
		SET @StorageChargeCalculationRequired = 0
	END
	
	IF dbo.fnRemoveTimeOnDate(@StorageChargeDate) < dbo.fnRemoveTimeOnDate(@dtmDeliveryDate) --1. When Storage Calculation Date less than Delivery date.
						OR (
									 @dtmLastStorageAccrueDate IS NOT NULL
								AND (dbo.fnRemoveTimeOnDate(@dtmLastStorageAccrueDate) >= dbo.fnRemoveTimeOnDate(@StorageChargeDate))
						   ) --2. When Last Storage Accrue date greather than or equal to Storage Calculation Date.
						OR (@strAllowancePeriod='Date(s)' AND dbo.fnRemoveTimeOnDate(@dtmDeliveryDate) >= dbo.fnRemoveTimeOnDate(@dtmAllowancePeriodFrom) AND dbo.fnRemoveTimeOnDate(@StorageChargeDate) <=dbo.fnRemoveTimeOnDate(@dtmAllowancePeriodTo))   
	BEGIN
		SET @dblStorageDuePerUnit = 0
		SET @dblStorageDueAmount = 0
		SET @StorageChargeCalculationRequired = 0
	END

	IF @strProcessType = 'Unpaid' AND @strUpdateType = 'estimate'
	BEGIN
		SET @StorageChargeCalculationRequired = 0
	END
	
	IF @strAllowancePeriod='Date(s)' AND dbo.fnRemoveTimeOnDate(@dtmDeliveryDate) < dbo.fnRemoveTimeOnDate(@dtmAllowancePeriodFrom) AND (dbo.fnRemoveTimeOnDate(@StorageChargeDate) >= dbo.fnRemoveTimeOnDate(@dtmAllowancePeriodFrom) AND dbo.fnRemoveTimeOnDate(@StorageChargeDate) <=dbo.fnRemoveTimeOnDate(@dtmAllowancePeriodTo))
	BEGIN
		SET @StorageChargeDate = @dtmAllowancePeriodFrom - 1
	END

	SELECT @TotalDaysApplicableForStorageCharge = DATEDIFF(DAY, dbo.fnRemoveTimeOnDate(@dtmDeliveryDate), dbo.fnRemoveTimeOnDate(@StorageChargeDate)) + 1

	SELECT @TotalMonthsApplicableForStorageCharge = DATEDIFF(MONTH, dbo.fnRemoveTimeOnDate(@dtmDeliveryDate), dbo.fnRemoveTimeOnDate(@StorageChargeDate)) + 1

	SET @TotalOriginalMonthsApplicableForStorageCharge = @TotalMonthsApplicableForStorageCharge
	
	SET @FirstMonthFullChargeApplicable=CASE 
											WHEN ((@TotalOriginalMonthsApplicableForStorageCharge = 1) AND (@strFirstMonth <> @strLastMonth)) OR(@strFirstMonth = 'Full Month' AND @strLastMonth = 'Full Month')  THEN 1
											WHEN ((@TotalOriginalMonthsApplicableForStorageCharge > 1) AND (@strFirstMonth = 'Full Month'))																		  THEN 1
											ELSE
											0
										END	

	

	---------------Start Of Daily----------------------
	--Due from Deliverydate to StorageCalculation Date. 
	
	IF @strStorageRate = 'Daily' AND @StorageChargeCalculationRequired = 1
	BEGIN
		SELECT @intSchedulePeriodId = MIN(intSchedulePeriodId)
		FROM @tblGRStorageSchedulePeriod
		
		WHILE @intSchedulePeriodId > 0 AND @TotalDaysApplicableForStorageCharge > 0
		BEGIN
			
			SET @intPeriodKey			= NULL	    
			SET @strPeriodType          = NULL
			SET @dtmDEffectiveDate      = NULL
			SET @dtmEndingDate		    = NULL
			SET @intNumberOfDays        = NULL
			SET @dblStorageRate         = NULL
			SET @dblFeeRate				= NULL
			SET @strFeeType				= NULL
			SET @CalculatedNumberOfDays = NULL


			SELECT
			     @intPeriodKey          = intPeriodKey 
				,@strPeriodType         = strPeriodType
				,@dtmDEffectiveDate     = dtmEffectiveDate
				,@dtmEndingDate         = dtmEndingDate
				,@intNumberOfDays       = ISNULL(intNumberOfDays, 0)
				,@dblStorageRate        = dblStorageRate
										  --CASE 
												--WHEN ISNULL(strFeeType,'')='Flat'      THEN dblStorageRate 
												--WHEN ISNULL(strFeeType,'')='Per Unit'  THEN dblStorageRate + dblFeeRate
										  --END
				,@dblFeeRate		    = dblFeeRate
				,@strFeeType			= ISNULL(strFeeType,'')
			FROM @tblGRStorageSchedulePeriod
			WHERE intSchedulePeriodId   = @intSchedulePeriodId

			--Number Of Days  
			IF @strPeriodType = 'Number of Days'
			BEGIN
				--CASE 1. Start Date = Blank ,Ending Date = Blank 
				IF @dtmDEffectiveDate IS NULL AND @dtmEndingDate IS NULL
				BEGIN
					IF @intNumberOfDays <= @TotalDaysApplicableForStorageCharge
					BEGIN
					    SET @CalculatedNumberOfDays=@intNumberOfDays						
					END
					ELSE
					BEGIN
						SET @CalculatedNumberOfDays=@TotalDaysApplicableForStorageCharge						
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
							SET @CalculatedNumberOfDays=(DATEDIFF(DAY, @dtmDeliveryDate, @dtmEndingDate) + 1)							
						END
						ELSE
						BEGIN
							SET @CalculatedNumberOfDays = @intNumberOfDays							
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
						SET @TotalDaysApplicableForStorageCharge = CASE 
																		WHEN (@TotalDaysApplicableForStorageCharge - DATEDIFF(DAY, @dtmDeliveryDate, @dtmDEffectiveDate)) < 0 THEN 0
																		ELSE (@TotalDaysApplicableForStorageCharge - DATEDIFF(DAY, @dtmDeliveryDate, @dtmDEffectiveDate))
																   END
						SET @dtmDeliveryDate = @dtmDeliveryDate + DATEDIFF(DAY, @dtmDeliveryDate, @dtmDEffectiveDate)
					END

					IF @intNumberOfDays > @TotalDaysApplicableForStorageCharge
						SET @intNumberOfDays = @TotalDaysApplicableForStorageCharge

					IF (DATEDIFF(DAY, @dtmDEffectiveDate, @StorageChargeDate) + 1) > 0 AND @TotalDaysApplicableForStorageCharge > 0
					BEGIN
						IF (DATEDIFF(DAY, @dtmDEffectiveDate, @StorageChargeDate) + 1) <= @intNumberOfDays
						BEGIN
							SET @CalculatedNumberOfDays=(DATEDIFF(DAY, @dtmDEffectiveDate, @StorageChargeDate) + 1)
						END
						ELSE
						BEGIN
							SET @CalculatedNumberOfDays= @intNumberOfDays
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
							SET @CalculatedNumberOfDays=(DATEDIFF(DAY, @dtmDeliveryDate, @dtmEndingDate) + 1)												
						END
						ELSE
						BEGIN
							SET @CalculatedNumberOfDays= @TotalDaysApplicableForStorageCharge							
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
						SET @TotalDaysApplicableForStorageCharge = CASE 
																		WHEN (@TotalDaysApplicableForStorageCharge - DATEDIFF(DAY, @dtmDeliveryDate, @dtmDEffectiveDate)) < 0 THEN 0
																		ELSE (@TotalDaysApplicableForStorageCharge - DATEDIFF(DAY, @dtmDeliveryDate, @dtmDEffectiveDate))
																   END
						SET @dtmDeliveryDate = @dtmDeliveryDate + DATEDIFF(DAY, @dtmDeliveryDate, @dtmDEffectiveDate)
					END

					IF @intNumberOfDays > @TotalDaysApplicableForStorageCharge
						SET @intNumberOfDays = @TotalDaysApplicableForStorageCharge

					IF (DATEDIFF(DAY, @dtmDEffectiveDate, @StorageChargeDate) + 1) > 0 AND @TotalDaysApplicableForStorageCharge > 0
					BEGIN
						IF (DATEDIFF(DAY, @dtmDEffectiveDate, @StorageChargeDate) + 1) <= @intNumberOfDays
						BEGIN
							SET @CalculatedNumberOfDays= (DATEDIFF(DAY, @dtmDEffectiveDate, @StorageChargeDate) + 1)							
						END
						ELSE
						BEGIN
							SET @CalculatedNumberOfDays= @intNumberOfDays							
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
						SET @TotalDaysApplicableForStorageCharge = CASE 
																		WHEN (@TotalDaysApplicableForStorageCharge - DATEDIFF(DAY, @dtmDeliveryDate, @dtmDEffectiveDate)) < 0 THEN 0
																		ELSE (@TotalDaysApplicableForStorageCharge - DATEDIFF(DAY, @dtmDeliveryDate, @dtmDEffectiveDate))
																	END
						SET @dtmDeliveryDate = @dtmDeliveryDate + DATEDIFF(DAY, @dtmDeliveryDate, @dtmDEffectiveDate)
					END

					IF @dtmEndingDate > @StorageChargeDate
						SET @dtmEndingDate = @StorageChargeDate

					IF (DATEDIFF(DAY, @dtmDEffectiveDate, @StorageChargeDate) + 1) > 0 AND ((DATEDIFF(DAY, @dtmDeliveryDate, @dtmEndingDate) + 1) > 0) AND @TotalDaysApplicableForStorageCharge > 0
					BEGIN
						IF (DATEDIFF(DAY, @dtmDEffectiveDate, @dtmEndingDate) + 1) <= @TotalDaysApplicableForStorageCharge
						BEGIN
							SET @CalculatedNumberOfDays=(DATEDIFF(DAY, @dtmDEffectiveDate, @dtmEndingDate) + 1)							
						END
						ELSE
						BEGIN
							SET @CalculatedNumberOfDays=@TotalDaysApplicableForStorageCharge
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
						SET @TotalDaysApplicableForStorageCharge = CASE 
																		WHEN (@TotalDaysApplicableForStorageCharge - DATEDIFF(DAY, @dtmDeliveryDate, @dtmDEffectiveDate)) < 0 THEN 0
																		ELSE (@TotalDaysApplicableForStorageCharge - DATEDIFF(DAY, @dtmDeliveryDate, @dtmDEffectiveDate))
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
							SET @CalculatedNumberOfDays=(DATEDIFF(DAY, @dtmDEffectiveDate, @StorageChargeDate) + 1)							
						END
						ELSE
						BEGIN
							SET @CalculatedNumberOfDays= @intNumberOfDays							
						END
					END
				END
			END

			--There After			      
			IF @strPeriodType = 'Thereafter'
			BEGIN
				IF @dtmDEffectiveDate IS NULL
				BEGIN
					SET @CalculatedNumberOfDays=@TotalDaysApplicableForStorageCharge					
				END
				ELSE
				BEGIN
					IF @dtmDeliveryDate > @dtmDEffectiveDate
					BEGIN
						SET @dtmDEffectiveDate = @dtmDeliveryDate
						---SET @TotalDaysApplicableForStorageCharge = @TotalDaysApplicableForStorageCharge - DATEDIFF(DAY, @dtmDEffectiveDate, @dtmDeliveryDate)

						IF @TotalDaysApplicableForStorageCharge > 0
						BEGIN							
							SET @CalculatedNumberOfDays= @TotalDaysApplicableForStorageCharge
						END
					END
					ELSE
					BEGIN
						SET @TotalDaysApplicableForStorageCharge =  CASE 
																		WHEN (@TotalDaysApplicableForStorageCharge - DATEDIFF(DAY, @dtmDeliveryDate, @dtmDEffectiveDate)) < 0 THEN 0
																		ELSE (@TotalDaysApplicableForStorageCharge - DATEDIFF(DAY, @dtmDeliveryDate, @dtmDEffectiveDate))
																	END
						SET @dtmDeliveryDate = @dtmDEffectiveDate

						IF @TotalDaysApplicableForStorageCharge > 0
						BEGIN							
							SET @CalculatedNumberOfDays= @TotalDaysApplicableForStorageCharge
						END
					END
				END
			END
			
			IF  @strFeeType = 'Flat' 
			BEGIN
				   
				   IF @FlatFeeCalculatioFromDate IS NULL
				   BEGIN
						SET @dblFlatFeeTotal		=  ISNULL(@dblFlatFeeTotal, 0) + @dblFeeRate
                   END
				   ELSE
				   BEGIN

						IF  @dtmDeliveryDate > @FlatFeeCalculatioFromDate
						BEGIN
							SET @dblFlatFeeTotal =  ISNULL(@dblFlatFeeTotal, 0) + @dblFeeRate
						END
				   END
			END

			SET @dblStorageDuePerUnit				 = ISNULL(@dblStorageDuePerUnit, 0)     + @dblStorageRate * ISNULL(@CalculatedNumberOfDays,0)
																							+ CASE WHEN @strFeeType = 'Per Unit' THEN @dblFeeRate ELSE 0 END

			SET @TotalDaysApplicableForStorageCharge = @TotalDaysApplicableForStorageCharge - ISNULL(@CalculatedNumberOfDays,0)
			SET @dtmDeliveryDate					 = @dtmDeliveryDate						+ ISNULL(@CalculatedNumberOfDays,0)

			IF ISNULL(@CalculatedNumberOfDays,0)>0
			BEGIN
				INSERT INTO @DailyStorageCharge 
				(
					 [intPeriodKey] 
					,[strPeriodType]
					,[dtmEffectiveDate]
					,[dtmEndingDate]
					,[intNumberOfDays]
					,[CalculatedNumberOfDays]
					,[dblStorageRate]
					,[dblStorageDuePerUnit]
					,[dblCummulativeStorageDuePerUnit]								
				)
				SELECT
				 [intPeriodKey] 					= @intPeriodKey 
				,[strPeriodType]					= @strPeriodType
				,[dtmEffectiveDate]					= @dtmDeliveryDate-ISNULL(@CalculatedNumberOfDays,0)
				,[dtmEndingDate]					= @dtmDeliveryDate-1
				,[intNumberOfDays]					= @intNumberOfDays
				,[CalculatedNumberOfDays]			= @CalculatedNumberOfDays 
				,[dblStorageRate]					= @dblStorageRate
				,[dblStorageDuePerUnit]				= @dblStorageRate * ISNULL(@CalculatedNumberOfDays,0)+ CASE WHEN @strFeeType = 'Per Unit' THEN @dblFeeRate ELSE 0 END
				,[dblCummulativeStorageDuePerUnit]	= @dblStorageDuePerUnit + @dblFlatFeeTotal
			END
			
			SELECT @intSchedulePeriodId = MIN(intSchedulePeriodId)
			FROM @tblGRStorageSchedulePeriod
			WHERE intSchedulePeriodId > @intSchedulePeriodId
		END
	END
		
	---Due from Deliverydate to Last Storage Accrue Date  
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
			
			WHILE @intSchedulePeriodId > 0 AND @TotalDaysApplicableForStorageCharge > 0
			BEGIN
			
				SET @intPeriodKey			= NULL
				SET @strPeriodType			= NULL
				SET @dtmDEffectiveDate		= NULL
				SET @dtmEndingDate          = NULL
				SET @intNumberOfDays        = NULL
				SET @dblStorageRate         = NULL
				SET @CalculatedNumberOfDays = NULL
			
				SELECT 
					 @intPeriodKey			= intPeriodKey 
					,@strPeriodType			= strPeriodType
					,@dtmDEffectiveDate		= dtmEffectiveDate
					,@dtmEndingDate			= dtmEndingDate
					,@intNumberOfDays		= ISNULL(intNumberOfDays, 0)
					,@dblStorageRate		= dblStorageRate
											 --CASE 
											 -- 	   WHEN ISNULL(strFeeType,'') = 'Flat'      THEN dblStorageRate 
											 -- 	   WHEN ISNULL(strFeeType,'') = 'Per Unit'  THEN dblStorageRate + dblFeeRate
											 -- END
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
							SET @CalculatedNumberOfDays=@intNumberOfDays
						END
						ELSE
						BEGIN
							SET @CalculatedNumberOfDays=@TotalDaysApplicableForStorageCharge							
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
								SET @CalculatedNumberOfDays=(DATEDIFF(DAY, @dtmDeliveryDate, @dtmEndingDate) + 1)								
							END
							ELSE
							BEGIN
								SET @CalculatedNumberOfDays= @intNumberOfDays								
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
								SET @CalculatedNumberOfDays=(DATEDIFF(DAY, @dtmDEffectiveDate, @dtmLastStorageAccrueDate) + 1)								
							END
							ELSE
							BEGIN
								SET @CalculatedNumberOfDays= @intNumberOfDays
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
						IF @dtmEndingDate > @dtmLastStorageAccrueDate
							SET @dtmEndingDate = @dtmLastStorageAccrueDate
							
						IF (DATEDIFF(DAY, @dtmDeliveryDate, @dtmEndingDate) + 1) > 0
						BEGIN						 
							IF (DATEDIFF(DAY, @dtmDeliveryDate, @dtmEndingDate) + 1) <= @TotalDaysApplicableForStorageCharge
							BEGIN
								SET @CalculatedNumberOfDays=(DATEDIFF(DAY, @dtmDeliveryDate, @dtmEndingDate) + 1)								
							END
							ELSE
							BEGIN
								SET @CalculatedNumberOfDays=@TotalDaysApplicableForStorageCharge								
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

						IF ((DATEDIFF(DAY, @dtmDEffectiveDate, @dtmLastStorageAccrueDate) + 1) > 0) AND (@TotalDaysApplicableForStorageCharge > 0)
						BEGIN
							IF (DATEDIFF(DAY, @dtmDEffectiveDate, @dtmLastStorageAccrueDate) + 1) <= @intNumberOfDays
							BEGIN
								SET @CalculatedNumberOfDays = (DATEDIFF(DAY, @dtmDEffectiveDate, @dtmLastStorageAccrueDate) + 1)								
							END
							ELSE
							BEGIN
								SET @CalculatedNumberOfDays =  @intNumberOfDays								
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

						IF @dtmEndingDate > @dtmLastStorageAccrueDate
							SET @dtmEndingDate = @dtmLastStorageAccrueDate

						IF ((DATEDIFF(DAY, @dtmDEffectiveDate, @dtmLastStorageAccrueDate) + 1) > 0) AND ((DATEDIFF(DAY, @dtmDeliveryDate, @dtmEndingDate) + 1) > 0) AND (@TotalDaysApplicableForStorageCharge > 0)
						BEGIN
							IF (DATEDIFF(DAY, @dtmDEffectiveDate, @dtmEndingDate) + 1) <= @TotalDaysApplicableForStorageCharge
							BEGIN
								SET @CalculatedNumberOfDays = (DATEDIFF(DAY, @dtmDEffectiveDate, @dtmEndingDate) + 1)								
							END
							ELSE
							BEGIN
								SET @CalculatedNumberOfDays =  @TotalDaysApplicableForStorageCharge								
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

						IF @dtmEndingDate > @dtmLastStorageAccrueDate
							SET @dtmEndingDate = @dtmLastStorageAccrueDate

						IF @intNumberOfDays > @TotalDaysApplicableForStorageCharge
							SET @intNumberOfDays = @TotalDaysApplicableForStorageCharge

						IF ((DATEDIFF(DAY, @dtmDEffectiveDate, @dtmLastStorageAccrueDate) + 1) > 0) AND ((DATEDIFF(DAY, @dtmDeliveryDate, @dtmEndingDate) + 1) > 0) AND (@TotalDaysApplicableForStorageCharge > 0)
						BEGIN
							IF (DATEDIFF(DAY, @dtmDEffectiveDate, @dtmLastStorageAccrueDate) + 1) <= @intNumberOfDays
							BEGIN
								SET @CalculatedNumberOfDays =  (DATEDIFF(DAY, @dtmDEffectiveDate, @dtmLastStorageAccrueDate) + 1)								
							END
							ELSE
							BEGIN
								SET @CalculatedNumberOfDays =  @intNumberOfDays								
							END
						END
					END
				END

				--There After			      
				IF @strPeriodType = 'Thereafter'
				BEGIN
					IF @dtmDEffectiveDate IS NULL
					BEGIN						
						SET @CalculatedNumberOfDays =  @TotalDaysApplicableForStorageCharge
					END
					ELSE
					BEGIN
						IF @dtmDeliveryDate > @dtmDEffectiveDate
						BEGIN
							SET @dtmDEffectiveDate = @dtmDeliveryDate
							--SET @TotalDaysApplicableForStorageCharge = @TotalDaysApplicableForStorageCharge - DATEDIFF(DAY, @dtmDEffectiveDate, @dtmDeliveryDate)

							IF @TotalDaysApplicableForStorageCharge > 0
							BEGIN
								SET @CalculatedNumberOfDays= @TotalDaysApplicableForStorageCharge
							END
						END
						ELSE
						BEGIN
							SET @TotalDaysApplicableForStorageCharge = @TotalDaysApplicableForStorageCharge - DATEDIFF(DAY, @dtmDeliveryDate, @dtmDEffectiveDate)
							SET @dtmDeliveryDate = @dtmDEffectiveDate

							IF @TotalDaysApplicableForStorageCharge > 0
							BEGIN
								SET @CalculatedNumberOfDays=  @TotalDaysApplicableForStorageCharge
							END
							
						END
					END
				END			
				
				SELECT @dblStorageDuePerUnit = ISNULL(@dblStorageDuePerUnit, 0) - @dblStorageRate * ISNULL(@CalculatedNumberOfDays,0)
																				- CASE WHEN @strFeeType = 'Per Unit' THEN @dblFeeRate ELSE 0 END

				SET @TotalDaysApplicableForStorageCharge = @TotalDaysApplicableForStorageCharge - ISNULL(@CalculatedNumberOfDays,0)
				SET @dtmDeliveryDate = @dtmDeliveryDate + ISNULL(@CalculatedNumberOfDays,0)
				
				IF ISNULL(@CalculatedNumberOfDays,0)>0
				BEGIN
					INSERT INTO @DailyStorageCharge 
					(
						 [intPeriodKey] 
						,[strPeriodType]
						,[dtmEffectiveDate]
						,[dtmEndingDate]
						,[intNumberOfDays]
						,[CalculatedNumberOfDays]
						,[dblStorageRate]
						,[dblStorageDuePerUnit]
						,[dblCummulativeStorageDuePerUnit]								
					)
					SELECT 
					 [intPeriodKey] 					= @intPeriodKey 
					,[strPeriodType]					= @strPeriodType
					,[dtmEffectiveDate]					= @dtmDeliveryDate-@CalculatedNumberOfDays
					,[dtmEndingDate]					= @dtmDeliveryDate-1
					,[intNumberOfDays]					= @intNumberOfDays
					,[CalculatedNumberOfDays]			= @CalculatedNumberOfDays
					,[dblStorageRate]					= @dblStorageRate
					,[dblStorageDuePerUnit]				= -@dblStorageRate * @CalculatedNumberOfDays - CASE WHEN @strFeeType = 'Per Unit' THEN @dblFeeRate ELSE 0 END
					,[dblCummulativeStorageDuePerUnit]	= @dblStorageDuePerUnit							
				END
									
				SELECT @intSchedulePeriodId = MIN(intSchedulePeriodId)
				FROM @tblGRStorageSchedulePeriod
				WHERE intSchedulePeriodId > @intSchedulePeriodId
			END
		END
	END
	---------------End Of Daily------------------------
	
	--------------Start Of Monthly---------------------
	---Due from Deliverydate to StorageCalculation Date.
	
	IF @strStorageRate = 'Monthly' AND @StorageChargeCalculationRequired = 1
	BEGIN
		SELECT @intSchedulePeriodId = MIN(intSchedulePeriodId)
		FROM @tblGRStorageSchedulePeriod
		
		WHILE @intSchedulePeriodId > 0 AND @TotalMonthsApplicableForStorageCharge > 0
		BEGIN
			SET @intPeriodKey      = NULL
			SET @strPeriodType     = NULL
			SET @dtmDEffectiveDate = NULL
			SET @dtmEndingDate     = NULL
			SET @intNumberOfDays   = NULL
			SET @dblStorageRate    = NULL
			SET @dblFeeRate		   = NULL
			SET @strFeeType		   = NULL
		
			SELECT 
				 @intPeriodKey      = intPeriodKey
				,@strPeriodType     = strPeriodType
				,@dtmDEffectiveDate = dtmEffectiveDate
				,@dtmEndingDate		= dtmEndingDate
				,@intNumberOfDays   = ISNULL(intNumberOfDays, 0)
				,@dblStorageRate    = dblStorageRate
											  --CASE 
													--WHEN ISNULL(strFeeType,'')='Flat'      THEN dblStorageRate 
													--WHEN ISNULL(strFeeType,'')='Per Unit'  THEN dblStorageRate + dblFeeRate
											  --END
				,@dblFeeRate		    = dblFeeRate
				,@strFeeType			= ISNULL(strFeeType,'')
			FROM @tblGRStorageSchedulePeriod
			WHERE intSchedulePeriodId = @intSchedulePeriodId
			
			IF  @strFeeType = 'Flat' 
			BEGIN
			       IF @FlatFeeCalculatioFromDate IS NULL
				   BEGIN
						SET @dblFlatFeeTotal		=  ISNULL(@dblFlatFeeTotal, 0) + @dblFeeRate
			       END
				   ELSE
				   BEGIN
			
						IF  @dtmDeliveryDate > @FlatFeeCalculatioFromDate
						BEGIN
							SET @dblFlatFeeTotal =  ISNULL(@dblFlatFeeTotal, 0) + @dblFeeRate
						END
				   END
			END

			--Period Range			
			IF @strPeriodType = 'Period Range'
			BEGIN
				--CASE 1.Start Date = Blank ,Ending Date < > Blank	
				IF @dtmDEffectiveDate IS NULL AND @dtmEndingDate IS NOT NULL
				BEGIN
					IF @dtmEndingDate > @StorageChargeDate
						SET @dtmEndingDate = @StorageChargeDate

					IF (DATEDIFF(DAY, @dtmDeliveryDate, @dtmEndingDate) + 1) > 0
					BEGIN
						--When Storage calculation Date is Same month of Delivery date.
						IF @TotalOriginalMonthsApplicableForStorageCharge = 1
						BEGIN
							
							
							SELECT @dblStorageDuePerUnit =   ISNULL(@dblStorageDuePerUnit, 0) 
															+ (CASE 
																	WHEN @FirstMonthFullChargeApplicable=1 THEN @dblStorageRate 
																	ELSE (@dblStorageRate/DATEDIFF(dd,@dtmDeliveryDate,DATEADD(m,1,@dtmDeliveryDate))) * (DATEDIFF(DAY, @dtmDeliveryDate, @StorageChargeDate) + 1)
															   END)
															+ CASE WHEN @strFeeType = 'Per Unit' THEN @dblFeeRate ELSE 0 END
							
							SET @TotalMonthsApplicableForStorageCharge = @TotalMonthsApplicableForStorageCharge - 1
							
							INSERT INTO @StorageCharge
							(
							    [intPeriodKey]
							   ,[strPeriodType]
							   ,[dtmEffectiveDate]
							   ,[dtmEndingDate]
							   ,[dblStorageRate]
							   ,[MonthType]
							   ,[ChargeType]
							   ,[ChargedNumberOfDays/Months]
							   ,[dblStorageDuePerUnit]
							   ,[dblCummulativeStorageDuePerUnit]
							   ,[RemainingMonths]
							 )
							SELECT 
							 @intPeriodKey
							,@strPeriodType
							,@dtmDeliveryDate
							,CASE 
								WHEN @FirstMonthFullChargeApplicable=1 THEN DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmDeliveryDate) + 1, 0)) 
								ELSE @StorageChargeDate
							 END
							,@dblStorageRate
							,'First Month'
							,CASE 
								WHEN @FirstMonthFullChargeApplicable=1 THEN 'Full Month' 
								ELSE 'Number of Days'
							 END
							,CASE 
								WHEN @FirstMonthFullChargeApplicable=1 THEN 1 
								ELSE DATEDIFF(DAY, @dtmDeliveryDate, @StorageChargeDate) + 1
							 END
							,CASE 
								WHEN @FirstMonthFullChargeApplicable=1 THEN @dblStorageRate 
								ELSE (@dblStorageRate/DATEDIFF(dd,@dtmDeliveryDate,DATEADD(m,1,@dtmDeliveryDate))) * (DATEDIFF(DAY, @dtmDeliveryDate, @StorageChargeDate) + 1)
							  END
							,@dblStorageDuePerUnit + @dblFlatFeeTotal
							,@TotalMonthsApplicableForStorageCharge
							
							SET @dtmDeliveryDate =CASE 
													 WHEN @FirstMonthFullChargeApplicable=1 THEN  DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmDeliveryDate) + 1, 0)) + 1 
													 ELSE @StorageChargeDate + 1
												  END							
							
						END
						ELSE
						BEGIN
							IF @TotalOriginalMonthsApplicableForStorageCharge = @TotalMonthsApplicableForStorageCharge
							BEGIN
								---First Month Charge
								SELECT @dblStorageDuePerUnit =   ISNULL(@dblStorageDuePerUnit, 0) 
																+  CASE 
																	  WHEN @FirstMonthFullChargeApplicable=1 THEN @dblStorageRate 
																	  ELSE (@dblStorageRate/DATEDIFF(dd,@dtmDeliveryDate,DATEADD(m,1,@dtmDeliveryDate))) * (DATEDIFF(DAY, @dtmDeliveryDate, DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmDeliveryDate) + 1, 0))) + 1)
																   END
																+ CASE WHEN @strFeeType = 'Per Unit' THEN @dblFeeRate ELSE 0 END

								SET @TotalMonthsApplicableForStorageCharge = @TotalMonthsApplicableForStorageCharge - 1
								
								INSERT INTO @StorageCharge
								(
								    [intPeriodKey]
								   ,[strPeriodType]
								   ,[dtmEffectiveDate]
								   ,[dtmEndingDate]
								   ,[dblStorageRate]
								   ,[MonthType]
								   ,[ChargeType]
								   ,[ChargedNumberOfDays/Months]
								   ,[dblStorageDuePerUnit]
								   ,[dblCummulativeStorageDuePerUnit]
								   ,[RemainingMonths]
								 )
								SELECT 
								 @intPeriodKey
								,@strPeriodType
								,@dtmDeliveryDate
								,DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmDeliveryDate) + 1, 0))
								,@dblStorageRate
								,'First Month'
								,CASE 
									WHEN @FirstMonthFullChargeApplicable=1 THEN 'Full Month' 
									ELSE 'Number of Days'
								 END
								,CASE 
									WHEN @FirstMonthFullChargeApplicable=1 THEN 1 
									ELSE DATEDIFF(DAY, @dtmDeliveryDate, DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmDeliveryDate) + 1, 0))) + 1
								 END
								,CASE 
									WHEN @FirstMonthFullChargeApplicable=1 THEN @dblStorageRate 
									ELSE (@dblStorageRate/DATEDIFF(dd,@dtmDeliveryDate,DATEADD(m,1,@dtmDeliveryDate))) * (DATEDIFF(DAY, @dtmDeliveryDate, DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmDeliveryDate) + 1, 0))) + 1)
								  END
								,@dblStorageDuePerUnit + @dblFlatFeeTotal
								,@TotalMonthsApplicableForStorageCharge
								
								SET @dtmDeliveryDate =DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmDeliveryDate) + 1, 0)) + 1	
													  
								IF (DATEDIFF(DAY, @dtmDeliveryDate, @dtmEndingDate) + 1) > 0
								BEGIN
									IF @StorageChargeDate > @dtmEndingDate
									BEGIN
										---Intermediate Month Charges
										SELECT @dblStorageDuePerUnit = ISNULL(@dblStorageDuePerUnit, 0) + @dblStorageRate *(DATEDIFF(MONTH, @dtmDeliveryDate, @dtmEndingDate) + 1)
																	   + CASE WHEN @strFeeType = 'Per Unit' THEN @dblFeeRate ELSE 0 END
																	    																															
										SET @TotalMonthsApplicableForStorageCharge = @TotalMonthsApplicableForStorageCharge - (DATEDIFF(MONTH, @dtmDeliveryDate, @dtmEndingDate) + 1)
											
											INSERT INTO @StorageCharge
											(
											    [intPeriodKey]
											   ,[strPeriodType]
											   ,[dtmEffectiveDate]
											   ,[dtmEndingDate]
											   ,[dblStorageRate]
											   ,[MonthType]
											   ,[ChargeType]
											   ,[ChargedNumberOfDays/Months]
											   ,[dblStorageDuePerUnit]
											   ,[dblCummulativeStorageDuePerUnit]
											   ,[RemainingMonths]
											 )
											SELECT 
											 @intPeriodKey
											,@strPeriodType
											,@dtmDeliveryDate
											,DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmEndingDate) + 1, 0))
											,@dblStorageRate
											,'Intermediate Month'
											,'Full Month'
											,DATEDIFF(MONTH, @dtmDeliveryDate, @dtmEndingDate) + 1
											,@dblStorageRate * (DATEDIFF(MONTH, @dtmDeliveryDate, @dtmEndingDate) + 1)
											,@dblStorageDuePerUnit + @dblFlatFeeTotal
											,@TotalMonthsApplicableForStorageCharge
													
										SET @dtmDeliveryDate = DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmEndingDate) + 1, 0)) + 1
									END
									ELSE
									BEGIN
										--Intermediate Month charges
										SELECT @dblStorageDuePerUnit = ISNULL(@dblStorageDuePerUnit, 0)
																	   + @dblStorageRate * (DATEDIFF(MONTH, @dtmDeliveryDate, DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @StorageChargeDate), 0))) + 1)
																	   + CASE WHEN @strFeeType = 'Per Unit' THEN @dblFeeRate ELSE 0 END
																	   
										SET @TotalMonthsApplicableForStorageCharge = @TotalMonthsApplicableForStorageCharge - (DATEDIFF(MONTH, @dtmDeliveryDate, DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @StorageChargeDate), 0))) + 1)
										
											INSERT INTO @StorageCharge
											(
											    [intPeriodKey]
											   ,[strPeriodType]
											   ,[dtmEffectiveDate]
											   ,[dtmEndingDate]
											   ,[dblStorageRate]
											   ,[MonthType]
											   ,[ChargeType]
											   ,[ChargedNumberOfDays/Months]
											   ,[dblStorageDuePerUnit]
											   ,[dblCummulativeStorageDuePerUnit]
											   ,[RemainingMonths]
											 )
											 SELECT 
											 @intPeriodKey
											,@strPeriodType
											,@dtmDeliveryDate
											,DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @StorageChargeDate), 0))
											,@dblStorageRate
											,'Intermediate Month'
											,'Full Month'
											,DATEDIFF(MONTH, @dtmDeliveryDate, DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @StorageChargeDate), 0))) + 1
											,@dblStorageRate * (DATEDIFF(MONTH, @dtmDeliveryDate, DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @StorageChargeDate), 0))) + 1)
											,@dblStorageDuePerUnit + @dblFlatFeeTotal
											,@TotalMonthsApplicableForStorageCharge
											
										SET @dtmDeliveryDate = DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @StorageChargeDate), 0)) + 1

										--Last Month Charge
										SELECT @dblStorageDuePerUnit = ISNULL(@dblStorageDuePerUnit, 0) + CASE 
																												WHEN @strLastMonth = 'Full Month' THEN @dblStorageRate 
																												ELSE (@dblStorageRate/DATEDIFF(dd,@dtmDeliveryDate,DATEADD(m,1,@dtmDeliveryDate))) * (DATEDIFF(DAY, @dtmDeliveryDate, @StorageChargeDate) + 1)
																										   END

																	  + CASE WHEN @strFeeType = 'Per Unit' THEN @dblFeeRate ELSE 0 END
																										   
										SET @TotalMonthsApplicableForStorageCharge = @TotalMonthsApplicableForStorageCharge - 1

										INSERT INTO @StorageCharge
										(
										    [intPeriodKey]
										   ,[strPeriodType]
										   ,[dtmEffectiveDate]
										   ,[dtmEndingDate]
										   ,[dblStorageRate]
										   ,[MonthType]
										   ,[ChargeType]
										   ,[ChargedNumberOfDays/Months]
										   ,[dblStorageDuePerUnit]
										   ,[dblCummulativeStorageDuePerUnit]
										   ,[RemainingMonths]
										 )
										 SELECT 
										 @intPeriodKey
										,@strPeriodType
										,@dtmDeliveryDate
										,CASE 
											WHEN @strLastMonth = 'Full Month' THEN DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @StorageChargeDate)+1, 0)) 
											ELSE @StorageChargeDate
										 END
										,@dblStorageRate
										,'Last Month'
										,CASE 
											WHEN @strLastMonth = 'Full Month' THEN 'Full Month' 
											ELSE 'Number of Days'
										 END
										,CASE 
											WHEN @strLastMonth = 'Full Month' THEN 1 
											ELSE DATEDIFF(DAY, @dtmDeliveryDate, @StorageChargeDate) + 1
										 END
										,CASE 
											WHEN @strLastMonth = 'Full Month' THEN @dblStorageRate 
											ELSE (@dblStorageRate/DATEDIFF(dd,@dtmDeliveryDate,DATEADD(m,1,@dtmDeliveryDate))) * (DATEDIFF(DAY, @dtmDeliveryDate, @StorageChargeDate) + 1)
										 END 
										,@dblStorageDuePerUnit + @dblFlatFeeTotal
										,@TotalMonthsApplicableForStorageCharge

										SET @dtmDeliveryDate =CASE 
																 WHEN @strLastMonth = 'Full Month' THEN  DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @StorageChargeDate) + 1, 0)) + 1 
																 ELSE @StorageChargeDate + 1
															  END
															  											
									END
								END
							END
							ELSE
							BEGIN
								IF (DATEDIFF(DAY, @dtmDeliveryDate, @dtmEndingDate) + 1) > 0
								BEGIN
									IF @StorageChargeDate > @dtmEndingDate
									BEGIN
										---Intermediate Month Charges
										SELECT @dblStorageDuePerUnit = ISNULL(@dblStorageDuePerUnit, 0) + @dblStorageRate * (DATEDIFF(MONTH, @dtmDeliveryDate, @dtmEndingDate) + 1)
																	  + CASE WHEN @strFeeType = 'Per Unit' THEN @dblFeeRate ELSE 0 END

										SET @TotalMonthsApplicableForStorageCharge = @TotalMonthsApplicableForStorageCharge - (DATEDIFF(MONTH, @dtmDeliveryDate, @dtmEndingDate) + 1)
										
											INSERT INTO @StorageCharge
											(
											    [intPeriodKey]
											   ,[strPeriodType]
											   ,[dtmEffectiveDate]
											   ,[dtmEndingDate]
											   ,[dblStorageRate]
											   ,[MonthType]
											   ,[ChargeType]
											   ,[ChargedNumberOfDays/Months]
											   ,[dblStorageDuePerUnit]
											   ,[dblCummulativeStorageDuePerUnit]
											   ,[RemainingMonths]
											 )											
											 SELECT 
											 @intPeriodKey
											,@strPeriodType
											,@dtmDeliveryDate
											,DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmEndingDate) + 1, 0))
											,@dblStorageRate
											,'Intermediate Month'
											,'Full Month'
											,DATEDIFF(MONTH, @dtmDeliveryDate, @dtmEndingDate) + 1
											,@dblStorageRate * (DATEDIFF(MONTH, @dtmDeliveryDate, @dtmEndingDate) + 1)
											,@dblStorageDuePerUnit + @dblFlatFeeTotal
											,@TotalMonthsApplicableForStorageCharge
											
										SET @dtmDeliveryDate = DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmEndingDate) + 1, 0)) + 1
									END
									ELSE
									BEGIN
										--Intermediate Month charges
										SELECT @dblStorageDuePerUnit = ISNULL(@dblStorageDuePerUnit, 0) + @dblStorageRate * (DATEDIFF(MONTH, @dtmDeliveryDate, DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @StorageChargeDate), 0))) + 1)
																	  + CASE WHEN @strFeeType = 'Per Unit' THEN @dblFeeRate ELSE 0 END
										SET @TotalMonthsApplicableForStorageCharge = @TotalMonthsApplicableForStorageCharge - (DATEDIFF(MONTH, @dtmDeliveryDate, DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @StorageChargeDate), 0))) + 1)
										
											INSERT INTO @StorageCharge
											(
											    [intPeriodKey]
											   ,[strPeriodType]
											   ,[dtmEffectiveDate]
											   ,[dtmEndingDate]
											   ,[dblStorageRate]
											   ,[MonthType]
											   ,[ChargeType]
											   ,[ChargedNumberOfDays/Months]
											   ,[dblStorageDuePerUnit]
											   ,[dblCummulativeStorageDuePerUnit]
											   ,[RemainingMonths]
											 )
											 SELECT 
											 @intPeriodKey
											,@strPeriodType
											,@dtmDeliveryDate
											,DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @StorageChargeDate), 0))
											,@dblStorageRate
											,'Intermediate Month'
											,'Full Month'
											,DATEDIFF(MONTH, @dtmDeliveryDate, DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @StorageChargeDate), 0))) + 1
											,@dblStorageRate * (DATEDIFF(MONTH, @dtmDeliveryDate, DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @StorageChargeDate), 0))) + 1)
											,@dblStorageDuePerUnit + @dblFlatFeeTotal
											,@TotalMonthsApplicableForStorageCharge
											
										SET @dtmDeliveryDate = DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @StorageChargeDate), 0)) + 1

										--Last Month Charge
										SELECT @dblStorageDuePerUnit = ISNULL(@dblStorageDuePerUnit, 0) + CASE 
																												WHEN @strLastMonth = 'Full Month' THEN @dblStorageRate 
																												ELSE (@dblStorageRate/DATEDIFF(dd,@dtmDeliveryDate,DATEADD(m,1,@dtmDeliveryDate))) * (DATEDIFF(DAY, @dtmDeliveryDate, @StorageChargeDate) + 1)
																										   END
																	  + CASE WHEN @strFeeType = 'Per Unit' THEN @dblFeeRate ELSE 0 END

										SET @TotalMonthsApplicableForStorageCharge = @TotalMonthsApplicableForStorageCharge - 1

										INSERT INTO @StorageCharge([strPeriodType],[dtmEffectiveDate],[dtmEndingDate],[dblStorageRate],[MonthType],[ChargeType],[ChargedNumberOfDays/Months],[dblStorageDuePerUnit],[dblCummulativeStorageDuePerUnit],[RemainingMonths])										
										SELECT @strPeriodType
										,@dtmDeliveryDate
										,CASE 
											WHEN @strLastMonth = 'Full Month' THEN DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @StorageChargeDate)+1, 0)) 
											ELSE @StorageChargeDate
										 END
										,@dblStorageRate
										,'Last Month'
										,CASE 
											WHEN @strLastMonth = 'Full Month' THEN 'Full Month' 
											ELSE 'Number of Days'
										 END
										,CASE 
											WHEN @strLastMonth = 'Full Month' THEN 1 
											ELSE DATEDIFF(DAY, @dtmDeliveryDate, @StorageChargeDate) + 1
										 END
										,CASE 
											WHEN @strLastMonth = 'Full Month' THEN @dblStorageRate 
											ELSE (@dblStorageRate/DATEDIFF(dd,@dtmDeliveryDate,DATEADD(m,1,@dtmDeliveryDate))) * (DATEDIFF(DAY, @dtmDeliveryDate, @StorageChargeDate) + 1)
										 END 
										,@dblStorageDuePerUnit + @dblFlatFeeTotal
										,@TotalMonthsApplicableForStorageCharge

										SET @dtmDeliveryDate =CASE 
																 WHEN @strLastMonth = 'Full Month' THEN  DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @StorageChargeDate) + 1, 0)) + 1 
																 ELSE @StorageChargeDate + 1
															  END
									END
								END
							END
						END
					END
				END
				
				--CASE 2.Start Date < > Blank, Ending Date = Blank
				ELSE IF @dtmDEffectiveDate IS NOT NULL AND @dtmEndingDate IS NULL
				BEGIN
					IF @dtmDeliveryDate > @dtmDEffectiveDate
						SET @dtmDEffectiveDate = @dtmDeliveryDate
					ELSE
					BEGIN
						SET @TotalMonthsApplicableForStorageCharge = CASE 
																		 WHEN (@TotalMonthsApplicableForStorageCharge - DATEDIFF(MONTH, @dtmDeliveryDate, @dtmDEffectiveDate)) < 0 THEN 0
																		 ELSE (@TotalMonthsApplicableForStorageCharge - DATEDIFF(MONTH, @dtmDeliveryDate, @dtmDEffectiveDate))
																	 END
						SET @dtmDeliveryDate = @dtmDEffectiveDate
					END
					
					IF (DATEDIFF(DAY, @dtmDEffectiveDate, @StorageChargeDate) + 1) > 0 AND @TotalMonthsApplicableForStorageCharge > 0
					BEGIN	
						
						--When Storage calculation Date is Same month of Delivery date.
						IF @TotalOriginalMonthsApplicableForStorageCharge = 1
						BEGIN
							SELECT @dblStorageDuePerUnit =   ISNULL(@dblStorageDuePerUnit, 0)+ CASE 
																									WHEN @FirstMonthFullChargeApplicable=1 THEN @dblStorageRate 
																									ELSE (@dblStorageRate/DATEDIFF(dd,@dtmDeliveryDate,DATEADD(m,1,@dtmDeliveryDate))) * (DATEDIFF(DAY, @dtmDeliveryDate, @StorageChargeDate) + 1)
																							   END
														  + CASE WHEN @strFeeType = 'Per Unit' THEN @dblFeeRate ELSE 0 END
							
							SET @TotalMonthsApplicableForStorageCharge = @TotalMonthsApplicableForStorageCharge - 1
							
							INSERT INTO @StorageCharge
							(
							    [intPeriodKey]
							   ,[strPeriodType]
							   ,[dtmEffectiveDate]
							   ,[dtmEndingDate]
							   ,[dblStorageRate]
							   ,[MonthType]
							   ,[ChargeType]
							   ,[ChargedNumberOfDays/Months]
							   ,[dblStorageDuePerUnit]
							   ,[dblCummulativeStorageDuePerUnit]
							   ,[RemainingMonths]
							 )
							SELECT 
							 @intPeriodKey
							,@strPeriodType
							,@dtmDeliveryDate
							,CASE 
								WHEN @FirstMonthFullChargeApplicable=1 THEN DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmDeliveryDate) + 1, 0)) 
								ELSE @StorageChargeDate
							 END
							,@dblStorageRate
							,'First Month'
							,CASE 
								WHEN @FirstMonthFullChargeApplicable=1 THEN 'Full Month' 
								ELSE 'Number of Days'
							 END
							,CASE 
								WHEN @FirstMonthFullChargeApplicable=1 THEN 1 
								ELSE DATEDIFF(DAY, @dtmDeliveryDate, @StorageChargeDate) + 1
							 END
							,CASE 
								WHEN @FirstMonthFullChargeApplicable=1 THEN @dblStorageRate 
								ELSE (@dblStorageRate/DATEDIFF(dd,@dtmDeliveryDate,DATEADD(m,1,@dtmDeliveryDate))) * (DATEDIFF(DAY, @dtmDeliveryDate, @StorageChargeDate) + 1)
							  END
							,@dblStorageDuePerUnit + @dblFlatFeeTotal
							,@TotalMonthsApplicableForStorageCharge
							
							SET @dtmDeliveryDate =CASE 
													 WHEN @FirstMonthFullChargeApplicable=1 THEN  DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmDeliveryDate) + 1, 0)) + 1 
													 ELSE @StorageChargeDate + 1
												  END
						END
						ELSE
						BEGIN
							IF @TotalOriginalMonthsApplicableForStorageCharge = @TotalMonthsApplicableForStorageCharge
							BEGIN
								---First Month Charge
								IF @strFirstMonth = 'Full Month'
								BEGIN
									SELECT @dblStorageDuePerUnit = ISNULL(@dblStorageDuePerUnit, 0) + @dblStorageRate
																  + CASE WHEN @strFeeType = 'Per Unit' THEN @dblFeeRate ELSE 0 END

									SET @TotalMonthsApplicableForStorageCharge = @TotalMonthsApplicableForStorageCharge - 1
									
									INSERT INTO @StorageCharge
									( 
									    [intPeriodKey] 
									   ,[strPeriodType] 
									   ,[dtmEffectiveDate] 
									   ,[dtmEndingDate] 
									   ,[dblStorageRate] 
									   ,[MonthType] 
									   ,[ChargeType] 
									   ,[ChargedNumberOfDays/Months] 
									   ,[dblStorageDuePerUnit] 
									   ,[dblCummulativeStorageDuePerUnit] 
									   ,[RemainingMonths] 
									 ) 
									 SELECT 
									 @intPeriodKey
									,@strPeriodType
									,@dtmDeliveryDate
									,DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmDeliveryDate) + 1, 0))
									,@dblStorageRate
									,'First Month'
									,'Full Month'
									,1
									,@dblStorageRate
									,@dblStorageDuePerUnit + @dblFlatFeeTotal
									,@TotalMonthsApplicableForStorageCharge
									
									SET @dtmDeliveryDate = DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmDeliveryDate) + 1, 0)) + 1
								END
								ELSE
								BEGIN									
									SELECT @dblStorageDuePerUnit = ISNULL(@dblStorageDuePerUnit, 0) +(@dblStorageRate/DATEDIFF(dd,@dtmDeliveryDate,DATEADD(m,1,@dtmDeliveryDate))) * (DATEDIFF(DAY, @dtmDeliveryDate, DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmDeliveryDate) + 1, 0))) + 1)
																  + CASE WHEN @strFeeType = 'Per Unit' THEN @dblFeeRate ELSE 0 END

									SET @TotalMonthsApplicableForStorageCharge = @TotalMonthsApplicableForStorageCharge - 1
									
									 INSERT INTO @StorageCharge
									 (
									     [intPeriodKey]
									    ,[strPeriodType]
									    ,[dtmEffectiveDate]
									    ,[dtmEndingDate]
									    ,[dblStorageRate]
									    ,[MonthType]
									    ,[ChargeType]
									    ,[ChargedNumberOfDays/Months]
									    ,[dblStorageDuePerUnit]
									    ,[dblCummulativeStorageDuePerUnit]
									    ,[RemainingMonths]
									  )									 
									 SELECT 
									 @intPeriodKey
									,@strPeriodType
									,@dtmDeliveryDate
									,DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmDeliveryDate) + 1, 0))
									,@dblStorageRate
									,'First Month'
									,'Number of Days'
									,DATEDIFF(DAY, @dtmDeliveryDate, DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmDeliveryDate) + 1, 0))) + 1
									,(@dblStorageRate/DATEDIFF(dd,@dtmDeliveryDate,DATEADD(m,1,@dtmDeliveryDate))) * (DATEDIFF(DAY, @dtmDeliveryDate, DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmDeliveryDate) + 1, 0))) + 1)
									,@dblStorageDuePerUnit + @dblFlatFeeTotal
									,@TotalMonthsApplicableForStorageCharge
									
									SET @dtmDeliveryDate = DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmDeliveryDate) + 1, 0)) + 1
								END
								
								---Intermediate and Last Month Charges
								IF (DATEDIFF(DAY, @dtmDeliveryDate, @StorageChargeDate) + 1) > 0
								BEGIN
								
									IF @TotalMonthsApplicableForStorageCharge > 1
									BEGIN
									
										--Intermediate Month charges
										SELECT @dblStorageDuePerUnit = ISNULL(@dblStorageDuePerUnit, 0) + @dblStorageRate * (DATEDIFF(MONTH, @dtmDeliveryDate, DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @StorageChargeDate), 0))) + 1)
																	  + CASE WHEN @strFeeType = 'Per Unit' THEN @dblFeeRate ELSE 0 END

										SET @TotalMonthsApplicableForStorageCharge = @TotalMonthsApplicableForStorageCharge - (DATEDIFF(MONTH, @dtmDeliveryDate, DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @StorageChargeDate), 0))) + 1)
										
										 INSERT INTO @StorageCharge
										 (
										     [intPeriodKey]
										    ,[strPeriodType]
										    ,[dtmEffectiveDate]
										    ,[dtmEndingDate]
										    ,[dblStorageRate]
										    ,[MonthType]
										    ,[ChargeType]
										    ,[ChargedNumberOfDays/Months]
										    ,[dblStorageDuePerUnit]
										    ,[dblCummulativeStorageDuePerUnit]
										    ,[RemainingMonths]
										  )
										 SELECT 
										 @intPeriodKey
										,@strPeriodType
										,@dtmDeliveryDate
										,DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @StorageChargeDate), 0))
										,@dblStorageRate
										,'Intermediate Month'
										,'Full Month'
										,DATEDIFF(MONTH, @dtmDeliveryDate, DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @StorageChargeDate), 0))) + 1
										,@dblStorageRate * (DATEDIFF(MONTH, @dtmDeliveryDate, DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @StorageChargeDate), 0))) + 1)
										,@dblStorageDuePerUnit + @dblFlatFeeTotal
										,@TotalMonthsApplicableForStorageCharge
											
										SET @dtmDeliveryDate = DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @StorageChargeDate), 0)) + 1

										--Last Month Charge
										IF @strLastMonth = 'Full Month'
										BEGIN
											SELECT @dblStorageDuePerUnit = ISNULL(@dblStorageDuePerUnit, 0) + @dblStorageRate
																		  + CASE WHEN @strFeeType = 'Per Unit' THEN @dblFeeRate ELSE 0 END

											SET @TotalMonthsApplicableForStorageCharge = @TotalMonthsApplicableForStorageCharge - 1
											
											INSERT INTO @StorageCharge
											(
											    [intPeriodKey]
											   ,[strPeriodType]
											   ,[dtmEffectiveDate]
											   ,[dtmEndingDate]
											   ,[dblStorageRate]
											   ,[MonthType]
											   ,[ChargeType]
											   ,[ChargedNumberOfDays/Months]
											   ,[dblStorageDuePerUnit]
											   ,[dblCummulativeStorageDuePerUnit]
											   ,[RemainingMonths]
											 )											
											SELECT 
											 @intPeriodKey
											,@strPeriodType
											,@dtmDeliveryDate
											,DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @StorageChargeDate)+1, 0))
											,@dblStorageRate
											,'Last Month'
											,'Full Month'
											,1
											,@dblStorageRate
											,@dblStorageDuePerUnit + @dblFlatFeeTotal
											,@TotalMonthsApplicableForStorageCharge
											
											SET @dtmDeliveryDate = DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @StorageChargeDate) + 1, 0)) + 1
										END
										ELSE
										BEGIN
											SELECT @dblStorageDuePerUnit = ISNULL(@dblStorageDuePerUnit, 0) + (@dblStorageRate/DATEDIFF(dd,@dtmDeliveryDate,DATEADD(m,1,@dtmDeliveryDate))) * (DATEDIFF(DAY, @dtmDeliveryDate, @StorageChargeDate) + 1)
																		  + CASE WHEN @strFeeType = 'Per Unit' THEN @dblFeeRate ELSE 0 END

											SET @TotalMonthsApplicableForStorageCharge = @TotalMonthsApplicableForStorageCharge - 1
											
											INSERT INTO @StorageCharge
											( 
											    [intPeriodKey] 
											   ,[strPeriodType] 
											   ,[dtmEffectiveDate] 
											   ,[dtmEndingDate] 
											   ,[dblStorageRate] 
											   ,[MonthType] 
											   ,[ChargeType] 
											   ,[ChargedNumberOfDays/Months] 
											   ,[dblStorageDuePerUnit] 
											   ,[dblCummulativeStorageDuePerUnit] 
											   ,[RemainingMonths] 
											 )
											 SELECT 
											 @intPeriodKey
											,@strPeriodType
											,@dtmDeliveryDate
											,@StorageChargeDate
											,@dblStorageRate
											,'Last Month'
											,'Number of Days'
											,DATEDIFF(DAY, @dtmDeliveryDate, @StorageChargeDate) + 1
											,(@dblStorageRate/DATEDIFF(dd,@dtmDeliveryDate,DATEADD(m,1,@dtmDeliveryDate))) * (DATEDIFF(DAY, @dtmDeliveryDate, @StorageChargeDate) + 1)
											,@dblStorageDuePerUnit + @dblFlatFeeTotal
											,@TotalMonthsApplicableForStorageCharge
											
											SET @dtmDeliveryDate = @StorageChargeDate + 1
										END
									END
									ELSE
									BEGIN
										--Last Month Charge
										IF @strLastMonth = 'Full Month'
										BEGIN
											SELECT @dblStorageDuePerUnit = ISNULL(@dblStorageDuePerUnit, 0) + @dblStorageRate
																		  + CASE WHEN @strFeeType = 'Per Unit' THEN @dblFeeRate ELSE 0 END

											SET @TotalMonthsApplicableForStorageCharge = @TotalMonthsApplicableForStorageCharge - 1
											
											INSERT INTO @StorageCharge
											( 
											    [intPeriodKey] 
											   ,[strPeriodType] 
											   ,[dtmEffectiveDate] 
											   ,[dtmEndingDate] 
											   ,[dblStorageRate] 
											   ,[MonthType] 
											   ,[ChargeType] 
											   ,[ChargedNumberOfDays/Months] 
											   ,[dblStorageDuePerUnit] 
											   ,[dblCummulativeStorageDuePerUnit] 
											   ,[RemainingMonths] 
											 ) 
											 SELECT 
											 @intPeriodKey
											,@strPeriodType
											,@dtmDeliveryDate
											,DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @StorageChargeDate)+1, 0))
											,@dblStorageRate
											,'Last Month'
											,'Full Month'
											,1
											,@dblStorageRate
											,@dblStorageDuePerUnit + @dblFlatFeeTotal
											,@TotalMonthsApplicableForStorageCharge
											
											SET @dtmDeliveryDate = DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @StorageChargeDate) + 1, 0)) + 1
										END
										ELSE
										BEGIN
											SELECT @dblStorageDuePerUnit = ISNULL(@dblStorageDuePerUnit, 0) + (@dblStorageRate/DATEDIFF(dd,@dtmDeliveryDate,DATEADD(m,1,@dtmDeliveryDate))) * (DATEDIFF(DAY, @dtmDeliveryDate, @StorageChargeDate) + 1)
																		  + CASE WHEN @strFeeType = 'Per Unit' THEN @dblFeeRate ELSE 0 END

											SET @TotalMonthsApplicableForStorageCharge = @TotalMonthsApplicableForStorageCharge - 1
											
											INSERT INTO @StorageCharge
											( 
											    [intPeriodKey] 
											   ,[strPeriodType] 
											   ,[dtmEffectiveDate] 
											   ,[dtmEndingDate] 
											   ,[dblStorageRate] 
											   ,[MonthType] 
											   ,[ChargeType] 
											   ,[ChargedNumberOfDays/Months] 
											   ,[dblStorageDuePerUnit] 
											   ,[dblCummulativeStorageDuePerUnit] 
											   ,[RemainingMonths] 
											 )
											 SELECT 
											 @intPeriodKey
											,@strPeriodType
											,@dtmDeliveryDate
											,@StorageChargeDate
											,@dblStorageRate
											,'Last Month'
											,'Number of Days'
											,DATEDIFF(DAY, @dtmDeliveryDate, @StorageChargeDate) + 1
											,(@dblStorageRate/DATEDIFF(dd,@dtmDeliveryDate,DATEADD(m,1,@dtmDeliveryDate))) * (DATEDIFF(DAY, @dtmDeliveryDate, @StorageChargeDate) + 1)
											,@dblStorageDuePerUnit + @dblFlatFeeTotal
											,@TotalMonthsApplicableForStorageCharge
											
											SET @dtmDeliveryDate = @StorageChargeDate + 1
										END	
									END	
								END
							END
							ELSE
							BEGIN
								---Intermediate and Last Month Charges
								IF (DATEDIFF(DAY, @dtmDeliveryDate, @StorageChargeDate) + 1) > 0
								BEGIN
								
									IF @TotalMonthsApplicableForStorageCharge > 1
									BEGIN									
										--Intermediate Month charges
										SELECT @dblStorageDuePerUnit = ISNULL(@dblStorageDuePerUnit, 0) + @dblStorageRate * (DATEDIFF(MONTH, @dtmDeliveryDate, DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @StorageChargeDate), 0))) + 1)
																	  + CASE WHEN @strFeeType = 'Per Unit' THEN @dblFeeRate ELSE 0 END

										SET @TotalMonthsApplicableForStorageCharge = @TotalMonthsApplicableForStorageCharge - (DATEDIFF(MONTH, @dtmDeliveryDate, DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @StorageChargeDate), 0))) + 1)
										
										 INSERT INTO @StorageCharge
										 (
										     [intPeriodKey]
										    ,[strPeriodType]
										    ,[dtmEffectiveDate]
										    ,[dtmEndingDate]
										    ,[dblStorageRate]
										    ,[MonthType]
										    ,[ChargeType]
										    ,[ChargedNumberOfDays/Months]
										    ,[dblStorageDuePerUnit]
										    ,[dblCummulativeStorageDuePerUnit]
										    ,[RemainingMonths]
										  )										 
										 SELECT 
										 @intPeriodKey
										,@strPeriodType
										,@dtmDeliveryDate
										,DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @StorageChargeDate), 0))
										,@dblStorageRate
										,'Intermediate Month'
										,'Full Month'
										,DATEDIFF(MONTH, @dtmDeliveryDate, DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @StorageChargeDate), 0))) + 1
										,@dblStorageRate * (DATEDIFF(MONTH, @dtmDeliveryDate, DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @StorageChargeDate), 0))) + 1)
										,@dblStorageDuePerUnit + @dblFlatFeeTotal
										,@TotalMonthsApplicableForStorageCharge
											
										SET @dtmDeliveryDate = DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @StorageChargeDate), 0)) + 1

										--Last Month Charge
										IF @strLastMonth = 'Full Month'
										BEGIN
											SELECT @dblStorageDuePerUnit = ISNULL(@dblStorageDuePerUnit, 0) + @dblStorageRate
																		  + CASE WHEN @strFeeType = 'Per Unit' THEN @dblFeeRate ELSE 0 END

											SET @TotalMonthsApplicableForStorageCharge = @TotalMonthsApplicableForStorageCharge - 1
											
											INSERT INTO @StorageCharge
											(
											    [intPeriodKey]
											   ,[strPeriodType]
											   ,[dtmEffectiveDate]
											   ,[dtmEndingDate]
											   ,[dblStorageRate]
											   ,[MonthType]
											   ,[ChargeType]
											   ,[ChargedNumberOfDays/Months]
											   ,[dblStorageDuePerUnit]
											   ,[dblCummulativeStorageDuePerUnit]
											   ,[RemainingMonths]
											 )
											SELECT 
											 @intPeriodKey
											,@strPeriodType
											,@dtmDeliveryDate
											,DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @StorageChargeDate)+1, 0))
											,@dblStorageRate
											,'Last Month'
											,'Full Month'
											,1
											,@dblStorageRate
											,@dblStorageDuePerUnit + @dblFlatFeeTotal
											,@TotalMonthsApplicableForStorageCharge
											
											SET @dtmDeliveryDate = DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @StorageChargeDate) + 1, 0)) + 1
										END
										ELSE
										BEGIN
											SELECT @dblStorageDuePerUnit = ISNULL(@dblStorageDuePerUnit, 0) + (@dblStorageRate/DATEDIFF(dd,@dtmDeliveryDate,DATEADD(m,1,@dtmDeliveryDate))) * (DATEDIFF(DAY, @dtmDeliveryDate, @StorageChargeDate) + 1)
																		  + CASE WHEN @strFeeType = 'Per Unit' THEN @dblFeeRate ELSE 0 END

											SET @TotalMonthsApplicableForStorageCharge = @TotalMonthsApplicableForStorageCharge - 1
											
											INSERT INTO @StorageCharge
											(
											    [intPeriodKey]
											   ,[strPeriodType]
											   ,[dtmEffectiveDate]
											   ,[dtmEndingDate]
											   ,[dblStorageRate]
											   ,[MonthType]
											   ,[ChargeType]
											   ,[ChargedNumberOfDays/Months]
											   ,[dblStorageDuePerUnit]
											   ,[dblCummulativeStorageDuePerUnit]
											   ,[RemainingMonths]
											 )
											 SELECT 
											 @intPeriodKey
											,@strPeriodType
											,@dtmDeliveryDate
											,@StorageChargeDate
											,@dblStorageRate
											,'Last Month'
											,'Number of Days'
											,DATEDIFF(DAY, @dtmDeliveryDate, @StorageChargeDate) + 1
											,(@dblStorageRate/DATEDIFF(dd,@dtmDeliveryDate,DATEADD(m,1,@dtmDeliveryDate))) * (DATEDIFF(DAY, @dtmDeliveryDate, @StorageChargeDate) + 1)
											,@dblStorageDuePerUnit + @dblFlatFeeTotal
											,@TotalMonthsApplicableForStorageCharge
											
											SET @dtmDeliveryDate = @StorageChargeDate + 1
										END
									END
									ELSE
									BEGIN
										--Last Month Charge
										IF @strLastMonth = 'Full Month'
										BEGIN
											SELECT @dblStorageDuePerUnit = ISNULL(@dblStorageDuePerUnit, 0) + @dblStorageRate
																		   + CASE WHEN @strFeeType = 'Per Unit' THEN @dblFeeRate ELSE 0 END
											SET @TotalMonthsApplicableForStorageCharge = @TotalMonthsApplicableForStorageCharge - 1
											
											INSERT INTO @StorageCharge
											(
											    [intPeriodKey]
											   ,[strPeriodType]
											   ,[dtmEffectiveDate]
											   ,[dtmEndingDate]
											   ,[dblStorageRate]
											   ,[MonthType]
											   ,[ChargeType]
											   ,[ChargedNumberOfDays/Months]
											   ,[dblStorageDuePerUnit]
											   ,[dblCummulativeStorageDuePerUnit]
											   ,[RemainingMonths]
											 )											
											SELECT 
											 @intPeriodKey
											,@strPeriodType
											,@dtmDeliveryDate
											,DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @StorageChargeDate)+1, 0))
											,@dblStorageRate
											,'Last Month'
											,'Full Month'
											,1
											,@dblStorageRate
											,@dblStorageDuePerUnit + @dblFlatFeeTotal
											,@TotalMonthsApplicableForStorageCharge
											
											SET @dtmDeliveryDate = DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @StorageChargeDate) + 1, 0)) + 1
										END
										ELSE
										BEGIN
											SELECT @dblStorageDuePerUnit = ISNULL(@dblStorageDuePerUnit, 0) + (@dblStorageRate/DATEDIFF(dd,@dtmDeliveryDate,DATEADD(m,1,@dtmDeliveryDate))) * (DATEDIFF(DAY, @dtmDeliveryDate, @StorageChargeDate) + 1)
																		  + CASE WHEN @strFeeType = 'Per Unit' THEN @dblFeeRate ELSE 0 END

											SET @TotalMonthsApplicableForStorageCharge = @TotalMonthsApplicableForStorageCharge - 1
											
											INSERT INTO @StorageCharge
											(
											    [intPeriodKey]
											   ,[strPeriodType]
											   ,[dtmEffectiveDate]
											   ,[dtmEndingDate]
											   ,[dblStorageRate]
											   ,[MonthType]
											   ,[ChargeType]
											   ,[ChargedNumberOfDays/Months]
											   ,[dblStorageDuePerUnit]
											   ,[dblCummulativeStorageDuePerUnit]
											   ,[RemainingMonths]
											 )
											SELECT 
											 @intPeriodKey
											,@strPeriodType
											,@dtmDeliveryDate
											,@StorageChargeDate
											,@dblStorageRate
											,'Last Month'
											,'Number of Days'
											,DATEDIFF(DAY, @dtmDeliveryDate, @StorageChargeDate) + 1
											,(@dblStorageRate/DATEDIFF(dd,@dtmDeliveryDate,DATEADD(m,1,@dtmDeliveryDate))) * (DATEDIFF(DAY, @dtmDeliveryDate, @StorageChargeDate) + 1)
											,@dblStorageDuePerUnit + @dblFlatFeeTotal
											,@TotalMonthsApplicableForStorageCharge
											
											SET @dtmDeliveryDate = @StorageChargeDate + 1
										END	
									END	
								END
							END
						END					
					END
				
				END
				
			    --CASE 3.Start Date < > Blank, Ending Date < > Blank			
				ELSE IF @dtmDEffectiveDate IS NOT NULL AND @dtmEndingDate IS NOT NULL
				BEGIN
					IF @dtmDeliveryDate > @dtmDEffectiveDate
						SET @dtmDEffectiveDate = @dtmDeliveryDate
					ELSE
					BEGIN
						SET @TotalMonthsApplicableForStorageCharge = CASE 
																		 WHEN (@TotalMonthsApplicableForStorageCharge - DATEDIFF(MONTH, @dtmDeliveryDate, @dtmDEffectiveDate)) < 0 THEN 0
																		 ELSE (@TotalMonthsApplicableForStorageCharge - DATEDIFF(MONTH, @dtmDeliveryDate, @dtmDEffectiveDate))
																	 END
						SET @dtmDeliveryDate = @dtmDEffectiveDate
					END

					IF @dtmEndingDate > @StorageChargeDate
						SET @dtmEndingDate = @StorageChargeDate

					IF (DATEDIFF(DAY, @dtmDEffectiveDate, @StorageChargeDate) + 1) > 0 AND ((DATEDIFF(DAY, @dtmDeliveryDate, @dtmEndingDate) + 1) > 0) AND @TotalMonthsApplicableForStorageCharge > 0
					BEGIN
					
						--When Storage calculation Date is Same month of Delivery date.
						IF @TotalOriginalMonthsApplicableForStorageCharge = 1
						BEGIN
							--When FirstMonth and Last Month not are Matching then Charge Full month
							IF @strFirstMonth <> @strLastMonth
							BEGIN
								SELECT @dblStorageDuePerUnit = ISNULL(@dblStorageDuePerUnit, 0) + @dblStorageRate + CASE WHEN @strFeeType = 'Per Unit' THEN @dblFeeRate ELSE 0 END
								SET @TotalMonthsApplicableForStorageCharge = @TotalMonthsApplicableForStorageCharge - 1
								
								INSERT INTO @StorageCharge
								(
								    [intPeriodKey]
								   ,[strPeriodType]
								   ,[dtmEffectiveDate]
								   ,[dtmEndingDate]
								   ,[dblStorageRate]
								   ,[MonthType]
								   ,[ChargeType]
								   ,[ChargedNumberOfDays/Months]
								   ,[dblStorageDuePerUnit]
								   ,[dblCummulativeStorageDuePerUnit]
								   ,[RemainingMonths]
								 )								
								SELECT 
								 @intPeriodKey
								,@strPeriodType
								,@dtmDeliveryDate
								,DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmDeliveryDate) + 1, 0))
								,@dblStorageRate 
								,'First Month'
								,'Full Month'
								,1										
								,@dblStorageRate
								,@dblStorageDuePerUnit + @dblFlatFeeTotal
								,@TotalMonthsApplicableForStorageCharge										
									
								SET @dtmDeliveryDate = DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmDeliveryDate) + 1, 0)) + 1
							END
							ELSE
							BEGIN
								IF @strFirstMonth = 'Full Month' AND @strLastMonth = 'Full Month'
								BEGIN
									SELECT @dblStorageDuePerUnit = ISNULL(@dblStorageDuePerUnit, 0) + @dblStorageRate + CASE WHEN @strFeeType = 'Per Unit' THEN @dblFeeRate ELSE 0 END
									SET @TotalMonthsApplicableForStorageCharge = @TotalMonthsApplicableForStorageCharge - 1
									
									     INSERT INTO @StorageCharge
										 (
										     [intPeriodKey]
										    ,[strPeriodType]
										    ,[dtmEffectiveDate]
										    ,[dtmEndingDate]
										    ,[dblStorageRate]
										    ,[MonthType]
										    ,[ChargeType]
										    ,[ChargedNumberOfDays/Months]
										    ,[dblStorageDuePerUnit]
										    ,[dblCummulativeStorageDuePerUnit]
										    ,[RemainingMonths]
										  )
										 SELECT 
										 @intPeriodKey
										,@strPeriodType
										,@dtmDeliveryDate
										,DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmDeliveryDate) + 1, 0))
										,@dblStorageRate
										,'First Month'
										,'Full Month'
										,1
										,@dblStorageRate
										,@dblStorageDuePerUnit + @dblFlatFeeTotal
										,@TotalMonthsApplicableForStorageCharge										
									
									SET @dtmDeliveryDate = DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmDeliveryDate) + 1, 0)) + 1
									
								END
								ELSE
								BEGIN
									SELECT @dblStorageDuePerUnit = ISNULL(@dblStorageDuePerUnit, 0) + (@dblStorageRate/DATEDIFF(dd,@dtmDeliveryDate,DATEADD(m,1,@dtmDeliveryDate))) * (DATEDIFF(DAY, @dtmDeliveryDate, @StorageChargeDate) + 1)
																  + CASE WHEN @strFeeType = 'Per Unit' THEN @dblFeeRate ELSE 0 END
									SET @TotalMonthsApplicableForStorageCharge = @TotalMonthsApplicableForStorageCharge - 1
									
										INSERT INTO @StorageCharge
										( 
										    [intPeriodKey] 
										   ,[strPeriodType] 
										   ,[dtmEffectiveDate] 
										   ,[dtmEndingDate] 
										   ,[dblStorageRate] 
										   ,[MonthType] 
										   ,[ChargeType] 
										   ,[ChargedNumberOfDays/Months] 
										   ,[dblStorageDuePerUnit] 
										   ,[dblCummulativeStorageDuePerUnit] 
										   ,[RemainingMonths] 
										 )
										 SELECT 
										 @intPeriodKey
										,@strPeriodType
										,@dtmDeliveryDate
										,@StorageChargeDate
										,@dblStorageRate
										,'First Month'
										,'Number of Days'
										,DATEDIFF(DAY, @dtmDeliveryDate, @StorageChargeDate) + 1
										,(@dblStorageRate/DATEDIFF(dd,@dtmDeliveryDate,DATEADD(m,1,@dtmDeliveryDate))) * (DATEDIFF(DAY, @dtmDeliveryDate, @StorageChargeDate) + 1)
										,@dblStorageDuePerUnit + @dblFlatFeeTotal
										,@TotalMonthsApplicableForStorageCharge
											
										SET @dtmDeliveryDate = DATEDIFF(DAY, @dtmDeliveryDate, @StorageChargeDate) + 1 									
								END
							END
						END
						ELSE
						BEGIN
							IF @TotalOriginalMonthsApplicableForStorageCharge = @TotalMonthsApplicableForStorageCharge
							BEGIN
								---First Month Charge
								IF @strFirstMonth = 'Full Month'
								BEGIN
									SELECT @dblStorageDuePerUnit = ISNULL(@dblStorageDuePerUnit, 0) + @dblStorageRate + CASE WHEN @strFeeType = 'Per Unit' THEN @dblFeeRate ELSE 0 END
									SET @TotalMonthsApplicableForStorageCharge = @TotalMonthsApplicableForStorageCharge - 1
									
									 INSERT INTO @StorageCharge
									 ( 
									     [intPeriodKey] 
									    ,[strPeriodType] 
									    ,[dtmEffectiveDate] 
									    ,[dtmEndingDate] 
									    ,[dblStorageRate] 
									    ,[MonthType] 
									    ,[ChargeType] 
									    ,[ChargedNumberOfDays/Months] 
									    ,[dblStorageDuePerUnit] 
									    ,[dblCummulativeStorageDuePerUnit]
									    ,[RemainingMonths] 
									  )
									 SELECT 
									 @intPeriodKey
									,@strPeriodType
									,@dtmDeliveryDate
									,DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmDeliveryDate) + 1, 0))
									,@dblStorageRate
									,'First Month'
									,'Full Month'
									,1
									,@dblStorageRate
									,@dblStorageDuePerUnit + @dblFlatFeeTotal
									,@TotalMonthsApplicableForStorageCharge
											
									SET @dtmDeliveryDate = DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmDeliveryDate) + 1, 0)) + 1
								END
								ELSE
								BEGIN
																	
									SELECT @dblStorageDuePerUnit = ISNULL(@dblStorageDuePerUnit, 0) + (@dblStorageRate/DATEDIFF(dd,@dtmDeliveryDate,DATEADD(m,1,@dtmDeliveryDate))) * (DATEDIFF(DAY, @dtmDeliveryDate, DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmDeliveryDate) + 1, 0))) + 1)
																  + CASE WHEN @strFeeType = 'Per Unit' THEN @dblFeeRate ELSE 0 END

									SET @TotalMonthsApplicableForStorageCharge = @TotalMonthsApplicableForStorageCharge - 1
									
									 INSERT INTO @StorageCharge
									 ( 
									     [intPeriodKey] 
									    ,[strPeriodType] 
									    ,[dtmEffectiveDate] 
									    ,[dtmEndingDate] 
									    ,[dblStorageRate] 
									    ,[MonthType] 
									    ,[ChargeType] 
									    ,[ChargedNumberOfDays/Months] 
									    ,[dblStorageDuePerUnit] 
									    ,[dblCummulativeStorageDuePerUnit]
									    ,[RemainingMonths] 
									  )									 
									 SELECT 
									 @intPeriodKey
									,@strPeriodType
									,@dtmDeliveryDate
									,DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmDeliveryDate) + 1, 0))
									,@dblStorageRate
									,'First Month'
									,'Number of Days'
									,DATEDIFF(DAY, @dtmDeliveryDate, DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmDeliveryDate) + 1, 0))) + 1
									,(@dblStorageRate/DATEDIFF(dd,@dtmDeliveryDate,DATEADD(m,1,@dtmDeliveryDate))) * (DATEDIFF(DAY, @dtmDeliveryDate, DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmDeliveryDate) + 1, 0))) + 1)
									,@dblStorageDuePerUnit + @dblFlatFeeTotal
									,@TotalMonthsApplicableForStorageCharge
										
									SET @dtmDeliveryDate = DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmDeliveryDate) + 1, 0)) + 1
								END

								IF (DATEDIFF(DAY, @dtmDeliveryDate, @dtmEndingDate) + 1) > 0
								BEGIN
									IF @StorageChargeDate > @dtmEndingDate
									BEGIN
										---Intermediate Month Charges
										SELECT @dblStorageDuePerUnit = ISNULL(@dblStorageDuePerUnit, 0) + @dblStorageRate * (DATEDIFF(MONTH, @dtmDeliveryDate, @dtmEndingDate) + 1)
																	  + CASE WHEN @strFeeType = 'Per Unit' THEN @dblFeeRate ELSE 0 END

										SET @TotalMonthsApplicableForStorageCharge = @TotalMonthsApplicableForStorageCharge - (DATEDIFF(MONTH, @dtmDeliveryDate, @dtmEndingDate) + 1)
																					+ CASE WHEN @strFeeType = 'Per Unit' THEN @dblFeeRate ELSE 0 END
										
										INSERT INTO @StorageCharge
										(  
										    [intPeriodKey]  
										   ,[strPeriodType]  
										   ,[dtmEffectiveDate]  
										   ,[dtmEndingDate]  
										   ,[dblStorageRate]  
										   ,[MonthType]  
										   ,[ChargeType]  
										   ,[ChargedNumberOfDays/Months]  
										   ,[dblStorageDuePerUnit]  
										   ,[dblCummulativeStorageDuePerUnit] 
										   ,[RemainingMonths]  
										 )
										 SELECT 
										 @intPeriodKey
										,@strPeriodType
										,@dtmDeliveryDate
										,DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmEndingDate) + 1, 0))
										,@dblStorageRate
										,'Intermediate Month'
										,'Full Month'
										,DATEDIFF(MONTH, @dtmDeliveryDate, @dtmEndingDate) + 1
										,@dblStorageRate * (DATEDIFF(MONTH, @dtmDeliveryDate, @dtmEndingDate) + 1)
										,@dblStorageDuePerUnit + @dblFlatFeeTotal
										,@TotalMonthsApplicableForStorageCharge
										
										SET @dtmDeliveryDate = DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmEndingDate) + 1, 0)) + 1
									END
									ELSE
									BEGIN
										--Intermediate Month charges
										SELECT @dblStorageDuePerUnit = ISNULL(@dblStorageDuePerUnit, 0) + @dblStorageRate * (DATEDIFF(MONTH, @dtmDeliveryDate, DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @StorageChargeDate), 0))) + 1)
																	   + CASE WHEN @strFeeType = 'Per Unit' THEN @dblFeeRate ELSE 0 END

										SET @TotalMonthsApplicableForStorageCharge = @TotalMonthsApplicableForStorageCharge - (DATEDIFF(MONTH, @dtmDeliveryDate, DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @StorageChargeDate), 0))) + 1)
										
										INSERT INTO @StorageCharge
										( 
										    [intPeriodKey] 
										   ,[strPeriodType] 
										   ,[dtmEffectiveDate] 
										   ,[dtmEndingDate] 
										   ,[dblStorageRate] 
										   ,[MonthType] 
										   ,[ChargeType] 
										   ,[ChargedNumberOfDays/Months] 
										   ,[dblStorageDuePerUnit] 
										   ,[dblCummulativeStorageDuePerUnit]
										   ,[RemainingMonths] 
										 )										
										SELECT 
										 @intPeriodKey
										,@strPeriodType
										,@dtmDeliveryDate
										,DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @StorageChargeDate), 0))
										,@dblStorageRate
										,'Intermediate Month'
										,'Full Month'
										,(DATEDIFF(MONTH, @dtmDeliveryDate, DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @StorageChargeDate), 0))) + 1)
										,@dblStorageRate * (DATEDIFF(MONTH, @dtmDeliveryDate, DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @StorageChargeDate), 0))) + 1)
										,@dblStorageDuePerUnit + @dblFlatFeeTotal
										,@TotalMonthsApplicableForStorageCharge
										
										SET @dtmDeliveryDate = DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @StorageChargeDate), 0)) + 1

										--Last Month Charge
										IF @strLastMonth = 'Full Month'
										BEGIN
											SELECT @dblStorageDuePerUnit = ISNULL(@dblStorageDuePerUnit, 0) + @dblStorageRate + CASE WHEN @strFeeType = 'Per Unit' THEN @dblFeeRate ELSE 0 END
											SET @TotalMonthsApplicableForStorageCharge = @TotalMonthsApplicableForStorageCharge - 1
											
											 INSERT INTO @StorageCharge
											 ( 
											     [intPeriodKey] 
											    ,[strPeriodType] 
											    ,[dtmEffectiveDate] 
											    ,[dtmEndingDate] 
											    ,[dblStorageRate] 
											    ,[MonthType] 
											    ,[ChargeType] 
											    ,[ChargedNumberOfDays/Months] 
											    ,[dblStorageDuePerUnit] 
											    ,[dblCummulativeStorageDuePerUnit]
											    ,[RemainingMonths] 
											  )
											 SELECT 
											 @intPeriodKey
											,@strPeriodType
											,@dtmDeliveryDate
											,DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @StorageChargeDate)+1, 0))
											,@dblStorageRate
											,'Last Month'
											,'Full Month'
											,1
											,@dblStorageRate
											,@dblStorageDuePerUnit + @dblFlatFeeTotal
											,@TotalMonthsApplicableForStorageCharge
											
											SET @dtmDeliveryDate = DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @StorageChargeDate) + 1, 0)) + 1
										
										END
										ELSE
										BEGIN
											SELECT @dblStorageDuePerUnit = ISNULL(@dblStorageDuePerUnit, 0) 
																		   + (@dblStorageRate/DATEDIFF(dd,@dtmDeliveryDate,DATEADD(m,1,@dtmDeliveryDate))) * (DATEDIFF(DAY, @dtmDeliveryDate, @StorageChargeDate) + 1)
																		   + CASE WHEN @strFeeType = 'Per Unit' THEN @dblFeeRate ELSE 0 END
											SET @TotalMonthsApplicableForStorageCharge = @TotalMonthsApplicableForStorageCharge - 1
												
												 INSERT INTO @StorageCharge
												 ( 
												     [intPeriodKey] 
												    ,[strPeriodType] 
												    ,[dtmEffectiveDate] 
												    ,[dtmEndingDate] 
												    ,[dblStorageRate] 
												    ,[MonthType] 
												    ,[ChargeType] 
												    ,[ChargedNumberOfDays/Months] 
												    ,[dblStorageDuePerUnit] 
												    ,[dblCummulativeStorageDuePerUnit]
												    ,[RemainingMonths] 
												  )
												 SELECT 
												 @intPeriodKey
												,@strPeriodType
												,@dtmDeliveryDate
												,@StorageChargeDate
												,@dblStorageRate
												,'Last Month'
												,'Number of Days'
												,DATEDIFF(DAY, @dtmDeliveryDate, @StorageChargeDate) + 1
												,(@dblStorageRate/DATEDIFF(dd,@dtmDeliveryDate,DATEADD(m,1,@dtmDeliveryDate))) * (DATEDIFF(DAY, @dtmDeliveryDate, @StorageChargeDate) + 1)
												,@dblStorageDuePerUnit + @dblFlatFeeTotal
												,@TotalMonthsApplicableForStorageCharge
												
												SET @dtmDeliveryDate = @StorageChargeDate + 1
										END
									END
								END
							END
							ELSE
							BEGIN

								IF (DATEDIFF(DAY, @dtmDeliveryDate, @dtmEndingDate) + 1) > 0
								BEGIN								    
									IF @StorageChargeDate > @dtmEndingDate
									BEGIN
										---Intermediate Month Charges
										SELECT @dblStorageDuePerUnit = ISNULL(@dblStorageDuePerUnit, 0) + @dblStorageRate * (DATEDIFF(MONTH, @dtmDeliveryDate, @dtmEndingDate) + 1)
																	   + CASE WHEN @strFeeType = 'Per Unit' THEN @dblFeeRate ELSE 0 END
										SET @TotalMonthsApplicableForStorageCharge = @TotalMonthsApplicableForStorageCharge - (DATEDIFF(MONTH, @dtmDeliveryDate, @dtmEndingDate) + 1)
										
										INSERT INTO @StorageCharge
										( 
										    [intPeriodKey] 
										   ,[strPeriodType] 
										   ,[dtmEffectiveDate] 
										   ,[dtmEndingDate] 
										   ,[dblStorageRate] 
										   ,[MonthType] 
										   ,[ChargeType] 
										   ,[ChargedNumberOfDays/Months] 
										   ,[dblStorageDuePerUnit] 
										   ,[dblCummulativeStorageDuePerUnit]
										   ,[RemainingMonths] 
										 )										
										SELECT 
										 @intPeriodKey
										,@strPeriodType
										,@dtmDeliveryDate
										,DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmEndingDate) + 1, 0))
										,@dblStorageRate
										,'Intermediate Month'
										,'Full Month'
										,DATEDIFF(MONTH, @dtmDeliveryDate, @dtmEndingDate) + 1
										,@dblStorageRate * (DATEDIFF(MONTH, @dtmDeliveryDate, @dtmEndingDate) + 1)
										,@dblStorageDuePerUnit + @dblFlatFeeTotal
										,@TotalMonthsApplicableForStorageCharge
												
										SET @dtmDeliveryDate = DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmEndingDate) + 1, 0)) + 1
									END
									ELSE
									BEGIN
										--Intermediate Month charges
										SELECT @dblStorageDuePerUnit = ISNULL(@dblStorageDuePerUnit, 0) + @dblStorageRate * (DATEDIFF(MONTH, @dtmDeliveryDate, DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @StorageChargeDate), 0))) + 1)
																	  + CASE WHEN @strFeeType = 'Per Unit' THEN @dblFeeRate ELSE 0 END
										SET @TotalMonthsApplicableForStorageCharge = @TotalMonthsApplicableForStorageCharge - (DATEDIFF(MONTH, @dtmDeliveryDate, DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @StorageChargeDate), 0))) + 1)
										
										 INSERT INTO @StorageCharge
										 ( 
										     [intPeriodKey] 
										    ,[strPeriodType] 
										    ,[dtmEffectiveDate] 
										    ,[dtmEndingDate] 
										    ,[dblStorageRate] 
										    ,[MonthType] 
										    ,[ChargeType] 
										    ,[ChargedNumberOfDays/Months] 
										    ,[dblStorageDuePerUnit] 
										    ,[dblCummulativeStorageDuePerUnit]
										    ,[RemainingMonths] 
										  )
										 SELECT 
										 @intPeriodKey
										,@strPeriodType
										,@dtmDeliveryDate
										,DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @StorageChargeDate), 0))
										,@dblStorageRate
										,'Intermediate Month'
										,'Full Month'
										,DATEDIFF(MONTH, @dtmDeliveryDate, DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @StorageChargeDate), 0))) + 1
										,@dblStorageRate * (DATEDIFF(MONTH, @dtmDeliveryDate, DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @StorageChargeDate), 0))) + 1)
										,@dblStorageDuePerUnit + @dblFlatFeeTotal
										,@TotalMonthsApplicableForStorageCharge
												
										SET @dtmDeliveryDate = DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @StorageChargeDate), 0)) + 1

										--Last Month Charge										
										IF @strLastMonth = 'Full Month'
										BEGIN
											SELECT @dblStorageDuePerUnit = ISNULL(@dblStorageDuePerUnit, 0) + @dblStorageRate + CASE WHEN @strFeeType = 'Per Unit' THEN @dblFeeRate ELSE 0 END
											SET @TotalMonthsApplicableForStorageCharge = @TotalMonthsApplicableForStorageCharge - 1
											
											 INSERT INTO @StorageCharge
											 ( 
											     [intPeriodKey] 
											    ,[strPeriodType] 
											    ,[dtmEffectiveDate] 
											    ,[dtmEndingDate] 
											    ,[dblStorageRate] 
											    ,[MonthType] 
											    ,[ChargeType] 
											    ,[ChargedNumberOfDays/Months] 
											    ,[dblStorageDuePerUnit] 
											    ,[dblCummulativeStorageDuePerUnit]
											    ,[RemainingMonths] 
											  )											 
											 SELECT 
											 @intPeriodKey
											,@strPeriodType
											,@dtmDeliveryDate
											,DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @StorageChargeDate)+1, 0))
											,@dblStorageRate
											,'Last Month'
											,'Full Month'
											,1
											,@dblStorageRate
											,@dblStorageDuePerUnit + @dblFlatFeeTotal
											,@TotalMonthsApplicableForStorageCharge								
												
										SET @dtmDeliveryDate = DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @StorageChargeDate) + 1, 0)) + 1
										
										END
										ELSE
										BEGIN										
											SELECT @dblStorageDuePerUnit = ISNULL(@dblStorageDuePerUnit, 0) + (@dblStorageRate/DATEDIFF(dd,@dtmDeliveryDate,DATEADD(m,1,@dtmDeliveryDate))) * (DATEDIFF(DAY, @dtmDeliveryDate, @StorageChargeDate) + 1)
																		   + CASE WHEN @strFeeType = 'Per Unit' THEN @dblFeeRate ELSE 0 END

											SET @TotalMonthsApplicableForStorageCharge = @TotalMonthsApplicableForStorageCharge - 1
											
											INSERT INTO @StorageCharge
											( 
											    [intPeriodKey] 
											   ,[strPeriodType] 
											   ,[dtmEffectiveDate] 
											   ,[dtmEndingDate] 
											   ,[dblStorageRate] 
											   ,[MonthType] 
											   ,[ChargeType] 
											   ,[ChargedNumberOfDays/Months] 
											   ,[dblStorageDuePerUnit] 
											   ,[dblCummulativeStorageDuePerUnit]
											   ,[RemainingMonths] 
											 )
											SELECT 
											 @intPeriodKey
											,@strPeriodType
											,@dtmDeliveryDate
											,@StorageChargeDate
											,@dblStorageRate
											,'Last Month'
											,'Number of Days'
											,DATEDIFF(DAY, @dtmDeliveryDate, @StorageChargeDate) + 1
											,(@dblStorageRate/DATEDIFF(dd,@dtmDeliveryDate,DATEADD(m,1,@dtmDeliveryDate))) * (DATEDIFF(DAY, @dtmDeliveryDate, @StorageChargeDate) + 1)
											,@dblStorageDuePerUnit + @dblFlatFeeTotal
											,@TotalMonthsApplicableForStorageCharge
												
											SET @dtmDeliveryDate = @StorageChargeDate + 1
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
				IF @dtmDEffectiveDate IS NULL
				BEGIN
					--When Storage calculation Date is Same month of Delivery date.
					IF @TotalOriginalMonthsApplicableForStorageCharge = 1
					BEGIN
						--When FirstMonth and Last Month not are Matching then Charge Full month
						IF @strFirstMonth <> @strLastMonth
						BEGIN
							SELECT @dblStorageDuePerUnit = ISNULL(@dblStorageDuePerUnit, 0) + @dblStorageRate+ CASE WHEN @strFeeType = 'Per Unit' THEN @dblFeeRate ELSE 0 END
							SET @TotalMonthsApplicableForStorageCharge = @TotalMonthsApplicableForStorageCharge - 1
							
						    INSERT INTO @StorageCharge
							( 
							    [intPeriodKey] 
							   ,[strPeriodType] 
							   ,[dtmEffectiveDate] 
							   ,[dtmEndingDate] 
							   ,[dblStorageRate] 
							   ,[MonthType] 
							   ,[ChargeType] 
							   ,[ChargedNumberOfDays/Months] 
							   ,[dblStorageDuePerUnit] 
							   ,[dblCummulativeStorageDuePerUnit]
							   ,[RemainingMonths] 
							 )
							SELECT 
							 @intPeriodKey
							,@strPeriodType
							,@dtmDeliveryDate
							,DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmDeliveryDate) + 1, 0))
							,@dblStorageRate
							,'First Month'
							,'Full Month'
							,1
							,@dblStorageRate
							,@dblStorageDuePerUnit + @dblFlatFeeTotal
							,@TotalMonthsApplicableForStorageCharge											
											
												
							SET @dtmDeliveryDate = DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmDeliveryDate) + 1, 0)) + 1
						END
						ELSE
						BEGIN
							IF @strFirstMonth = 'Full Month' AND @strLastMonth = 'Full Month'
							BEGIN
								SELECT @dblStorageDuePerUnit = ISNULL(@dblStorageDuePerUnit, 0) + @dblStorageRate+ CASE WHEN @strFeeType = 'Per Unit' THEN @dblFeeRate ELSE 0 END
								SET @TotalMonthsApplicableForStorageCharge = @TotalMonthsApplicableForStorageCharge - 1
								   
								INSERT INTO @StorageCharge
								(  
								    [intPeriodKey]  
								   ,[strPeriodType]  
								   ,[dtmEffectiveDate]  
								   ,[dtmEndingDate]  
								   ,[dblStorageRate]  
								   ,[MonthType]  
								   ,[ChargeType]  
								   ,[ChargedNumberOfDays/Months]  
								   ,[dblStorageDuePerUnit]  
								   ,[dblCummulativeStorageDuePerUnit] 
								   ,[RemainingMonths]  
								 ) 
								 SELECT 
								 @intPeriodKey
								,@strPeriodType
								,@dtmDeliveryDate
								,DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmDeliveryDate) + 1, 0))
								,@dblStorageRate
								,'First Month'
								,'Full Month'
								,1
								,@dblStorageRate
								,@dblStorageDuePerUnit + @dblFlatFeeTotal
								,@TotalMonthsApplicableForStorageCharge
													
								SET @dtmDeliveryDate = DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmDeliveryDate) + 1, 0)) + 1
							END
							ELSE
							BEGIN
								SELECT @dblStorageDuePerUnit = ISNULL(@dblStorageDuePerUnit, 0) + (@dblStorageRate/DATEDIFF(dd,@dtmDeliveryDate,DATEADD(m,1,@dtmDeliveryDate))) * (DATEDIFF(DAY, @dtmDeliveryDate, @StorageChargeDate) + 1)
															  + CASE WHEN @strFeeType = 'Per Unit' THEN @dblFeeRate ELSE 0 END

								SET @TotalMonthsApplicableForStorageCharge = @TotalMonthsApplicableForStorageCharge - 1
								
								 INSERT INTO @StorageCharge
								 ( 
								     [intPeriodKey] 
								    ,[strPeriodType] 
								    ,[dtmEffectiveDate] 
								    ,[dtmEndingDate] 
								    ,[dblStorageRate] 
								    ,[MonthType] 
								    ,[ChargeType] 
								    ,[ChargedNumberOfDays/Months] 
								    ,[dblStorageDuePerUnit] 
								    ,[dblCummulativeStorageDuePerUnit]
								    ,[RemainingMonths] 
								  )								 
								 SELECT 
								 @intPeriodKey
								,@strPeriodType
								,@dtmDeliveryDate
								,DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmDeliveryDate) + 1, 0))
								,@dblStorageRate
								,'First Month'
								,'Number of Days'
								,DATEDIFF(DAY, @dtmDeliveryDate, @StorageChargeDate) + 1
								,(@dblStorageRate/DATEDIFF(dd,@dtmDeliveryDate,DATEADD(m,1,@dtmDeliveryDate))) * (DATEDIFF(DAY, @dtmDeliveryDate, @StorageChargeDate) + 1)
								,@dblStorageDuePerUnit + @dblFlatFeeTotal
								,@TotalMonthsApplicableForStorageCharge
												
								SET @dtmDeliveryDate = @StorageChargeDate + 1
							END
						END
					END
					ELSE
					BEGIN
						IF @TotalOriginalMonthsApplicableForStorageCharge = @TotalMonthsApplicableForStorageCharge
						BEGIN
							---First Month Charge
							IF @strFirstMonth = 'Full Month'
							BEGIN
								SELECT @dblStorageDuePerUnit = ISNULL(@dblStorageDuePerUnit, 0) + @dblStorageRate + CASE WHEN @strFeeType = 'Per Unit' THEN @dblFeeRate ELSE 0 END
								SET @TotalMonthsApplicableForStorageCharge = @TotalMonthsApplicableForStorageCharge - 1
								
								INSERT INTO @StorageCharge
								( 
								    [intPeriodKey] 
								   ,[strPeriodType] 
								   ,[dtmEffectiveDate] 
								   ,[dtmEndingDate] 
								   ,[dblStorageRate] 
								   ,[MonthType] 
								   ,[ChargeType] 
								   ,[ChargedNumberOfDays/Months] 
								   ,[dblStorageDuePerUnit] 
								   ,[dblCummulativeStorageDuePerUnit]
								   ,[RemainingMonths] 
								 )
								SELECT 
								 @intPeriodKey
								,@strPeriodType
								,@dtmDeliveryDate
								,DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmDeliveryDate) + 1, 0))
								,@dblStorageRate
								,'First Month'
								,'Full Month'
								,1
								,@dblStorageRate
								,@dblStorageDuePerUnit + @dblFlatFeeTotal
								,@TotalMonthsApplicableForStorageCharge
													
								SET @dtmDeliveryDate = DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmDeliveryDate) + 1, 0)) + 1
							END
							ELSE
							BEGIN
								SELECT @dblStorageDuePerUnit = ISNULL(@dblStorageDuePerUnit, 0) + (@dblStorageRate/DATEDIFF(dd,@dtmDeliveryDate,DATEADD(m,1,@dtmDeliveryDate))) * (DATEDIFF(DAY, @dtmDeliveryDate, DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmDeliveryDate) + 1, 0))) + 1)
															  + CASE WHEN @strFeeType = 'Per Unit' THEN @dblFeeRate ELSE 0 END
								SET @TotalMonthsApplicableForStorageCharge = @TotalMonthsApplicableForStorageCharge - 1
								
							     INSERT INTO @StorageCharge
								 ( 
								     [intPeriodKey] 
								    ,[strPeriodType] 
								    ,[dtmEffectiveDate] 
								    ,[dtmEndingDate] 
								    ,[dblStorageRate] 
								    ,[MonthType] 
								    ,[ChargeType] 
								    ,[ChargedNumberOfDays/Months] 
								    ,[dblStorageDuePerUnit] 
								    ,[dblCummulativeStorageDuePerUnit]
								    ,[RemainingMonths] 
								  )
								 SELECT 
								 @intPeriodKey
								,@strPeriodType
								,@dtmDeliveryDate 
								,DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmDeliveryDate) + 1, 0))
								,@dblStorageRate
								,'First Month'
								,'Number of Days'
								,(DATEDIFF(DAY, @dtmDeliveryDate, DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmDeliveryDate) + 1, 0))) + 1)
								,(@dblStorageRate/DATEDIFF(dd,@dtmDeliveryDate,DATEADD(m,1,@dtmDeliveryDate))) * (DATEDIFF(DAY, @dtmDeliveryDate, DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmDeliveryDate) + 1, 0))) + 1)
								,@dblStorageDuePerUnit + @dblFlatFeeTotal
								,@TotalMonthsApplicableForStorageCharge	s
												
								SET @dtmDeliveryDate = DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmDeliveryDate) + 1, 0)) + 1
							END

							IF (DATEDIFF(DAY, @dtmDeliveryDate, @StorageChargeDate) + 1) > 0 AND @TotalMonthsApplicableForStorageCharge > 0
							BEGIN
								--Intermediate Month charges
								SELECT @dblStorageDuePerUnit = ISNULL(@dblStorageDuePerUnit, 0) + @dblStorageRate * (DATEDIFF(MONTH, @dtmDeliveryDate, DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @StorageChargeDate), 0))) + 1)
															  + CASE WHEN @strFeeType = 'Per Unit' THEN @dblFeeRate ELSE 0 END
								SET @TotalMonthsApplicableForStorageCharge = @TotalMonthsApplicableForStorageCharge - (DATEDIFF(MONTH, @dtmDeliveryDate, DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @StorageChargeDate), 0))) + 1)
								
								 INSERT INTO @StorageCharge
								 ( 
								     [intPeriodKey] 
								    ,[strPeriodType] 
								    ,[dtmEffectiveDate] 
								    ,[dtmEndingDate] 
								    ,[dblStorageRate] 
								    ,[MonthType] 
								    ,[ChargeType] 
								    ,[ChargedNumberOfDays/Months] 
								    ,[dblStorageDuePerUnit] 
								    ,[dblCummulativeStorageDuePerUnit]
								    ,[RemainingMonths] 
								  )
								 SELECT 
								 @intPeriodKey
								,@strPeriodType
								,@dtmDeliveryDate
								,DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @StorageChargeDate), 0))--GOPI												
								,@dblStorageRate
								,'Intermediate Month'
								,'Full Month'
								,DATEDIFF(MONTH, @dtmDeliveryDate, DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @StorageChargeDate), 0))) + 1
								,@dblStorageRate * (DATEDIFF(MONTH, @dtmDeliveryDate, DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @StorageChargeDate), 0))) + 1)
								,@dblStorageDuePerUnit + @dblFlatFeeTotal
								,@TotalMonthsApplicableForStorageCharge
												
								SET @dtmDeliveryDate = DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @StorageChargeDate), 0)) + 1

								--Last Month Charge
								IF @strLastMonth = 'Full Month'
								BEGIN
									SELECT @dblStorageDuePerUnit = ISNULL(@dblStorageDuePerUnit, 0) + @dblStorageRate + CASE WHEN @strFeeType = 'Per Unit' THEN @dblFeeRate ELSE 0 END
									SET @TotalMonthsApplicableForStorageCharge = @TotalMonthsApplicableForStorageCharge - 1
									
									INSERT INTO @StorageCharge
									(  
									    [intPeriodKey]  
									   ,[strPeriodType]  
									   ,[dtmEffectiveDate]  
									   ,[dtmEndingDate]  
									   ,[dblStorageRate]  
									   ,[MonthType]  
									   ,[ChargeType]  
									   ,[ChargedNumberOfDays/Months]  
									   ,[dblStorageDuePerUnit]  
									   ,[dblCummulativeStorageDuePerUnit] 
									   ,[RemainingMonths]  
									 ) 
									 
									 SELECT 
									 @intPeriodKey
									,@strPeriodType
									,@dtmDeliveryDate
									,DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmDeliveryDate) + 1, 0))
									,@dblStorageRate
									,'Last Month'
									,'Full Month'
									,1
									,@dblStorageRate
									,@dblStorageDuePerUnit + @dblFlatFeeTotal
									,@TotalMonthsApplicableForStorageCharge												
												
									SET @dtmDeliveryDate = DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @StorageChargeDate) + 1, 0)) + 1
								END
								ELSE
								BEGIN
									SELECT @dblStorageDuePerUnit = ISNULL(@dblStorageDuePerUnit, 0) + (@dblStorageRate/DATEDIFF(dd,@dtmDeliveryDate,DATEADD(m,1,@dtmDeliveryDate))) * (DATEDIFF(DAY, @dtmDeliveryDate, @StorageChargeDate) + 1)
																  + CASE WHEN @strFeeType = 'Per Unit' THEN @dblFeeRate ELSE 0 END
									SET @TotalMonthsApplicableForStorageCharge = @TotalMonthsApplicableForStorageCharge - 1
									
									INSERT INTO @StorageCharge
									(  
									    [intPeriodKey]  
									   ,[strPeriodType]  
									   ,[dtmEffectiveDate]  
									   ,[dtmEndingDate]  
									   ,[dblStorageRate]  
									   ,[MonthType]  
									   ,[ChargeType]  
									   ,[ChargedNumberOfDays/Months]  
									   ,[dblStorageDuePerUnit]  
									   ,[dblCummulativeStorageDuePerUnit]
									   ,[RemainingMonths]  
									 ) 
									SELECT 
									 @intPeriodKey
									,@strPeriodType
									,@dtmDeliveryDate
									,@StorageChargeDate
									,@dblStorageRate
									,'Last Month'
									,'Number of Days'
									,DATEDIFF(DAY, @dtmDeliveryDate, @StorageChargeDate) + 1
									,(@dblStorageRate/DATEDIFF(dd,@dtmDeliveryDate,DATEADD(m,1,@dtmDeliveryDate))) * (DATEDIFF(DAY, @dtmDeliveryDate, @StorageChargeDate) + 1)
									,@dblStorageDuePerUnit + @dblFlatFeeTotal
									,@TotalMonthsApplicableForStorageCharge										
												 
												
									SET @dtmDeliveryDate = @StorageChargeDate + 1
								END
							END
						END
						ELSE
						BEGIN
							IF (DATEDIFF(DAY, @dtmDeliveryDate, @StorageChargeDate) + 1) > 0
							BEGIN
								--Intermediate Month charges
								SELECT @dblStorageDuePerUnit = ISNULL(@dblStorageDuePerUnit, 0) + @dblStorageRate * (DATEDIFF(MONTH, @dtmDeliveryDate, DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @StorageChargeDate), 0))) + 1)
															   + CASE WHEN @strFeeType = 'Per Unit' THEN @dblFeeRate ELSE 0 END
								SET @TotalMonthsApplicableForStorageCharge = @TotalMonthsApplicableForStorageCharge - (DATEDIFF(MONTH, @dtmDeliveryDate, DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @StorageChargeDate), 0))) + 1)
								
								INSERT INTO @StorageCharge
								(  
								    [intPeriodKey]  
								   ,[strPeriodType]  
								   ,[dtmEffectiveDate]  
								   ,[dtmEndingDate]  
								   ,[dblStorageRate]  
								   ,[MonthType]  
								   ,[ChargeType]  
								   ,[ChargedNumberOfDays/Months]  
								   ,[dblStorageDuePerUnit]  
								   ,[dblCummulativeStorageDuePerUnit]
								   ,[RemainingMonths]  
								 ) 
								SELECT 
								 @intPeriodKey
								,@strPeriodType
								,@dtmDeliveryDate
								,DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @StorageChargeDate), 0))
								,@dblStorageRate
								,'Intermediate Month'
								,'Full Month'
								,DATEDIFF(MONTH, @dtmDeliveryDate, DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @StorageChargeDate), 0))) + 1
								,@dblStorageRate * (DATEDIFF(MONTH, @dtmDeliveryDate, DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @StorageChargeDate), 0))) + 1)
								,@dblStorageDuePerUnit + @dblFlatFeeTotal
								,@TotalMonthsApplicableForStorageCharge												
												
								SET @dtmDeliveryDate = DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @StorageChargeDate), 0)) + 1

								--Last Month Charge									
								IF @strLastMonth = 'Full Month'
								BEGIN
									SELECT @dblStorageDuePerUnit = ISNULL(@dblStorageDuePerUnit, 0) + @dblStorageRate + CASE WHEN @strFeeType = 'Per Unit' THEN @dblFeeRate ELSE 0 END
									SET @TotalMonthsApplicableForStorageCharge = @TotalMonthsApplicableForStorageCharge - 1
										
									 INSERT INTO @StorageCharge
									 (  
									     [intPeriodKey]  
									    ,[strPeriodType]  
									    ,[dtmEffectiveDate]  
									    ,[dtmEndingDate]  
									    ,[dblStorageRate]  
									    ,[MonthType]  
									    ,[ChargeType]  
									    ,[ChargedNumberOfDays/Months]  
									    ,[dblStorageDuePerUnit]  
									    ,[dblCummulativeStorageDuePerUnit]
									    ,[RemainingMonths]  
									  ) 
									 SELECT 
									 @intPeriodKey
									,@strPeriodType
									,@dtmDeliveryDate
									,DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @StorageChargeDate)+1, 0))
									,@dblStorageRate
									,'Last Month'
									,'Full Month'
									,1
									,@dblStorageRate
									,@dblStorageDuePerUnit + @dblFlatFeeTotal
									,@TotalMonthsApplicableForStorageCharge												
												
									SET @dtmDeliveryDate = DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @StorageChargeDate) + 1, 0)) + 1
								END
								ELSE
								BEGIN
									SELECT @dblStorageDuePerUnit = ISNULL(@dblStorageDuePerUnit, 0) + (@dblStorageRate/DATEDIFF(dd,@dtmDeliveryDate,DATEADD(m,1,@dtmDeliveryDate))) * (DATEDIFF(DAY, @dtmDeliveryDate, @StorageChargeDate) + 1)
									+ CASE WHEN @strFeeType = 'Per Unit' THEN @dblFeeRate ELSE 0 END
									SET @TotalMonthsApplicableForStorageCharge = @TotalMonthsApplicableForStorageCharge - 1
										
									INSERT INTO @StorageCharge
									(  
									    [intPeriodKey]  
									   ,[strPeriodType]  
									   ,[dtmEffectiveDate]  
									   ,[dtmEndingDate]  
									   ,[dblStorageRate]  
									   ,[MonthType]  
									   ,[ChargeType]  
									   ,[ChargedNumberOfDays/Months]  
									   ,[dblStorageDuePerUnit]  
									   ,[dblCummulativeStorageDuePerUnit]
									   ,[RemainingMonths]  
									 ) 
									SELECT 
									 @intPeriodKey
								    ,@strPeriodType
									,@dtmDeliveryDate
									,@StorageChargeDate
									,@dblStorageRate
									,'Last Month'
									,'Number of Days'
									,DATEDIFF(DAY, @dtmDeliveryDate, @StorageChargeDate) + 1
									,(@dblStorageRate/DATEDIFF(dd,@dtmDeliveryDate,DATEADD(m,1,@dtmDeliveryDate))) * (DATEDIFF(DAY, @dtmDeliveryDate, @StorageChargeDate) + 1)
									,@dblStorageDuePerUnit + @dblFlatFeeTotal
									,@TotalMonthsApplicableForStorageCharge	
												
									SET @dtmDeliveryDate = @StorageChargeDate + 1
								END
							END
						END
					END
				END
				ELSE
				BEGIN
					
					IF @dtmDeliveryDate > @dtmDEffectiveDate
						SET @dtmDEffectiveDate = @dtmDeliveryDate
					ELSE
					BEGIN
						SET @TotalMonthsApplicableForStorageCharge = CASE 
																		 WHEN (@TotalMonthsApplicableForStorageCharge - DATEDIFF(MONTH, @dtmDeliveryDate, @dtmDEffectiveDate)) < 0 THEN 0
																		 ELSE (@TotalMonthsApplicableForStorageCharge - DATEDIFF(MONTH, @dtmDeliveryDate, @dtmDEffectiveDate))
																	 END
						SET @dtmDeliveryDate = @dtmDEffectiveDate
					END				
								
					IF (DATEDIFF(DAY, @dtmDEffectiveDate, @StorageChargeDate) + 1) > 0 AND @TotalMonthsApplicableForStorageCharge > 0
					BEGIN
						--When Storage calculation Date is Same month of Delivery date.
						IF @TotalOriginalMonthsApplicableForStorageCharge = 1
						BEGIN
							--When FirstMonth and Last Month not are Matching then Charge Full month
							IF @strFirstMonth <> @strLastMonth
							BEGIN
								SELECT @dblStorageDuePerUnit = ISNULL(@dblStorageDuePerUnit, 0) + @dblStorageRate + CASE WHEN @strFeeType = 'Per Unit' THEN @dblFeeRate ELSE 0 END
								SET @TotalMonthsApplicableForStorageCharge = @TotalMonthsApplicableForStorageCharge - 1
									
								 INSERT INTO @StorageCharge
								 (  
								     [intPeriodKey]  
								    ,[strPeriodType]  
								    ,[dtmEffectiveDate]  
								    ,[dtmEndingDate]  
								    ,[dblStorageRate]  
								    ,[MonthType]  
								    ,[ChargeType]  
								    ,[ChargedNumberOfDays/Months]  
								    ,[dblStorageDuePerUnit]  
								    ,[dblCummulativeStorageDuePerUnit]
								    ,[RemainingMonths]  
								  ) 
								 SELECT 
								 @intPeriodKey
								,@strPeriodType
								,@dtmDeliveryDate
								,DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmDeliveryDate) + 1, 0))
								,@dblStorageRate
								,'First Month'
								,'Full Month'
								,1
								,@dblStorageRate
								,@dblStorageDuePerUnit + @dblFlatFeeTotal
								,@TotalMonthsApplicableForStorageCharge
		
								SET @dtmDeliveryDate = DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmDeliveryDate) + 1, 0)) + 1
							END
							ELSE
							BEGIN
								IF @strFirstMonth = 'Full Month' AND @strLastMonth = 'Full Month'
								BEGIN
									SELECT @dblStorageDuePerUnit = ISNULL(@dblStorageDuePerUnit, 0) + @dblStorageRate + CASE WHEN @strFeeType = 'Per Unit' THEN @dblFeeRate ELSE 0 END
									SET @TotalMonthsApplicableForStorageCharge = @TotalMonthsApplicableForStorageCharge - 1
									
									INSERT INTO @StorageCharge
									(  
									    [intPeriodKey]  
									   ,[strPeriodType]  
									   ,[dtmEffectiveDate]  
									   ,[dtmEndingDate]  
									   ,[dblStorageRate]  
									   ,[MonthType]  
									   ,[ChargeType]  
									   ,[ChargedNumberOfDays/Months]  
									   ,[dblStorageDuePerUnit]  
									   ,[dblCummulativeStorageDuePerUnit]
									   ,[RemainingMonths]  
									 ) 
									SELECT 
									 @intPeriodKey
									,@strPeriodType
									,@dtmDeliveryDate
									,DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmDeliveryDate) + 1, 0))
									,@dblStorageRate
									,'First Month'
									,'Full Month'
									,1
									,@dblStorageRate
									,@dblStorageDuePerUnit + @dblFlatFeeTotal
									,@TotalMonthsApplicableForStorageCharge
									
									SET @dtmDeliveryDate = DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmDeliveryDate) + 1, 0)) + 1
								END
								ELSE
								BEGIN
									SELECT @dblStorageDuePerUnit = ISNULL(@dblStorageDuePerUnit, 0) + (@dblStorageRate/DATEDIFF(dd,@dtmDeliveryDate,DATEADD(m,1,@dtmDeliveryDate))) * (DATEDIFF(DAY, @dtmDeliveryDate, DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmDeliveryDate) + 1, 0))) + 1)
																  + CASE WHEN @strFeeType = 'Per Unit' THEN @dblFeeRate ELSE 0 END

									SET @TotalMonthsApplicableForStorageCharge = @TotalMonthsApplicableForStorageCharge - 1
										
									INSERT INTO @StorageCharge
									(  
									    [intPeriodKey]  
									   ,[strPeriodType]  
									   ,[dtmEffectiveDate]  
									   ,[dtmEndingDate]  
									   ,[dblStorageRate]  
									   ,[MonthType]  
									   ,[ChargeType]  
									   ,[ChargedNumberOfDays/Months]  
									   ,[dblStorageDuePerUnit]  
									   ,[dblCummulativeStorageDuePerUnit]
									   ,[RemainingMonths]  
									 ) 
									SELECT 
									 @intPeriodKey
									,@strPeriodType
									,@dtmDeliveryDate
									,@StorageChargeDate
									,@dblStorageRate
									,'First Month'
									,'Number of Days'
									,DATEDIFF(DAY, @dtmDeliveryDate, DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmDeliveryDate) + 1, 0))) + 1
									,(@dblStorageRate/DATEDIFF(dd,@dtmDeliveryDate,DATEADD(m,1,@dtmDeliveryDate))) * (DATEDIFF(DAY, @dtmDeliveryDate, DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmDeliveryDate) + 1, 0))) + 1)
									,@dblStorageDuePerUnit + @dblFlatFeeTotal
									,@TotalMonthsApplicableForStorageCharge
										
									SET @dtmDeliveryDate = @StorageChargeDate + 1
								END
							END
						END
						ELSE
						BEGIN
							IF @TotalOriginalMonthsApplicableForStorageCharge = @TotalMonthsApplicableForStorageCharge
							BEGIN
								---First Month Charge
								IF @strFirstMonth = 'Full Month'
								BEGIN
									SELECT @dblStorageDuePerUnit = ISNULL(@dblStorageDuePerUnit, 0) + @dblStorageRate + CASE WHEN @strFeeType = 'Per Unit' THEN @dblFeeRate ELSE 0 END
									SET @TotalMonthsApplicableForStorageCharge = @TotalMonthsApplicableForStorageCharge - 1
									
									 INSERT INTO @StorageCharge
									 (  
									     [intPeriodKey]  
									    ,[strPeriodType]  
									    ,[dtmEffectiveDate]  
									    ,[dtmEndingDate]  
									    ,[dblStorageRate]  
									    ,[MonthType]  
									    ,[ChargeType]  
									    ,[ChargedNumberOfDays/Months]  
									    ,[dblStorageDuePerUnit]  
									    ,[dblCummulativeStorageDuePerUnit]
									    ,[RemainingMonths]  
									  ) 
									 SELECT 
									 @intPeriodKey
									,@strPeriodType
									,@dtmDeliveryDate
									,DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmDeliveryDate) + 1, 0))
									,@dblStorageRate
									,'First Month'
									,'Full Month'
									,1
									,@dblStorageRate
									,@dblStorageDuePerUnit + @dblFlatFeeTotal
									,@TotalMonthsApplicableForStorageCharge
									
									SET @dtmDeliveryDate = DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmDeliveryDate) + 1, 0)) + 1
								END
								ELSE
								BEGIN
									SELECT @dblStorageDuePerUnit = ISNULL(@dblStorageDuePerUnit, 0) + (@dblStorageRate/DATEDIFF(dd,@dtmDeliveryDate,DATEADD(m,1,@dtmDeliveryDate))) * (DATEDIFF(DAY, @dtmDeliveryDate, DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmDeliveryDate) + 1, 0))) + 1)
																  + CASE WHEN @strFeeType = 'Per Unit' THEN @dblFeeRate ELSE 0 END
									SET @TotalMonthsApplicableForStorageCharge = @TotalMonthsApplicableForStorageCharge - 1
									
									INSERT INTO @StorageCharge
									(  
									    [intPeriodKey]  
									   ,[strPeriodType]  
									   ,[dtmEffectiveDate]  
									   ,[dtmEndingDate]  
									   ,[dblStorageRate]  
									   ,[MonthType]  
									   ,[ChargeType]  
									   ,[ChargedNumberOfDays/Months]  
									   ,[dblStorageDuePerUnit]  
									   ,[dblCummulativeStorageDuePerUnit]
									   ,[RemainingMonths]  
									 ) 
									SELECT 
									 @intPeriodKey
									,@strPeriodType
									,@dtmDeliveryDate
									,DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmDeliveryDate) + 1, 0))
									,@dblStorageRate
									,'First Month'
									,'Number of Days'
									,DATEDIFF(DAY, @dtmDeliveryDate, DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmDeliveryDate) + 1, 0))) + 1
									,(@dblStorageRate/DATEDIFF(dd,@dtmDeliveryDate,DATEADD(m,1,@dtmDeliveryDate))) * (DATEDIFF(DAY, @dtmDeliveryDate, DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmDeliveryDate) + 1, 0))) + 1)
									,@dblStorageDuePerUnit + @dblFlatFeeTotal
									,@TotalMonthsApplicableForStorageCharge
									
									SET @dtmDeliveryDate = DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmDeliveryDate) + 1, 0)) + 1
								END
								
								---Intermediate and Last Month Charges
								IF (DATEDIFF(DAY, @dtmDeliveryDate, @StorageChargeDate) + 1) > 0
								BEGIN
								
									IF @TotalMonthsApplicableForStorageCharge > 1
									BEGIN
									
										--Intermediate Month charges
										SELECT @dblStorageDuePerUnit = ISNULL(@dblStorageDuePerUnit, 0) + @dblStorageRate * (DATEDIFF(MONTH, @dtmDeliveryDate, DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @StorageChargeDate), 0))) + 1)
																	  + CASE WHEN @strFeeType = 'Per Unit' THEN @dblFeeRate ELSE 0 END
										SET @TotalMonthsApplicableForStorageCharge = @TotalMonthsApplicableForStorageCharge - (DATEDIFF(MONTH, @dtmDeliveryDate, DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @StorageChargeDate), 0))) + 1)
										
										INSERT INTO @StorageCharge
										(  
										    [intPeriodKey]  
										   ,[strPeriodType]  
										   ,[dtmEffectiveDate]  
										   ,[dtmEndingDate]  
										   ,[dblStorageRate]  
										   ,[MonthType]  
										   ,[ChargeType]  
										   ,[ChargedNumberOfDays/Months]  
										   ,[dblStorageDuePerUnit]  
										   ,[dblCummulativeStorageDuePerUnit]
										   ,[RemainingMonths]  
										 ) 
										SELECT 
										 @intPeriodKey
										,@strPeriodType
										,@dtmDeliveryDate
										,DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @StorageChargeDate), 0))
										,@dblStorageRate
										,'Intermediate Month'
										,'Full Month'
										,DATEDIFF(MONTH, @dtmDeliveryDate, DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @StorageChargeDate), 0))) + 1
										,@dblStorageRate * (DATEDIFF(MONTH, @dtmDeliveryDate, DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @StorageChargeDate), 0))) + 1)
										,@dblStorageDuePerUnit + @dblFlatFeeTotal
										,@TotalMonthsApplicableForStorageCharge
											
										SET @dtmDeliveryDate = DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @StorageChargeDate), 0)) + 1

										--Last Month Charge
										IF @strLastMonth = 'Full Month'
										BEGIN
											SELECT @dblStorageDuePerUnit = ISNULL(@dblStorageDuePerUnit, 0) + @dblStorageRate + CASE WHEN @strFeeType = 'Per Unit' THEN @dblFeeRate ELSE 0 END
											SET @TotalMonthsApplicableForStorageCharge = @TotalMonthsApplicableForStorageCharge - 1
											
											 INSERT INTO @StorageCharge
											 (  
											     [intPeriodKey]  
											    ,[strPeriodType]  
											    ,[dtmEffectiveDate]  
											    ,[dtmEndingDate]  
											    ,[dblStorageRate]  
											    ,[MonthType]  
											    ,[ChargeType]  
											    ,[ChargedNumberOfDays/Months]  
											    ,[dblStorageDuePerUnit]  
											    ,[dblCummulativeStorageDuePerUnit]
											    ,[RemainingMonths]  
											  ) 
											 SELECT 
											 @intPeriodKey
											,@strPeriodType
											,@dtmDeliveryDate
											,DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @StorageChargeDate)+1, 0))
											,@dblStorageRate
											,'Last Month'
											,'Full Month'
											,1
											,@dblStorageRate
											,@dblStorageDuePerUnit + @dblFlatFeeTotal
											,@TotalMonthsApplicableForStorageCharge
											
											SET @dtmDeliveryDate = DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @StorageChargeDate) + 1, 0)) + 1
										END
										ELSE
										BEGIN
											SELECT @dblStorageDuePerUnit = ISNULL(@dblStorageDuePerUnit, 0) + (@dblStorageRate/DATEDIFF(dd,@dtmDeliveryDate,DATEADD(m,1,@dtmDeliveryDate))) * (DATEDIFF(DAY, @dtmDeliveryDate, @StorageChargeDate) + 1)
																		   + CASE WHEN @strFeeType = 'Per Unit' THEN @dblFeeRate ELSE 0 END
											SET @TotalMonthsApplicableForStorageCharge = @TotalMonthsApplicableForStorageCharge - 1
											
											INSERT INTO @StorageCharge
											(   
											    [intPeriodKey]   
											   ,[strPeriodType]   
											   ,[dtmEffectiveDate]   
											   ,[dtmEndingDate]   
											   ,[dblStorageRate]   
											   ,[MonthType]   
											   ,[ChargeType]   
											   ,[ChargedNumberOfDays/Months]   
											   ,[dblStorageDuePerUnit]   
											   ,[dblCummulativeStorageDuePerUnit] 
											   ,[RemainingMonths]   
											 )  
											 SELECT 
											 @intPeriodKey
											,@strPeriodType
											,@dtmDeliveryDate
											,@StorageChargeDate
											,@dblStorageRate
											,'Last Month'
											,'Number of Days'
											,DATEDIFF(DAY, @dtmDeliveryDate, @StorageChargeDate) + 1
											,(@dblStorageRate/DATEDIFF(dd,@dtmDeliveryDate,DATEADD(m,1,@dtmDeliveryDate))) * (DATEDIFF(DAY, @dtmDeliveryDate, @StorageChargeDate) + 1)
											,@dblStorageDuePerUnit + @dblFlatFeeTotal
											,@TotalMonthsApplicableForStorageCharge
											
											SET @dtmDeliveryDate = @StorageChargeDate + 1
										END
									END
									ELSE
									BEGIN
										--Last Month Charge
										IF @strLastMonth = 'Full Month'
										BEGIN
											SELECT @dblStorageDuePerUnit = ISNULL(@dblStorageDuePerUnit, 0) + @dblStorageRate + CASE WHEN @strFeeType = 'Per Unit' THEN @dblFeeRate ELSE 0 END
											SET @TotalMonthsApplicableForStorageCharge = @TotalMonthsApplicableForStorageCharge - 1
											
											INSERT INTO @StorageCharge
											(   
											    [intPeriodKey]   
											   ,[strPeriodType]   
											   ,[dtmEffectiveDate]   
											   ,[dtmEndingDate]   
											   ,[dblStorageRate]   
											   ,[MonthType]   
											   ,[ChargeType]   
											   ,[ChargedNumberOfDays/Months]   
											   ,[dblStorageDuePerUnit]   
											   ,[dblCummulativeStorageDuePerUnit] 
											   ,[RemainingMonths]   
											 )  
											 SELECT 
											 @intPeriodKey
											,@strPeriodType
											,@dtmDeliveryDate
											,DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @StorageChargeDate)+1, 0))
											,@dblStorageRate
											,'Last Month'
											,'Full Month'
											,1
											,@dblStorageRate
											,@dblStorageDuePerUnit + @dblFlatFeeTotal
											,@TotalMonthsApplicableForStorageCharge
											
											SET @dtmDeliveryDate = DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @StorageChargeDate) + 1, 0)) + 1
										END
										ELSE
										BEGIN
											SELECT @dblStorageDuePerUnit = ISNULL(@dblStorageDuePerUnit, 0) + (@dblStorageRate/DATEDIFF(dd,@dtmDeliveryDate,DATEADD(m,1,@dtmDeliveryDate))) * (DATEDIFF(DAY, @dtmDeliveryDate, @StorageChargeDate) + 1)
																		  + CASE WHEN @strFeeType = 'Per Unit' THEN @dblFeeRate ELSE 0 END
											SET @TotalMonthsApplicableForStorageCharge = @TotalMonthsApplicableForStorageCharge - 1
											
											INSERT INTO @StorageCharge
											(   
											    [intPeriodKey]   
											   ,[strPeriodType]   
											   ,[dtmEffectiveDate]   
											   ,[dtmEndingDate]   
											   ,[dblStorageRate]   
											   ,[MonthType]   
											   ,[ChargeType]   
											   ,[ChargedNumberOfDays/Months]   
											   ,[dblStorageDuePerUnit]   
											   ,[dblCummulativeStorageDuePerUnit] 
											   ,[RemainingMonths]   
											 )  
											 SELECT 
											 @intPeriodKey
											,@strPeriodType
											,@dtmDeliveryDate
											,@StorageChargeDate
											,@dblStorageRate
											,'Last Month'
											,'Number of Days'
											,DATEDIFF(DAY, @dtmDeliveryDate, @StorageChargeDate) + 1
											,(@dblStorageRate/DATEDIFF(dd,@dtmDeliveryDate,DATEADD(m,1,@dtmDeliveryDate))) * (DATEDIFF(DAY, @dtmDeliveryDate, @StorageChargeDate) + 1)
											,@dblStorageDuePerUnit + @dblFlatFeeTotal
											,@TotalMonthsApplicableForStorageCharge
											
											SET @dtmDeliveryDate = @StorageChargeDate + 1
										END	
									END	
								END
							END
							ELSE
							BEGIN
								---Intermediate and Last Month Charges
								IF (DATEDIFF(DAY, @dtmDeliveryDate, @StorageChargeDate) + 1) > 0
								BEGIN
								
									IF @TotalMonthsApplicableForStorageCharge > 1
									BEGIN									
										--Intermediate Month charges
										SELECT @dblStorageDuePerUnit = ISNULL(@dblStorageDuePerUnit, 0) + @dblStorageRate * (DATEDIFF(MONTH, @dtmDeliveryDate, DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @StorageChargeDate), 0))) + 1)
																	  + CASE WHEN @strFeeType = 'Per Unit' THEN @dblFeeRate ELSE 0 END
										SET @TotalMonthsApplicableForStorageCharge = @TotalMonthsApplicableForStorageCharge - (DATEDIFF(MONTH, @dtmDeliveryDate, DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @StorageChargeDate), 0))) + 1)
										
										 INSERT INTO @StorageCharge
										 (  
										     [intPeriodKey]  
										    ,[strPeriodType]  
										    ,[dtmEffectiveDate]  
										    ,[dtmEndingDate]  
										    ,[dblStorageRate]  
										    ,[MonthType]  
										    ,[ChargeType]  
										    ,[ChargedNumberOfDays/Months]  
										    ,[dblStorageDuePerUnit]  
										    ,[dblCummulativeStorageDuePerUnit]
										    ,[RemainingMonths]  
										  ) 
										 SELECT 
										 @intPeriodKey
										,@strPeriodType
										,@dtmDeliveryDate
										,DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @StorageChargeDate), 0))
										,@dblStorageRate
										,'Intermediate Month'
										,'Full Month'
										,DATEDIFF(MONTH, @dtmDeliveryDate, DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @StorageChargeDate), 0))) + 1
										,@dblStorageRate * (DATEDIFF(MONTH, @dtmDeliveryDate, DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @StorageChargeDate), 0))) + 1)
										,@dblStorageDuePerUnit + @dblFlatFeeTotal
										,@TotalMonthsApplicableForStorageCharge
											
										SET @dtmDeliveryDate = DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @StorageChargeDate), 0)) + 1

										--Last Month Charge
										IF @strLastMonth = 'Full Month'
										BEGIN
											SELECT @dblStorageDuePerUnit = ISNULL(@dblStorageDuePerUnit, 0) + @dblStorageRate + CASE WHEN @strFeeType = 'Per Unit' THEN @dblFeeRate ELSE 0 END
											SET @TotalMonthsApplicableForStorageCharge = @TotalMonthsApplicableForStorageCharge - 1
											
											INSERT INTO @StorageCharge
											(  
											    [intPeriodKey]  
											   ,[strPeriodType]  
											   ,[dtmEffectiveDate]  
											   ,[dtmEndingDate]  
											   ,[dblStorageRate]  
											   ,[MonthType]  
											   ,[ChargeType]  
											   ,[ChargedNumberOfDays/Months]  
											   ,[dblStorageDuePerUnit]  
											   ,[dblCummulativeStorageDuePerUnit]
											   ,[RemainingMonths]  
											 ) 
											SELECT 
											 @intPeriodKey
											,@strPeriodType
											,@dtmDeliveryDate
											,DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @StorageChargeDate)+1, 0))
											,@dblStorageRate
											,'Last Month'
											,'Full Month'
											,1
											,@dblStorageRate
											,@dblStorageDuePerUnit + @dblFlatFeeTotal
											,@TotalMonthsApplicableForStorageCharge
											
											SET @dtmDeliveryDate = DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @StorageChargeDate) + 1, 0)) + 1
										END
										ELSE
										BEGIN
											SELECT @dblStorageDuePerUnit = ISNULL(@dblStorageDuePerUnit, 0) + (@dblStorageRate/DATEDIFF(dd,@dtmDeliveryDate,DATEADD(m,1,@dtmDeliveryDate))) * (DATEDIFF(DAY, @dtmDeliveryDate, @StorageChargeDate) + 1)
																		  + CASE WHEN @strFeeType = 'Per Unit' THEN @dblFeeRate ELSE 0 END
											SET @TotalMonthsApplicableForStorageCharge = @TotalMonthsApplicableForStorageCharge - 1
											
											INSERT INTO @StorageCharge
											(   
											    [intPeriodKey]   
											   ,[strPeriodType]   
											   ,[dtmEffectiveDate]   
											   ,[dtmEndingDate]   
											   ,[dblStorageRate]   
											   ,[MonthType]   
											   ,[ChargeType]   
											   ,[ChargedNumberOfDays/Months]   
											   ,[dblStorageDuePerUnit]   
											   ,[dblCummulativeStorageDuePerUnit] 
											   ,[RemainingMonths]   
											 )  
											 SELECT 
											 @intPeriodKey
											,@strPeriodType
											,@dtmDeliveryDate
											,@StorageChargeDate
											,@dblStorageRate
											,'Last Month'
											,'Number of Days'
											,DATEDIFF(DAY, @dtmDeliveryDate, @StorageChargeDate) + 1
											,(@dblStorageRate/DATEDIFF(dd,@dtmDeliveryDate,DATEADD(m,1,@dtmDeliveryDate))) * (DATEDIFF(DAY, @dtmDeliveryDate, @StorageChargeDate) + 1)
											,@dblStorageDuePerUnit + @dblFlatFeeTotal
											,@TotalMonthsApplicableForStorageCharge
											
											SET @dtmDeliveryDate = @StorageChargeDate + 1
										END
									END
									ELSE
									BEGIN
										--Last Month Charge
										IF @strLastMonth = 'Full Month'
										BEGIN
											SELECT @dblStorageDuePerUnit = ISNULL(@dblStorageDuePerUnit, 0) + @dblStorageRate + CASE WHEN @strFeeType = 'Per Unit' THEN @dblFeeRate ELSE 0 END
											SET @TotalMonthsApplicableForStorageCharge = @TotalMonthsApplicableForStorageCharge - 1
											
											INSERT INTO @StorageCharge
											(   
											    [intPeriodKey]   
											   ,[strPeriodType]   
											   ,[dtmEffectiveDate]   
											   ,[dtmEndingDate]   
											   ,[dblStorageRate]   
											   ,[MonthType]   
											   ,[ChargeType]   
											   ,[ChargedNumberOfDays/Months]   
											   ,[dblStorageDuePerUnit]   
											   ,[dblCummulativeStorageDuePerUnit] 
											   ,[RemainingMonths]   
											 )  
											 SELECT 
											 @intPeriodKey
											,@strPeriodType
											,@dtmDeliveryDate
											,DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @StorageChargeDate)+1, 0))
											,@dblStorageRate
											,'Last Month'
											,'Full Month'
											,1
											,@dblStorageRate
											,@dblStorageDuePerUnit + @dblFlatFeeTotal
											,@TotalMonthsApplicableForStorageCharge
											
											SET @dtmDeliveryDate = DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @StorageChargeDate) + 1, 0)) + 1
										END
										ELSE
										BEGIN
											SELECT @dblStorageDuePerUnit = ISNULL(@dblStorageDuePerUnit, 0) + (@dblStorageRate/DATEDIFF(dd,@dtmDeliveryDate,DATEADD(m,1,@dtmDeliveryDate))) * (DATEDIFF(DAY, @dtmDeliveryDate, @StorageChargeDate) + 1)
																		   + CASE WHEN @strFeeType = 'Per Unit' THEN @dblFeeRate ELSE 0 END
											SET @TotalMonthsApplicableForStorageCharge = @TotalMonthsApplicableForStorageCharge - 1
											
											INSERT INTO @StorageCharge
											(   
											    [intPeriodKey]   
											   ,[strPeriodType]   
											   ,[dtmEffectiveDate]   
											   ,[dtmEndingDate]   
											   ,[dblStorageRate]   
											   ,[MonthType]   
											   ,[ChargeType]   
											   ,[ChargedNumberOfDays/Months]   
											   ,[dblStorageDuePerUnit]   
											   ,[dblCummulativeStorageDuePerUnit] 
											   ,[RemainingMonths]   
											 )  
											 SELECT 
											 @intPeriodKey
											,@strPeriodType
											,@dtmDeliveryDate
											,@StorageChargeDate
											,@dblStorageRate
											,'Last Month'
											,'Number of Days'
											,DATEDIFF(DAY, @dtmDeliveryDate, @StorageChargeDate) + 1
											,(@dblStorageRate/DATEDIFF(dd,@dtmDeliveryDate,DATEADD(m,1,@dtmDeliveryDate))) * (DATEDIFF(DAY, @dtmDeliveryDate, @StorageChargeDate) + 1)
											,@dblStorageDuePerUnit + @dblFlatFeeTotal
											,@TotalMonthsApplicableForStorageCharge
											
											SET @dtmDeliveryDate = @StorageChargeDate + 1
										END	
									END	
								END
							END
						END	
					END
					
				END
			END
			
			SELECT @intSchedulePeriodId = MIN(intSchedulePeriodId)
			FROM @tblGRStorageSchedulePeriod
			WHERE intSchedulePeriodId > @intSchedulePeriodId
		END
	END
		
	---Due from Deliverydate to Last Storage Accrue Date.
	IF @strStorageRate = 'Monthly' AND @StorageChargeCalculationRequired = 1
	BEGIN
		SELECT @dtmDeliveryDate     = dtmDeliveryDate
		FROM   tblGRCustomerStorage
		WHERE  intCustomerStorageId = @intCustomerStorageId
		
		SELECT @TotalMonthsApplicableForStorageCharge		    =   DATEDIFF(MONTH, @dtmDeliveryDate, @dtmLastStorageAccrueDate) + 1
		SET    @TotalOriginalMonthsApplicableForStorageCharge   =   @TotalMonthsApplicableForStorageCharge
		
		SELECT @intSchedulePeriodId = MIN(intSchedulePeriodId)
		FROM @tblGRStorageSchedulePeriod		

		WHILE @intSchedulePeriodId > 0 AND @TotalMonthsApplicableForStorageCharge > 0
		BEGIN
			SET @intPeriodKey       = NULL
			SET @strPeriodType      = NULL
			SET @dtmDEffectiveDate  = NULL
			SET @dtmEndingDate      = NULL
			SET @intNumberOfDays    = NULL
			SET @dblStorageRate     = NULL
		
			SELECT 
				 @intPeriodKey	    = intPeriodKey
				,@strPeriodType     = strPeriodType
				,@dtmDEffectiveDate = dtmEffectiveDate
				,@dtmEndingDate		= dtmEndingDate
				,@intNumberOfDays   = ISNULL(intNumberOfDays, 0)
				,@dblStorageRate    = CASE 
									  	WHEN ISNULL(strFeeType,'')='Flat'      THEN dblStorageRate 
									  	WHEN ISNULL(strFeeType,'')='Per Unit'  THEN dblStorageRate + dblFeeRate
									  END
			FROM @tblGRStorageSchedulePeriod
			WHERE intSchedulePeriodId = @intSchedulePeriodId
			
			--Period Range			
			IF @strPeriodType = 'Period Range'
			BEGIN
				--CASE 1.Start Date = Blank ,Ending Date < > Blank	
				IF @dtmDEffectiveDate IS NULL AND @dtmEndingDate IS NOT NULL
				BEGIN
					IF @dtmEndingDate > @dtmLastStorageAccrueDate
						SET @dtmEndingDate = @dtmLastStorageAccrueDate

					IF (DATEDIFF(DAY, @dtmDeliveryDate, @dtmEndingDate) + 1) > 0
					BEGIN
						--When Storage calculation Date is Same month of Delivery date.
						IF @TotalOriginalMonthsApplicableForStorageCharge = 1
						BEGIN
						
							SELECT @dblStorageDuePerUnit =   ISNULL(@dblStorageDuePerUnit, 0)- CASE 
																									WHEN  @FirstMonthFullChargeApplicable=1 THEN @dblStorageRate 
																									ELSE  (@dblStorageRate/DATEDIFF(dd,@dtmDeliveryDate,DATEADD(m,1,@dtmDeliveryDate))) * (DATEDIFF(DAY, @dtmDeliveryDate, DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmDeliveryDate) + 1, 0))) + 1)
																							   END
														    - CASE WHEN @strFeeType = 'Per Unit' THEN @dblFeeRate ELSE 0 END
							SET @TotalMonthsApplicableForStorageCharge = @TotalMonthsApplicableForStorageCharge - 1
							
							INSERT INTO @StorageCharge
							(  
							    [intPeriodKey]  
							   ,[strPeriodType]  
							   ,[dtmEffectiveDate]  
							   ,[dtmEndingDate]  
							   ,[dblStorageRate]  
							   ,[MonthType]  
							   ,[ChargeType]  
							   ,[ChargedNumberOfDays/Months]  
							   ,[dblStorageDuePerUnit]  
							   ,[dblCummulativeStorageDuePerUnit]
							   ,[RemainingMonths]  
							 ) 
							SELECT 
							 @intPeriodKey
							,@strPeriodType
							,@dtmDeliveryDate
							,CASE 
								WHEN @FirstMonthFullChargeApplicable=1 THEN DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmDeliveryDate) + 1, 0)) 
								ELSE @dtmLastStorageAccrueDate
							 END
							,@dblStorageRate
							,'First Month'
							,CASE 
								WHEN @FirstMonthFullChargeApplicable=1 THEN 'Full Month' 
								ELSE 'Number of Days'
							 END
							,CASE 
								WHEN @FirstMonthFullChargeApplicable=1 THEN 1 
								ELSE DATEDIFF(DAY, @dtmDeliveryDate, DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmDeliveryDate) + 1, 0))) + 1
							 END
							,CASE 
								WHEN @FirstMonthFullChargeApplicable=1 THEN -@dblStorageRate 
								ELSE -(@dblStorageRate/DATEDIFF(dd,@dtmDeliveryDate,DATEADD(m,1,@dtmDeliveryDate))) * (DATEDIFF(DAY, @dtmDeliveryDate, DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmDeliveryDate) + 1, 0))) + 1)
							  END
							,@dblStorageDuePerUnit
							,@TotalMonthsApplicableForStorageCharge
							
							SET @dtmDeliveryDate =CASE 
													 WHEN @FirstMonthFullChargeApplicable=1 THEN  DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmDeliveryDate) + 1, 0)) + 1 
													 ELSE @dtmLastStorageAccrueDate + 1
												  END							
							
						END
						ELSE
						BEGIN
							IF @TotalOriginalMonthsApplicableForStorageCharge = @TotalMonthsApplicableForStorageCharge
							BEGIN
								---First Month Charge
								SELECT @dblStorageDuePerUnit =   ISNULL(@dblStorageDuePerUnit, 0) 
																- CASE 
																		WHEN @FirstMonthFullChargeApplicable=1 THEN @dblStorageRate 
																		ELSE (@dblStorageRate/DATEDIFF(dd,@dtmDeliveryDate,DATEADD(m,1,@dtmDeliveryDate))) * (DATEDIFF(DAY, @dtmDeliveryDate, DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmDeliveryDate) + 1, 0))) + 1)
																  END
																- CASE WHEN @strFeeType = 'Per Unit' THEN @dblFeeRate ELSE 0 END
																  
								SET @TotalMonthsApplicableForStorageCharge = @TotalMonthsApplicableForStorageCharge - 1
								
								INSERT INTO @StorageCharge
								(  
								    [intPeriodKey]  
								   ,[strPeriodType]  
								   ,[dtmEffectiveDate]  
								   ,[dtmEndingDate]  
								   ,[dblStorageRate]  
								   ,[MonthType]  
								   ,[ChargeType]  
								   ,[ChargedNumberOfDays/Months]  
								   ,[dblStorageDuePerUnit]  
								   ,[dblCummulativeStorageDuePerUnit]
								   ,[RemainingMonths]  
								 ) 
								SELECT 
								 @intPeriodKey
								,@strPeriodType
								,@dtmDeliveryDate
								,DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmDeliveryDate) + 1, 0))
								,@dblStorageRate
								,'First Month'
								,CASE 
									WHEN @FirstMonthFullChargeApplicable=1 THEN 'Full Month' 
									ELSE 'Number of Days'
								 END
								,CASE 
									WHEN @FirstMonthFullChargeApplicable=1 THEN 1 
									ELSE DATEDIFF(DAY, @dtmDeliveryDate, DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmDeliveryDate) + 1, 0))) + 1
								 END
								,CASE 
									WHEN @FirstMonthFullChargeApplicable=1 THEN -@dblStorageRate 
									ELSE -(@dblStorageRate/DATEDIFF(dd,@dtmDeliveryDate,DATEADD(m,1,@dtmDeliveryDate))) * (DATEDIFF(DAY, @dtmDeliveryDate, DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmDeliveryDate) + 1, 0))) + 1)
								  END
								,@dblStorageDuePerUnit
								,@TotalMonthsApplicableForStorageCharge
								
								SET @dtmDeliveryDate =DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmDeliveryDate) + 1, 0)) + 1	
													  
								IF (DATEDIFF(DAY, @dtmDeliveryDate, @dtmEndingDate) + 1) > 0
								BEGIN
									IF @dtmLastStorageAccrueDate > @dtmEndingDate
									BEGIN
										---Intermediate Month Charges
										SELECT @dblStorageDuePerUnit = ISNULL(@dblStorageDuePerUnit, 0) - @dblStorageRate * (DATEDIFF(MONTH, @dtmDeliveryDate, @dtmEndingDate) + 1)
																	  - CASE WHEN @strFeeType = 'Per Unit' THEN @dblFeeRate ELSE 0 END
										SET @TotalMonthsApplicableForStorageCharge = @TotalMonthsApplicableForStorageCharge - (DATEDIFF(MONTH, @dtmDeliveryDate, @dtmEndingDate) + 1)
											
											INSERT INTO @StorageCharge
											(  
											    [intPeriodKey]  
											   ,[strPeriodType]  
											   ,[dtmEffectiveDate]  
											   ,[dtmEndingDate]  
											   ,[dblStorageRate]  
											   ,[MonthType]  
											   ,[ChargeType]  
											   ,[ChargedNumberOfDays/Months]  
											   ,[dblStorageDuePerUnit]  
											   ,[dblCummulativeStorageDuePerUnit]
											   ,[RemainingMonths]  
											 ) 
											SELECT 
											 @intPeriodKey
											,@strPeriodType
											,@dtmDeliveryDate
											,DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmEndingDate) + 1, 0))
											,@dblStorageRate
											,'Intermediate Month'
											,'Full Month'
											,DATEDIFF(MONTH, @dtmDeliveryDate, @dtmEndingDate) + 1
											,- @dblStorageRate * (DATEDIFF(MONTH, @dtmDeliveryDate, @dtmEndingDate) + 1)
											,@dblStorageDuePerUnit
											,@TotalMonthsApplicableForStorageCharge
													
										SET @dtmDeliveryDate = DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmEndingDate) + 1, 0)) + 1
									END
									ELSE
									BEGIN
										--Intermediate Month charges
										SELECT @dblStorageDuePerUnit = ISNULL(@dblStorageDuePerUnit, 0) - @dblStorageRate * (DATEDIFF(MONTH, @dtmDeliveryDate, DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmLastStorageAccrueDate), 0))) + 1)
																	  - CASE WHEN @strFeeType = 'Per Unit' THEN @dblFeeRate ELSE 0 END
										SET @TotalMonthsApplicableForStorageCharge = @TotalMonthsApplicableForStorageCharge - (DATEDIFF(MONTH, @dtmDeliveryDate, DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmLastStorageAccrueDate), 0))) + 1)
										
											INSERT INTO @StorageCharge
											(  
											    [intPeriodKey]  
											   ,[strPeriodType]  
											   ,[dtmEffectiveDate]  
											   ,[dtmEndingDate]  
											   ,[dblStorageRate]  
											   ,[MonthType]  
											   ,[ChargeType]  
											   ,[ChargedNumberOfDays/Months]  
											   ,[dblStorageDuePerUnit]  
											   ,[dblCummulativeStorageDuePerUnit]
											   ,[RemainingMonths]  
											 ) 
											SELECT 
											 @intPeriodKey
											,@strPeriodType
											,@dtmDeliveryDate
											,DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmLastStorageAccrueDate), 0))
											,@dblStorageRate
											,'Intermediate Month'
											,'Full Month'
											,DATEDIFF(MONTH, @dtmDeliveryDate, DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmLastStorageAccrueDate), 0))) + 1
											,- @dblStorageRate * (DATEDIFF(MONTH, @dtmDeliveryDate, DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmLastStorageAccrueDate), 0))) + 1)
											,@dblStorageDuePerUnit
											,@TotalMonthsApplicableForStorageCharge
											
										SET @dtmDeliveryDate = DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmLastStorageAccrueDate), 0)) + 1

										--Last Month Charge
										SELECT @dblStorageDuePerUnit = ISNULL(@dblStorageDuePerUnit, 0) - CASE 
																												WHEN @strLastMonth = 'Full Month' THEN  @dblStorageRate 
																												ELSE  (@dblStorageRate/DATEDIFF(dd,@dtmDeliveryDate,DATEADD(m,1,@dtmDeliveryDate))) * (DATEDIFF(DAY, @dtmDeliveryDate, @dtmLastStorageAccrueDate) + 1)
																										  END
																	  - CASE WHEN @strFeeType = 'Per Unit' THEN @dblFeeRate ELSE 0 END
																										  
										SET @TotalMonthsApplicableForStorageCharge = @TotalMonthsApplicableForStorageCharge - 1

										INSERT INTO @StorageCharge
										(  
										    [intPeriodKey]  
										   ,[strPeriodType]  
										   ,[dtmEffectiveDate]  
										   ,[dtmEndingDate]  
										   ,[dblStorageRate]  
										   ,[MonthType]  
										   ,[ChargeType]  
										   ,[ChargedNumberOfDays/Months]  
										   ,[dblStorageDuePerUnit]  
										   ,[dblCummulativeStorageDuePerUnit]
										   ,[RemainingMonths]  
										 ) 
										SELECT 
										 @intPeriodKey
										,@strPeriodType
										,@dtmDeliveryDate
										,CASE 
											WHEN @strLastMonth = 'Full Month' THEN DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmLastStorageAccrueDate)+1, 0)) 
											ELSE @dtmLastStorageAccrueDate
										 END
										,@dblStorageRate
										,'Last Month'
										,CASE 
											WHEN @strLastMonth = 'Full Month' THEN 'Full Month' 
											ELSE 'Number of Days'
										 END
										,CASE 
											WHEN @strLastMonth = 'Full Month' THEN 1 
											ELSE DATEDIFF(DAY, @dtmDeliveryDate, @dtmLastStorageAccrueDate) + 1
										 END
										,CASE 
											WHEN @strLastMonth = 'Full Month' THEN  -@dblStorageRate 
											ELSE  -(@dblStorageRate/DATEDIFF(dd,@dtmDeliveryDate,DATEADD(m,1,@dtmDeliveryDate))) * (DATEDIFF(DAY, @dtmDeliveryDate, @dtmLastStorageAccrueDate) + 1)
										 END 
										,@dblStorageDuePerUnit
										,@TotalMonthsApplicableForStorageCharge

										SET @dtmDeliveryDate =CASE 
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
										SELECT @dblStorageDuePerUnit = ISNULL(@dblStorageDuePerUnit, 0) - @dblStorageRate * (DATEDIFF(MONTH, @dtmDeliveryDate, @dtmEndingDate) + 1)
																	  - CASE WHEN @strFeeType = 'Per Unit' THEN @dblFeeRate ELSE 0 END
										SET @TotalMonthsApplicableForStorageCharge = @TotalMonthsApplicableForStorageCharge - (DATEDIFF(MONTH, @dtmDeliveryDate, @dtmEndingDate) + 1)
										
											INSERT INTO @StorageCharge([intPeriodKey],[strPeriodType],[dtmEffectiveDate],[dtmEndingDate],[dblStorageRate],[MonthType],[ChargeType],[ChargedNumberOfDays/Months],[dblStorageDuePerUnit],[dblCummulativeStorageDuePerUnit],[RemainingMonths])
											SELECT 
											 @intPeriodKey
											,@strPeriodType
											,@dtmDeliveryDate
											,DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmEndingDate) + 1, 0))
											,@dblStorageRate
											,'Intermediate Month'
											,'Full Month'
											,DATEDIFF(MONTH, @dtmDeliveryDate, @dtmEndingDate) + 1
											,- @dblStorageRate * (DATEDIFF(MONTH, @dtmDeliveryDate, @dtmEndingDate) + 1)
											,@dblStorageDuePerUnit
											,@TotalMonthsApplicableForStorageCharge
											
										SET @dtmDeliveryDate = DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmEndingDate) + 1, 0)) + 1
									END
									ELSE
									BEGIN
										--Intermediate Month charges
										SELECT @dblStorageDuePerUnit = ISNULL(@dblStorageDuePerUnit, 0) - @dblStorageRate * (DATEDIFF(MONTH, @dtmDeliveryDate, DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmLastStorageAccrueDate), 0))) + 1)
																	  - CASE WHEN @strFeeType = 'Per Unit' THEN @dblFeeRate ELSE 0 END
										SET @TotalMonthsApplicableForStorageCharge = @TotalMonthsApplicableForStorageCharge - (DATEDIFF(MONTH, @dtmDeliveryDate, DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmLastStorageAccrueDate), 0))) + 1)
										
											INSERT INTO @StorageCharge([intPeriodKey],[strPeriodType],[dtmEffectiveDate],[dtmEndingDate],[dblStorageRate],[MonthType],[ChargeType],[ChargedNumberOfDays/Months],[dblStorageDuePerUnit],[dblCummulativeStorageDuePerUnit],[RemainingMonths])
											SELECT 
											 @intPeriodKey
											,@strPeriodType
											,@dtmDeliveryDate
											,DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmLastStorageAccrueDate), 0))
											,@dblStorageRate
											,'Intermediate Month'
											,'Full Month'
											,DATEDIFF(MONTH, @dtmDeliveryDate, DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmLastStorageAccrueDate), 0))) + 1
											,- @dblStorageRate * (DATEDIFF(MONTH, @dtmDeliveryDate, DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmLastStorageAccrueDate), 0))) + 1)
											,@dblStorageDuePerUnit
											,@TotalMonthsApplicableForStorageCharge
											
										SET @dtmDeliveryDate = DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmLastStorageAccrueDate), 0)) + 1

										--Last Month Charge
										SELECT @dblStorageDuePerUnit = ISNULL(@dblStorageDuePerUnit, 0) - CASE 
																												WHEN @strLastMonth = 'Full Month' THEN @dblStorageRate 
																												ELSE (@dblStorageRate/DATEDIFF(dd,@dtmDeliveryDate,DATEADD(m,1,@dtmDeliveryDate))) * (DATEDIFF(DAY, @dtmDeliveryDate, @dtmLastStorageAccrueDate) + 1)
																										   END
																	 - CASE WHEN @strFeeType = 'Per Unit' THEN @dblFeeRate ELSE 0 END																										

										SET @TotalMonthsApplicableForStorageCharge = @TotalMonthsApplicableForStorageCharge - 1

										INSERT INTO @StorageCharge([strPeriodType],[dtmEffectiveDate],[dtmEndingDate],[dblStorageRate],[MonthType],[ChargeType],[ChargedNumberOfDays/Months],[dblStorageDuePerUnit],[dblCummulativeStorageDuePerUnit],[RemainingMonths])										
										SELECT @strPeriodType
										,@dtmDeliveryDate
										,CASE 
											WHEN @strLastMonth = 'Full Month' THEN DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmLastStorageAccrueDate)+1, 0)) 
											ELSE @dtmLastStorageAccrueDate
										 END
										,@dblStorageRate
										,'Last Month'
										,CASE 
											WHEN @strLastMonth = 'Full Month' THEN 'Full Month' 
											ELSE 'Number of Days'
										 END
										,CASE 
											WHEN @strLastMonth = 'Full Month' THEN 1 
											ELSE DATEDIFF(DAY, @dtmDeliveryDate, @dtmLastStorageAccrueDate) + 1
										 END
										,CASE 
											WHEN @strLastMonth = 'Full Month' THEN -@dblStorageRate 
											ELSE -(@dblStorageRate/DATEDIFF(dd,@dtmDeliveryDate,DATEADD(m,1,@dtmDeliveryDate))) * (DATEDIFF(DAY, @dtmDeliveryDate, @dtmLastStorageAccrueDate) + 1)
										 END 
										,@dblStorageDuePerUnit
										,@TotalMonthsApplicableForStorageCharge

										SET @dtmDeliveryDate =CASE 
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
				ELSE IF @dtmDEffectiveDate IS NOT NULL AND @dtmEndingDate IS NULL
				BEGIN
					IF @dtmDeliveryDate > @dtmDEffectiveDate
						SET @dtmDEffectiveDate = @dtmDeliveryDate
					ELSE
					BEGIN
						SET @TotalMonthsApplicableForStorageCharge = CASE 
																		 WHEN (@TotalMonthsApplicableForStorageCharge - DATEDIFF(MONTH, @dtmDeliveryDate, @dtmDEffectiveDate)) < 0 THEN 0
																		 ELSE (@TotalMonthsApplicableForStorageCharge - DATEDIFF(MONTH, @dtmDeliveryDate, @dtmDEffectiveDate))
																	 END
						SET @dtmDeliveryDate = @dtmDEffectiveDate
					END
					
					IF (DATEDIFF(DAY, @dtmDEffectiveDate, @dtmLastStorageAccrueDate) + 1) > 0 AND @TotalMonthsApplicableForStorageCharge > 0
					BEGIN	
						
						--When Storage calculation Date is Same month of Delivery date.
						IF @TotalOriginalMonthsApplicableForStorageCharge = 1
						BEGIN
							SELECT @dblStorageDuePerUnit =   ISNULL(@dblStorageDuePerUnit, 0) 
															- CASE 
																  WHEN @FirstMonthFullChargeApplicable=1 THEN @dblStorageRate 
																  ELSE (@dblStorageRate/DATEDIFF(dd,@dtmDeliveryDate,DATEADD(m,1,@dtmDeliveryDate))) * (DATEDIFF(DAY, @dtmDeliveryDate, DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmDeliveryDate) + 1, 0))) + 1)
															  END
															- CASE WHEN @strFeeType = 'Per Unit' THEN @dblFeeRate ELSE 0 END
							
							SET @TotalMonthsApplicableForStorageCharge = @TotalMonthsApplicableForStorageCharge - 1
							
							INSERT INTO @StorageCharge([intPeriodKey],[strPeriodType],[dtmEffectiveDate],[dtmEndingDate],[dblStorageRate],[MonthType],[ChargeType],[ChargedNumberOfDays/Months],[dblStorageDuePerUnit],[dblCummulativeStorageDuePerUnit],[RemainingMonths])
							SELECT 
							 @intPeriodKey
							,@strPeriodType
							,@dtmDeliveryDate
							,CASE 
								WHEN @FirstMonthFullChargeApplicable=1 THEN DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmDeliveryDate) + 1, 0)) 
								ELSE @dtmLastStorageAccrueDate
							 END
							,@dblStorageRate
							,'First Month'
							,CASE 
								WHEN @FirstMonthFullChargeApplicable=1 THEN 'Full Month' 
								ELSE 'Number of Days'
							 END
							,CASE 
								WHEN @FirstMonthFullChargeApplicable=1 THEN 1 
								ELSE DATEDIFF(DAY, @dtmDeliveryDate, DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmDeliveryDate) + 1, 0))) + 1
							 END
							,CASE 
								WHEN @FirstMonthFullChargeApplicable=1 THEN -@dblStorageRate 
								ELSE -(@dblStorageRate/DATEDIFF(dd,@dtmDeliveryDate,DATEADD(m,1,@dtmDeliveryDate))) * (DATEDIFF(DAY, @dtmDeliveryDate, DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmDeliveryDate) + 1, 0))) + 1)
							  END
							,@dblStorageDuePerUnit
							,@TotalMonthsApplicableForStorageCharge
							
							SET @dtmDeliveryDate =CASE 
													 WHEN @FirstMonthFullChargeApplicable=1 THEN  DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmDeliveryDate) + 1, 0)) + 1 
													 ELSE @dtmLastStorageAccrueDate + 1
												  END
						END
						ELSE
						BEGIN
							IF @TotalOriginalMonthsApplicableForStorageCharge = @TotalMonthsApplicableForStorageCharge
							BEGIN
								---First Month Charge
								IF @strFirstMonth = 'Full Month'
								BEGIN
									SELECT @dblStorageDuePerUnit = ISNULL(@dblStorageDuePerUnit, 0) - @dblStorageRate - CASE WHEN @strFeeType = 'Per Unit' THEN @dblFeeRate ELSE 0 END
									SET @TotalMonthsApplicableForStorageCharge = @TotalMonthsApplicableForStorageCharge - 1
									
									INSERT INTO @StorageCharge([intPeriodKey],[strPeriodType],[dtmEffectiveDate],[dtmEndingDate],[dblStorageRate],[MonthType],[ChargeType],[ChargedNumberOfDays/Months],[dblStorageDuePerUnit],[dblCummulativeStorageDuePerUnit],[RemainingMonths])
									SELECT 
										 @intPeriodKey
										,@strPeriodType
										,@dtmDeliveryDate
										,DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmDeliveryDate) + 1, 0))
										,@dblStorageRate
										,'First Month'
										,'Full Month'
										,1
										,-@dblStorageRate
										,@dblStorageDuePerUnit
										,@TotalMonthsApplicableForStorageCharge
									
									SET @dtmDeliveryDate = DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmDeliveryDate) + 1, 0)) + 1
								END
								ELSE
								BEGIN
									SELECT @dblStorageDuePerUnit = ISNULL(@dblStorageDuePerUnit, 0) -(@dblStorageRate/DATEDIFF(dd,@dtmDeliveryDate,DATEADD(m,1,@dtmDeliveryDate))) * (DATEDIFF(DAY, @dtmDeliveryDate, DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmDeliveryDate) + 1, 0))) + 1)
																  - CASE WHEN @strFeeType = 'Per Unit' THEN @dblFeeRate ELSE 0 END
									SET @TotalMonthsApplicableForStorageCharge = @TotalMonthsApplicableForStorageCharge - 1
									
									INSERT INTO @StorageCharge([intPeriodKey],[strPeriodType],[dtmEffectiveDate],[dtmEndingDate],[dblStorageRate],[MonthType],[ChargeType],[ChargedNumberOfDays/Months],[dblStorageDuePerUnit],[dblCummulativeStorageDuePerUnit],[RemainingMonths])
									SELECT 
									 @intPeriodKey
									,@strPeriodType
									,@dtmDeliveryDate
									,DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmDeliveryDate) + 1, 0))
									,@dblStorageRate
									,'First Month'
									,'Number of Days'
									,DATEDIFF(DAY, @dtmDeliveryDate, DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmDeliveryDate) + 1, 0))) + 1
									,-(@dblStorageRate/DATEDIFF(dd,@dtmDeliveryDate,DATEADD(m,1,@dtmDeliveryDate))) * (DATEDIFF(DAY, @dtmDeliveryDate, DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmDeliveryDate) + 1, 0))) + 1)
									,@dblStorageDuePerUnit
									,@TotalMonthsApplicableForStorageCharge
									
									SET @dtmDeliveryDate = DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmDeliveryDate) + 1, 0)) + 1
								END
								
								---Intermediate and Last Month Charges
								IF (DATEDIFF(DAY, @dtmDeliveryDate, @dtmLastStorageAccrueDate) + 1) > 0
								BEGIN
								
									IF @TotalMonthsApplicableForStorageCharge > 1
									BEGIN
									
										--Intermediate Month charges
										SELECT @dblStorageDuePerUnit = ISNULL(@dblStorageDuePerUnit, 0) - @dblStorageRate * (DATEDIFF(MONTH, @dtmDeliveryDate, DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmLastStorageAccrueDate), 0))) + 1)
																	  - CASE WHEN @strFeeType = 'Per Unit' THEN @dblFeeRate ELSE 0 END
										SET @TotalMonthsApplicableForStorageCharge = @TotalMonthsApplicableForStorageCharge - (DATEDIFF(MONTH, @dtmDeliveryDate, DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmLastStorageAccrueDate), 0))) + 1)
										
										INSERT INTO @StorageCharge([intPeriodKey],[strPeriodType],[dtmEffectiveDate],[dtmEndingDate],[dblStorageRate],[MonthType],[ChargeType],[ChargedNumberOfDays/Months],[dblStorageDuePerUnit],[dblCummulativeStorageDuePerUnit],[RemainingMonths])
										 SELECT 
										 @intPeriodKey
										,@strPeriodType
										,@dtmDeliveryDate
										,DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmLastStorageAccrueDate), 0))
										,@dblStorageRate
										,'Intermediate Month'
										,'Full Month'
										,DATEDIFF(MONTH, @dtmDeliveryDate, DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmLastStorageAccrueDate), 0))) + 1
										,-@dblStorageRate * (DATEDIFF(MONTH, @dtmDeliveryDate, DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmLastStorageAccrueDate), 0))) + 1)
										,@dblStorageDuePerUnit
										,@TotalMonthsApplicableForStorageCharge
											
										SET @dtmDeliveryDate = DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmLastStorageAccrueDate), 0)) + 1

										--Last Month Charge
										IF @strLastMonth = 'Full Month'
										BEGIN
											SELECT @dblStorageDuePerUnit = ISNULL(@dblStorageDuePerUnit, 0) - @dblStorageRate - CASE WHEN @strFeeType = 'Per Unit' THEN @dblFeeRate ELSE 0 END
											SET @TotalMonthsApplicableForStorageCharge = @TotalMonthsApplicableForStorageCharge - 1
											
											INSERT INTO @StorageCharge([intPeriodKey],[strPeriodType],[dtmEffectiveDate],[dtmEndingDate],[dblStorageRate],[MonthType],[ChargeType],[ChargedNumberOfDays/Months],[dblStorageDuePerUnit],[dblCummulativeStorageDuePerUnit],[RemainingMonths])
											SELECT 
											 @intPeriodKey
											,@strPeriodType
											,@dtmDeliveryDate
											,DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmLastStorageAccrueDate)+1, 0))
											,@dblStorageRate
											,'Last Month'
											,'Full Month'
											,1
											,-@dblStorageRate
											,@dblStorageDuePerUnit
											,@TotalMonthsApplicableForStorageCharge
											
											SET @dtmDeliveryDate = DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmLastStorageAccrueDate) + 1, 0)) + 1
										END
										ELSE
										BEGIN
											SELECT @dblStorageDuePerUnit = ISNULL(@dblStorageDuePerUnit, 0) -(@dblStorageRate/DATEDIFF(dd,@dtmDeliveryDate,DATEADD(m,1,@dtmDeliveryDate))) * (DATEDIFF(DAY, @dtmDeliveryDate, @dtmLastStorageAccrueDate) + 1)
																		  - CASE WHEN @strFeeType = 'Per Unit' THEN @dblFeeRate ELSE 0 END
											SET @TotalMonthsApplicableForStorageCharge = @TotalMonthsApplicableForStorageCharge - 1
											
											INSERT INTO @StorageCharge([intPeriodKey],[strPeriodType],[dtmEffectiveDate],[dtmEndingDate],[dblStorageRate],[MonthType],[ChargeType],[ChargedNumberOfDays/Months],[dblStorageDuePerUnit],[dblCummulativeStorageDuePerUnit],[RemainingMonths])
											SELECT 
											 @intPeriodKey
											,@strPeriodType
											,@dtmDeliveryDate
											,@dtmLastStorageAccrueDate
											,@dblStorageRate
											,'Last Month'
											,'Number of Days'
											,DATEDIFF(DAY, @dtmDeliveryDate, @dtmLastStorageAccrueDate) + 1
											,-(@dblStorageRate/DATEDIFF(dd,@dtmDeliveryDate,DATEADD(m,1,@dtmDeliveryDate))) * (DATEDIFF(DAY, @dtmDeliveryDate, @dtmLastStorageAccrueDate) + 1)
											,@dblStorageDuePerUnit
											,@TotalMonthsApplicableForStorageCharge
											
											SET @dtmDeliveryDate = @dtmLastStorageAccrueDate + 1
										END
									END
									ELSE
									BEGIN
										--Last Month Charge
										IF @strLastMonth = 'Full Month'
										BEGIN
											SELECT @dblStorageDuePerUnit = ISNULL(@dblStorageDuePerUnit, 0) - @dblStorageRate - CASE WHEN @strFeeType = 'Per Unit' THEN @dblFeeRate ELSE 0 END
											SET @TotalMonthsApplicableForStorageCharge = @TotalMonthsApplicableForStorageCharge - 1
											
											INSERT INTO @StorageCharge([intPeriodKey],[strPeriodType],[dtmEffectiveDate],[dtmEndingDate],[dblStorageRate],[MonthType],[ChargeType],[ChargedNumberOfDays/Months],[dblStorageDuePerUnit],[dblCummulativeStorageDuePerUnit],[RemainingMonths])
											SELECT 
											 @intPeriodKey
											,@strPeriodType
											,@dtmDeliveryDate
											,DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmLastStorageAccrueDate)+1, 0))
											,@dblStorageRate
											,'Last Month'
											,'Full Month'
											,1
											,-@dblStorageRate
											,@dblStorageDuePerUnit
											,@TotalMonthsApplicableForStorageCharge
											
											SET @dtmDeliveryDate = DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmLastStorageAccrueDate) + 1, 0)) + 1
										END
										ELSE
										BEGIN
											SELECT @dblStorageDuePerUnit = ISNULL(@dblStorageDuePerUnit, 0) - (@dblStorageRate/DATEDIFF(dd,@dtmDeliveryDate,DATEADD(m,1,@dtmDeliveryDate))) * (DATEDIFF(DAY, @dtmDeliveryDate, @dtmLastStorageAccrueDate) + 1)
																		  - CASE WHEN @strFeeType = 'Per Unit' THEN @dblFeeRate ELSE 0 END
											SET @TotalMonthsApplicableForStorageCharge = @TotalMonthsApplicableForStorageCharge - 1
											
											INSERT INTO @StorageCharge([intPeriodKey],[strPeriodType],[dtmEffectiveDate],[dtmEndingDate],[dblStorageRate],[MonthType],[ChargeType],[ChargedNumberOfDays/Months],[dblStorageDuePerUnit],[dblCummulativeStorageDuePerUnit],[RemainingMonths])
											SELECT 
											 @intPeriodKey
											,@strPeriodType
											,@dtmDeliveryDate
											,@dtmLastStorageAccrueDate
											,@dblStorageRate
											,'Last Month'
											,'Number of Days'
											,DATEDIFF(DAY, @dtmDeliveryDate, @dtmLastStorageAccrueDate) + 1
											,-(@dblStorageRate/DATEDIFF(dd,@dtmDeliveryDate,DATEADD(m,1,@dtmDeliveryDate))) * (DATEDIFF(DAY, @dtmDeliveryDate, @dtmLastStorageAccrueDate) + 1)
											,@dblStorageDuePerUnit
											,@TotalMonthsApplicableForStorageCharge
											
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
								
									IF @TotalMonthsApplicableForStorageCharge > 1
									BEGIN									
										--Intermediate Month charges
										SELECT @dblStorageDuePerUnit = ISNULL(@dblStorageDuePerUnit, 0) - @dblStorageRate * (DATEDIFF(MONTH, @dtmDeliveryDate, DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmLastStorageAccrueDate), 0))) + 1)
																	  - CASE WHEN @strFeeType = 'Per Unit' THEN @dblFeeRate ELSE 0 END
										SET @TotalMonthsApplicableForStorageCharge = @TotalMonthsApplicableForStorageCharge - (DATEDIFF(MONTH, @dtmDeliveryDate, DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmLastStorageAccrueDate), 0))) + 1)
										
										 INSERT INTO @StorageCharge([intPeriodKey],[strPeriodType],[dtmEffectiveDate],[dtmEndingDate],[dblStorageRate],[MonthType],[ChargeType],[ChargedNumberOfDays/Months],[dblStorageDuePerUnit],[dblCummulativeStorageDuePerUnit],[RemainingMonths])
										 SELECT 
										 @intPeriodKey
										,@strPeriodType
										,@dtmDeliveryDate
										,DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmLastStorageAccrueDate), 0))
										,@dblStorageRate
										,'Intermediate Month'
										,'Full Month'
										,DATEDIFF(MONTH, @dtmDeliveryDate, DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmLastStorageAccrueDate), 0))) + 1
										,- @dblStorageRate * (DATEDIFF(MONTH, @dtmDeliveryDate, DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmLastStorageAccrueDate), 0))) + 1)
										,@dblStorageDuePerUnit
										,@TotalMonthsApplicableForStorageCharge
											
										SET @dtmDeliveryDate = DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmLastStorageAccrueDate), 0)) + 1

										--Last Month Charge
										IF @strLastMonth = 'Full Month'
										BEGIN
											SELECT @dblStorageDuePerUnit = ISNULL(@dblStorageDuePerUnit, 0) - @dblStorageRate - CASE WHEN @strFeeType = 'Per Unit' THEN @dblFeeRate ELSE 0 END
											SET @TotalMonthsApplicableForStorageCharge = @TotalMonthsApplicableForStorageCharge - 1
											
											INSERT INTO @StorageCharge([intPeriodKey],[strPeriodType],[dtmEffectiveDate],[dtmEndingDate],[dblStorageRate],[MonthType],[ChargeType],[ChargedNumberOfDays/Months],[dblStorageDuePerUnit],[dblCummulativeStorageDuePerUnit],[RemainingMonths])
											SELECT 
											 @intPeriodKey
											,@strPeriodType
											,@dtmDeliveryDate
											,DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmLastStorageAccrueDate)+1, 0))
											,@dblStorageRate
											,'Last Month'
											,'Full Month'
											,1
											,-@dblStorageRate
											,@dblStorageDuePerUnit
											,@TotalMonthsApplicableForStorageCharge
											
											SET @dtmDeliveryDate = DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmLastStorageAccrueDate) + 1, 0)) + 1
										END
										ELSE
										BEGIN
											SELECT @dblStorageDuePerUnit = ISNULL(@dblStorageDuePerUnit, 0) -(@dblStorageRate/DATEDIFF(dd,@dtmDeliveryDate,DATEADD(m,1,@dtmDeliveryDate))) * (DATEDIFF(DAY, @dtmDeliveryDate, @dtmLastStorageAccrueDate) + 1)
																		  - CASE WHEN @strFeeType = 'Per Unit' THEN @dblFeeRate ELSE 0 END
											SET @TotalMonthsApplicableForStorageCharge = @TotalMonthsApplicableForStorageCharge - 1
											
											INSERT INTO @StorageCharge([intPeriodKey],[strPeriodType],[dtmEffectiveDate],[dtmEndingDate],[dblStorageRate],[MonthType],[ChargeType],[ChargedNumberOfDays/Months],[dblStorageDuePerUnit],[dblCummulativeStorageDuePerUnit],[RemainingMonths])
											SELECT 
											 @intPeriodKey
											,@strPeriodType
											,@dtmDeliveryDate
											,@dtmLastStorageAccrueDate
											,@dblStorageRate
											,'Last Month'
											,'Number of Days'
											,DATEDIFF(DAY, @dtmDeliveryDate, @dtmLastStorageAccrueDate) + 1
											,-(@dblStorageRate/DATEDIFF(dd,@dtmDeliveryDate,DATEADD(m,1,@dtmDeliveryDate))) * (DATEDIFF(DAY, @dtmDeliveryDate, @dtmLastStorageAccrueDate) + 1)
											,@dblStorageDuePerUnit
											,@TotalMonthsApplicableForStorageCharge
											
											SET @dtmDeliveryDate = @dtmLastStorageAccrueDate + 1
										END
									END
									ELSE
									BEGIN
										--Last Month Charge
										IF @strLastMonth = 'Full Month'
										BEGIN
											SELECT @dblStorageDuePerUnit = ISNULL(@dblStorageDuePerUnit, 0) - @dblStorageRate - CASE WHEN @strFeeType = 'Per Unit' THEN @dblFeeRate ELSE 0 END
											SET @TotalMonthsApplicableForStorageCharge = @TotalMonthsApplicableForStorageCharge - 1
											
											INSERT INTO @StorageCharge([intPeriodKey],[strPeriodType],[dtmEffectiveDate],[dtmEndingDate],[dblStorageRate],[MonthType],[ChargeType],[ChargedNumberOfDays/Months],[dblStorageDuePerUnit],[dblCummulativeStorageDuePerUnit],[RemainingMonths])
											SELECT 
											 @intPeriodKey
											,@strPeriodType
											,@dtmDeliveryDate
											,DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmLastStorageAccrueDate)+1, 0))
											,@dblStorageRate
											,'Last Month'
											,'Full Month'
											,1
											,-@dblStorageRate
											,@dblStorageDuePerUnit
											,@TotalMonthsApplicableForStorageCharge
											
											SET @dtmDeliveryDate = DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmLastStorageAccrueDate) + 1, 0)) + 1
										END
										ELSE
										BEGIN
											SELECT @dblStorageDuePerUnit = ISNULL(@dblStorageDuePerUnit, 0) -(@dblStorageRate/DATEDIFF(dd,@dtmDeliveryDate,DATEADD(m,1,@dtmDeliveryDate))) * (DATEDIFF(DAY, @dtmDeliveryDate, @dtmLastStorageAccrueDate) + 1)
																		  - CASE WHEN @strFeeType = 'Per Unit' THEN @dblFeeRate ELSE 0 END
											SET @TotalMonthsApplicableForStorageCharge = @TotalMonthsApplicableForStorageCharge - 1
											
											INSERT INTO @StorageCharge([intPeriodKey],[strPeriodType],[dtmEffectiveDate],[dtmEndingDate],[dblStorageRate],[MonthType],[ChargeType],[ChargedNumberOfDays/Months],[dblStorageDuePerUnit],[dblCummulativeStorageDuePerUnit],[RemainingMonths])
											SELECT 
											 @intPeriodKey
											,@strPeriodType
											,@dtmDeliveryDate
											,@dtmLastStorageAccrueDate
											,@dblStorageRate
											,'Last Month'
											,'Number of Days'
											,DATEDIFF(DAY, @dtmDeliveryDate, @dtmLastStorageAccrueDate) + 1
											,-(@dblStorageRate/DATEDIFF(dd,@dtmDeliveryDate,DATEADD(m,1,@dtmDeliveryDate))) * (DATEDIFF(DAY, @dtmDeliveryDate, @dtmLastStorageAccrueDate) + 1)
											,@dblStorageDuePerUnit
											,@TotalMonthsApplicableForStorageCharge
											
											SET @dtmDeliveryDate = @dtmLastStorageAccrueDate + 1
										END	
									END	
								END
							END
						END					
					END
				
				END
				
			    --CASE 3.Start Date < > Blank, Ending Date < > Blank			
				ELSE IF @dtmDEffectiveDate IS NOT NULL AND @dtmEndingDate IS NOT NULL
				BEGIN
					IF @dtmDeliveryDate > @dtmDEffectiveDate
						SET @dtmDEffectiveDate = @dtmDeliveryDate
					ELSE
					BEGIN
						SET @TotalMonthsApplicableForStorageCharge = CASE 
																		 WHEN (@TotalMonthsApplicableForStorageCharge - DATEDIFF(MONTH, @dtmDeliveryDate, @dtmDEffectiveDate)) < 0 THEN 0
																		 ELSE (@TotalMonthsApplicableForStorageCharge - DATEDIFF(MONTH, @dtmDeliveryDate, @dtmDEffectiveDate))
																	 END
						SET @dtmDeliveryDate = @dtmDEffectiveDate
					END

					IF @dtmEndingDate > @dtmLastStorageAccrueDate
						SET @dtmEndingDate = @dtmLastStorageAccrueDate

					IF (DATEDIFF(DAY, @dtmDEffectiveDate, @dtmLastStorageAccrueDate) + 1) > 0 AND ((DATEDIFF(DAY, @dtmDeliveryDate, @dtmEndingDate) + 1) > 0) AND @TotalMonthsApplicableForStorageCharge > 0
					BEGIN
					
						--When Storage calculation Date is Same month of Delivery date.
						IF @TotalOriginalMonthsApplicableForStorageCharge = 1
						BEGIN
							--When FirstMonth and Last Month not are Matching then Charge Full month
							IF @strFirstMonth <> @strLastMonth
							BEGIN
								SELECT @dblStorageDuePerUnit = ISNULL(@dblStorageDuePerUnit, 0) - @dblStorageRate - CASE WHEN @strFeeType = 'Per Unit' THEN @dblFeeRate ELSE 0 END
								SET @TotalMonthsApplicableForStorageCharge = @TotalMonthsApplicableForStorageCharge - 1
								
								INSERT INTO @StorageCharge([intPeriodKey],[strPeriodType],[dtmEffectiveDate],[dtmEndingDate],[dblStorageRate],[MonthType],[ChargeType],[ChargedNumberOfDays/Months],[dblStorageDuePerUnit],[dblCummulativeStorageDuePerUnit],[RemainingMonths])
								SELECT 
								 @intPeriodKey
								,@strPeriodType
								,@dtmDeliveryDate
								,DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmDeliveryDate) + 1, 0))
								,@dblStorageRate 
								,'First Month'
								,'Full Month'
								,1										
								,-@dblStorageRate
								,@dblStorageDuePerUnit
								,@TotalMonthsApplicableForStorageCharge										
									
								SET @dtmDeliveryDate = DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmDeliveryDate) + 1, 0)) + 1
							END
							ELSE
							BEGIN
								IF @strFirstMonth = 'Full Month' AND @strLastMonth = 'Full Month'
								BEGIN
									SELECT @dblStorageDuePerUnit = ISNULL(@dblStorageDuePerUnit, 0) - @dblStorageRate - CASE WHEN @strFeeType = 'Per Unit' THEN @dblFeeRate ELSE 0 END
									SET @TotalMonthsApplicableForStorageCharge = @TotalMonthsApplicableForStorageCharge - 1
									
									     INSERT INTO @StorageCharge([intPeriodKey],[strPeriodType],[dtmEffectiveDate],[dtmEndingDate],[dblStorageRate],[MonthType],[ChargeType],[ChargedNumberOfDays/Months],[dblStorageDuePerUnit],[dblCummulativeStorageDuePerUnit],[RemainingMonths])
										 SELECT 
										 @intPeriodKey
										,@strPeriodType
										,@dtmDeliveryDate
										,DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmDeliveryDate) + 1, 0))
										,@dblStorageRate
										,'First Month'
										,'Full Month'
										,1
										,-@dblStorageRate
										,@dblStorageDuePerUnit
										,@TotalMonthsApplicableForStorageCharge										
									
									SET @dtmDeliveryDate = DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmDeliveryDate) + 1, 0)) + 1
									
								END
								ELSE
								BEGIN
									SELECT @dblStorageDuePerUnit = ISNULL(@dblStorageDuePerUnit, 0) - (@dblStorageRate/DATEDIFF(dd,@dtmDeliveryDate,DATEADD(m,1,@dtmDeliveryDate))) * (DATEDIFF(DAY, @dtmDeliveryDate, @dtmLastStorageAccrueDate) + 1)
																   - CASE WHEN @strFeeType = 'Per Unit' THEN @dblFeeRate ELSE 0 END
									SET @TotalMonthsApplicableForStorageCharge = @TotalMonthsApplicableForStorageCharge - 1
									
										INSERT INTO @StorageCharge([intPeriodKey],[strPeriodType],[dtmEffectiveDate],[dtmEndingDate],[dblStorageRate],[MonthType],[ChargeType],[ChargedNumberOfDays/Months],[dblStorageDuePerUnit],[dblCummulativeStorageDuePerUnit],[RemainingMonths])
										 SELECT 
										 @intPeriodKey
										,@strPeriodType
										,@dtmDeliveryDate
										,@dtmLastStorageAccrueDate
										,@dblStorageRate
										,'First Month'
										,'Number of Days'
										,DATEDIFF(DAY, @dtmDeliveryDate, @dtmLastStorageAccrueDate) + 1
										,-(@dblStorageRate/DATEDIFF(dd,@dtmDeliveryDate,DATEADD(m,1,@dtmDeliveryDate))) * (DATEDIFF(DAY, @dtmDeliveryDate, @dtmLastStorageAccrueDate) + 1)
										,@dblStorageDuePerUnit
										,@TotalMonthsApplicableForStorageCharge
											
										SET @dtmDeliveryDate = DATEDIFF(DAY, @dtmDeliveryDate, @dtmLastStorageAccrueDate) + 1 									
								END
							END
						END
						ELSE
						BEGIN
							IF @TotalOriginalMonthsApplicableForStorageCharge = @TotalMonthsApplicableForStorageCharge
							BEGIN
								---First Month Charge
								IF @strFirstMonth = 'Full Month'
								BEGIN
									SELECT @dblStorageDuePerUnit = ISNULL(@dblStorageDuePerUnit, 0) - @dblStorageRate - CASE WHEN @strFeeType = 'Per Unit' THEN @dblFeeRate ELSE 0 END
									SET @TotalMonthsApplicableForStorageCharge = @TotalMonthsApplicableForStorageCharge - 1
									
									 INSERT INTO @StorageCharge([intPeriodKey],[strPeriodType],[dtmEffectiveDate],[dtmEndingDate],[dblStorageRate],[MonthType],[ChargeType],[ChargedNumberOfDays/Months],[dblStorageDuePerUnit],[dblCummulativeStorageDuePerUnit],[RemainingMonths])
									 SELECT 
									 @intPeriodKey
									,@strPeriodType
									,@dtmDeliveryDate
									,DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmDeliveryDate) + 1, 0))
									,@dblStorageRate
									,'First Month'
									,'Full Month'
									,1
									,-@dblStorageRate
									,@dblStorageDuePerUnit
									,@TotalMonthsApplicableForStorageCharge
											
									SET @dtmDeliveryDate = DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmDeliveryDate) + 1, 0)) + 1
								END
								ELSE
								BEGIN
																	
									SELECT @dblStorageDuePerUnit = ISNULL(@dblStorageDuePerUnit, 0) - (@dblStorageRate/DATEDIFF(dd,@dtmDeliveryDate,DATEADD(m,1,@dtmDeliveryDate))) * (DATEDIFF(DAY, @dtmDeliveryDate, DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmDeliveryDate) + 1, 0))) + 1)
																  - CASE WHEN @strFeeType = 'Per Unit' THEN @dblFeeRate ELSE 0 END
									SET @TotalMonthsApplicableForStorageCharge = @TotalMonthsApplicableForStorageCharge - 1
									
									 INSERT INTO @StorageCharge([intPeriodKey],[strPeriodType],[dtmEffectiveDate],[dtmEndingDate],[dblStorageRate],[MonthType],[ChargeType],[ChargedNumberOfDays/Months],[dblStorageDuePerUnit],[dblCummulativeStorageDuePerUnit],[RemainingMonths])
									 SELECT 
									 @intPeriodKey
									,@strPeriodType
									,@dtmDeliveryDate
									,DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmDeliveryDate) + 1, 0))
									,@dblStorageRate
									,'First Month'
									,'Number of Days'
									,DATEDIFF(DAY, @dtmDeliveryDate, DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmDeliveryDate) + 1, 0))) + 1
									,-(@dblStorageRate/DATEDIFF(dd,@dtmDeliveryDate,DATEADD(m,1,@dtmDeliveryDate))) * (DATEDIFF(DAY, @dtmDeliveryDate, DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmDeliveryDate) + 1, 0))) + 1)
									,@dblStorageDuePerUnit
									,@TotalMonthsApplicableForStorageCharge
										
									SET @dtmDeliveryDate = DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmDeliveryDate) + 1, 0)) + 1
								END

								IF (DATEDIFF(DAY, @dtmDeliveryDate, @dtmEndingDate) + 1) > 0
								BEGIN
									IF @dtmLastStorageAccrueDate > @dtmEndingDate
									BEGIN
										---Intermediate Month Charges
										SELECT @dblStorageDuePerUnit = ISNULL(@dblStorageDuePerUnit, 0) - @dblStorageRate * (DATEDIFF(MONTH, @dtmDeliveryDate, @dtmEndingDate) + 1)
																	  - CASE WHEN @strFeeType = 'Per Unit' THEN @dblFeeRate ELSE 0 END
										SET @TotalMonthsApplicableForStorageCharge = @TotalMonthsApplicableForStorageCharge - (DATEDIFF(MONTH, @dtmDeliveryDate, @dtmEndingDate) + 1)
										
										INSERT INTO @StorageCharge([intPeriodKey],[strPeriodType],[dtmEffectiveDate],[dtmEndingDate],[dblStorageRate],[MonthType],[ChargeType],[ChargedNumberOfDays/Months],[dblStorageDuePerUnit],[dblCummulativeStorageDuePerUnit],[RemainingMonths])
										 SELECT 
										 @intPeriodKey
										,@strPeriodType
										,@dtmDeliveryDate
										,DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmEndingDate) + 1, 0))
										,@dblStorageRate
										,'Intermediate Month'
										,'Full Month'
										,DATEDIFF(MONTH, @dtmDeliveryDate, @dtmEndingDate) + 1
										,-@dblStorageRate * (DATEDIFF(MONTH, @dtmDeliveryDate, @dtmEndingDate) + 1)
										,@dblStorageDuePerUnit
										,@TotalMonthsApplicableForStorageCharge
										
										SET @dtmDeliveryDate = DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmEndingDate) + 1, 0)) + 1
									END
									ELSE
									BEGIN
										--Intermediate Month charges
										SELECT @dblStorageDuePerUnit = ISNULL(@dblStorageDuePerUnit, 0) - @dblStorageRate * (DATEDIFF(MONTH, @dtmDeliveryDate, DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmLastStorageAccrueDate), 0))) + 1)
																	  - CASE WHEN @strFeeType = 'Per Unit' THEN @dblFeeRate ELSE 0 END
										SET @TotalMonthsApplicableForStorageCharge = @TotalMonthsApplicableForStorageCharge - (DATEDIFF(MONTH, @dtmDeliveryDate, DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmLastStorageAccrueDate), 0))) + 1)
										
										INSERT INTO @StorageCharge([intPeriodKey],[strPeriodType],[dtmEffectiveDate],[dtmEndingDate],[dblStorageRate],[MonthType],[ChargeType],[ChargedNumberOfDays/Months],[dblStorageDuePerUnit],[dblCummulativeStorageDuePerUnit],[RemainingMonths])
										SELECT 
										 @intPeriodKey
										,@strPeriodType
										,@dtmDeliveryDate
										,DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmLastStorageAccrueDate), 0))
										,@dblStorageRate
										,'Intermediate Month'
										,'Full Month'
										,(DATEDIFF(MONTH, @dtmDeliveryDate, DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmLastStorageAccrueDate), 0))) + 1)
										,-@dblStorageRate * (DATEDIFF(MONTH, @dtmDeliveryDate, DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmLastStorageAccrueDate), 0))) + 1)
										,@dblStorageDuePerUnit
										,@TotalMonthsApplicableForStorageCharge
										
										SET @dtmDeliveryDate = DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmLastStorageAccrueDate), 0)) + 1

										--Last Month Charge
										IF @strLastMonth = 'Full Month'
										BEGIN
											SELECT @dblStorageDuePerUnit = ISNULL(@dblStorageDuePerUnit, 0) - @dblStorageRate - CASE WHEN @strFeeType = 'Per Unit' THEN @dblFeeRate ELSE 0 END
											SET @TotalMonthsApplicableForStorageCharge = @TotalMonthsApplicableForStorageCharge - 1
											
										INSERT INTO @StorageCharge([intPeriodKey],[strPeriodType],[dtmEffectiveDate],[dtmEndingDate],[dblStorageRate],[MonthType],[ChargeType],[ChargedNumberOfDays/Months],[dblStorageDuePerUnit],[dblCummulativeStorageDuePerUnit],[RemainingMonths])
										 SELECT 
										 @intPeriodKey
										,@strPeriodType
										,@dtmDeliveryDate
										,DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmLastStorageAccrueDate)+1, 0))
										,@dblStorageRate
										,'Last Month'
										,'Full Month'
										,1
										,-@dblStorageRate
										,@dblStorageDuePerUnit
										,@TotalMonthsApplicableForStorageCharge
										
										SET @dtmDeliveryDate = DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmLastStorageAccrueDate) + 1, 0)) + 1
										
										END
										ELSE
										BEGIN
											SELECT @dblStorageDuePerUnit = ISNULL(@dblStorageDuePerUnit, 0) - (@dblStorageRate/DATEDIFF(dd,@dtmDeliveryDate,DATEADD(m,1,@dtmDeliveryDate))) * (DATEDIFF(DAY, @dtmDeliveryDate, @dtmLastStorageAccrueDate) + 1)
																		  - CASE WHEN @strFeeType = 'Per Unit' THEN @dblFeeRate ELSE 0 END
											SET @TotalMonthsApplicableForStorageCharge = @TotalMonthsApplicableForStorageCharge - 1
												
												 INSERT INTO @StorageCharge([intPeriodKey],[strPeriodType],[dtmEffectiveDate],[dtmEndingDate],[dblStorageRate],[MonthType],[ChargeType],[ChargedNumberOfDays/Months],[dblStorageDuePerUnit],[dblCummulativeStorageDuePerUnit],[RemainingMonths])
												 SELECT 
												 @intPeriodKey
												,@strPeriodType
												,@dtmDeliveryDate
												,@dtmLastStorageAccrueDate
												,@dblStorageRate
												,'Last Month'
												,'Number of Days'
												,DATEDIFF(DAY, @dtmDeliveryDate, @dtmLastStorageAccrueDate) + 1
												,-(@dblStorageRate/DATEDIFF(dd,@dtmDeliveryDate,DATEADD(m,1,@dtmDeliveryDate))) * (DATEDIFF(DAY, @dtmDeliveryDate, @dtmLastStorageAccrueDate) + 1)
												,@dblStorageDuePerUnit
												,@TotalMonthsApplicableForStorageCharge
												
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
										SELECT @dblStorageDuePerUnit = ISNULL(@dblStorageDuePerUnit, 0) - @dblStorageRate * (DATEDIFF(MONTH, @dtmDeliveryDate, @dtmEndingDate) + 1)
																	  - CASE WHEN @strFeeType = 'Per Unit' THEN @dblFeeRate ELSE 0 END
										SET @TotalMonthsApplicableForStorageCharge = @TotalMonthsApplicableForStorageCharge - (DATEDIFF(MONTH, @dtmDeliveryDate, @dtmEndingDate) + 1)
										
										INSERT INTO @StorageCharge([intPeriodKey],[strPeriodType],[dtmEffectiveDate],[dtmEndingDate],[dblStorageRate],[MonthType],[ChargeType],[ChargedNumberOfDays/Months],[dblStorageDuePerUnit],[dblCummulativeStorageDuePerUnit],[RemainingMonths])
										SELECT 
										 @intPeriodKey
										,@strPeriodType
										,@dtmDeliveryDate
										,DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmEndingDate), 0))
										,@dblStorageRate
										,'Intermediate Month'
										,'Full Month'
										,DATEDIFF(MONTH, @dtmDeliveryDate, @dtmEndingDate) + 1
										,-@dblStorageRate * (DATEDIFF(MONTH, @dtmDeliveryDate, @dtmEndingDate) + 1)
										,@dblStorageDuePerUnit
										,@TotalMonthsApplicableForStorageCharge
												
										SET @dtmDeliveryDate = DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmEndingDate) + 1, 0)) + 1
									END
									ELSE
									BEGIN
										--Intermediate Month charges
										SELECT @dblStorageDuePerUnit = ISNULL(@dblStorageDuePerUnit, 0) - @dblStorageRate * (DATEDIFF(MONTH, @dtmDeliveryDate, DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmLastStorageAccrueDate), 0))) + 1)
																	  - CASE WHEN @strFeeType = 'Per Unit' THEN @dblFeeRate ELSE 0 END
										SET @TotalMonthsApplicableForStorageCharge = @TotalMonthsApplicableForStorageCharge - (DATEDIFF(MONTH, @dtmDeliveryDate, DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmLastStorageAccrueDate), 0))) + 1)
										
										 INSERT INTO @StorageCharge([intPeriodKey],[strPeriodType],[dtmEffectiveDate],[dtmEndingDate],[dblStorageRate],[MonthType],[ChargeType],[ChargedNumberOfDays/Months],[dblStorageDuePerUnit],[dblCummulativeStorageDuePerUnit],[RemainingMonths])
										 SELECT 
										 @intPeriodKey
										,@strPeriodType
										,@dtmDeliveryDate
										,DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmLastStorageAccrueDate), 0))
										,@dblStorageRate
										,'Intermediate Month'
										,'Full Month'
										,DATEDIFF(MONTH, @dtmDeliveryDate, DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmLastStorageAccrueDate), 0))) + 1
										,-@dblStorageRate * (DATEDIFF(MONTH, @dtmDeliveryDate, DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmLastStorageAccrueDate), 0))) + 1)
										,@dblStorageDuePerUnit
										,@TotalMonthsApplicableForStorageCharge
												
										SET @dtmDeliveryDate = DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmLastStorageAccrueDate), 0)) + 1

										--Last Month Charge										
										IF @strLastMonth = 'Full Month'
										BEGIN
											SELECT @dblStorageDuePerUnit = ISNULL(@dblStorageDuePerUnit, 0) - @dblStorageRate - CASE WHEN @strFeeType = 'Per Unit' THEN @dblFeeRate ELSE 0 END
											SET @TotalMonthsApplicableForStorageCharge = @TotalMonthsApplicableForStorageCharge - 1
											
											 INSERT INTO @StorageCharge([intPeriodKey],[strPeriodType],[dtmEffectiveDate],[dtmEndingDate],[dblStorageRate],[MonthType],[ChargeType],[ChargedNumberOfDays/Months],[dblStorageDuePerUnit],[dblCummulativeStorageDuePerUnit],[RemainingMonths])
											 SELECT 
											 @intPeriodKey
											,@strPeriodType
											,@dtmDeliveryDate
											,DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmLastStorageAccrueDate)+1, 0))
											,@dblStorageRate
											,'Last Month'
											,'Full Month'
											,1
											,-@dblStorageRate
											,@dblStorageDuePerUnit
											,@TotalMonthsApplicableForStorageCharge								
												
										SET @dtmDeliveryDate = DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmLastStorageAccrueDate) + 1, 0)) + 1
										
										END
										ELSE
										BEGIN										
											SELECT @dblStorageDuePerUnit = ISNULL(@dblStorageDuePerUnit, 0) - (@dblStorageRate/DATEDIFF(dd,@dtmDeliveryDate,DATEADD(m,1,@dtmDeliveryDate))) * (DATEDIFF(DAY, @dtmDeliveryDate, @dtmLastStorageAccrueDate) + 1)
																		  - CASE WHEN @strFeeType = 'Per Unit' THEN @dblFeeRate ELSE 0 END
											SET @TotalMonthsApplicableForStorageCharge = @TotalMonthsApplicableForStorageCharge - 1
											
											INSERT INTO @StorageCharge([intPeriodKey],[strPeriodType],[dtmEffectiveDate],[dtmEndingDate],[dblStorageRate],[MonthType],[ChargeType],[ChargedNumberOfDays/Months],[dblStorageDuePerUnit],[dblCummulativeStorageDuePerUnit],[RemainingMonths])
											SELECT 
											 @intPeriodKey
											,@strPeriodType
											,@dtmDeliveryDate
											,@dtmLastStorageAccrueDate
											,@dblStorageRate
											,'Last Month'
											,'Number of Days'
											,DATEDIFF(DAY, @dtmDeliveryDate, @dtmLastStorageAccrueDate) + 1
											,-(@dblStorageRate/DATEDIFF(dd,@dtmDeliveryDate,DATEADD(m,1,@dtmDeliveryDate))) * (DATEDIFF(DAY, @dtmDeliveryDate, @dtmLastStorageAccrueDate) + 1)
											,@dblStorageDuePerUnit
											,@TotalMonthsApplicableForStorageCharge
												
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
				IF @dtmDEffectiveDate IS NULL
				BEGIN
					--When Storage calculation Date is Same month of Delivery date.
					IF @TotalOriginalMonthsApplicableForStorageCharge = 1
					BEGIN
						--When FirstMonth and Last Month not are Matching then Charge Full month
						IF @strFirstMonth <> @strLastMonth
						BEGIN
							SELECT @dblStorageDuePerUnit = ISNULL(@dblStorageDuePerUnit, 0) - @dblStorageRate - CASE WHEN @strFeeType = 'Per Unit' THEN @dblFeeRate ELSE 0 END
							SET @TotalMonthsApplicableForStorageCharge = @TotalMonthsApplicableForStorageCharge - 1
							
						    INSERT INTO @StorageCharge([intPeriodKey],[strPeriodType],[dtmEffectiveDate],[dtmEndingDate],[dblStorageRate],[MonthType],[ChargeType],[ChargedNumberOfDays/Months],[dblStorageDuePerUnit],[dblCummulativeStorageDuePerUnit],[RemainingMonths])
							SELECT 
							 @intPeriodKey
							,@strPeriodType
							,@dtmDeliveryDate
							,DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmDeliveryDate) + 1, 0))
							,@dblStorageRate
							,'First Month'
							,'Full Month'
							,1
							,-@dblStorageRate
							,@dblStorageDuePerUnit
							,@TotalMonthsApplicableForStorageCharge
							
							SET @dtmDeliveryDate = DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmDeliveryDate) + 1, 0)) + 1
						END
						ELSE
						BEGIN
							IF @strFirstMonth = 'Full Month' AND @strLastMonth = 'Full Month'
							BEGIN
								SELECT @dblStorageDuePerUnit = ISNULL(@dblStorageDuePerUnit, 0) - @dblStorageRate - CASE WHEN @strFeeType = 'Per Unit' THEN @dblFeeRate ELSE 0 END
								SET @TotalMonthsApplicableForStorageCharge = @TotalMonthsApplicableForStorageCharge - 1
								   
								INSERT INTO @StorageCharge([intPeriodKey],[strPeriodType],[dtmEffectiveDate],[dtmEndingDate],[dblStorageRate],[MonthType],[ChargeType],[ChargedNumberOfDays/Months],[dblStorageDuePerUnit],[dblCummulativeStorageDuePerUnit],[RemainingMonths])
								 SELECT 
								 @intPeriodKey
								,@strPeriodType
								,@dtmDeliveryDate
								,DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmDeliveryDate) + 1, 0))
								,@dblStorageRate
								,'First Month'
								,'Full Month'
								,1
								,-@dblStorageRate
								,@dblStorageDuePerUnit
								,@TotalMonthsApplicableForStorageCharge
													
								SET @dtmDeliveryDate = DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmDeliveryDate) + 1, 0)) + 1
							END
							ELSE
							BEGIN
								SELECT @dblStorageDuePerUnit = ISNULL(@dblStorageDuePerUnit, 0) - (@dblStorageRate/DATEDIFF(dd,@dtmDeliveryDate,DATEADD(m,1,@dtmDeliveryDate))) * (DATEDIFF(DAY, @dtmDeliveryDate, @dtmLastStorageAccrueDate) + 1)
															  - CASE WHEN @strFeeType = 'Per Unit' THEN @dblFeeRate ELSE 0 END
								SET @TotalMonthsApplicableForStorageCharge = @TotalMonthsApplicableForStorageCharge - 1
								
								 INSERT INTO @StorageCharge([intPeriodKey],[strPeriodType],[dtmEffectiveDate],[dtmEndingDate],[dblStorageRate],[MonthType],[ChargeType],[ChargedNumberOfDays/Months],[dblStorageDuePerUnit],[dblCummulativeStorageDuePerUnit],[RemainingMonths])
								 SELECT 
								 @intPeriodKey
								,@strPeriodType
								,@dtmDeliveryDate
								,DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmDeliveryDate) + 1, 0))
								,@dblStorageRate
								,'First Month'
								,'Number of Days'
								,DATEDIFF(DAY, @dtmDeliveryDate, @dtmLastStorageAccrueDate) + 1
								,-(@dblStorageRate/DATEDIFF(dd,@dtmDeliveryDate,DATEADD(m,1,@dtmDeliveryDate))) * (DATEDIFF(DAY, @dtmDeliveryDate, @dtmLastStorageAccrueDate) + 1)
								,@dblStorageDuePerUnit
								,@TotalMonthsApplicableForStorageCharge
												
								SET @dtmDeliveryDate = @dtmLastStorageAccrueDate + 1
							END
						END
					END
					ELSE
					BEGIN
						IF @TotalOriginalMonthsApplicableForStorageCharge = @TotalMonthsApplicableForStorageCharge
						BEGIN
							---First Month Charge
							IF @strFirstMonth = 'Full Month'
							BEGIN
								SELECT @dblStorageDuePerUnit = ISNULL(@dblStorageDuePerUnit, 0) - @dblStorageRate - CASE WHEN @strFeeType = 'Per Unit' THEN @dblFeeRate ELSE 0 END
								SET @TotalMonthsApplicableForStorageCharge = @TotalMonthsApplicableForStorageCharge - 1
								
								INSERT INTO @StorageCharge([intPeriodKey],[strPeriodType],[dtmEffectiveDate],[dtmEndingDate],[dblStorageRate],[MonthType],[ChargeType],[ChargedNumberOfDays/Months],[dblStorageDuePerUnit],[dblCummulativeStorageDuePerUnit],[RemainingMonths])
								SELECT 
								 @intPeriodKey
								,@strPeriodType
								,@dtmDeliveryDate
								,DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmDeliveryDate) + 1, 0))
								,@dblStorageRate
								,'First Month'
								,'Full Month'
								,1
								,-@dblStorageRate
								,@dblStorageDuePerUnit
								,@TotalMonthsApplicableForStorageCharge
													
								SET @dtmDeliveryDate = DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmDeliveryDate) + 1, 0)) + 1
							END
							ELSE
							BEGIN
								SELECT @dblStorageDuePerUnit = ISNULL(@dblStorageDuePerUnit, 0) - (@dblStorageRate/DATEDIFF(dd,@dtmDeliveryDate,DATEADD(m,1,@dtmDeliveryDate))) * (DATEDIFF(DAY, @dtmDeliveryDate, DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmDeliveryDate) + 1, 0))) + 1)
															  - CASE WHEN @strFeeType = 'Per Unit' THEN @dblFeeRate ELSE 0 END
								SET @TotalMonthsApplicableForStorageCharge = @TotalMonthsApplicableForStorageCharge - 1
								
							     INSERT INTO @StorageCharge([intPeriodKey],[strPeriodType],[dtmEffectiveDate],[dtmEndingDate],[dblStorageRate],[MonthType],[ChargeType],[ChargedNumberOfDays/Months],[dblStorageDuePerUnit],[dblCummulativeStorageDuePerUnit],[RemainingMonths])
								 SELECT 
								 @intPeriodKey
								,@strPeriodType
								,@dtmDeliveryDate 
								,DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmDeliveryDate) + 1, 0))
								,@dblStorageRate
								,'First Month'
								,'Number of Days'
								,(DATEDIFF(DAY, @dtmDeliveryDate, DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmDeliveryDate) + 1, 0))) + 1)
								,-(@dblStorageRate/DATEDIFF(dd,@dtmDeliveryDate,DATEADD(m,1,@dtmDeliveryDate))) * (DATEDIFF(DAY, @dtmDeliveryDate, DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmDeliveryDate) + 1, 0))) + 1)
								,@dblStorageDuePerUnit
								,@TotalMonthsApplicableForStorageCharge	s
												
								SET @dtmDeliveryDate = DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmDeliveryDate) + 1, 0)) + 1
							END

							IF (DATEDIFF(DAY, @dtmDeliveryDate, @dtmLastStorageAccrueDate) + 1) > 0 AND @TotalMonthsApplicableForStorageCharge > 0
							BEGIN
								--Intermediate Month charges
								SELECT @dblStorageDuePerUnit = ISNULL(@dblStorageDuePerUnit, 0) - @dblStorageRate * (DATEDIFF(MONTH, @dtmDeliveryDate, DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmLastStorageAccrueDate), 0))) + 1)
															 - CASE WHEN @strFeeType = 'Per Unit' THEN @dblFeeRate ELSE 0 END
								SET @TotalMonthsApplicableForStorageCharge = @TotalMonthsApplicableForStorageCharge - (DATEDIFF(MONTH, @dtmDeliveryDate, DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmLastStorageAccrueDate), 0))) + 1)
								
								 INSERT INTO @StorageCharge([intPeriodKey],[strPeriodType],[dtmEffectiveDate],[dtmEndingDate],[dblStorageRate],[MonthType],[ChargeType],[ChargedNumberOfDays/Months],[dblStorageDuePerUnit],[dblCummulativeStorageDuePerUnit],[RemainingMonths])
								 SELECT 
								 @intPeriodKey
								,@strPeriodType
								,@dtmDeliveryDate
								,DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmLastStorageAccrueDate), 0))--GOPI												
								,@dblStorageRate
								,'Intermediate Month'
								,'Full Month'
								,DATEDIFF(MONTH, @dtmDeliveryDate, DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmLastStorageAccrueDate), 0))) + 1
								,- @dblStorageRate * (DATEDIFF(MONTH, @dtmDeliveryDate, DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmLastStorageAccrueDate), 0))) + 1)
								,@dblStorageDuePerUnit
								,@TotalMonthsApplicableForStorageCharge
												
								SET @dtmDeliveryDate = DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmLastStorageAccrueDate), 0)) + 1

								--Last Month Charge
								IF @strLastMonth = 'Full Month'
								BEGIN
									SELECT @dblStorageDuePerUnit = ISNULL(@dblStorageDuePerUnit, 0) - @dblStorageRate - CASE WHEN @strFeeType = 'Per Unit' THEN @dblFeeRate ELSE 0 END
									SET @TotalMonthsApplicableForStorageCharge = @TotalMonthsApplicableForStorageCharge - 1
									
									INSERT INTO @StorageCharge([intPeriodKey],[strPeriodType],[dtmEffectiveDate],[dtmEndingDate],[dblStorageRate],[MonthType],[ChargeType],[ChargedNumberOfDays/Months],[dblStorageDuePerUnit],[dblCummulativeStorageDuePerUnit],[RemainingMonths])
									 SELECT 
									 @intPeriodKey
									,@strPeriodType
									,@dtmDeliveryDate
									,DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmDeliveryDate) + 1, 0))
									,@dblStorageRate
									,'Last Month'
									,'Full Month'
									,1
									,-@dblStorageRate
									,@dblStorageDuePerUnit
									,@TotalMonthsApplicableForStorageCharge												
												
									SET @dtmDeliveryDate = DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmLastStorageAccrueDate) + 1, 0)) + 1
								END
								ELSE
								BEGIN
									SELECT @dblStorageDuePerUnit = ISNULL(@dblStorageDuePerUnit, 0) - (@dblStorageRate/DATEDIFF(dd,@dtmDeliveryDate,DATEADD(m,1,@dtmDeliveryDate))) * (DATEDIFF(DAY, @dtmDeliveryDate, @dtmLastStorageAccrueDate) + 1)
																 - CASE WHEN @strFeeType = 'Per Unit' THEN @dblFeeRate ELSE 0 END
									SET @TotalMonthsApplicableForStorageCharge = @TotalMonthsApplicableForStorageCharge - 1
									
									INSERT INTO @StorageCharge([intPeriodKey],[strPeriodType],[dtmEffectiveDate],[dtmEndingDate],[dblStorageRate],[MonthType],[ChargeType],[ChargedNumberOfDays/Months],[dblStorageDuePerUnit],[dblCummulativeStorageDuePerUnit],[RemainingMonths])
									SELECT 
									 @intPeriodKey
									,@strPeriodType
									,@dtmDeliveryDate
									,@dtmLastStorageAccrueDate
									,@dblStorageRate
									,'Last Month'
									,'Number of Days'
									,DATEDIFF(DAY, @dtmDeliveryDate, @dtmLastStorageAccrueDate) + 1
									,-(@dblStorageRate/DATEDIFF(dd,@dtmDeliveryDate,DATEADD(m,1,@dtmDeliveryDate))) * (DATEDIFF(DAY, @dtmDeliveryDate, @dtmLastStorageAccrueDate) + 1)
									,@dblStorageDuePerUnit
									,@TotalMonthsApplicableForStorageCharge
									
									SET @dtmDeliveryDate = @dtmLastStorageAccrueDate + 1
								END
							END
						END
						ELSE
						BEGIN
							IF (DATEDIFF(DAY, @dtmDeliveryDate, @dtmLastStorageAccrueDate) + 1) > 0
							BEGIN
								--Intermediate Month charges
								SELECT @dblStorageDuePerUnit = ISNULL(@dblStorageDuePerUnit, 0) - @dblStorageRate * (DATEDIFF(MONTH, @dtmDeliveryDate, DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmLastStorageAccrueDate), 0))) + 1)
															 - CASE WHEN @strFeeType = 'Per Unit' THEN @dblFeeRate ELSE 0 END
								SET @TotalMonthsApplicableForStorageCharge = @TotalMonthsApplicableForStorageCharge - (DATEDIFF(MONTH, @dtmDeliveryDate, DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmLastStorageAccrueDate), 0))) + 1)
								
								INSERT INTO @StorageCharge([intPeriodKey],[strPeriodType],[dtmEffectiveDate],[dtmEndingDate],[dblStorageRate],[MonthType],[ChargeType],[ChargedNumberOfDays/Months],[dblStorageDuePerUnit],[dblCummulativeStorageDuePerUnit],[RemainingMonths])
								SELECT 
								 @intPeriodKey
								,@strPeriodType
								,@dtmDeliveryDate
								,DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmLastStorageAccrueDate), 0))
								,@dblStorageRate
								,'Intermediate Month'
								,'Full Month'
								,DATEDIFF(MONTH, @dtmDeliveryDate, DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmLastStorageAccrueDate), 0))) + 1
								,-@dblStorageRate * (DATEDIFF(MONTH, @dtmDeliveryDate, DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmLastStorageAccrueDate), 0))) + 1)
								,@dblStorageDuePerUnit
								,@TotalMonthsApplicableForStorageCharge												
												
								SET @dtmDeliveryDate = DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmLastStorageAccrueDate), 0)) + 1

								--Last Month Charge									
								IF @strLastMonth = 'Full Month'
								BEGIN
									SELECT @dblStorageDuePerUnit = ISNULL(@dblStorageDuePerUnit, 0) - @dblStorageRate - CASE WHEN @strFeeType = 'Per Unit' THEN @dblFeeRate ELSE 0 END
									SET @TotalMonthsApplicableForStorageCharge = @TotalMonthsApplicableForStorageCharge - 1
										
									 INSERT INTO @StorageCharge([intPeriodKey],[strPeriodType],[dtmEffectiveDate],[dtmEndingDate],[dblStorageRate],[MonthType],[ChargeType],[ChargedNumberOfDays/Months],[dblStorageDuePerUnit],[dblCummulativeStorageDuePerUnit],[RemainingMonths])
									 SELECT 
									 @intPeriodKey
									,@strPeriodType
									,@dtmDeliveryDate
									,DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmLastStorageAccrueDate)+1, 0))
									,@dblStorageRate
									,'Last Month'
									,'Full Month'
									,1
									,-@dblStorageRate
									,@dblStorageDuePerUnit
									,@TotalMonthsApplicableForStorageCharge												
												
									SET @dtmDeliveryDate = DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmLastStorageAccrueDate) + 1, 0)) + 1
								END
								ELSE
								BEGIN
									SELECT @dblStorageDuePerUnit = ISNULL(@dblStorageDuePerUnit, 0) - (@dblStorageRate/DATEDIFF(dd,@dtmDeliveryDate,DATEADD(m,1,@dtmDeliveryDate))) * (DATEDIFF(DAY, @dtmDeliveryDate, @dtmLastStorageAccrueDate) + 1)
																 - CASE WHEN @strFeeType = 'Per Unit' THEN @dblFeeRate ELSE 0 END
									SET @TotalMonthsApplicableForStorageCharge = @TotalMonthsApplicableForStorageCharge - 1
										
									INSERT INTO @StorageCharge([intPeriodKey],[strPeriodType],[dtmEffectiveDate],[dtmEndingDate],[dblStorageRate],[MonthType],[ChargeType],[ChargedNumberOfDays/Months],[dblStorageDuePerUnit],[dblCummulativeStorageDuePerUnit],[RemainingMonths])
									SELECT 
									 @intPeriodKey
								    ,@strPeriodType
									,@dtmDeliveryDate
									,@dtmLastStorageAccrueDate
									,@dblStorageRate
									,'Last Month'
									,'Number of Days'
									,DATEDIFF(DAY, @dtmDeliveryDate, @dtmLastStorageAccrueDate) + 1
									,-(@dblStorageRate/DATEDIFF(dd,@dtmDeliveryDate,DATEADD(m,1,@dtmDeliveryDate))) * (DATEDIFF(DAY, @dtmDeliveryDate, @dtmLastStorageAccrueDate) + 1)
									,@dblStorageDuePerUnit
									,@TotalMonthsApplicableForStorageCharge	
												
									SET @dtmDeliveryDate = @dtmLastStorageAccrueDate + 1
								END
							END
						END
					END
				END
				ELSE
				BEGIN
					
					IF @dtmDeliveryDate > @dtmDEffectiveDate
						SET @dtmDEffectiveDate = @dtmDeliveryDate
					ELSE
					BEGIN
						SET @TotalMonthsApplicableForStorageCharge = CASE 
																		 WHEN (@TotalMonthsApplicableForStorageCharge - DATEDIFF(MONTH, @dtmDeliveryDate, @dtmDEffectiveDate)) < 0 THEN 0
																		 ELSE (@TotalMonthsApplicableForStorageCharge - DATEDIFF(MONTH, @dtmDeliveryDate, @dtmDEffectiveDate))
																	 END
						SET @dtmDeliveryDate = @dtmDEffectiveDate
					END
					
					IF (DATEDIFF(DAY, @dtmDEffectiveDate, @dtmLastStorageAccrueDate) + 1) > 0 AND @TotalMonthsApplicableForStorageCharge > 0
					BEGIN
						--When Storage calculation Date is Same month of Delivery date.
						IF @TotalOriginalMonthsApplicableForStorageCharge = 1
						BEGIN
							--When FirstMonth and Last Month not are Matching then Charge Full month
							IF @strFirstMonth <> @strLastMonth
							BEGIN
								SELECT @dblStorageDuePerUnit = ISNULL(@dblStorageDuePerUnit, 0) - @dblStorageRate - CASE WHEN @strFeeType = 'Per Unit' THEN @dblFeeRate ELSE 0 END
								SET @TotalMonthsApplicableForStorageCharge = @TotalMonthsApplicableForStorageCharge - 1
									
								 INSERT INTO @StorageCharge([intPeriodKey],[strPeriodType],[dtmEffectiveDate],[dtmEndingDate],[dblStorageRate],[MonthType],[ChargeType],[ChargedNumberOfDays/Months],[dblStorageDuePerUnit],[dblCummulativeStorageDuePerUnit],[RemainingMonths])
								 SELECT 
								 @intPeriodKey
								,@strPeriodType
								,@dtmDeliveryDate
								,DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmDeliveryDate) + 1, 0))
								,@dblStorageRate
								,'First Month'
								,'Full Month'
								,1
								,-@dblStorageRate
								,@dblStorageDuePerUnit
								,@TotalMonthsApplicableForStorageCharge
		
								SET @dtmDeliveryDate = DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmDeliveryDate) + 1, 0)) + 1
							END
							ELSE
							BEGIN
								IF @strFirstMonth = 'Full Month' AND @strLastMonth = 'Full Month'
								BEGIN
									SELECT @dblStorageDuePerUnit = ISNULL(@dblStorageDuePerUnit, 0) - @dblStorageRate - CASE WHEN @strFeeType = 'Per Unit' THEN @dblFeeRate ELSE 0 END
									SET @TotalMonthsApplicableForStorageCharge = @TotalMonthsApplicableForStorageCharge - 1
									
									INSERT INTO @StorageCharge([intPeriodKey],[strPeriodType],[dtmEffectiveDate],[dtmEndingDate],[dblStorageRate],[MonthType],[ChargeType],[ChargedNumberOfDays/Months],[dblStorageDuePerUnit],[dblCummulativeStorageDuePerUnit],[RemainingMonths])
									SELECT 
									 @intPeriodKey
									,@strPeriodType
									,@dtmDeliveryDate
									,DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmDeliveryDate) + 1, 0))
									,@dblStorageRate
									,'First Month'
									,'Full Month'
									,1
									,-@dblStorageRate
									,@dblStorageDuePerUnit
									,@TotalMonthsApplicableForStorageCharge
									
									SET @dtmDeliveryDate = DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmDeliveryDate) + 1, 0)) + 1
								END
								ELSE
								BEGIN
									SELECT @dblStorageDuePerUnit = ISNULL(@dblStorageDuePerUnit, 0) - (@dblStorageRate/DATEDIFF(dd,@dtmDeliveryDate,DATEADD(m,1,@dtmDeliveryDate))) * (DATEDIFF(DAY, @dtmDeliveryDate, DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmDeliveryDate) + 1, 0))) + 1)
																 - CASE WHEN @strFeeType = 'Per Unit' THEN @dblFeeRate ELSE 0 END
									SET @TotalMonthsApplicableForStorageCharge = @TotalMonthsApplicableForStorageCharge - 1
										
									INSERT INTO @StorageCharge([intPeriodKey],[strPeriodType],[dtmEffectiveDate],[dtmEndingDate],[dblStorageRate],[MonthType],[ChargeType],[ChargedNumberOfDays/Months],[dblStorageDuePerUnit],[dblCummulativeStorageDuePerUnit],[RemainingMonths])
									SELECT 
									 @intPeriodKey
									,@strPeriodType
									,@dtmDeliveryDate
									,@dtmLastStorageAccrueDate
									,@dblStorageRate
									,'First Month'
									,'Number of Days'
									,DATEDIFF(DAY, @dtmDeliveryDate, DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmDeliveryDate) + 1, 0))) + 1
									,-(@dblStorageRate/DATEDIFF(dd,@dtmDeliveryDate,DATEADD(m,1,@dtmDeliveryDate))) * (DATEDIFF(DAY, @dtmDeliveryDate, DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmDeliveryDate) + 1, 0))) + 1)
									,@dblStorageDuePerUnit
									,@TotalMonthsApplicableForStorageCharge
										
									SET @dtmDeliveryDate = @dtmLastStorageAccrueDate + 1
								END
							END
						END
						ELSE
						BEGIN
							IF @TotalOriginalMonthsApplicableForStorageCharge = @TotalMonthsApplicableForStorageCharge
							BEGIN
								---First Month Charge
								IF @strFirstMonth = 'Full Month'
								BEGIN
									SELECT @dblStorageDuePerUnit = ISNULL(@dblStorageDuePerUnit, 0) - @dblStorageRate - CASE WHEN @strFeeType = 'Per Unit' THEN @dblFeeRate ELSE 0 END
									SET @TotalMonthsApplicableForStorageCharge = @TotalMonthsApplicableForStorageCharge - 1
									
									 INSERT INTO @StorageCharge([intPeriodKey],[strPeriodType],[dtmEffectiveDate],[dtmEndingDate],[dblStorageRate],[MonthType],[ChargeType],[ChargedNumberOfDays/Months],[dblStorageDuePerUnit],[dblCummulativeStorageDuePerUnit],[RemainingMonths])
									 SELECT 
									 @intPeriodKey
									,@strPeriodType
									,@dtmDeliveryDate
									,DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmDeliveryDate) + 1, 0))
									,@dblStorageRate
									,'First Month'
									,'Full Month'
									,1
									,-@dblStorageRate
									,@dblStorageDuePerUnit
									,@TotalMonthsApplicableForStorageCharge
									
									SET @dtmDeliveryDate = DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmDeliveryDate) + 1, 0)) + 1
								END
								ELSE
								BEGIN
									SELECT @dblStorageDuePerUnit = ISNULL(@dblStorageDuePerUnit, 0) -(@dblStorageRate/DATEDIFF(dd,@dtmDeliveryDate,DATEADD(m,1,@dtmDeliveryDate))) * (DATEDIFF(DAY, @dtmDeliveryDate, DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmDeliveryDate) + 1, 0))) + 1)
																	- CASE WHEN @strFeeType = 'Per Unit' THEN @dblFeeRate ELSE 0 END
									SET @TotalMonthsApplicableForStorageCharge = @TotalMonthsApplicableForStorageCharge - 1
									
									INSERT INTO @StorageCharge([intPeriodKey],[strPeriodType],[dtmEffectiveDate],[dtmEndingDate],[dblStorageRate],[MonthType],[ChargeType],[ChargedNumberOfDays/Months],[dblStorageDuePerUnit],[dblCummulativeStorageDuePerUnit],[RemainingMonths])
									SELECT 
									 @intPeriodKey
									,@strPeriodType
									,@dtmDeliveryDate
									,DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmDeliveryDate) + 1, 0))
									,@dblStorageRate
									,'First Month'
									,'Number of Days'
									,DATEDIFF(DAY, @dtmDeliveryDate, DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmDeliveryDate) + 1, 0))) + 1
									,-(@dblStorageRate/DATEDIFF(dd,@dtmDeliveryDate,DATEADD(m,1,@dtmDeliveryDate))) * (DATEDIFF(DAY, @dtmDeliveryDate, DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmDeliveryDate) + 1, 0))) + 1)
									,@dblStorageDuePerUnit
									,@TotalMonthsApplicableForStorageCharge
									
									SET @dtmDeliveryDate = DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmDeliveryDate) + 1, 0)) + 1
								END
								
								---Intermediate and Last Month Charges
								IF (DATEDIFF(DAY, @dtmDeliveryDate, @dtmLastStorageAccrueDate) + 1) > 0
								BEGIN
								
									IF @TotalMonthsApplicableForStorageCharge > 1
									BEGIN
									
										--Intermediate Month charges
										SELECT @dblStorageDuePerUnit = ISNULL(@dblStorageDuePerUnit, 0) - @dblStorageRate * (DATEDIFF(MONTH, @dtmDeliveryDate, DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmLastStorageAccrueDate), 0))) + 1)
																	  - CASE WHEN @strFeeType = 'Per Unit' THEN @dblFeeRate ELSE 0 END
										SET @TotalMonthsApplicableForStorageCharge = @TotalMonthsApplicableForStorageCharge - (DATEDIFF(MONTH, @dtmDeliveryDate, DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmLastStorageAccrueDate), 0))) + 1)
										
										INSERT INTO @StorageCharge([intPeriodKey],[strPeriodType],[dtmEffectiveDate],[dtmEndingDate],[dblStorageRate],[MonthType],[ChargeType],[ChargedNumberOfDays/Months],[dblStorageDuePerUnit],[dblCummulativeStorageDuePerUnit],[RemainingMonths])
										SELECT 
										 @intPeriodKey
										,@strPeriodType
										,@dtmDeliveryDate
										,DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmLastStorageAccrueDate), 0))
										,@dblStorageRate
										,'Intermediate Month'
										,'Full Month'
										,DATEDIFF(MONTH, @dtmDeliveryDate, DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmLastStorageAccrueDate), 0))) + 1
										,-@dblStorageRate * (DATEDIFF(MONTH, @dtmDeliveryDate, DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmLastStorageAccrueDate), 0))) + 1)
										,@dblStorageDuePerUnit
										,@TotalMonthsApplicableForStorageCharge
											
										SET @dtmDeliveryDate = DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmLastStorageAccrueDate), 0)) + 1

										--Last Month Charge
										IF @strLastMonth = 'Full Month'
										BEGIN
											SELECT @dblStorageDuePerUnit = ISNULL(@dblStorageDuePerUnit, 0) - @dblStorageRate - CASE WHEN @strFeeType = 'Per Unit' THEN @dblFeeRate ELSE 0 END
											SET @TotalMonthsApplicableForStorageCharge = @TotalMonthsApplicableForStorageCharge - 1
											
											 INSERT INTO @StorageCharge([intPeriodKey],[strPeriodType],[dtmEffectiveDate],[dtmEndingDate],[dblStorageRate],[MonthType],[ChargeType],[ChargedNumberOfDays/Months],[dblStorageDuePerUnit],[dblCummulativeStorageDuePerUnit],[RemainingMonths])
											 SELECT 
											 @intPeriodKey
											,@strPeriodType
											,@dtmDeliveryDate
											,DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmLastStorageAccrueDate)+1, 0))
											,@dblStorageRate
											,'Last Month'
											,'Full Month'
											,1
											,-@dblStorageRate
											,@dblStorageDuePerUnit
											,@TotalMonthsApplicableForStorageCharge
											
											SET @dtmDeliveryDate = DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmLastStorageAccrueDate) + 1, 0)) + 1
										END
										ELSE
										BEGIN
											SELECT @dblStorageDuePerUnit = ISNULL(@dblStorageDuePerUnit, 0) -(@dblStorageRate/DATEDIFF(dd,@dtmDeliveryDate,DATEADD(m,1,@dtmDeliveryDate))) * (DATEDIFF(DAY, @dtmDeliveryDate, @dtmLastStorageAccrueDate) + 1)
																		  - CASE WHEN @strFeeType = 'Per Unit' THEN @dblFeeRate ELSE 0 END
											SET @TotalMonthsApplicableForStorageCharge = @TotalMonthsApplicableForStorageCharge - 1
											
											INSERT INTO @StorageCharge([intPeriodKey],[strPeriodType],[dtmEffectiveDate],[dtmEndingDate],[dblStorageRate],[MonthType],[ChargeType],[ChargedNumberOfDays/Months],[dblStorageDuePerUnit],[dblCummulativeStorageDuePerUnit],[RemainingMonths])
											 SELECT 
											 @intPeriodKey
											,@strPeriodType
											,@dtmDeliveryDate
											,@dtmLastStorageAccrueDate
											,@dblStorageRate
											,'Last Month'
											,'Number of Days'
											,DATEDIFF(DAY, @dtmDeliveryDate, @dtmLastStorageAccrueDate) + 1
											,-(@dblStorageRate/DATEDIFF(dd,@dtmDeliveryDate,DATEADD(m,1,@dtmDeliveryDate))) * (DATEDIFF(DAY, @dtmDeliveryDate, @dtmLastStorageAccrueDate) + 1)
											,@dblStorageDuePerUnit
											,@TotalMonthsApplicableForStorageCharge
											
											SET @dtmDeliveryDate = @dtmLastStorageAccrueDate + 1
										END
									END
									ELSE
									BEGIN
										--Last Month Charge
										IF @strLastMonth = 'Full Month'
										BEGIN
											SELECT @dblStorageDuePerUnit = ISNULL(@dblStorageDuePerUnit, 0) - @dblStorageRate - CASE WHEN @strFeeType = 'Per Unit' THEN @dblFeeRate ELSE 0 END
											SET @TotalMonthsApplicableForStorageCharge = @TotalMonthsApplicableForStorageCharge - 1
											
											INSERT INTO @StorageCharge([intPeriodKey],[strPeriodType],[dtmEffectiveDate],[dtmEndingDate],[dblStorageRate],[MonthType],[ChargeType],[ChargedNumberOfDays/Months],[dblStorageDuePerUnit],[dblCummulativeStorageDuePerUnit],[RemainingMonths])
											 SELECT 
											 @intPeriodKey
											,@strPeriodType
											,@dtmDeliveryDate
											,DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmLastStorageAccrueDate)+1, 0))
											,@dblStorageRate
											,'Last Month'
											,'Full Month'
											,1
											,-@dblStorageRate
											,@dblStorageDuePerUnit
											,@TotalMonthsApplicableForStorageCharge
											
											SET @dtmDeliveryDate = DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmLastStorageAccrueDate) + 1, 0)) + 1
										END
										ELSE
										BEGIN
											SELECT @dblStorageDuePerUnit = ISNULL(@dblStorageDuePerUnit, 0)-(@dblStorageRate/DATEDIFF(dd,@dtmDeliveryDate,DATEADD(m,1,@dtmDeliveryDate))) * (DATEDIFF(DAY, @dtmDeliveryDate, @dtmLastStorageAccrueDate) + 1)
																		   - CASE WHEN @strFeeType = 'Per Unit' THEN @dblFeeRate ELSE 0 END	
											SET @TotalMonthsApplicableForStorageCharge = @TotalMonthsApplicableForStorageCharge - 1
											
											INSERT INTO @StorageCharge([intPeriodKey],[strPeriodType],[dtmEffectiveDate],[dtmEndingDate],[dblStorageRate],[MonthType],[ChargeType],[ChargedNumberOfDays/Months],[dblStorageDuePerUnit],[dblCummulativeStorageDuePerUnit],[RemainingMonths])
											 SELECT 
											 @intPeriodKey
											,@strPeriodType
											,@dtmDeliveryDate
											,@dtmLastStorageAccrueDate
											,@dblStorageRate
											,'Last Month'
											,'Number of Days'
											,DATEDIFF(DAY, @dtmDeliveryDate, @dtmLastStorageAccrueDate) + 1
											,-(@dblStorageRate/DATEDIFF(dd,@dtmDeliveryDate,DATEADD(m,1,@dtmDeliveryDate))) * (DATEDIFF(DAY, @dtmDeliveryDate, @dtmLastStorageAccrueDate) + 1)
											,@dblStorageDuePerUnit
											,@TotalMonthsApplicableForStorageCharge
											
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
								
									IF @TotalMonthsApplicableForStorageCharge > 1
									BEGIN
									
										--Intermediate Month charges
										SELECT @dblStorageDuePerUnit = ISNULL(@dblStorageDuePerUnit, 0) - @dblStorageRate * (DATEDIFF(MONTH, @dtmDeliveryDate, DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmLastStorageAccrueDate), 0))) + 1)
																	  - CASE WHEN @strFeeType = 'Per Unit' THEN @dblFeeRate ELSE 0 END
										SET @TotalMonthsApplicableForStorageCharge = @TotalMonthsApplicableForStorageCharge - (DATEDIFF(MONTH, @dtmDeliveryDate, DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmLastStorageAccrueDate), 0))) + 1)
										
										 INSERT INTO @StorageCharge([intPeriodKey],[strPeriodType],[dtmEffectiveDate],[dtmEndingDate],[dblStorageRate],[MonthType],[ChargeType],[ChargedNumberOfDays/Months],[dblStorageDuePerUnit],[dblCummulativeStorageDuePerUnit],[RemainingMonths])
										 SELECT 
										 @intPeriodKey
										,@strPeriodType
										,@dtmDeliveryDate
										,DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmLastStorageAccrueDate), 0))
										,@dblStorageRate
										,'Intermediate Month'
										,'Full Month'
										,DATEDIFF(MONTH, @dtmDeliveryDate, DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmLastStorageAccrueDate), 0))) + 1
										,-@dblStorageRate * (DATEDIFF(MONTH, @dtmDeliveryDate, DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmLastStorageAccrueDate), 0))) + 1)
										,@dblStorageDuePerUnit
										,@TotalMonthsApplicableForStorageCharge
											
										SET @dtmDeliveryDate = DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmLastStorageAccrueDate), 0)) + 1

										--Last Month Charge
										IF @strLastMonth = 'Full Month'
										BEGIN
											SELECT @dblStorageDuePerUnit = ISNULL(@dblStorageDuePerUnit, 0) - @dblStorageRate - CASE WHEN @strFeeType = 'Per Unit' THEN @dblFeeRate ELSE 0 END
											SET @TotalMonthsApplicableForStorageCharge = @TotalMonthsApplicableForStorageCharge - 1
											
											INSERT INTO @StorageCharge([intPeriodKey],[strPeriodType],[dtmEffectiveDate],[dtmEndingDate],[dblStorageRate],[MonthType],[ChargeType],[ChargedNumberOfDays/Months],[dblStorageDuePerUnit],[dblCummulativeStorageDuePerUnit],[RemainingMonths])
											SELECT 
											 @intPeriodKey
											,@strPeriodType
											,@dtmDeliveryDate
											,DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmLastStorageAccrueDate)+1, 0))
											,@dblStorageRate
											,'Last Month'
											,'Full Month'
											,1
											,- @dblStorageRate
											,@dblStorageDuePerUnit
											,@TotalMonthsApplicableForStorageCharge
											
											SET @dtmDeliveryDate = DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmLastStorageAccrueDate) + 1, 0)) + 1
										END
										ELSE
										BEGIN
											SELECT @dblStorageDuePerUnit = ISNULL(@dblStorageDuePerUnit, 0) - (@dblStorageRate/DATEDIFF(dd,@dtmDeliveryDate,DATEADD(m,1,@dtmDeliveryDate))) * (DATEDIFF(DAY, @dtmDeliveryDate, @dtmLastStorageAccrueDate) + 1)
																		   - CASE WHEN @strFeeType = 'Per Unit' THEN @dblFeeRate ELSE 0 END
											SET @TotalMonthsApplicableForStorageCharge = @TotalMonthsApplicableForStorageCharge - 1
											
											INSERT INTO @StorageCharge([intPeriodKey],[strPeriodType],[dtmEffectiveDate],[dtmEndingDate],[dblStorageRate],[MonthType],[ChargeType],[ChargedNumberOfDays/Months],[dblStorageDuePerUnit],[dblCummulativeStorageDuePerUnit],[RemainingMonths])
											 SELECT 
											 @intPeriodKey
											,@strPeriodType
											,@dtmDeliveryDate
											,@dtmLastStorageAccrueDate
											,@dblStorageRate
											,'Last Month'
											,'Number of Days'
											,DATEDIFF(DAY, @dtmDeliveryDate, @dtmLastStorageAccrueDate) + 1
											,-(@dblStorageRate/DATEDIFF(dd,@dtmDeliveryDate,DATEADD(m,1,@dtmDeliveryDate))) * (DATEDIFF(DAY, @dtmDeliveryDate, @dtmLastStorageAccrueDate) + 1)
											,@dblStorageDuePerUnit
											,@TotalMonthsApplicableForStorageCharge
											
											SET @dtmDeliveryDate = @dtmLastStorageAccrueDate + 1
										END
									END
									ELSE
									BEGIN
										--Last Month Charge
										IF @strLastMonth = 'Full Month'
										BEGIN
											SELECT @dblStorageDuePerUnit = ISNULL(@dblStorageDuePerUnit, 0) - @dblStorageRate - CASE WHEN @strFeeType = 'Per Unit' THEN @dblFeeRate ELSE 0 END
											SET @TotalMonthsApplicableForStorageCharge = @TotalMonthsApplicableForStorageCharge - 1
											
											INSERT INTO @StorageCharge([intPeriodKey],[strPeriodType],[dtmEffectiveDate],[dtmEndingDate],[dblStorageRate],[MonthType],[ChargeType],[ChargedNumberOfDays/Months],[dblStorageDuePerUnit],[dblCummulativeStorageDuePerUnit],[RemainingMonths])
											 SELECT 
											 @intPeriodKey
											,@strPeriodType
											,@dtmDeliveryDate
											,DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmLastStorageAccrueDate)+1, 0))
											,@dblStorageRate
											,'Last Month'
											,'Full Month'
											,1
											,-@dblStorageRate
											,@dblStorageDuePerUnit
											,@TotalMonthsApplicableForStorageCharge
											
											SET @dtmDeliveryDate = DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, @dtmLastStorageAccrueDate) + 1, 0)) + 1
										END
										ELSE
										BEGIN
											SELECT @dblStorageDuePerUnit = ISNULL(@dblStorageDuePerUnit, 0) -(@dblStorageRate/DATEDIFF(dd,@dtmDeliveryDate,DATEADD(m,1,@dtmDeliveryDate))) * (DATEDIFF(DAY, @dtmDeliveryDate, @dtmLastStorageAccrueDate) + 1)
																			- CASE WHEN @strFeeType = 'Per Unit' THEN @dblFeeRate ELSE 0 END
											SET @TotalMonthsApplicableForStorageCharge = @TotalMonthsApplicableForStorageCharge - 1
											
											INSERT INTO @StorageCharge([intPeriodKey],[strPeriodType],[dtmEffectiveDate],[dtmEndingDate],[dblStorageRate],[MonthType],[ChargeType],[ChargedNumberOfDays/Months],[dblStorageDuePerUnit],[dblCummulativeStorageDuePerUnit],[RemainingMonths])
											 SELECT 
											 @intPeriodKey
											,@strPeriodType
											,@dtmDeliveryDate
											,@dtmLastStorageAccrueDate
											,@dblStorageRate
											,'Last Month'
											,'Number of Days'
											,DATEDIFF(DAY, @dtmDeliveryDate, @dtmLastStorageAccrueDate) + 1
											,-(@dblStorageRate/DATEDIFF(dd,@dtmDeliveryDate,DATEADD(m,1,@dtmDeliveryDate))) * (DATEDIFF(DAY, @dtmDeliveryDate, @dtmLastStorageAccrueDate) + 1)
											,@dblStorageDuePerUnit
											,@TotalMonthsApplicableForStorageCharge
											
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
			FROM @tblGRStorageSchedulePeriod
			WHERE intSchedulePeriodId > @intSchedulePeriodId
		END
		
	END
	---------End Of Monthly----------------------------

	---Updating Last Storage AccrueDate, Storage Due Field and Creating History.
	IF @StorageChargeCalculationRequired = 1
	BEGIN
		IF @strUpdateType = 'accrue' OR @strUpdateType = 'Bill'
		BEGIN
			UPDATE tblGRCustomerStorage
			SET dtmLastStorageAccrueDate = @ActualStorageChargeDate
			WHERE intCustomerStorageId   = @intCustomerStorageId

			UPDATE tblGRCustomerStorage
			SET dblStorageDue = CASE 
									 WHEN @strProcessType < > 'recalculate' THEN dblStorageDue + @dblStorageDuePerUnit + @dblFlatFeeTotal
									 ELSE @dblStorageDuePerUnit + @dblFlatFeeTotal
								END
										 
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
			SELECT
				 [intConcurrencyId]		 = 1
				,[intCustomerStorageId]	 = @intCustomerStorageId
				,[intTicketId]			 = NULL
				,[intInventoryReceiptId] = NULL
				,[intInvoiceId]			 = NULL
				,[intContractHeaderId]	 = NULL
				,[dblUnits]				 = @dblOpenBalance
				,[dtmHistoryDate]		 = @ActualStorageChargeDate
				,[dblPaidAmount]		 = @dblStorageDuePerUnit + @dblFlatFeeTotal
				,[strPaidDescription]	 = NULL
				,[dblCurrencyRate]		 = NULL
				,[strType]				 = 'Accrued Storage Due'
				,[strUserName]			 = @UserName
				,[intTransactionTypeId]	 = NULL
				,[intEntityId]			 = NULL
				,[intCompanyLocationId]	 = NULL
			
		END
	END

	IF @strUpdateType = 'Bill'
	BEGIN
		UPDATE tblGRCustomerStorage
		SET    dblStoragePaid	   = dblStorageDue
		WHERE intCustomerStorageId = @intCustomerStorageId

		SELECT @dblNewStoragePaid  = dblStoragePaid
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
		SELECT 
			 [intConcurrencyId]		 = 1
			,[intCustomerStorageId]	 = @intCustomerStorageId
			,[intTicketId]			 = NULL
			,[intInventoryReceiptId] = NULL
			,[intInvoiceId]			 = NULL
			,[intContractHeaderId]	 = NULL
			,[dblUnits]				 = @dblOpenBalance
			,[dtmHistoryDate]		 = @ActualStorageChargeDate
			,[dblPaidAmount]		 = (@dblNewStoragePaid - @dblOldStoragePaid)
			,[strPaidDescription]	 = NULL
			,[dblCurrencyRate]		 = NULL
			,[strType]				 = 'Storage Paid'
			,[strUserName]			 = @UserName
			,[intTransactionTypeId]	 = NULL
			,[intEntityId]			 = NULL
			,[intCompanyLocationId]	 = NULL
			
	END
	
	SET @dblStorageDuePerUnit=ISNULL(@dblStorageDuePerUnit,0)

	SELECT @dblStorageDueTotalPerUnit = dblStorageDue  - dblStoragePaid
		  ,@dblStorageBilledPerUnit   = dblStoragePaid - @dblOldStoragePaid
	FROM tblGRCustomerStorage
	WHERE intCustomerStorageId = @intCustomerStorageId
	
	SET @dblStorageDueTotalPerUnit = ISNULL(@dblStorageDueTotalPerUnit,0)
	SET @dblStorageBilledPerUnit   = ISNULL(@dblStorageBilledPerUnit,0)

	IF @strProcessType = 'Unpaid'
	BEGIN
		SET @dblStorageDuePerUnit = @dblStorageDueTotalPerUnit
	END

	SET @dblStorageDueAmount = @dblStorageDuePerUnit * @dblOpenBalance

	SELECT @dblStorageDueTotalAmount = @dblStorageDueTotalPerUnit * @dblOpenBalance

	SELECT @dblStorageBilledAmount = @dblStorageBilledPerUnit * @dblOpenBalance
	
	IF @returnChargeByPeriodWise = 1
	BEGIN

		IF @strStorageRate = 'Monthly'
		SELECT
			 [intStorageChargeKey]
			,[intPeriodKey]
			,[strPeriodType]
			,[dtmEffectiveDate]
			,[dtmEndingDate]
			,[dblStorageRate]
			,[MonthType]
			,[ChargeType]
			,[ChargedNumberOfDays/Months] AS CalculatedNumberOfDays
			,[dblStorageDuePerUnit]
			,[dblCummulativeStorageDuePerUnit]
			,[RemainingMonths]				
		FROM @StorageCharge Where [ChargedNumberOfDays/Months]>0
		
		ELSE
			
		SELECT 
		 [intStorageChargeKey]
		,[intPeriodKey]
		,[strPeriodType]
		,[dtmEffectiveDate]
		,[dtmEndingDate]
		,[intNumberOfDays]
		,[CalculatedNumberOfDays]
		,[dblStorageRate]
		,[dblStorageDuePerUnit]
		,[dblCummulativeStorageDuePerUnit] FROM @DailyStorageCharge

	END
	EXEC sp_xml_removedocument @idoc
END TRY

BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()
	SET @ErrMsg = 'uspGRCalculateStorageCharge: ' + @ErrMsg
	IF @idoc <> 0 EXEC sp_xml_removedocument @idoc
	RAISERROR (@ErrMsg,16,1,'WITH NOWAIT')
END CATCH