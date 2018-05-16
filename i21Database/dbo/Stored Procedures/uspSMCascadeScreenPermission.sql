CREATE PROCEDURE [dbo].[uspSMCascadeScreenPermission]
	@userRoleId int,
	@screenId int,
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
	SELECT @permission = strPermission FROM tblSMUserRoleScreenPermission WHERE intUserRoleId = @userRoleId AND intScreenId = @screenId

	IF @IsDefaultPortal = 1
	BEGIN
		DELETE tblSMUserRoleScreenPermission 
		WHERE intScreenId = @screenId 
		AND intUserRoleId IN 
		(
			SELECT intUserRoleID 
			FROM tblSMUserRole
			WHERE strRoleType IN ('Contact Admin', 'Contact')
		)

		IF @status IN ('Added', 'Modified')
		BEGIN			
			INSERT INTO tblSMUserRoleScreenPermission ([intUserRoleId],[intScreenId],[strPermission])
			SELECT intUserRoleID, @screenId, @permission
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
				DELETE tblSMUserRoleScreenPermission 
				WHERE intScreenId = @screenId 
				AND intUserRoleId IN 
				(
					SELECT EntityToRole.intEntityRoleId
					FROM tblEMEntityToRole EntityToRole
					INNER JOIN tblSMUserRole UserRole ON EntityToRole.intEntityRoleId = UserRole.intUserRoleID
					WHERE EntityToRole.intEntityId = @groupId AND UserRole.intUserRoleID <> @userRoleId
				)
				
				IF @status IN ('Added', 'Modified')
				BEGIN
					INSERT INTO tblSMUserRoleScreenPermission ([intUserRoleId],[intScreenId],[strPermission])
					SELECT EntityToRole.intEntityRoleId, @screenId, @permission
					FROM tblEMEntityToRole EntityToRole
					INNER JOIN tblSMUserRole UserRole ON EntityToRole.intEntityRoleId = UserRole.intUserRoleID
					WHERE EntityToRole.intEntityId = @groupId AND UserRole.intUserRoleID <> @userRoleId
				END
			END
		END		
	END
END
