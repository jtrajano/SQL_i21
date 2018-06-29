CREATE PROCEDURE [dbo].[uspPATPostStockStatus] 
	@intUpdateId INT = NULL,
	@applyChange BIT = NULL
AS
BEGIN
		IF(ISNULL(@applyChange, 1) = 1)
		BEGIN
			UPDATE ARC SET ARC.strStockStatus = CSD.strNewStatus
				FROM tblARCustomer ARC 
				INNER JOIN tblPATChangeStatusDetail CSD 
					ON CSD.intCustomerId = ARC.[intEntityId] 
				WHERE CSD.intChangeStatusId = @intUpdateId
		END
		ELSE
		BEGIN
			UPDATE ARC SET ARC.strStockStatus = CSD.strCurrentStatus
				FROM tblARCustomer ARC 
				INNER JOIN tblPATChangeStatusDetail CSD 
					ON CSD.intCustomerId = ARC.[intEntityId] 
				WHERE CSD.intChangeStatusId = @intUpdateId
		END
END
GO