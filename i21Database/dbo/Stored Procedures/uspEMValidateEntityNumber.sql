CREATE PROCEDURE uspEMValidateEntityNumber
	@Identification		NVARCHAR(100),
	@EntityId			int,
	@Message			NVARCHAR(200)	OUTPUT
as
BEGIN
	SET QUOTED_IDENTIFIER OFF
	SET ANSI_NULLS ON
	SET NOCOUNT ON
	SET XACT_ABORT ON
	SET ANSI_WARNINGS OFF

	IF EXISTS(SELECT TOP 1 1 FROM tblEMEntity where strEntityNo = @Identification AND intEntityId != @EntityId)
	BEGIN
		Set @Message = 'Entity No already exists'
		GOTO ExitHere
	END

	IF EXISTS(SELECT TOP 1 1 FROM tblAPVendor where strVendorId = @Identification  AND [intEntityId] != @EntityId)
	BEGIN
		Set @Message = 'Entity No already exists as Vendor'
		GOTO ExitHere
	END

	IF EXISTS(SELECT TOP 1 1 FROM tblARCustomer where strCustomerNumber = @Identification AND [intEntityId] != @EntityId)
	BEGIN
		Set @Message = 'Entity No already exists as Customer'
		GOTO ExitHere
	END

	IF EXISTS(SELECT TOP 1 1 FROM tblARSalesperson where strSalespersonId = @Identification AND [intEntityId] != @EntityId)
	BEGIN
		Set @Message = 'Entity No already exists as Salesperson'
		GOTO ExitHere
	END


ExitHere: 
END
GO