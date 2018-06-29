CREATE TRIGGER [dbo].[trgSMAfterInsertUserSecurityCompanyLocationRolePermission]
    ON [dbo].[tblSMUserSecurityCompanyLocationRolePermission]
    AFTER INSERT
    AS
    declare
		@newId  int
		
	begin transaction;

		begin try			
			select
				@newId = i.intUserSecurityCompanyLocationRolePermissionId
			from
				inserted i;
			
			update tblSMUserSecurityCompanyLocationRolePermission set intEntityId = intEntityUserSecurityId where intUserSecurityCompanyLocationRolePermissionId = @newId;

		end try
		begin catch
			rollback transaction;
		end catch

	commit transaction;
GO