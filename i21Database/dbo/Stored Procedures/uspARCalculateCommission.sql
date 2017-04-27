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
	   , @strAccounts				NVARCHAR(MAX)
	   , @strSalespersons			NVARCHAR(MAX)
	   , @strAgents					NVARCHAR(MAX)
	   , @strDrivers				NVARCHAR(MAX)
	   , @strItemCategories			NVARCHAR(MAX)
	   , @strItems					NVARCHAR(MAX)
	   , @intApprovalListId			NVARCHAR(MAX)
	   , @ysnMarginalSales			BIT
	   , @ysnPaymentRequired		BIT
	   , @dtmStartDate				DATETIME
	   , @dtmEndDate				DATETIME

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
	@intCommissionAccountId	= intCommissionAccountId
  , @strBasis				= strBasis
  , @strCalculationType		= strCalculationType
  , @strHurdleFrequency		= strHurdleFrequency
  , @strHurdleType			= strHurdleType
  , @strHourType			= CASE WHEN strBasis = @BASIS_HOURS THEN strHourType ELSE NULL END
  , @strUnitType			= CASE WHEN strBasis = @BASIS_UNITS THEN strUnitType ELSE NULL END
  , @strAccounts			= CASE WHEN strBasis = @BASIS_REVENUE THEN strAccounts ELSE NULL END
  , @strSalespersons		= CASE WHEN strBasis = @BASIS_REVENUE THEN strSalespersons ELSE NULL END
  , @strAgents				= CASE WHEN strBasis = @BASIS_REVENUE THEN strAgents ELSE NULL END
  , @strDrivers				= CASE WHEN strBasis = @BASIS_REVENUE THEN strDrivers ELSE NULL END
  , @strItemCategories		= CASE WHEN strBasis = @BASIS_REVENUE THEN strItemCategories ELSE NULL END
  , @strItems				= CASE WHEN strBasis = @BASIS_REVENUE THEN strItems ELSE NULL END
  , @intApprovalListId		= CASE WHEN strBasis = @BASIS_CONDITIONAL THEN intApprovalListId ELSE NULL END
  , @ysnMarginalSales		= CASE WHEN strBasis = @BASIS_REVENUE THEN ysnMarginalSales ELSE 0 END
  , @dblHurdle				= ISNULL(dblHurdle, 0.000000)
  , @dblCalculationAmount	= ISNULL(dblCalculationAmount, 0.000000)
  , @ysnPaymentRequired		= ysnPaymentRequired  
  , @dtmStartDate			= dtmStartDate
  , @dtmEndDate				= dtmEndDate
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
		SELECT intTicketHoursWorkedId
		     , dtmDate
			 , intHours			 
			 , ysnBillable
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
		SELECT @intCommissionRecapId
			 , @intEntityId
			 , intTicketHoursWorkedId
			 , 'tblHDTicketHoursWorked'
			 , dtmDate
			 , (intHours - (@dblHurdle * (intHours/@dblTotalHrs))) * @dblCalculationAmount
			 , 1
		FROM @tmpHDTicketHoursWorkedTable
		
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

		DECLARE @dblTotalRevenue		NUMERIC(18,6) = 0
		      , @dblTotalCOGSAmount		NUMERIC(18,6) = 0
	
		--GET REVENUE BY GL ACCOUNTS
		INSERT INTO @tmpAccountsTable
		SELECT intAccountId
			 , intGLDetailId
			 , dblDebit
			 , dblCredit
			 , dtmDate
		FROM tblGLDetail 
		WHERE ysnIsUnposted = 0 
			AND intAccountId IS NOT NULL
			AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), dtmDate))) BETWEEN @dtmCalcStartDate AND @dtmCalcEndDate
					
		IF ISNULL(@strAccounts, '') <> ''
			BEGIN
				DELETE FROM @tmpAccountsTable
				WHERE intAccountId NOT IN (SELECT intID FROM dbo.fnGetRowsFromDelimitedValues(@strAccounts))
			END
		
		SELECT @dblTotalRevenue = ISNULL(SUM(dblDebit - dblCredit), 0) FROM @tmpAccountsTable 

		INSERT INTO tblARCommissionRecapDetail
		SELECT @intCommissionRecapId
			 , @intEntityId
			 , intGLDetailId
			 , 'tblGLDetail'
			 , dtmDate
			 , dblDebit - dblCredit
			 , 1
		FROM @tmpAccountsTable

		IF @ysnMarginalSales = 1
			BEGIN
				SET @dblTotalRevenue = @dblTotalRevenue - @dblTotalCOGSAmount
			END

		--GET INVOICE TOTAL BY SALESPERSON
		INSERT INTO @tmpSalespersonsTable
		SELECT intEntitySalespersonId
			 , intInvoiceId
			 , dblInvoiceTotal
			 , dtmPostDate
		FROM tblARInvoice
		WHERE ysnPosted = 1
			AND intEntitySalespersonId IS NOT NULL
			AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), dtmPostDate))) BETWEEN @dtmCalcStartDate AND @dtmCalcEndDate

		IF ISNULL(@strSalespersons, '') <> ''
			BEGIN
				DELETE FROM @tmpSalespersonsTable				
				WHERE intSalespersonId NOT IN (SELECT intID FROM dbo.fnGetRowsFromDelimitedValues(@strSalespersons))
			END
		
		SELECT @dblTotalRevenue = @dblTotalRevenue + ISNULL(SUM(dblInvoiceTotal), 0) FROM @tmpSalespersonsTable

		INSERT INTO tblARCommissionRecapDetail
		SELECT @intCommissionRecapId
			 , @intEntityId
			 , intInvoiceId
			 , 'tblARInvoice'
			 , dtmPostDate
			 , dblInvoiceTotal
			 , 1
		FROM @tmpSalespersonsTable

		--GET BILLABLE RATES BY AGENT
		INSERT INTO @tmpAgentsTable
		SELECT intAgentEntityId
			 , intTicketHoursWorkedId
			 , dtmDate
			 , ISNULL(intHours, 0) * ISNULL(dblRate, 0)
		FROM tblHDTicketHoursWorked
		WHERE intAgentEntityId IS NOT NULL
			AND ysnBillable = 1
			AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), dtmDate))) BETWEEN @dtmCalcStartDate AND @dtmCalcEndDate
		
		IF ISNULL(@strAgents, '') <> ''
			BEGIN
				DELETE FROM @tmpAgentsTable
				WHERE intAgentId NOT IN (SELECT intID FROM dbo.fnGetRowsFromDelimitedValues(@strAgents))
			END

		SELECT @dblTotalRevenue = @dblTotalRevenue + SUM(dblAmount) FROM @tmpAgentsTable

		INSERT INTO tblARCommissionRecapDetail
		SELECT @intCommissionRecapId
			 , @intEntityId
			 , intTicketHoursWorkedId
			 , 'tblHDTicketHoursWorked'
			 , dtmDate
			 , dblAmount
			 , 1
		FROM @tmpAgentsTable

		IF ISNULL(@strDrivers, '') <> ''
			BEGIN
				INSERT INTO @tmpDriversTable
				SELECT intID FROM dbo.fnGetRowsFromDelimitedValues(@strDrivers)
			END

		--GET INVOICE LINETOTAL BY ITEM CATEGORY
		INSERT INTO @tmpItemCategoriesTable
		SELECT IC.intCategoryId
			 , ID.intInvoiceDetailId
			 , I.intInvoiceId
			 , ID.dblTotal
			 , I.dtmPostDate
		FROM tblARInvoice I
			INNER JOIN tblARInvoiceDetail ID ON I.intInvoiceId = ID.intInvoiceId
			INNER JOIN tblICItem ICI ON ID.intItemId = ICI.intItemId
			INNER JOIN tblICCategory IC ON ICI.intCategoryId = IC.intCategoryId
		WHERE I.ysnPosted = 1
			AND IC.intCategoryId IS NOT NULL
			AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), dtmPostDate))) BETWEEN @dtmCalcStartDate AND @dtmCalcEndDate

		IF ISNULL(@strItemCategories, '') <> ''
			BEGIN
				DELETE FROM @tmpItemCategoriesTable
				WHERE intItemCategoryId NOT IN (SELECT intID FROM dbo.fnGetRowsFromDelimitedValues(@strItemCategories))
			END
		
		SELECT @dblTotalRevenue = @dblTotalRevenue + ISNULL(SUM(dblTotalAmount), 0) FROM @tmpItemCategoriesTable

		INSERT INTO tblARCommissionRecapDetail
		SELECT @intCommissionRecapId
			 , @intEntityId
			 , intInvoiceDetailId
			 , 'tblARInvoiceDetail'
			 , dtmPostDate
			 , dblTotalAmount
			 , 1
		FROM @tmpItemCategoriesTable ICT
		
		--GET INVOICE LINETOTAL BY ITEM
		INSERT INTO @tmpItemsTable
		SELECT ID.intItemId
			 , ID.intInvoiceDetailId
			 , I.intInvoiceId
			 , ID.dblTotal
			 , I.dtmPostDate
		FROM tblARInvoice I
			INNER JOIN tblARInvoiceDetail ID ON I.intInvoiceId = ID.intInvoiceId
		WHERE I.ysnPosted = 1
			AND ID.intItemId IS NOT NULL
			AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), dtmPostDate))) BETWEEN @dtmCalcStartDate AND @dtmCalcEndDate

		IF ISNULL(@strItems, '') <> ''
			BEGIN
				DELETE FROM @tmpItemsTable
				WHERE intItemId NOT IN (SELECT intID FROM dbo.fnGetRowsFromDelimitedValues(@strItems))
			END
		
		SELECT @dblTotalRevenue = @dblTotalRevenue + ISNULL(SUM(dblTotalAmount), 0) FROM @tmpItemsTable

		INSERT INTO tblARCommissionRecapDetail
		SELECT @intCommissionRecapId
			 , @intEntityId
			 , intInvoiceDetailId
			 , 'tblARInvoiceDetail'
			 , dtmPostDate
			 , dblTotalAmount
			 , 1
		FROM @tmpItemsTable
		
		IF @strCalculationType = @CALCTYPE_PERCENT
			SET @dblLineTotal = (@dblCalculationAmount * @dblTotalRevenue) - @dblHurdle
		ELSE IF @strCalculationType = @CALCTYPE_FLAT
			SET @dblLineTotal = @dblCalculationAmount

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
		SELECT @intCommissionRecapId
			 , @intEntityId
			 , NULL
			 , 'Flat Amount'
			 , GETDATE()
			 , @dblLineTotal
			 , 1
	END