CREATE PROCEDURE [dbo].[uspPATPostStockStatus] 
	@intUpdateId INT = NULL,
	@ysnPosted BIT = NULL
AS
BEGIN
		SELECT CS.intUpdateId,
			   CSD.intCustomerId,
			   CSD.strCurrentStatus
		  INTO #tempStatus
		  FROM tblPATChangeStatus CS
	INNER JOIN tblPATChangeStatusDetail CSD
			ON CSD.intUpdateId = CS.intUpdateId
		 WHERE CS.intUpdateId = @intUpdateId


			IF(@ysnPosted = 1)
			BEGIN
				UPDATE tblARCustomer
				   SET strStockStatus = 'Voting'
				 WHERE intEntityCustomerId IN (SELECT intCustomerId FROM #tempStatus)

				UPDATE tblPATChangeStatus
				   SET ysnPosted = 1
				 WHERE intUpdateId = @intUpdateId
			END
			ELSE
			BEGIN
				DECLARE @intCustomerId INT,
						@strCurrentStatus NVARCHAR(MAX)

				DECLARE stockCursor CURSOR FOR 	
				SELECT DISTINCT intCustomerId, strCurrentStatus FROM #tempStatus
				OPEN stockCursor
				FETCH NEXT FROM stockCursor into @intCustomerId, @strCurrentStatus
				WHILE (@@FETCH_STATUS <> -1)
				BEGIN
					UPDATE tblARCustomer
						SET strStockStatus = @strCurrentStatus
						WHERE intEntityCustomerId = @intCustomerId

					FETCH NEXT FROM stockCursor into @intCustomerId, @strCurrentStatus
				END
				CLOSE stockCursor
				DEALLOCATE stockCursor

				UPDATE tblPATChangeStatus
				   SET ysnPosted = 0
				 WHERE intUpdateId = @intUpdateId
			END

			DROP TABLE #tempStatus
END

GO