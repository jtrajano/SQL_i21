CREATE PROCEDURE [dbo].[uspPATPostCancelEquity]
	@intCancelId INT = NULL,
	@ysnPosted BIT = NULL
AS
BEGIN
		SELECT CE.intCancelId,
			   CED.intCustomerId,
			   CED.intFiscalYearId,
			   CED.dblQuantityAvailable,
			   CED.dblQuantityCancelled
		  INTO #tempStatus
		  FROM tblPATCancelEquity CE
	INNER JOIN tblPATCancelEquityDetail CED
			ON CED.intCancelId = CE.intCancelId

		DECLARE @intCustomerId INT,
				@intFiscalYearId NVARCHAR(MAX),
				@dblQuantityAvailable NUMERIC(18,6),
				@dblQuantityCancelled NUMERIC(18,6)

		IF(@ysnPosted = 1)
		BEGIN
			DECLARE equityCursor CURSOR FOR 	
			SELECT DISTINCT intCustomerId, intFiscalYearId, dblQuantityAvailable, dblQuantityCancelled FROM #tempStatus
			OPEN equityCursor
			FETCH NEXT FROM equityCursor into @intCustomerId, @intFiscalYearId, @dblQuantityAvailable, @dblQuantityCancelled
			WHILE (@@FETCH_STATUS <> -1)
			BEGIN
				UPDATE tblPATCustomerEquity
				   SET dblEquity = @dblQuantityAvailable - @dblQuantityCancelled
				 WHERE intCustomerId = @intCustomerId
				   AND intFiscalYearId = @intFiscalYearId

				FETCH NEXT FROM equityCursor into @intCustomerId, @intFiscalYearId, @dblQuantityAvailable, @dblQuantityCancelled
			END
			CLOSE equityCursor
			DEALLOCATE equityCursor

			UPDATE tblPATCancelEquity
				SET ysnPosted = 1
				WHERE intCancelId = @intCancelId

		END
		ELSE
		BEGIN
			
			DECLARE equityCursor CURSOR FOR 	
			SELECT DISTINCT intCustomerId, intFiscalYearId, dblQuantityAvailable, dblQuantityCancelled FROM #tempStatus
			OPEN equityCursor
			FETCH NEXT FROM equityCursor into @intCustomerId, @intFiscalYearId, @dblQuantityAvailable, @dblQuantityCancelled
			WHILE (@@FETCH_STATUS <> -1)
			BEGIN
				UPDATE tblPATCustomerEquity
				   SET dblEquity = @dblQuantityAvailable
				 WHERE intCustomerId = @intCustomerId
				   AND intFiscalYearId = @intFiscalYearId

				FETCH NEXT FROM equityCursor into @intCustomerId, @intFiscalYearId, @dblQuantityAvailable, @dblQuantityCancelled
			END
			CLOSE equityCursor
			DEALLOCATE equityCursor

			UPDATE tblPATCancelEquity
				SET ysnPosted = 0
				WHERE intCancelId = @intCancelId

		DROP TABLE #tempStatus

		END
END

GO