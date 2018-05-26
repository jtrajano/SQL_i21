﻿CREATE PROCEDURE [dbo].[uspEMTogglePortalAccess]
	@intEntityId			int,
	@intEntityContactId		int,	
	@ysnEnablePortalAccess	bit,	
	@intUserRoleId			int,
	@strPassword			nvarchar(100) = '',
	@ysnAdmin				bit = 0,
	@message				nvarchar(200) output	
AS
BEGIN
	if @ysnEnablePortalAccess = 0 
	begin
		update [tblEMEntityToContact] set ysnPortalAccess = 0, intEntityRoleId = null where intEntityId = @intEntityId

		delete from [tblEMEntityCredential] where intEntityId in (select intEntityContactId from [tblEMEntityToContact] where intEntityId = @intEntityId)

		if @ysnAdmin = 1
		begin
			update [tblEMEntityToContact] set ysnPortalAdmin = 0 where intEntityContactId = @intEntityContactId
		end

		set @message =  ''
	end
	else
	begin

		if not exists(select top 1 1 from tblEMEntityToRole where intEntityId = @intEntityId)
		begin
			INSERT INTO tblEMEntityToRole(intEntityId, intEntityRoleId) VALUES(@intEntityId, @intUserRoleId) --exec [uspSMCreateContactAdmin] @entityId = @intEntityId
		end 

		--declare @roleId int
		--select @roleId = a.intEntityRoleId 
		--	from tblEMEntityToRole a
		--	 join tblSMUserRole b
		--		on a.intEntityRoleId = b.intUserRoleID		 
		--	 where intEntityId = @intEntityId and b.ysnAdmin = @ysnAdmin
		declare @userName nvarchar(200)
		select @userName = strEmail from tblEMEntity where intEntityId = @intEntityContactId
				
		--if(@roleId is null or @roleId < 0)
		--begin
		--	set @message =  'User role is not yet created'
		--	return 0
		--end

		--if exists( select top 1 1 from [tblEMEntityToContact] where intEntityRoleId = @roleId and intEntityContactId = @intEntityContactId and ysnPortalAccess = 1)
		--begin
		--	return 0;
		--end

		--set @intUserRoleId = @roleId

		if(@userName is null or @userName = '')
		begin
			set @message =  'Email address is empty'
			return 0
		end

		if exists(select top 1 1 from [tblEMEntityCredential] where strUserName = @userName and intEntityId <> @intEntityContactId)
		begin
			set @message =  'Username already exists'
			return 0
		end

		--delete from [tblEMEntityCredential] where intEntityId in (select intEntityContactId from [tblEMEntityToContact] where intEntityId = @intEntityId and intEntityRoleId = @roleId)

		if not exists(select top 1 1 from [tblEMEntityCredential] where intEntityId = @intEntityContactId)
		begin
			if(@strPassword = '')
				set @strPassword = '1234'
			
			declare @dc nvarchar(max)
			exec uspAESEncryptASym @strPassword, @dc output


			insert into [tblEMEntityCredential](intEntityId,strUserName,strPassword,ysnNotEncrypted)
			select @intEntityContactId, @userName, @dc, 0
		end

		if @ysnAdmin = 1
		begin
			update [tblEMEntityToContact] set ysnPortalAdmin = 0 where intEntityId = @intEntityId
		end
		
		UPDATE tblEMEntity SET strDateFormat = 'M/d/yyyy',
			strNumberFormat = '1,234,567.89'
			WHERE intEntityId  = @intEntityContactId 

		update [tblEMEntityToContact] set 
			--ysnPortalAccess = 0, 
			intEntityRoleId = null 
				where intEntityId = @intEntityId 
					and intEntityRoleId = @intUserRoleId--@roleId

		update [tblEMEntityToContact] set 
			ysnPortalAccess = 1, 
			ysnPortalAdmin = @ysnAdmin,
			intEntityRoleId = @intUserRoleId--@roleId
				where intEntityId = @intEntityId 
					and intEntityContactId = @intEntityContactId

		set @message =  ''
	end

END
