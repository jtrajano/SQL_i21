CREATE TABLE [dbo].[tblPATCancelEquityDetail]
(
	[intCancelEquityDetailId] INT NOT NULL IDENTITY, 
    [intCancelEquityId] INT NULL, 
    [intFiscalYearId] INT NULL, 
    [intCustomerId] INT NULL,
	[strEquityType] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [intRefundTypeId] INT NULL, 
    [dblQuantityAvailable] NUMERIC(18, 6) NULL, 
    [dblQuantityCancelled] NUMERIC(18, 6) NULL, 
    [intConcurrencyId] INT NULL DEFAULT 0, 
    CONSTRAINT [PK_tblPATCancelEquityDetail_intCancelEquityDetailId] PRIMARY KEY ([intCancelEquityDetailId]), 
    CONSTRAINT [FK_tblPATCancelEquityDetail_tblPATCancelEquity_intCancelEquityId] FOREIGN KEY ([intCancelEquityId]) REFERENCES [tblPATCancelEquity]([intCancelEquityId]) ON DELETE CASCADE
)
