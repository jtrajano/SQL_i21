CREATE TABLE [dbo].[tblSTRegisterSetup]
(
    [intRegisterSetupId]			INT NOT NULL IDENTITY,
    [strRegisterClass]				NVARCHAR(30) COLLATE Latin1_General_CI_AS NOT NULL,
    [strXmlVersion]					NVARCHAR(10) COLLATE Latin1_General_CI_AS NOT NULL,
	[intConcurrencyId]				INT				NOT NULL,
    CONSTRAINT [PK_tblSTRegisterSetup] PRIMARY KEY CLUSTERED ([intRegisterSetupId] ASC),
    CONSTRAINT [AK_tblSTRegisterSetup_strRegisterName_strXmlGateWayVersion] UNIQUE ([strRegisterClass], [strXmlVersion])  
)