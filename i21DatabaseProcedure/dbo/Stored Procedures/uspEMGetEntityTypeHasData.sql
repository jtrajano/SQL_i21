CREATE PROCEDURE [dbo].[uspEMGetEntityTypeHasData]
	@entityId int,
	@type nvarchar(100)
AS
	
	DECLARE @hasData bit
	SET @type = LOWER(@type)

	SET @hasData = 0

	IF @type = 'user'
		SELECT TOP 1 @hasData = 1 FROM tblSMUserSecurity WHERE intEntityId = @entityId

	ELSE IF @type = 'customer' OR @type = 'prospect'
		SELECT TOP 1 @hasData = 1 FROM tblARCustomer WHERE intEntityId = @entityId

	ELSE IF @type = 'lead'
		SELECT TOP 1 @hasData = 1 FROM tblARLead WHERE intEntityId = @entityId

	ELSE IF @type = 'salesperson'
		SELECT TOP 1 @hasData = 1 FROM tblARSalesperson WHERE intEntityId = @entityId

	ELSE IF @type = 'employee'
		SELECT TOP 1 @hasData = 1 FROM tblPREmployee WHERE intEntityId = @entityId

	ELSE IF @type = 'vendor'
		SELECT TOP 1 @hasData = 1 FROM tblAPVendor WHERE intEntityId = @entityId

	ELSE IF @type = 'veterinary'
		SELECT TOP 1 @hasData = 1 FROM tblVTVeterinary WHERE intEntityId = @entityId		

	ELSE IF @type = 'ship via'
		SELECT TOP 1 @hasData = 1 FROM tblSMShipVia WHERE intEntityId = @entityId


	SELECT @hasData

RETURN @hasData
