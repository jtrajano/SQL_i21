
CREATE PROCEDURE [dbo].[uspARDeleteCustomer]
@intEntityId INT = 0
AS
BEGIN
	SET NOCOUNT ON;
	
	--Get the intEntityId of Customer's Contact
	SELECT
	Con.intEntityId as ContactEntityId 
	INTO #tblCustomerContacts 
	FROM tblARCustomer Cus 
	INNER JOIN tblARCustomerToContact CusToCon ON Cus.intCustomerId = CusToCon.intCustomerId
	INNER JOIN tblEntityContact Con ON CusToCon.intContactId = Con.intContactId
	WHERE Cus.intEntityId =  @intEntityId
	
	--Delete Customer
	BEGIN TRY
		BEGIN TRANSACTION
			DELETE FROM tblARCustomer WHERE intEntityId = @intEntityId
			DELETE FROM tblEntity WHERE intEntityId = @intEntityId
		--If the DELETE statement succeeds, commit the transaction	
		COMMIT TRANSACTION
		
		--Delete Credentials of associated Contacts for Customer
		DELETE FROM tblEntityCredential WHERE intEntityId IN (Select ContactEntityId FROM #tblCustomerContacts)
	END TRY
	
	BEGIN CATCH
		ROLLBACK TRANSACTION
	END CATCH
	
END
GO