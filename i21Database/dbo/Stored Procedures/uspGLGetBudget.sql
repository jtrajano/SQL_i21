CREATE PROCEDURE uspGLGetBudget
(
	@budgetCode INT,
	@intFiscalYearId INT,
	@dtmDateFrom DATETIME,
	@dtmDateTo DATETIME,
	@intAccountId INT,
	@budget DECIMAL (18,6) OUT
)
AS
--Select * from tblFRBudget WHERE intBudgetCode =@budgetCode
SET @budget = 0
IF EXISTS (SELECT TOP 1 1  FROM tblFRBudget WHERE intAccountId = @intAccountId AND intBudgetCode = @budgetCode)
BEGIN
	DECLARE @dtmPeriod1 DATE
	DECLARE @dtmPeriod2 DATE
	DECLARE @periodOrder1 varchar(2)
	DECLARE @periodOrder2 varchar(2)
	DECLARE @sql NVARCHAR(500)
	DECLARE @ParamDefinition NVARCHAR(500)

	--DETERMINE THE START DATE OF DATE PARAMETERS TO GET THE PERIOD ORDER
	Select @dtmPeriod1 = dtmStartDate from tblGLFiscalYearPeriod where @dtmDateFrom >= dtmStartDate and @dtmDateFrom <= dtmEndDate and intFiscalYearId = @intFiscalYearId
	Select @dtmPeriod2 = dtmStartDate from tblGLFiscalYearPeriod where @dtmDateTo >= dtmStartDate and @dtmDateTo <= dtmEndDate and intFiscalYearId = @intFiscalYearId

	--DETERMINE THE PERIOD ORDER
	
	IF @dtmPeriod1 IS NOT NULL
		SELECT @periodOrder1 =  CONVERT(VARCHAR(2),COUNT(1)) FROM tblGLFiscalYearPeriod WHERE dtmStartDate <= @dtmPeriod1 AND intFiscalYearId = @intFiscalYearId
	ELSE
		SET @periodOrder1 = 1

	IF @dtmPeriod2 IS NOT NULL
		SELECT @periodOrder2 = CONVERT(VARCHAR(2),COUNT(1)) FROM tblGLFiscalYearPeriod WHERE dtmStartDate <= @dtmPeriod2 AND intFiscalYearId = @intFiscalYearId
	ELSE
	BEGIN
		SELECT @periodOrder2 = ISNULL(intPeriod13,12) FROM tblFRBudget WHERE intBudgetCode = @budgetCode
	END
	
	--COMPUTE THE BUDGET
	--GET THE BUDGET OF THE FIRST PERIOD
	SET @sql =
	'SELECT @budgetOut=dblBudget' + @periodOrder1 + ' from tblFRBudget WHERE intAccountId = @intAccountId AND intBudgetCode = @budgetCode' 
	SET @ParamDefinition = N'@intAccountId INT, @budgetCode INT,  @budgetOut DECIMAL(18,6) OUTPUT'
	EXEC sp_executesql @sql,@ParamDefinition,@intAccountId = @intAccountId, @budgetCode = @budgetCode, @budgetOut = @budget OUTPUT;
	
	--GET THE BUDGET OF THE SECOND PERIOD
	IF @periodOrder1 <> @periodOrder2
	BEGIN
		DECLARE @budget1 DECIMAL (18,6)
		SET @sql =
		'SELECT @budgetOut=dblBudget' + @periodOrder2 + ' from tblFRBudget WHERE intAccountId = @intAccountId AND intBudgetCode = @budgetCode' 
		SET @ParamDefinition = N'@intAccountId INT, @budgetCode INT,  @budgetOut DECIMAL(18,6) OUTPUT'
		EXEC sp_executesql @sql,@ParamDefinition,@intAccountId = @intAccountId, @budgetCode = @budgetCode, @budgetOut = @budget1 OUTPUT;
				
		IF @budget1 IS NOT NULL
			SET @budget += @budget1
	END
END