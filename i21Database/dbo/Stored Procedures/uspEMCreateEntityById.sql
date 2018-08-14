CREATE PROCEDURE uspEMCreateEntityById
	@Id nvarchar(100),
	@Type NVARCHAR(50),
	@UserId INT,
	@Message NVARCHAR(100) OUTPUT,
	@EntityId INT OUTPUT
AS
BEGIN
	SET NOCOUNT ON
	DECLARE @EntityContactId int
	DECLARE @EntityLocationId int
		
	IF EXISTS(SELECT TOP 1 1 FROM tblEMEntity where strEntityNo = @Id)
	BEGIN	
		SET @Message = 'Entity No already exists.'		
		RETURN 0
	END
	--Add validation for existing entity no
	INSERT INTO tblEMEntity (strName, strContactNumber, strEntityNo)
	SELECT @Id,'', @Id

	SET @EntityId = @@IDENTITY

	INSERT INTO tblEMEntity (strName, strContactNumber)
	SELECT @Id,''

	SET @EntityContactId = @@IDENTITY

	INSERT INTO [tblEMEntityToContact](intEntityId, intEntityContactId, ysnDefaultContact, ysnPortalAccess)
	SELECT @EntityId, @EntityContactId,1, 0

	INSERT INTO [tblEMEntityLocation]( intEntityId, strLocationName, ysnDefaultLocation)
	SELECT @EntityId, @Id, 1

	INSERT INTO [tblEMEntityType](intEntityId, strType, intConcurrencyId)
	SELECT @EntityId, @Type, 0

	IF @Type = 'Vendor'
	BEGIN
		INSERT INTO tblAPVendor([intEntityId], strVendorId, intVendorType, ysnWithholding, dblCreditLimit)
		SELECT @EntityId, @Id, 0, 0, 0
	END
	ELSE IF @Type = 'Customer'
	BEGIN
		INSERT INTO tblARCustomer(intEntityId, strCustomerNumber, strType, dblARBalance)
		SELECT @EntityId, @Id, 'Person', 0.00
	END

	EXEC uspSMAuditLog
        @keyValue = @EntityId,
        @screenName = 'EntityManagement.view.Entity',
        @entityId = @UserId,
        @actionType = 'Created'

END

go
