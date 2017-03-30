CREATE PROCEDURE [dbo].[uspEMDeactivateEntity]
	@Id int
AS
	

	IF EXISTS( SELECT TOP 1 1 FROM [tblEMEntityType] WHERE intEntityId = @Id and strType = 'Vendor')
	BEGIN
		UPDATE tblAPVendor SET ysnPymtCtrlActive = 0 WHERE [intEntityId] = @Id
	END	

	IF EXISTS( SELECT TOP 1 1 FROM [tblEMEntityType] WHERE intEntityId = @Id and strType = 'Customer')
	BEGIN	
		UPDATE tblARCustomer SET ysnActive= 0 WHERE [intEntityId] = @Id
	END	

	IF EXISTS( SELECT TOP 1 1 FROM [tblEMEntityType] WHERE intEntityId = @Id and strType = 'Salesperson')
	BEGIN	
		UPDATE tblARSalesperson SET ysnActive= 0 WHERE intEntitySalespersonId = @Id
	END	

	IF EXISTS( SELECT TOP 1 1 FROM [tblEMEntityType] WHERE intEntityId = @Id and strType = 'User')
	BEGIN	
		UPDATE tblSMUserSecurity SET ysnDisabled = 1 WHERE intEntityUserSecurityId = @Id
	END	

	IF EXISTS( SELECT TOP 1 1 FROM [tblEMEntityType] WHERE intEntityId = @Id and strType = 'Employee')
	BEGIN	
		UPDATE tblPREmployee SET ysnActive= 0 WHERE [intEntityId] = @Id
	END	

	UPDATE a set a.ysnActive = 0
		FROM tblEMEntity a
			JOIN [tblEMEntityToContact] b
				on b.intEntityContactId = a.intEntityId
		WHERE b.intEntityId = @Id


	UPDATE tblEMEntity set ysnActive = 0 WHERE intEntityId = @Id
