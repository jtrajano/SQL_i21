CREATE PROCEDURE [dbo].[uspEMTogglePortalAccess]
	@intEntityId			int,
	@intEntityContactId		int,
	@ysnEnablePortalAccess	bit,
	@message				nvarchar(200) output,
	@intUserRoleId			int output,
	@strPassword			nvarchar(100) = ''
AS
BEGIN
	if @ysnEnablePortalAccess = 0 
	begin
		update tblEntityToContact set ysnPortalAccess = 0, intEntityRoleId = null where intEntityId = @intEntityId

		delete from tblEntityCredential where intEntityId in (select intEntityContactId from tblEntityToContact where intEntityId = @intEntityId)

		set @message =  ''
	end
	else
	begin

		if not exists(select top 1 1 from tblEMEntityToRole where intEntityId = @intEntityId)
		begin
			exec [uspSMCreateContactAdmin] @entityId = @intEntityId
		end 

		declare @roleId int
		select @roleId = a.intEntityRoleId 
			from tblEMEntityToRole a
			 join tblSMUserRole b
				on a.intEntityRoleId = b.intUserRoleID		 
			 where intEntityId = @intEntityId and b.ysnAdmin = 1
		declare @userName nvarchar(200)
		select @userName = strEmail from tblEntity where intEntityId = @intEntityContactId
				
		if(@roleId is null or @roleId < 0)
		begin
			set @message =  'User role is not yet created'
			return 0
		end

		if exists( select top 1 1 from tblEntityToContact where intEntityRoleId = @roleId and intEntityContactId = @intEntityContactId and ysnPortalAccess = 1)
		begin
			return 0;
		end

		set @intUserRoleId = @roleId

		if(@userName is null or @userName = '')
		begin
			set @message =  'Email address is empty'
			return 0
		end

		if exists(select top 1 1 from tblEntityCredential where strUserName = @userName and intEntityId <> @intEntityContactId)
		begin
			set @message =  'Username already exists'
			return 0
		end

		delete from tblEntityCredential where intEntityId in (select intEntityContactId from tblEntityToContact where intEntityId = @intEntityId and intEntityRoleId = @roleId)

		if not exists(select top 1 1 from tblEntityCredential where intEntityId = @intEntityContactId)
		begin
			if(@strPassword = '')
				set @strPassword = '1234'

			insert into tblEntityCredential(intEntityId,strUserName,strPassword)
			select @intEntityContactId, @userName, @strPassword
		end
		

		update tblEntityToContact set 
			ysnPortalAccess = 0, 
			intEntityRoleId = null 
				where intEntityId = @intEntityId 
					and intEntityRoleId = @roleId

		update tblEntityToContact set 
			ysnPortalAccess = 1, 
			intEntityRoleId = @roleId 
				where intEntityId = @intEntityId 
					and intEntityContactId = @intEntityContactId

		set @message =  ''
	end

END
