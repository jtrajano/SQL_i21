CREATE PROCEDURE [dbo].[uspEMDeactivateEntity]
	@Id int
AS
	

	IF EXISTS( SELECT TOP 1 1 FROM tblEntityType WHERE intEntityId = @Id and strType = 'Vendor')
	BEGIN
		UPDATE tblAPVendor SET ysnPymtCtrlActive = 0 WHERE intEntityVendorId = @Id
	END	

	IF EXISTS( SELECT TOP 1 1 FROM tblEntityType WHERE intEntityId = @Id and strType = 'Customer')
	BEGIN	
		UPDATE tblARCustomer SET ysnActive= 0 WHERE intEntityCustomerId = @Id
	END	

	IF EXISTS( SELECT TOP 1 1 FROM tblEntityType WHERE intEntityId = @Id and strType = 'Salesperson')
	BEGIN	
		UPDATE tblARSalesperson SET ysnActive= 0 WHERE intEntitySalespersonId = @Id
	END	
