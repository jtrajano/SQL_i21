CREATE PROCEDURE [dbo].[uspSMCascadeControlPermission]
	@userRoleId int,
	@controlId int,
	@status nvarchar(10)
AS
BEGIN

	DECLARE @isContact BIT
	DECLARE @isAdmin BIT
	DECLARE @groupId INT
	DECLARE @IsDefaultPortal BIT
	DECLARE @permission NVARCHAR(20)
	DECLARE @required BIT
	
	-- CHECK IF ROLE IS FOR CONTACT/S
	SELECT @isContact = CASE strRoleType WHEN 'Contact Admin' THEN 1 ELSE (CASE strRoleType WHEN 'Contact' THEN 1 ELSE 0 END) END FROM tblSMUserRole WHERE intUserRoleID = @userRoleId
	SELECT @IsDefaultPortal = CASE strRoleType WHEN 'Portal Default' THEN 1 ELSE 0 END FROM tblSMUserRole WHERE intUserRoleID = @userRoleId
	SELECT @permission = strPermission FROM tblSMUserRoleControlPermission WHERE intUserRoleId = @userRoleId AND intControlId = @controlId
	SELECT @required = ysnRequired FROM tblSMUserRoleControlPermission WHERE intUserRoleId = @userRoleId AND intControlId = @controlId

	IF @IsDefaultPortal = 1
	BEGIN
		DELETE tblSMUserRoleControlPermission 
		WHERE intControlId = @controlId 
		AND intUserRoleId IN 
		(
			SELECT intUserRoleID 
			FROM tblSMUserRole
			WHERE strRoleType IN ('Contact Admin', 'Contact')
		)

		IF @status IN ('Added', 'Modified')
		BEGIN			
			INSERT INTO tblSMUserRoleControlPermission ([intUserRoleId],[intControlId],[strPermission],[ysnRequired])
			SELECT intUserRoleID, @controlId, @permission, @required
			FROM tblSMUserRole
			WHERE strRoleType IN ('Contact Admin', 'Contact') AND intUserRoleID <> @userRoleId
		END		
	END	
	ELSE IF @isContact = 1 -- If role is for contact
	BEGIN
		-- Get Contact Admin Parent
		SELECT @groupId = intEntityId FROM tblEMEntityToRole WHERE intEntityRoleId = @userRoleId
		IF(@groupId IS NOT NULL)
		BEGIN
			-- CHECK ROLE IF ADMIN
			SELECT @isAdmin = ysnAdmin FROM tblSMUserRole WHERE intUserRoleID = @userRoleId

			IF @isAdmin = 1 -- If admin update self first then the group		
			BEGIN		
				DELETE tblSMUserRoleControlPermission 
				WHERE intControlId = @controlId 
				AND intUserRoleId IN 
				(
					SELECT EntityToRole.intEntityRoleId
					FROM tblEMEntityToRole EntityToRole
					INNER JOIN tblSMUserRole UserRole ON EntityToRole.intEntityRoleId = UserRole.intUserRoleID
					WHERE EntityToRole.intEntityId = @groupId AND UserRole.intUserRoleID <> @userRoleId
				)
				
				IF @status IN ('Added', 'Modified')
				BEGIN
					INSERT INTO tblSMUserRoleControlPermission ([intUserRoleId],[intControlId],[strPermission],[ysnRequired])
					SELECT EntityToRole.intEntityRoleId, @controlId, @permission, @required
					FROM tblEMEntityToRole EntityToRole
					INNER JOIN tblSMUserRole UserRole ON EntityToRole.intEntityRoleId = UserRole.intUserRoleID
					WHERE EntityToRole.intEntityId = @groupId AND UserRole.intUserRoleID <> @userRoleId
				END
			END
		END		
	END
END
