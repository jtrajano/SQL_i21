CREATE TABLE [dbo].[tblCTValuationGroupDetail]
(
	[intValuationGroupDetailId] INT IDENTITY NOT NULL , 
    [intValuationGroupId] INT NOT NULL, 
    [dblPremium] NUMERIC(18, 6) NULL, 
    [intCurrencyId] INT NULL, 
    [intUOMId] INT NULL, 
    [dtmStartDate] DATETIME NULL, 
    [dtmEndDate] DATETIME NULL, 
    [intConcurrencyId] INT NULL DEFAULT ((0)), 
    CONSTRAINT [PK_tblCTValuationGroupDetail] PRIMARY KEY ([intValuationGroupDetailId]), 
    CONSTRAINT [FK_tblCTValuationGroupDetail_tblCTValuationGroup] FOREIGN KEY ([intValuationGroupDetailId]) REFERENCES [tblCTValuationGroup]([intValuationGroupId]) ON DELETE CASCADE, 
    CONSTRAINT [FK_tblCTValuationGroupDetail_tblSMCurrency] FOREIGN KEY ([intCurrencyId]) REFERENCES [tblSMCurrency]([intCurrencyID]), 
    CONSTRAINT [FK_tblCTValuationGroupDetail_tblICUnitMeasure] FOREIGN KEY ([intUOMId]) REFERENCES [tblICUnitMeasure]([intUnitMeasureId])
)
