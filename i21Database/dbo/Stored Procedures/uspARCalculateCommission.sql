CREATE PROCEDURE [dbo].[uspARCalculateCommission]
	@intCommissionPlanId	INT,
	@intEntityId			INT,
	@intCommissionRecapId	INT,
	@dtmCalcStartDate		DATETIME		= NULL,
	@dtmCalcEndDate			DATETIME		= NULL,
	@dblLineTotal			NUMERIC(18,6)	= 0 OUTPUT
AS

IF ISNULL(@intCommissionPlanId, 0) = 0
	BEGIN
		RAISERROR('Commission Plan is required!', 16, 1);
		RETURN 0;
	END

IF ISNULL(@intCommissionRecapId, 0) = 0
	BEGIN
		RAISERROR('Commission Recap ID is required!', 16, 1);
		RETURN 0;
	END

DECLARE  @intCommissionAccountId	INT
	   , @strBasis					NVARCHAR(50)
	   , @strCalculationType		NVARCHAR(50)
	   , @strHurdleFrequency		NVARCHAR(25)
	   , @strHurdleType				NVARCHAR(25)
	   , @dblHurdle					NUMERIC(18,6)
	   , @dblCalculationAmount		NUMERIC(18,6)
	   , @strHourType				NVARCHAR(25)
	   , @strUnitType				NVARCHAR(25)
	   , @intApprovalListId			NVARCHAR(MAX)
	   , @ysnMarginalSales			BIT
	   , @ysnPaymentRequired		BIT
	   , @dtmStartDate				DATETIME
	   , @dtmEndDate				DATETIME
	   , @ysnDeductFreightSurcharge	BIT
	   , @ysnDeductTax				BIT

DECLARE @HURDLETYPE_DRAW			NVARCHAR(20) = 'Draw'
      , @HURDLETYPE_FIXED			NVARCHAR(20) = 'Fixed'	  
	  , @BASIS_HOURS				NVARCHAR(20) = 'Hours'
	  , @BASIS_UNITS				NVARCHAR(20) = 'Units'
	  , @BASIS_REVENUE				NVARCHAR(20) = 'Revenue'
	  , @BASIS_CONDITIONAL			NVARCHAR(20) = 'Conditional'
	  , @HOURTYPE_BILLABLE			NVARCHAR(20) = 'Billable Hours'
	  , @HOURTYPE_TOTAL				NVARCHAR(20) = 'Total Hours'
	  , @CALCTYPE_PERUNIT			NVARCHAR(20) = 'Amount Per Unit'
	  , @CALCTYPE_FLAT				NVARCHAR(20) = 'Flat Amount'
	  , @CALCTYPE_PERCENT			NVARCHAR(20) = 'Percentage'
	  , @HURDLEFREQUENCY_MONTHLY	NVARCHAR(20) = 'Monthly'
	  , @HURDLEFREQUENCY_ANNUAL		NVARCHAR(20) = 'Annual'

SELECT TOP 1 
	@intCommissionAccountId		= intCommissionAccountId
  , @strBasis					= strBasis
  , @strCalculationType			= strCalculationType
  , @strHurdleFrequency			= strHurdleFrequency
  , @strHurdleType				= strHurdleType
  , @strHourType				= CASE WHEN strBasis = @BASIS_HOURS THEN strHourType ELSE NULL END
  , @strUnitType				= CASE WHEN strBasis = @BASIS_UNITS THEN strUnitType ELSE NULL END
  , @intApprovalListId			= CASE WHEN strBasis = @BASIS_CONDITIONAL THEN intApprovalListId ELSE NULL END
  , @ysnMarginalSales			= CASE WHEN strBasis = @BASIS_REVENUE THEN ysnMarginalSales ELSE 0 END
  , @dblHurdle					= ISNULL(dblHurdle, 0.000000)
  , @dblCalculationAmount		= ISNULL(dblCalculationAmount, 0.000000)
  , @ysnPaymentRequired			= ysnPaymentRequired  
  , @dtmStartDate				= dtmStartDate
  , @dtmEndDate					= dtmEndDate
  , @ysnDeductFreightSurcharge	= CASE WHEN strBasis = @BASIS_REVENUE THEN ysnDeductFreightSurcharge ELSE 0 END
  , @ysnDeductTax				= CASE WHEN strBasis = @BASIS_REVENUE THEN ysnDeductTax ELSE 0 END
FROM tblARCommissionPlan 
WHERE intCommissionPlanId = @intCommissionPlanId

SET @dtmCalcStartDate = CASE WHEN @dtmCalcStartDate < @dtmStartDate THEN @dtmStartDate ELSE @dtmCalcStartDate END
SET @dtmCalcEndDate = CASE WHEN @dtmCalcEndDate > @dtmEndDate THEN @dtmEndDate ELSE @dtmCalcEndDate END

IF @strHurdleType = @HURDLETYPE_DRAW
	BEGIN
		IF @strHurdleFrequency = @HURDLEFREQUENCY_ANNUAL AND @dblHurdle > 0
			BEGIN
				SET @dblHurdle = @dblHurdle / 12 
			END
	END

IF @strBasis = @BASIS_HOURS
	BEGIN
		DECLARE @dblTotalHrs		NUMERIC(18,6) = 0
		DECLARE @tmpHDTicketHoursWorkedTable TABLE (
			  intTicketHoursWorkedId INT
			, dtmDate DATETIME
			, intHours NUMERIC(18,6)
			, ysnBillable BIT
		)

		INSERT INTO @tmpHDTicketHoursWorkedTable
		SELECT intTicketHoursWorkedId	= intTicketHoursWorkedId
		     , dtmDate					= dtmDate
			 , intHours					= intHours			 
			 , ysnBillable				= ysnBillable
		FROM tblHDTicketHoursWorked 
		WHERE intAgentEntityId = @intEntityId
			AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), dtmDate))) BETWEEN @dtmCalcStartDate AND @dtmCalcEndDate

		IF @strHourType = @HOURTYPE_BILLABLE
			DELETE FROM @tmpHDTicketHoursWorkedTable WHERE ysnBillable = 0
		ELSE IF (@strHourType = @HOURTYPE_TOTAL)
			DELETE FROM @tmpHDTicketHoursWorkedTable WHERE ysnBillable = 1
		
		SELECT @dblTotalHrs = ISNULL(SUM(intHours), 0) FROM @tmpHDTicketHoursWorkedTable

		--insert into recap
		INSERT INTO tblARCommissionRecapDetail
		SELECT intCommissionRecapId		= @intCommissionRecapId
			 , intEntityId				= @intEntityId
			 , intSourceId				= intTicketHoursWorkedId
			 , strSourceType			= 'tblHDTicketHoursWorked'
			 , dtmSourceDate			= dtmDate
			 , dblAmount				= (intHours - (@dblHurdle * (intHours/@dblTotalHrs))) * @dblCalculationAmount
			 , intConcurrencyId			= 1
		FROM @tmpHDTicketHoursWorkedTable
			where @dblTotalHrs > @dblHurdle
			
		IF @strCalculationType = @CALCTYPE_PERUNIT
			SET @dblLineTotal = CASE WHEN  @dblTotalHrs > @dblHurdle THEN (@dblTotalHrs - @dblHurdle) * @dblCalculationAmount ELSE 0 END
		ELSE IF @strCalculationType = @CALCTYPE_FLAT
			SET @dblLineTotal = @dblCalculationAmount

	END
ELSE IF @strBasis = @BASIS_REVENUE
	BEGIN
		DECLARE @tmpTransactionTable TABLE (
			 intSourceId	INT
			,dblAmount	NUMERIC(18,6)
			,dtmSourceDate	DATETIME
		)

		--GET REVENUE BY GL ACCOUNTS
		INSERT INTO @tmpTransactionTable
		SELECT 
			 intSourceId	= intGLDetailId
			,dblAmount		= ISNULL(GL.dblDebit, 0) - ISNULL(GL.dblCredit, 0)
			,dtmSourceDate	= GL.dtmDate
		FROM tblGLDetail GL
		INNER JOIN tblARCommissionPlanAccount CPA ON GL.intAccountId = CPA.intAccountId
		WHERE GL.ysnIsUnposted = 0 
		  AND GL.intAccountId IS NOT NULL
		  AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), GL.dtmDate))) BETWEEN @dtmCalcStartDate AND @dtmCalcEndDate
		  AND CPA.intCommissionPlanId = @intCommissionPlanId

		INSERT INTO tblARCommissionRecapDetail
		SELECT 
			 intCommissionRecapId	= @intCommissionRecapId
			,intEntityId			= @intEntityId
			,intSourceId			=  intSourceId
			,strSourceType			= 'tblGLDetail'
			,dtmSourceDate			= dtmSourceDate
			,dblAmount				= dblAmount
			,intConcurrencyId		= 1
		FROM @tmpTransactionTable

		--GET INVOICE TOTAL BY SALESPERSON
		IF(NOT EXISTS(SELECT TOP 1 NULL FROM @tmpTransactionTable WHERE dblAmount > 0))
		BEGIN
			INSERT INTO @tmpTransactionTable
			SELECT 
				 intSourceId	= I.intInvoiceId
				,dblAmount		= ISNULL(I.dblInvoiceTotal, 0)
				,dtmSourceDate	= I.dtmPostDate
			FROM tblARInvoice I
			INNER JOIN tblARCommissionPlanSalesperson SP ON I.intEntitySalespersonId = SP.intEntitySalespersonId
			LEFT JOIN tblARCommissionDetail CD on I.intInvoiceId = CD.intSourceId
			LEFT JOIN tblARCommission C on CD.intCommissionId = C.intCommissionId
			WHERE I.ysnPosted = 1
			  AND I.intEntitySalespersonId IS NOT NULL
			  AND ISNULL(C.ysnPaid, 0) = 0
			  AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), I.dtmPostDate))) BETWEEN @dtmCalcStartDate AND @dtmCalcEndDate
			  AND SP.intCommissionPlanId = @intCommissionPlanId

			--INSERT INTO tblARCommissionRecapDetail
			--SELECT 
			--	 intCommissionRecapId	= @intCommissionRecapId
			--	,intEntityId			= @intEntityId
			--	,intSourceId			= intSourceId
			--	,strSourceType			= 'tblARInvoice'
			--	,dtmSourceDate			= dtmSourceDate
			--	,dblAmount				= dblAmount
			--	,intConcurrencyId		= 1
			--FROM @tmpTransactionTable
			select * from @tmpTransactionTable
		END

		--GET BILLABLE RATES BY AGENT
		IF(NOT EXISTS(SELECT TOP 1 NULL FROM @tmpTransactionTable WHERE dblAmount > 0))
		BEGIN
			INSERT INTO @tmpTransactionTable
			SELECT 
				 intSourceId	= HD.intTicketHoursWorkedId
				,dblAmount		= ISNULL(HD.intHours, 0) * ISNULL(HD.dblRate, 0)
				,dtmSourceDate	= HD.dtmDate
			FROM tblHDTicketHoursWorked HD
			INNER JOIN tblARCommissionPlanAgent A ON HD.intAgentEntityId = A.intEntityAgentId
			WHERE HD.intAgentEntityId IS NOT NULL
			  AND HD.ysnBillable = 1
			  AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), HD.dtmDate))) BETWEEN @dtmCalcStartDate AND @dtmCalcEndDate
			  AND A.intCommissionPlanId = @intCommissionPlanId
		
			INSERT INTO tblARCommissionRecapDetail
			SELECT 
				 intCommissionRecapId	= @intCommissionRecapId
				,intEntityId			= @intEntityId
				,intSourceId			= intSourceId
				,strSourceType			= 'tblHDTicketHoursWorked'
				,dtmSourceDate			= dtmSourceDate
				,dblAmount				= dblAmount
				,intConcurrencyId		= 1
			FROM @tmpTransactionTable
		END

		--GET INVOICE LINETOTAL BY ITEM CATEGORY
		--IF(NOT EXISTS(SELECT TOP 1 NULL FROM @tmpTransactionTable WHERE dblAmount > 0))
		--BEGIN
			INSERT INTO @tmpTransactionTable
			SELECT 
				 intSourceId	= I.intInvoiceId
				,dblAmount		= SUM(ID.dblTotal + ID.dblTotalTax)
				,dtmSourceDate	= I.dtmPostDate
			FROM tblARInvoice I
			INNER JOIN tblARInvoiceDetail ID ON I.intInvoiceId = ID.intInvoiceId
			INNER JOIN tblICItem ICI ON ID.intItemId = ICI.intItemId
			INNER JOIN tblICCategory IC ON ICI.intCategoryId = IC.intCategoryId
			INNER JOIN tblARCommissionPlanItemCategory CPIC ON IC.intCategoryId = CPIC.intItemCategoryId
			LEFT JOIN tblARCommissionDetail CD on I.intInvoiceId = CD.intSourceId
			LEFT JOIN tblARCommission C on CD.intCommissionId = C.intCommissionId
			WHERE I.ysnPosted = 1
				AND IC.intCategoryId IS NOT NULL
				AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), I.dtmPostDate))) BETWEEN @dtmCalcStartDate AND @dtmCalcEndDate
				AND ISNULL(C.ysnPaid, 0) = 0
				AND I.intEntitySalespersonId IS NULL
				AND CPIC.intCommissionPlanId = @intCommissionPlanId
			GROUP BY I.intInvoiceId, I.dtmPostDate

			--INSERT INTO tblARCommissionRecapDetail
			--SELECT 
			--	 intCommissionRecapId	= @intCommissionRecapId
			--	,intEntityId			= @intEntityId
			--	,intSourceId			= intSourceId
			--	,strSourceType			= 'tblARInvoice'
			--	,dtmSourceDate			= dtmSourceDate
			--	,dblAmount				= dblAmount
			--	,intConcurrencyId		= 1
			--FROM @tmpTransactionTable
		--END
		
		--GET INVOICE LINETOTAL BY ITEM
		--IF(NOT EXISTS(SELECT TOP 1 NULL FROM @tmpTransactionTable WHERE dblAmount > 0))
		--BEGIN
			INSERT INTO @tmpTransactionTable
			SELECT 
				 intSourceId	= I.intInvoiceId
				,dblTotalAmount	= SUM(ID.dblTotal + ID.dblTotalTax)
				,dtmSourceDate	= I.dtmPostDate
			FROM tblARInvoice I
			INNER JOIN tblARInvoiceDetail ID ON I.intInvoiceId = ID.intInvoiceId
			INNER JOIN tblARCommissionPlanItem CPI ON ID.intItemId = CPI.intItemId
			LEFT JOIN tblARCommissionDetail CD on I.intInvoiceId = CD.intSourceId
			LEFT JOIN tblARCommission C on CD.intCommissionId = C.intCommissionId
			WHERE I.ysnPosted = 1
			  AND ID.intItemId IS NOT NULL
			  AND ISNULL(C.ysnPaid, 0) = 0
			  AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), dtmPostDate))) BETWEEN @dtmCalcStartDate AND @dtmCalcEndDate
			  AND CPI.intCommissionPlanId = @intCommissionPlanId
			GROUP BY I.intInvoiceId, I.dtmPostDate
		
			INSERT INTO tblARCommissionRecapDetail
			SELECT 
				 intCommissionRecapId	= @intCommissionRecapId
				,intEntityId			= @intEntityId
				,intSourceId			= intSourceId
				,strSourceType			= 'tblARInvoice'
				,dtmSourceDate			= dtmSourceDate
				,dblAmount				= dblAmount
				,intConcurrencyId		= 1
			FROM @tmpTransactionTable
		--END
		
		IF @ysnMarginalSales = 1
		BEGIN
			UPDATE ARCRD
			SET dblAmount = dblAmount - dblTotalCOGSAmount
			FROM tblARCommissionRecapDetail ARCRD
			INNER JOIN (
				SELECT 
					 intCommissionRecapDetailId
					,dblTotalCOGSAmount			= SUM(ABS(ISNULL(ICIT.dblQty, 0)) * ISNULL(ICIT.dblCost, 0))
				FROM tblARCommissionRecapDetail ARCRD
				INNER JOIN tblARInvoiceDetail ARID 
				ON ARCRD.intCommissionRecapId = @intCommissionRecapId AND ARCRD.intSourceId = ARID.intInvoiceId AND ARCRD.strSourceType = 'tblARInvoice'
				INNER JOIN tblICInventoryTransaction ICIT 
				ON ARID.intInvoiceDetailId = ICIT.intTransactionDetailId AND ICIT.strTransactionForm = 'Invoice' AND ICIT.ysnIsUnposted = 0
				GROUP BY intCommissionRecapDetailId
			) COGS ON ARCRD.intCommissionRecapDetailId = COGS.intCommissionRecapDetailId

			IF @ysnDeductFreightSurcharge = 1
			BEGIN
				UPDATE ARCRD
				SET dblAmount = dblAmount - dblTotalFreightSurcharge
				FROM tblARCommissionRecapDetail ARCRD
				INNER JOIN (
					SELECT
						 intCommissionRecapDetailId
						,dblTotalFreightSurcharge	= SUM(ISNULL(ARID.dblTotal, 0))
					FROM tblARCommissionRecapDetail ARCRD
					INNER JOIN tblARInvoiceDetail ARID 
					ON intCommissionRecapId = @intCommissionRecapId AND ARCRD.intSourceId = ARID.intInvoiceId AND ARCRD.strSourceType = 'tblARInvoice'
					INNER JOIN vyuICGetOtherCharges ICGOC ON ARID.intItemId = ICGOC.intItemId
					GROUP BY intCommissionRecapDetailId
				) FREIGHTSURCHARGE ON ARCRD.intCommissionRecapDetailId = FREIGHTSURCHARGE.intCommissionRecapDetailId
			END

			IF @ysnDeductTax = 1
			BEGIN
				UPDATE ARCRD
				SET dblAmount = dblAmount - dblTotalTax
				FROM tblARCommissionRecapDetail ARCRD
				INNER JOIN (
					SELECT 
						 intCommissionRecapDetailId
						,dblTotalTax				= SUM(ISNULL(ARID.dblTotalTax, 0))
					FROM tblARCommissionRecapDetail ARCRD
					INNER JOIN tblARInvoiceDetail ARID 
					ON intCommissionRecapId = @intCommissionRecapId AND ARCRD.intSourceId = ARID.intInvoiceId AND ARCRD.strSourceType = 'tblARInvoice'
					GROUP BY intCommissionRecapDetailId
				) TAX ON ARCRD.intCommissionRecapDetailId = TAX.intCommissionRecapDetailId
			END
		END

		UPDATE tblARCommissionRecapDetail
		SET dblAmount = CASE 
							WHEN @strCalculationType = @CALCTYPE_PERCENT AND ISNULL(@dblCalculationAmount, 0) > 0.00 THEN ((@dblCalculationAmount/100.00) * ISNULL((dblAmount), 0)) - ISNULL(@dblHurdle, 0) 
							WHEN @strCalculationType = @CALCTYPE_FLAT THEN @dblCalculationAmount
						END
		WHERE intCommissionRecapId = @intCommissionRecapId

		DELETE FROM tblARCommissionRecapDetail WHERE dblAmount <= 0.000000

		SELECT @dblLineTotal = SUM(dblAmount)
		FROM tblARCommissionRecapDetail
		WHERE intCommissionRecapId = @intCommissionRecapId
	END
ELSE IF @strBasis = @BASIS_UNITS
	BEGIN
		--TODO
		SET @dblLineTotal = 0
	END
ELSE IF @strBasis = @BASIS_CONDITIONAL
	BEGIN
		IF @strCalculationType = @CALCTYPE_FLAT
			SET @dblLineTotal = @dblCalculationAmount

		INSERT INTO tblARCommissionRecapDetail
		SELECT intCommissionRecapId		= @intCommissionRecapId
			 , intEntityId				= @intEntityId
			 , intSourceId				= NULL
			 , strSourceType			= 'Flat Amount'
			 , dtmSourceDate			= GETDATE()
			 , dblAmount				= @dblLineTotal
			 , intConcurrencyId			= 1
	END
GO