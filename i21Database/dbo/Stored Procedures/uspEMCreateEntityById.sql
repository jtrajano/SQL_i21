CREATE PROCEDURE uspEMCreateEntityById
	@Id nvarchar(100),
	@Type NVARCHAR(50),
	@UserId INT,
	@Message NVARCHAR(100) OUTPUT
AS
BEGIN
	SET NOCOUNT ON
	DECLARE @EntityId int
	DECLARE @EntityContactId int
	DECLARE @EntityLocationId int
		
	IF EXISTS(SELECT TOP 1 1 FROM tblEntity where strEntityNo = @Id)
	begin	
		SET @Message = 'Entity No already exists.'		
		RETURN 0
	end
	--Add validation for existing entity no
	INSERT INTO tblEntity (strName, strContactNumber, strEntityNo)
	select @Id,'', @Id

	SET @EntityId = @@IDENTITY

	INSERT INTO tblEntity (strName, strContactNumber)
	select @Id,''

	SET @EntityContactId = @@IDENTITY

	INSERT INTO tblEntityToContact(intEntityId, intEntityContactId, ysnDefaultContact, ysnPortalAccess)
	SELECT @EntityId, @EntityContactId,1, 0

	INSERT INTO tblEntityLocation( intEntityId, strLocationName, ysnDefaultLocation)
	SELECT @EntityId, @Id, 1

	INSERT INTO tblEntityType(intEntityId, strType, intConcurrencyId)
	SELECT @EntityId, @Type, 0

	if @Type = 'Vendor'
	begin
		INSERT into tblAPVendor(intEntityVendorId, strVendorId, intVendorType, ysnWithholding, dblCreditLimit)
		SELECT @EntityId, @Id, 0, 0, 0
	end

	EXEC uspSMAuditLog
        @keyValue = @EntityId,
        @screenName = 'EntityManagement.view.Entity',
        @entityId = @UserId,
        @actionType = 'Created'

END

go
