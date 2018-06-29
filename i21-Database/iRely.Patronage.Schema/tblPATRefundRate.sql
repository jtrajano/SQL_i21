CREATE TABLE [dbo].[tblPATRefundRate](
	[intRefundTypeId] [int] NOT NULL IDENTITY,
	[strRefundType] [char](5) COLLATE Latin1_General_CI_AS NOT NULL,
	[strRefundDescription] [nvarchar](max) COLLATE Latin1_General_CI_AS NOT NULL,
	[ysnQualified] [bit] NULL,
	[intGeneralReserveId] [int] NOT NULL,
	[intAllocatedReserveId] [int] NOT NULL,
	[intUndistributedEquityId] [int] NOT NULL,
	[dblCashPayout] [numeric](18, 6) NOT NULL,
    [intConcurrencyId] INT NULL DEFAULT 0, 
    CONSTRAINT [PK_tblPATRefundRate] PRIMARY KEY ([intRefundTypeId]), 
    CONSTRAINT [AK_tblPATRefundRate_strRefundType] UNIQUE ([strRefundType]),
	CONSTRAINT [FK_tblPATRefundRate_tblGLAccount_intGeneralReserveId_intAccountId] FOREIGN KEY ([intGeneralReserveId]) REFERENCEs [tblGLAccount]([intAccountId]),
	CONSTRAINT [FK_tblPATRefundRate_tblGLAccount_intAllocatedReserveId_intAccountId] FOREIGN KEY ([intAllocatedReserveId]) REFERENCEs [tblGLAccount]([intAccountId]),
	CONSTRAINT [FK_tblPATRefundRate_tblGLAccount_intUndistributedEquityId_intAccountId] FOREIGN KEY ([intUndistributedEquityId]) REFERENCEs [tblGLAccount]([intAccountId])
)