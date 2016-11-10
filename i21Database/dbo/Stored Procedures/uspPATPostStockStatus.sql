CREATE PROCEDURE [dbo].[uspPATPostStockStatus] 
	@intUpdateId INT = NULL,
	@ysnPosted BIT = NULL
AS
BEGIN
		IF(ISNULL(@ysnPosted,1) = 1)
		BEGIN
			UPDATE ARC SET ARC.strStockStatus = CSD.strNewStatus
				FROM tblARCustomer ARC 
				INNER JOIN tblPATChangeStatusDetail CSD 
					ON CSD.intCustomerId = ARC.intEntityCustomerId 
				WHERE CSD.intChangeStatusId = @intUpdateId
				
			UPDATE tblPATChangeStatus
				SET ysnPosted = ISNULL(@ysnPosted,1)
				WHERE intChangeStatusId = @intUpdateId
		END
		ELSE
		BEGIN
			UPDATE ARC SET ARC.strStockStatus = CSD.strCurrentStatus
				FROM tblARCustomer ARC 
				INNER JOIN tblPATChangeStatusDetail CSD 
					ON CSD.intCustomerId = ARC.intEntityCustomerId 
				WHERE CSD.intChangeStatusId = @intUpdateId

			UPDATE tblPATChangeStatus
				SET ysnPosted = ISNULL(@ysnPosted,0)
				WHERE intChangeStatusId = @intUpdateId
		END
END
GO