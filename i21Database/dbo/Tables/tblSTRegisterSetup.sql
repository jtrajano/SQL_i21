CREATE TABLE [dbo].[tblSTRegisterSetup]
(
    [intRegisterSetupId] INT NOT NULL IDENTITY,
    [strRegisterName] NVARCHAR(15) COLLATE Latin1_General_CI_AS NOT NULL,
    [strXmlGateWayVersion] NVARCHAR(10) COLLATE Latin1_General_CI_AS NOT NULL,
    CONSTRAINT [PK_tblSTRegisterSetup] PRIMARY KEY CLUSTERED ([intRegisterSetupId] ASC),
    CONSTRAINT [AK_tblSTRegisterSetup_strRegisterName_strXmlGateWayVersion] UNIQUE ([strRegisterName], [strXmlGateWayVersion])  
)