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

	-- Parameter Validations ------------------------------------------
	IF EXISTS(SELECT TOP 1 1 FROM tblEMEntity where strEntityNo = @Id)
	BEGIN	
		SET @Message = 'Entity No already exists.'		
		RETURN 0
	END

	IF ISNULL(@Id, '') = ''
	BEGIN
		SET @Message = 'Entity No cannot be empty.'
		RETURN 0
	END

	IF ISNULL(@Type, '') = ''
	BEGIN
		SET @Message = 'Entity Type cannot be empty.'
		RETURN 0
	END

	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMUserSecurity where intEntityId = @UserId)
	BEGIN
		SET @Message = 'User Id is not existing.'
		RETURN 0
	END
	---------------------------------------------------------------------

	-- Insert records ---------------------------------------------------
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
	----------------------------------------------------------------------
	
	-- Insert record in the specific table and set the screen name -------
	DECLARE @screen NVARCHAR(100)
	SET @screen = 'EntityManagement.view.EntityDirect'

	IF @Type = 'Vendor'
	BEGIN
		INSERT INTO tblAPVendor([intEntityId], strVendorId, intVendorType, ysnWithholding, dblCreditLimit)
		SELECT @EntityId, @Id, 0, 0, 0

		SET @screen = 'AccountsPayable.view.EntityVendor'
	END
	ELSE IF @Type = 'Customer'
	BEGIN
		DECLARE @termId INT
		SELECT @termId = intDefaultTermId FROM tblSMCompanyPreference

		INSERT INTO tblARCustomer(intEntityId, strCustomerNumber, strType, dblARBalance, intTermsId)
		SELECT @EntityId, @Id, 'Person', 0.00, @termId

		SET @screen = 'AccountsReceivable.view.EntityCustomer'
	END
	----------------------------------------------------------------------

	-- Add to audit log --------------------------------------------------
	EXEC uspSMAuditLog
        @keyValue = @EntityId,
        @screenName = @screen,
        @entityId = @UserId,
        @actionType = 'Created'
	----------------------------------------------------------------------
END