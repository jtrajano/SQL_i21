CREATE PROCEDURE [dbo].[uspTMUpdateCustomerBudget]
	@EntityId INT
	,@strCalculation NvARCHAR(15)
	,@intPeriods INT
AS
BEGIN	
	DECLARE @strBudgetAmountForBudgetBilling NVARCHAR(50)
	DECLARE @intEntityCustomerId INT
	DECLARE @dtmBeginBudgetDate DATETIME
	DECLARE @strBeginBudgetDate NVARCHAR(25)
	DECLARE @ctr INT
	DECLARE @dtmBeginDate DATETIME

	SELECT 
		intEntityCustomerId = C.intCustomerNumber
		,dblBudget = SUM(ISNULL(A.dblEstimatedBudget,0.0))
		INTO #tmpCustomerBudget
	FROM tblTMBudgetCalculationSite A
	INNER JOIN tblTMSite B
		ON A.intSiteId = B.intSiteID
	INNER JOIN tblTMCustomer C
		ON C.intCustomerID = B.intCustomerID
	GROUP BY C.intCustomerNumber
	
	WHILE EXISTS(SELECT TOP 1 1 FROM #tmpCustomerBudget)
	BEGIN
		SELECT TOP 1 
			@strBudgetAmountForBudgetBilling = CAST(dblBudget AS NVARCHAR(50))
			,@intEntityCustomerId = intEntityCustomerId
		FROM #tmpCustomerBudget

		IF(@strCalculation = 'Next Year')
		BEGIN
			--UPDATE CUSTOMER info
			EXEC uspEMUpdateCustomerTable 'dblMonthlyBudget', @strBudgetAmountForBudgetBilling, @intEntityCustomerId, @EntityId


			

			--check and update begin date
			SELECT TOP 1 @dtmBeginBudgetDate = dtmBudgetBeginDate FROM tblARCustomer WHERE [intEntityId] = @intEntityCustomerId 
			IF(@dtmBeginBudgetDate IS NOT NULL)
			BEGIN
				SET @dtmBeginDate =  DATEADD(YEAR,1,@dtmBeginBudgetDate)
				SET @strBeginBudgetDate = CAST(MONTH(@dtmBeginDate) AS NVARCHAR(2)) + '/' + CAST(DAY(@dtmBeginDate) AS NVARCHAR(2)) + '/' + CAST(YEAR(@dtmBeginDate) AS NVARCHAR(4)) 
				EXEC uspEMUpdateCustomerTable 'dtmBudgetBeginDate',@strBeginBudgetDate, @intEntityCustomerId, @EntityId 
			END


			
			---Check and update periods
			IF(@intPeriods IS NOT NULL)
			BEGIN
				EXEC uspEMUpdateCustomerTable 'intNoOfPeriods', @intPeriods, @intEntityCustomerId, @EntityId
			END

			--Create Budget Schedule
			IF(@dtmBeginBudgetDate IS NOT NULL)
			BEGIN
				SET @ctr = 1
				INSERT INTO tblARCustomerBudget	(
					intEntityCustomerId
					,dblBudgetAmount
					,dtmBudgetDate
					,intConcurrencyId
				)
				SELECT 
					intEntityCustomerId = @intEntityCustomerId
					,dblBudgetAmount = CAST(@strBudgetAmountForBudgetBilling AS NUMERIC(18,6))
					,dtmBudgetDate = @dtmBeginDate
					,intConcurrencyId = 0

				WHILE(ISNULL(@intPeriods,0) > @ctr)
				BEGIN
					INSERT INTO tblARCustomerBudget	(
						intEntityCustomerId
						,dblBudgetAmount
						,dtmBudgetDate
						,intConcurrencyId
					)
					SELECT 
						intEntityCustomerId = @intEntityCustomerId
						,dblBudgetAmount = CAST(@strBudgetAmountForBudgetBilling AS NUMERIC(18,6))
						,dtmBudgetDate = DATEADD(MONTH,@ctr,@dtmBeginDate)
						,intConcurrencyId = 0

					SET @ctr = @ctr + 1
				END 
			END
		END
		ELSE
		BEGIN
			--- This Year calculation

			-- update schedule
			UPDATE tblARCustomerBudget
			SET dblBudgetAmount = CAST(@strBudgetAmountForBudgetBilling AS NUMERIC(18,6))
			WHERE intEntityCustomerId = @intEntityCustomerId
				AND DATEADD(dd, DATEDIFF(dd, 0, dtmBudgetDate), 0)  >= DATEADD(dd, DATEDIFF(dd, 0, GETDATE()), 0) 
		END

		DELETE FROM #tmpCustomerBudget WHERE intEntityCustomerId = @intEntityCustomerId
	END
	
END
GO