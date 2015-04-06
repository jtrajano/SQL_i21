
CREATE PROCEDURE [dbo].[uspARDeleteCustomer]
@intEntityId INT = 0
AS
BEGIN
	SET NOCOUNT ON;
	
	--Get the intEntityId of Customer's Contact
	SELECT
	Con.[intEntityContactId] as ContactEntityId 
	INTO #tblCustomerContacts 
	FROM tblARCustomer Cus 
	INNER JOIN tblARCustomerToContact CusToCon ON Cus.[intEntityCustomerId] = CusToCon.[intEntityCustomerId]
	INNER JOIN tblEntityContact Con ON CusToCon.[intEntityContactId] = Con.[intEntityContactId]
	WHERE Cus.[intEntityCustomerId] =  @intEntityId
	
	--Delete Customer
	BEGIN TRY
		BEGIN TRANSACTION
			DELETE FROM tblARCustomer WHERE [intEntityCustomerId] = @intEntityId
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