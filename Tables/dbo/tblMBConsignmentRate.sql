CREATE TABLE [dbo].[tblMBConsignmentRate]
(
	[intConsignmentRateId] INT NOT NULL IDENTITY, 
    [intConsignmentGroupId] INT NOT NULL, 
    [dtmEffectiveDate] DATETIME NOT NULL DEFAULT (GETDATE()), 
    [intSort] INT NULL, 
    [intConcurrencyId] INT NULL DEFAULT ((0)), 
    CONSTRAINT [PK_tblMBConsignmentRate] PRIMARY KEY ([intConsignmentRateId]), 
    CONSTRAINT [FK_tblMBConsignmentRate_tblMBConsignmentGroup] FOREIGN KEY ([intConsignmentGroupId]) REFERENCES [tblMBConsignmentGroup]([intConsignmentGroupId])
)
