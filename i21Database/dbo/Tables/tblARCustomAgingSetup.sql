CREATE TABLE [dbo].[tblARCustomAgingSetup]
(
    [intCustomAgingSetupId]         INT NOT NULL IDENTITY, 
    [intEntityId]                   INT NULL,
    [intConcurrencyId]              INT NULL DEFAULT ((1)), 
    CONSTRAINT [PK_tblARCustomAgingSetup] PRIMARY KEY ([intCustomAgingSetupId])
)