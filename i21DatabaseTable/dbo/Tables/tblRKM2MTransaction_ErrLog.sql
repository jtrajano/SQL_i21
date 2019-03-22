CREATE TABLE [dbo].[tblRKM2MTransaction_ErrLog]
(
	[intTransactionImportErrId] int identity(1,1) NOT NULL,
	[intConcurrencyId] int,
	[strFutMarketName] nvarchar(30) COLLATE Latin1_General_CI_AS NULL,
	[strCommodityCode] nvarchar(50) COLLATE Latin1_General_CI_AS NULL,
	[strItemNo] nvarchar(40) COLLATE Latin1_General_CI_AS NULL,
	[strCurrency] nvarchar(40) COLLATE Latin1_General_CI_AS NULL,
	[dblBasis] numeric(18, 6) NULL, 
	[strUnitMeasure] nvarchar(50) COLLATE Latin1_General_CI_AS NULL,
	[strErrMessage] nvarchar(max) COLLATE Latin1_General_CI_AS NULL,

	CONSTRAINT [PK_tblRKM2MTransaction_ErrLog_intTransactionImportErrId] PRIMARY KEY (intTransactionImportErrId),	
)
