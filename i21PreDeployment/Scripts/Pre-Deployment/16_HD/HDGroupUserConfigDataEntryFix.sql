GO
	PRINT N'Start fixing HD Group User Configuration.'
GO

	IF NOT EXISTS (
		SELECT
			* 
        FROM
			sys.foreign_keys 
        WHERE
			object_id = OBJECT_ID(N'[dbo].[FK_tblHDGroupUserConfig_tblSMUserSecurity]') 
            AND parent_object_id = OBJECT_ID(N'[dbo].[tblHDGroupUserConfig]')
	)
	BEGIN

		IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE='BASE TABLE' AND TABLE_NAME='tblHDGroupUserConfig')
		BEGIN
			IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE='BASE TABLE' AND TABLE_NAME='tblSMUserSecurity')
			BEGIN
				exec(
						'Update
							a set
							a.intUserSecurityEntityId = b.intEntityUserSecurityId
							,a.intUserSecurityId = b.intEntityUserSecurityId
						from
							tblHDGroupUserConfig a, tblSMUserSecurity b
						where
							a.intUserSecurityId = b.intUserSecurityIdOld
							and b.intUserSecurityIdOld is not null'
					)
			END
		END
	END

GO
	PRINT N'End fixing HD Group User Configuration.'
GO