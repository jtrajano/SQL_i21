CREATE PROCEDURE [dbo].[uspEMDeactivateEntity]
	@Id int,
	@intUserId INT = NULL
AS
	

	IF EXISTS( SELECT TOP 1 1 FROM [tblEMEntityType] WHERE intEntityId = @Id and strType = 'Vendor')
	BEGIN
		UPDATE tblAPVendor SET ysnPymtCtrlActive = 0 WHERE [intEntityId] = @Id
		
		DECLARE @details NVARCHAR(MAX) = '{"change":"ysnPymtCtrlActive","from":"true","to":"false","leaf":true,"iconCls":"small-gear","isField":true,"keyValue":' +CAST(@Id AS NVARCHAR(MAX)) + ',"changeDescription":"Active","hidden":false}'
		EXEC uspSMAuditLog 
			@keyValue = @Id,
			@screenName = 'EntityManagement.view.Entity',
			@entityId = @intUserId,
			@actionType = 'Updated',
			@details = @details
	END	

	IF EXISTS( SELECT TOP 1 1 FROM [tblEMEntityType] WHERE intEntityId = @Id and strType = 'Customer')
	BEGIN	
		UPDATE tblARCustomer SET ysnActive= 0 WHERE [intEntityId] = @Id
	END	

	IF EXISTS( SELECT TOP 1 1 FROM [tblEMEntityType] WHERE intEntityId = @Id and strType = 'Salesperson')
	BEGIN	
		UPDATE tblARSalesperson SET ysnActive= 0 WHERE [intEntityId] = @Id
	END	

	IF EXISTS( SELECT TOP 1 1 FROM [tblEMEntityType] WHERE intEntityId = @Id and strType = 'User')
	BEGIN	
		UPDATE tblSMUserSecurity SET ysnDisabled = 1 WHERE [intEntityId] = @Id
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
