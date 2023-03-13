﻿CREATE PROCEDURE [dbo].[uspARCalculateCommission]
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
		DECLARE @tmpAccountsTable TABLE (
			  intAccountId	INT
			, intGLDetailId	INT
			, dblDebit		NUMERIC(18,6)
			, dblCredit		NUMERIC(18,6)
			, dtmDate		DATETIME
		)
		DECLARE @tmpSalespersonsTable TABLE (
			  intSalespersonId	INT
			, intInvoiceId		INT
			, dblInvoiceTotal	NUMERIC(18,6)
			, dtmPostDate		DATETIME
		)
		DECLARE @tmpAgentsTable	TABLE (
			  intAgentId				INT
			, intTicketHoursWorkedId	INT
			, dtmDate					DATETIME
			, dblAmount					NUMERIC(18,6)	  
		)
		DECLARE @tmpDriversTable TABLE (intDriversId INT)
		DECLARE @tmpItemCategoriesTable TABLE (
			  intItemCategoryId		INT
			, intInvoiceDetailId	INT
			, intInvoiceId			INT
			, dblTotalAmount		NUMERIC(18,6)
			, dtmPostDate			DATETIME
		)
		DECLARE @tmpItemsTable TABLE (
			  intItemId				INT
			, intInvoiceDetailId	INT
			, intInvoiceId			INT
			, dblTotalAmount		NUMERIC(18,6)
			, dtmPostDate			DATETIME
		)

		DECLARE @dblTotalRevenue			NUMERIC(18,6) = 0
		      , @dblTotalCOGSAmount			NUMERIC(18,6) = 0
			  , @dblTotalFreightSurcharge	NUMERIC(18,6) = 0
			  , @dblTotalTax				NUMERIC(18,6) = 0
	
		--GET REVENUE BY GL ACCOUNTS
		INSERT INTO @tmpAccountsTable
		SELECT intAccountId		= GL.intAccountId
			 , intGLDetailId	= GL.intGLDetailId
			 , dblDebit			= ISNULL(GL.dblDebit, 0)
			 , dblCredit		= ISNULL(GL.dblCredit, 0)
			 , dtmDate			= GL.dtmDate
		FROM tblGLDetail GL
		INNER JOIN tblARCommissionPlanAccount CPA ON GL.intAccountId = CPA.intAccountId
		WHERE GL.ysnIsUnposted = 0 
		  AND GL.intAccountId IS NOT NULL
		  AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), GL.dtmDate))) BETWEEN @dtmCalcStartDate AND @dtmCalcEndDate
		  AND CPA.intCommissionPlanId = @intCommissionPlanId
		
		SELECT @dblTotalRevenue = ISNULL(SUM(dblDebit - dblCredit), 0) FROM @tmpAccountsTable 

		INSERT INTO tblARCommissionRecapDetail
		SELECT intCommissionRecapId		= @intCommissionRecapId
			 , intEntityId				= @intEntityId
			 , intSourceId				=  intGLDetailId
			 , strSourceType			= 'tblGLDetail'
			 , dtmSourceDate			= dtmDate
			 , dblAmount				= (CASE 
											WHEN @strCalculationType = @CALCTYPE_PERCENT AND ISNULL(@dblCalculationAmount, 0) > 0.00 THEN ((@dblCalculationAmount/100.00) * ISNULL((dblDebit - dblCredit), 0)) - ISNULL(@dblHurdle, 0) 
											WHEN @strCalculationType = @CALCTYPE_FLAT THEN @dblCalculationAmount
										  END)
			 , intConcurrencyId			= 1
		FROM @tmpAccountsTable

		--GET INVOICE TOTAL BY SALESPERSON
		IF(@dblTotalRevenue = 0)
		BEGIN
			INSERT INTO @tmpSalespersonsTable
			SELECT intSalespersonId		= I.intEntitySalespersonId
				 , intInvoiceId			= I.intInvoiceId
				 , dblInvoiceTotal		= ISNULL(I.dblInvoiceTotal, 0)
				 , dtmPostDate			= I.dtmPostDate
			FROM tblARInvoice I
			INNER JOIN tblARCommissionPlanSalesperson SP ON I.intEntitySalespersonId = SP.intEntitySalespersonId
			WHERE I.ysnPosted = 1
			 AND I.intEntitySalespersonId IS NOT NULL
			 AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), I.dtmPostDate))) BETWEEN @dtmCalcStartDate AND @dtmCalcEndDate
			 AND SP.intCommissionPlanId = @intCommissionPlanId

			SELECT @dblTotalRevenue = ISNULL(@dblTotalRevenue, 0) + ISNULL(SUM(dblInvoiceTotal), 0) FROM @tmpSalespersonsTable

			INSERT INTO tblARCommissionRecapDetail
			SELECT intCommissionRecapId		= @intCommissionRecapId
				 , intEntityId				= @intEntityId
				 , intSourceId				= intInvoiceId
				 , strSourceType			= 'tblARInvoice'
				 , dtmSourceDate			= dtmPostDate
				 , dblAmount				= (CASE 
												WHEN @strCalculationType = @CALCTYPE_PERCENT AND ISNULL(@dblCalculationAmount, 0) > 0.00 THEN ((@dblCalculationAmount/100.00) * ISNULL((dblInvoiceTotal), 0)) - ISNULL(@dblHurdle, 0) 
												WHEN @strCalculationType = @CALCTYPE_FLAT THEN @dblCalculationAmount
											  END)
				 , intConcurrencyId			= 1
			FROM @tmpSalespersonsTable
		END

		--GET BILLABLE RATES BY AGENT
		IF(@dblTotalRevenue = 0)
		BEGIN
			INSERT INTO @tmpAgentsTable
			SELECT intAgentId				= HD.intAgentEntityId
				 , intTicketHoursWorkedId	= HD.intTicketHoursWorkedId
				 , dtmDate					= HD.dtmDate
				 , dblAmount				= ISNULL(HD.intHours, 0) * ISNULL(HD.dblRate, 0)
			FROM tblHDTicketHoursWorked HD
			INNER JOIN tblARCommissionPlanAgent A ON HD.intAgentEntityId = A.intEntityAgentId
			WHERE HD.intAgentEntityId IS NOT NULL
			  AND HD.ysnBillable = 1
			  AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), HD.dtmDate))) BETWEEN @dtmCalcStartDate AND @dtmCalcEndDate
			  AND A.intCommissionPlanId = @intCommissionPlanId
		
			SELECT @dblTotalRevenue = ISNULL(@dblTotalRevenue, 0) + ISNULL(SUM(dblAmount), 0) FROM @tmpAgentsTable

			INSERT INTO tblARCommissionRecapDetail
			SELECT intCommissionRecapId		= @intCommissionRecapId
				 , intEntityId				= @intEntityId
				 , intSourceId				= intTicketHoursWorkedId
				 , strSourceType			= 'tblHDTicketHoursWorked'
				 , dtmSourceDate			= dtmDate
				 , dblAmount				= (CASE 
												WHEN @strCalculationType = @CALCTYPE_PERCENT AND ISNULL(@dblCalculationAmount, 0) > 0.00 THEN ((@dblCalculationAmount/100.00) * ISNULL((dblAmount), 0)) - ISNULL(@dblHurdle, 0) 
												WHEN @strCalculationType = @CALCTYPE_FLAT THEN @dblCalculationAmount
											  END)
				 , intConcurrencyId			= 1
			FROM @tmpAgentsTable
		END

		--GET INVOICE LINETOTAL BY ITEM CATEGORY
		IF(@dblTotalRevenue = 0)
		BEGIN
			INSERT INTO @tmpItemCategoriesTable
			SELECT intItemCategoryId	= IC.intCategoryId
				 , intInvoiceDetailId	= ID.intInvoiceDetailId
				 , intInvoiceId			= I.intInvoiceId
				 , dblTotalAmount		= ID.dblTotal
				 , dtmPostDate			= I.dtmPostDate
			FROM tblARInvoice I
			INNER JOIN tblARInvoiceDetail ID ON I.intInvoiceId = ID.intInvoiceId
			INNER JOIN tblICItem ICI ON ID.intItemId = ICI.intItemId
			INNER JOIN tblICCategory IC ON ICI.intCategoryId = IC.intCategoryId
			INNER JOIN tblARCommissionPlanItemCategory CPIC ON IC.intCategoryId = CPIC.intItemCategoryId
			WHERE I.ysnPosted = 1
				AND IC.intCategoryId IS NOT NULL
				AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), dtmPostDate))) BETWEEN @dtmCalcStartDate AND @dtmCalcEndDate
				AND CPIC.intCommissionPlanId = @intCommissionPlanId
		
			SELECT @dblTotalRevenue = ISNULL(@dblTotalRevenue, 0) + ISNULL(SUM(dblTotalAmount), 0) FROM @tmpItemCategoriesTable

			INSERT INTO tblARCommissionRecapDetail
			SELECT intCommissionRecapId		= @intCommissionRecapId
				 , intEntityId				= @intEntityId
				 , intSourceId				= intInvoiceId
				 , strSourceType			= 'tblARInvoice'
				 , dtmSourceDate			= dtmPostDate
				 , dblAmount				= (CASE 
												WHEN @strCalculationType = @CALCTYPE_PERCENT AND ISNULL(@dblCalculationAmount, 0) > 0.00 THEN ((@dblCalculationAmount/100.00) * ISNULL((dblTotalAmount), 0)) - ISNULL(@dblHurdle, 0) 
												WHEN @strCalculationType = @CALCTYPE_FLAT THEN @dblCalculationAmount
											  END)
				 , intConcurrencyId			= 1
			FROM @tmpItemCategoriesTable ICT
		END
		
		--GET INVOICE LINETOTAL BY ITEM
		IF(@dblTotalRevenue = 0)
		BEGIN
			INSERT INTO @tmpItemsTable
			SELECT intItemId			= ID.intItemId
				 , intInvoiceDetailId	= ID.intInvoiceDetailId
				 , intInvoiceId			= I.intInvoiceId
				 , dblTotalAmount		= ID.dblTotal
				 , dtmPostDate			= I.dtmPostDate
			FROM tblARInvoice I
			INNER JOIN tblARInvoiceDetail ID ON I.intInvoiceId = ID.intInvoiceId
			INNER JOIN tblARCommissionPlanItem CPI ON ID.intItemId = CPI.intItemId
			WHERE I.ysnPosted = 1
			  AND ID.intItemId IS NOT NULL
			  AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), dtmPostDate))) BETWEEN @dtmCalcStartDate AND @dtmCalcEndDate
			  AND CPI.intCommissionPlanId = @intCommissionPlanId
		
			SELECT @dblTotalRevenue = ISNULL(@dblTotalRevenue, 0) + ISNULL(SUM(dblTotalAmount), 0) FROM @tmpItemsTable

			INSERT INTO tblARCommissionRecapDetail
			SELECT intCommissionRecapId		= @intCommissionRecapId
				 , intEntityId				= @intEntityId
				 , intSourceId				= intInvoiceId
				 , strSourceType			= 'tblARInvoice'
				 , dtmSourceDate			= dtmPostDate
				 , dblAmount				= (CASE 
												WHEN @strCalculationType = @CALCTYPE_PERCENT AND ISNULL(@dblCalculationAmount, 0) > 0.00 THEN ((@dblCalculationAmount/100.00) * ISNULL((dblTotalAmount), 0)) - ISNULL(@dblHurdle, 0) 
												WHEN @strCalculationType = @CALCTYPE_FLAT THEN @dblCalculationAmount
											  END)
				 , intConcurrencyId			= 1
			FROM @tmpItemsTable
		END
		
		IF @ysnMarginalSales = 1
		BEGIN
			SELECT @dblTotalCOGSAmount = SUM(ABS(ISNULL(ICIT.dblQty, 0)) * ISNULL(ICIT.dblCost, 0))
			FROM tblARCommissionRecapDetail ARCRD
			INNER JOIN tblARInvoiceDetail ARID 
			ON intCommissionRecapId = @intCommissionRecapId AND ARCRD.intSourceId = ARID.intInvoiceId
			INNER JOIN tblICInventoryTransaction ICIT 
			ON ARID.intInvoiceDetailId = ICIT.intTransactionDetailId AND ICIT.strTransactionForm = 'Invoice' AND ICIT.ysnIsUnposted = 0

			SET @dblTotalRevenue = @dblTotalRevenue - @dblTotalCOGSAmount

			IF @ysnDeductFreightSurcharge = 1
			BEGIN
				SELECT @dblTotalFreightSurcharge = SUM(ISNULL(ARID.dblTotal, 0))
				FROM tblARCommissionRecapDetail ARCRD
				INNER JOIN tblARInvoiceDetail ARID 
				ON intCommissionRecapId = @intCommissionRecapId AND ARCRD.intSourceId = ARID.intInvoiceId
				INNER JOIN vyuICGetOtherCharges ICGOC ON ARID.intItemId = ICGOC.intItemId

				SET @dblTotalRevenue = @dblTotalRevenue - @dblTotalFreightSurcharge
			END

			IF @ysnDeductTax = 1
			BEGIN
				SELECT @dblTotalTax = SUM(ISNULL(ARID.dblTotalTax, 0))
				FROM tblARCommissionRecapDetail ARCRD
				INNER JOIN tblARInvoiceDetail ARID 
				ON intCommissionRecapId = @intCommissionRecapId AND ARCRD.intSourceId = ARID.intInvoiceId

				SET @dblTotalRevenue = @dblTotalRevenue - @dblTotalTax
			END
		END

		IF @strCalculationType = @CALCTYPE_PERCENT AND ISNULL(@dblCalculationAmount, 0) > 0.00
			SET @dblLineTotal = ((@dblCalculationAmount / 100.00) * ISNULL(@dblTotalRevenue, 0)) - ISNULL(@dblHurdle, 0)
		ELSE IF @strCalculationType = @CALCTYPE_FLAT
			SET @dblLineTotal = @dblCalculationAmount

		UPDATE tblARCommissionRecapDetail
		SET dblAmount = @dblLineTotal
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