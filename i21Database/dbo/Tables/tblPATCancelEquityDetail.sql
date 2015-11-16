CREATE TABLE [dbo].[tblPATCancelEquityDetail]
(
	[intCancelDetailId] INT NOT NULL IDENTITY, 
    [intCancelId] INT NULL, 
    [intFiscalYearId] INT NULL, 
    [intCustomerId] INT NULL, 
    [intRefundTypeId] INT NULL, 
    [dblQuantityAvailable] NUMERIC(18, 6) NULL, 
    [strCancelBy] NVARCHAR(50)  COLLATE Latin1_General_CI_AS NULL, 
    [dblCancelByPercentage] NUMERIC(18, 6) NULL, 
    [dblQuantityCancelled] NUMERIC(18, 6) NULL, 
    [intConcurrencyId] INT NULL DEFAULT 0, 
    CONSTRAINT [PK_tblPATCancelEquityDetail] PRIMARY KEY ([intCancelDetailId]), 
    CONSTRAINT [FK_tblPATCancelEquityDetail_tblPATCancelEquity] FOREIGN KEY ([intCancelId]) REFERENCES [tblPATCancelEquity]([intCancelId]) 
)
