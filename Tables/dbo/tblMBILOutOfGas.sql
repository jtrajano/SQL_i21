CREATE TABLE [dbo].[tblMBILOutOfGas]
(
	[intOutOfGasId] INT NOT NULL IDENTITY, 
    [intEntityId] INT NOT NULL, 
    [intSiteId] INT NOT NULL, 
    [ysnLeakTest] BIT NULL DEFAULT ((0)), 
    [dblPressureReading] NUMERIC(18, 6) NULL DEFAULT ((0)), 
    [dblMinutesHeld] NUMERIC(18, 6) NULL DEFAULT ((0)), 
    [ysnTaggedLocked] BIT NULL DEFAULT ((0)), 
    [ysnCustomerNotified] BIT NULL DEFAULT ((0)), 
    [ysnAppliancesLit] BIT NULL DEFAULT ((0)), 
    [strNotes] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL, 
    [intConcurrencyId] INT NULL DEFAULT ((1)), 
    CONSTRAINT [PK_tblMBILOutOfGas] PRIMARY KEY ([intOutOfGasId]), 
    CONSTRAINT [FK_tblMBILOutOfGas_tblARCustomer] FOREIGN KEY ([intEntityId]) REFERENCES [tblARCustomer]([intEntityId]), 
    CONSTRAINT [FK_tblMBILOutOfGas_tblTMSite] FOREIGN KEY ([intSiteId]) REFERENCES [tblTMSite]([intSiteID])
)
