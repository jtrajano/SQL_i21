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
		
	IF EXISTS(SELECT TOP 1 1 FROM tblEMEntity where strEntityNo = @Id)
	begin	
		SET @Message = 'Entity No already exists.'		
		RETURN 0
	end
	--Add validation for existing entity no
	INSERT INTO tblEMEntity (strName, strContactNumber, strEntityNo)
	select @Id,'', @Id

	SET @EntityId = @@IDENTITY

	INSERT INTO tblEMEntity (strName, strContactNumber)
	select @Id,''

	SET @EntityContactId = @@IDENTITY

	INSERT INTO [tblEMEntityToContact](intEntityId, intEntityContactId, ysnDefaultContact, ysnPortalAccess)
	SELECT @EntityId, @EntityContactId,1, 0

	INSERT INTO [tblEMEntityLocation]( intEntityId, strLocationName, ysnDefaultLocation)
	SELECT @EntityId, @Id, 1

	INSERT INTO [tblEMEntityType](intEntityId, strType, intConcurrencyId)
	SELECT @EntityId, @Type, 0

	if @Type = 'Vendor'
	begin
		INSERT into tblAPVendor([intEntityId], strVendorId, intVendorType, ysnWithholding, dblCreditLimit)
		SELECT @EntityId, @Id, 0, 0, 0
	end

	EXEC uspSMAuditLog
        @keyValue = @EntityId,
        @screenName = 'EntityManagement.view.Entity',
        @entityId = @UserId,
        @actionType = 'Created'

END

go
