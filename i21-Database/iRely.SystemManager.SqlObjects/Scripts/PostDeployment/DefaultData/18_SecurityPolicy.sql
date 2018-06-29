GO
	PRINT N'BEGIN INSERT DEFAULT USER POLICY'
GO
	PRINT N'SKIPPING CONSTRAINT CHECKING'
	ALTER TABLE tblSMSecurityPolicy NOCHECK CONSTRAINT FK_tblSMSecurityPolicy_tblEMEntity
	ALTER TABLE tblSMUserSecurity NOCHECK CONSTRAINT FK_UserSecurity_tblSMSecurityPolicy

GO
	DELETE FROM tblSMSecurityPolicy WHERE intSecurityPolicyId = 1	
GO
	SET IDENTITY_INSERT [dbo].[tblSMSecurityPolicy] ON
	INSERT INTO tblSMSecurityPolicy([intSecurityPolicyId], [strPolicyName], [strDescription], [ysnAllowUserToChangePassword], [intMinPasswordLen], [intMaxPasswordLen],	[intPasswordExpires], [intDisplayPasswordExpirationWarn], 
									[intEnforcePasswordHistory], [ysnDisallowIncrementPassword], [intMaxRepeatedChar], [intMinUniqueChar], [intMinLowerCaseChar], [intMinUpperCaseChar], [intMinNumericChar], 
									[intMinSpecialCharacter], [ysnReqTwoFactorAuth], [intLockIdleUserAfter], [intReqCaptchaAfter], [intLockUserAccountAfter], [intLockUserAccountDuration], [strAfterHoursLogin])
	SELECT 1, 'Default User Policy', 'Default User Policy', 1, 6, 10, 0, 0, 0, 0, 4, 0, 1, 1, 1, 0, 0, 0, 3, 10, 30, 'Allow'
	SET IDENTITY_INSERT [dbo].[tblSMSecurityPolicy] OFF
GO
	PRINT N'RETURNING CONSTRAINT CHECKING'
	ALTER TABLE tblSMSecurityPolicy CHECK CONSTRAINT FK_tblSMSecurityPolicy_tblEMEntity
	ALTER TABLE tblSMUserSecurity CHECK CONSTRAINT FK_UserSecurity_tblSMSecurityPolicy
GO