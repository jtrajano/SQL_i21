﻿CREATE TABLE [dbo].[tblSMSecurityPolicy]
(
	[intSecurityPolicyId] INT NOT NULL PRIMARY KEY IDENTITY, 
    [strPolicyName] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL, 
    [strDescription] NVARCHAR(150) COLLATE Latin1_General_CI_AS NOT NULL, 
    [ysnAllowUserToChangePassword] BIT NOT NULL DEFAULT 1, 
    [intMinPasswordLen] INT NOT NULL DEFAULT 4, 
    [intMaxPasswordLen] INT NOT NULL DEFAULT 8, 
    [intPasswordExpires] INT NOT NULL DEFAULT 0, 
    [intDisplayPasswordExpirationWarn] INT NOT NULL DEFAULT 0, 
    [intEnforcePasswordHistory] INT NOT NULL DEFAULT 0, 
    [ysnDisallowIncrementPassword] BIT NOT NULL DEFAULT 0, 
    [intMaxRepeatedChar] INT NOT NULL DEFAULT 4, 
    [intMinUniqueChar] INT NOT NULL DEFAULT 0, 
    [intMinLowerCaseChar] INT NOT NULL DEFAULT 0, 
    [intMinUpperCaseChar] INT NOT NULL DEFAULT 0, 
    [intMinNumericChar] INT NOT NULL DEFAULT 0, 
    [intMinSpecialCharacter] INT NOT NULL DEFAULT 0, 
    [ysnReqTwoFactorAuth] BIT NOT NULL DEFAULT 0, 
    [intLockIdleUserAfter] INT NOT NULL DEFAULT 0, 
    [intReqCaptchaAfter] INT NOT NULL DEFAULT 3, 
    [intLockUserAccountAfter] INT NOT NULL DEFAULT 10, 
    [intLockUserAccountDuration] INT NOT NULL DEFAULT 30, 
    [strAfterHoursLogin] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL DEFAULT 'Allow' , 
    [dtmBusHoursStartTime] DATETIME NOT NULL DEFAULT CAST(CAST(GETDATE() AS DATE) AS DATETIME) + '07:00:00', 
    [dtmBusHoursEndTime] DATETIME NOT NULL DEFAULT CAST(CAST(GETDATE() AS DATE) AS DATETIME) + '18:00:00', 
    [intEntitySupervisorId] INT NULL, 
    [intConcurrencyId] INT NOT NULL DEFAULT 1, 
    CONSTRAINT [FK_tblSMSecurityPolicy_tblEMEntity] FOREIGN KEY ([intEntitySupervisorId]) REFERENCES [tblEMEntity]([intEntityId])
)
