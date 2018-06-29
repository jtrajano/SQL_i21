CREATE TABLE [dbo].[tblRKElectronicUserInformation] 
(
	 [intElectronicUserInformationId] INT NOT NULL IDENTITY	
	,[strProviderUserId] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL DEFAULT ('')
	,[ysnUserIdInUse] BIT NULL DEFAULT 0 
    CONSTRAINT [PK_tblRKElectronicUserInformation_intElectronicUserInformationId] PRIMARY KEY ([intElectronicUserInformationId])
)
