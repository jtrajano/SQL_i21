CREATE PROCEDURE [dbo].[uspARCalculateCommission]
	@intCommissionPlanId	INT,
	@intEntityId			INT,
	@ysnEmployee			BIT = 0,
	@ysnAutoCreatePayables	BIT = 0,
	@ysnAutoCreatePayroll	BIT = 0
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
	   , @strCondition				NVARCHAR(MAX)
	   , @ysnMarginalSales			BIT
	   , @ysnPaymentRequired		BIT

SELECT TOP 1 
	@intCommissionAccountId	= intCommissionAccountId
  , @strBasis				= strBasis
  , @strCalculationType		= strCalculationType
  , @strHurdleFrequency		= strHurdleFrequency
  , @strHurdleType			= strHurdleType
  , @strHourType			= CASE WHEN strBasis = 'Hours' THEN strHourType ELSE NULL END
  , @strUnitType			= CASE WHEN strBasis = 'Units' THEN strUnitType ELSE NULL END
  , @strAccounts			= CASE WHEN strBasis = 'Revenue' THEN strAccounts ELSE NULL END
  , @strSalespersons		= CASE WHEN strBasis = 'Revenue' THEN strSalespersons ELSE NULL END
  , @strAgents				= CASE WHEN strBasis = 'Revenue' THEN strAgents ELSE NULL END
  , @strDrivers				= CASE WHEN strBasis = 'Revenue' THEN strDrivers ELSE NULL END
  , @strItemCategories		= CASE WHEN strBasis = 'Revenue' THEN strItemCategories ELSE NULL END
  , @strItems				= CASE WHEN strBasis = 'Revenue' THEN strItems ELSE NULL END
  , @strCondition			= CASE WHEN strBasis = 'Conditional' THEN strCondition ELSE NULL END
  , @dblHurdle				= ISNULL(dblHurdle, 0.000000)
  , @dblCalculationAmount	= ISNULL(dblCalculationAmount, 0.000000)
  , @ysnPaymentRequired		= ysnPaymentRequired
  , @ysnMarginalSales		= CASE WHEN strBasis = 'Revenue' THEN ysnMarginalSales ELSE 0 END
FROM tblARCommissionPlan 
WHERE intCommissionId = @intCommissionPlanId
AND GETDATE() BETWEEN dtmStartDate AND dtmEndDate

IF @strBasis = 'Hours'
	BEGIN
		SELECT @strHourType
	END
ELSE IF @strBasis = 'Revenue'
	BEGIN
		DECLARE @tmpAccountsTable		TABLE (intAccountId INT)
		DECLARE @tmpSalespersonsTable	TABLE (intSalespersonId INT)
		DECLARE @tmpAgentsTable			TABLE (intAgentId INT)
		DECLARE @tmpDriversTable		TABLE (intDriversId INT)
		DECLARE @tmpItemCategoriesTable TABLE (intItemCategoryId INT)
		DECLARE @tmpItemsTable			TABLE (intItemId INT)
	
		IF ISNULL(@strAccounts, '') <> ''
			BEGIN
				INSERT INTO @tmpAccountsTable
				SELECT intID FROM dbo.fnGetRowsFromDelimitedValues(@strAccounts)
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
	END
ELSE IF @strBasis = 'Units'
	BEGIN
		SELECT @strUnitType
	END
ELSE IF @strBasis = 'Conditional'
	BEGIN
		SELECT @strCondition
	END

--CREATE AUTO PAYABLES
IF @ysnAutoCreatePayables = 1
BEGIN
	SELECT * FROM tblAPBill											
END

--CREATE AUTO PAYROLL
IF @ysnAutoCreatePayroll = 1 AND @ysnEmployee = 1
BEGIN
	SELECT * FROM tblPRPaycheck
END