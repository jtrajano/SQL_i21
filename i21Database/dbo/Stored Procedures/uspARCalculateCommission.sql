CREATE PROCEDURE [dbo].[uspARCalculateCommission]
	@intCommissionPlanId	INT,
	@intEntityId			INT,
	@dtmCalcStartDate		DATETIME		= NULL,
	@dtmCalcEndDate			DATETIME		= NULL,
	@dblLineTotal			NUMERIC(18,6)	= NULL OUTPUT
AS
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
		DECLARE @dblTotalHrs NUMERIC(18,6) = 0
		DECLARE @tmpHDTicketHoursWorkedTable TABLE (intHours NUMERIC(18,6), ysnBillable BIT)

		INSERT INTO @tmpHDTicketHoursWorkedTable
		SELECT intHours
			 , ysnBillable
		FROM tblHDTicketHoursWorked 
		WHERE intAgentEntityId = @intEntityId
			AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), dtmDate))) BETWEEN @dtmCalcStartDate AND @dtmCalcEndDate

		IF @strHourType = @HOURTYPE_BILLABLE
			DELETE FROM @tmpHDTicketHoursWorkedTable WHERE ysnBillable = 0
		ELSE IF (@strHourType = @HOURTYPE_TOTAL)
			DELETE FROM @tmpHDTicketHoursWorkedTable WHERE ysnBillable = 1

		SELECT @dblTotalHrs = SUM(intHours) FROM @tmpHDTicketHoursWorkedTable

		IF @strCalculationType = @CALCTYPE_PERUNIT
			SET @dblLineTotal = (@dblTotalHrs - @dblHurdle) * @dblCalculationAmount
		ELSE IF @strCalculationType = @CALCTYPE_FLAT
			SET @dblLineTotal = @dblCalculationAmount

	END
ELSE IF @strBasis = @BASIS_REVENUE
	BEGIN
		DECLARE @tmpAccountsTable		TABLE (intAccountId INT)
		DECLARE @tmpSalespersonsTable	TABLE (intSalespersonId INT)
		DECLARE @tmpAgentsTable			TABLE (intAgentId INT)
		DECLARE @tmpDriversTable		TABLE (intDriversId INT)
		DECLARE @tmpItemCategoriesTable TABLE (intItemCategoryId INT)
		DECLARE @tmpItemsTable			TABLE (intItemId INT)
		DECLARE @dblTotalRevenue		NUMERIC(18,6) = 0
		      , @dblTotalCOGSAmount		NUMERIC(18,6) = 0
	
		IF ISNULL(@strAccounts, '') <> ''
			BEGIN
				INSERT INTO @tmpAccountsTable
				SELECT intID FROM dbo.fnGetRowsFromDelimitedValues(@strAccounts)

				SELECT @dblTotalRevenue = SUM(dblDebit - dblCredit)
				FROM tblGLDetail 
				WHERE ysnIsUnposted = 0 
					AND intAccountId IN (SELECT intAccountId FROM @tmpAccountsTable)
					AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), dtmDate))) BETWEEN @dtmCalcStartDate AND @dtmCalcEndDate

				IF @ysnMarginalSales = 1
					BEGIN
						SET @dblTotalRevenue = @dblTotalRevenue - @dblTotalCOGSAmount
					END
			END

		IF ISNULL(@strSalespersons, '') <> ''
			BEGIN
				INSERT INTO @tmpSalespersonsTable
				SELECT intID FROM dbo.fnGetRowsFromDelimitedValues(@strSalespersons)
			END

		IF ISNULL(@strAgents, '') <> ''
			BEGIN
				INSERT INTO @tmpAgentsTable
				SELECT intID FROM dbo.fnGetRowsFromDelimitedValues(@strAgents)
			END

		IF ISNULL(@strDrivers, '') <> ''
			BEGIN
				INSERT INTO @tmpDriversTable
				SELECT intID FROM dbo.fnGetRowsFromDelimitedValues(@strDrivers)
			END

		IF ISNULL(@strItemCategories, '') <> ''
			BEGIN
				INSERT INTO @tmpItemCategoriesTable
				SELECT intID FROM dbo.fnGetRowsFromDelimitedValues(@strItemCategories)
			END
		
		IF ISNULL(@strItems, '') <> ''
			BEGIN
				INSERT INTO @tmpItemsTable
				SELECT intID FROM dbo.fnGetRowsFromDelimitedValues(@strItems)
			END
		
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
	END