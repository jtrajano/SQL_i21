
--2 ENTRY PER ADJUSTMENT (1 FOR PRINCIPAL AND FOR RELATED)

CREATE TABLE [dbo].[tblCMBankTransactionAdjustment](
	[intAdjustmentId] [int] IDENTITY(1,1) NOT NULL,
	[intRelatedId] [int] NULL,
	[intTransactionId] [int] NULL,
    [strType] NVARCHAR(10) COLLATE Latin1_General_CI_AS NOT NULL,
 CONSTRAINT [PK_tblCMBankTransactionAdjustment] PRIMARY KEY CLUSTERED (	[intAdjustmentId] ASC)
) 
GO

