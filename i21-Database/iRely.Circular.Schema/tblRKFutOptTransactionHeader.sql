CREATE TABLE [dbo].[tblRKFutOptTransactionHeader]
(
	[intFutOptTransactionHeaderId] INT IDENTITY(1,1) NOT NULL,
	[intConcurrencyId] INT NOT NULL, 
	[dtmTransactionDate] datetime NULL,
	[intSelectedInstrumentTypeId] int NULL,
	[strSelectedInstrumentType] [nvarchar](30) COLLATE Latin1_General_CI_AS NOT NULL,
	[intCompanyId] INT NULL,
	[intFutOptTransactionHeaderRefId] INT NULL,
	CONSTRAINT [PK_tblRKFutOptTransactionHeader_intFutOptTransactionHeaderId] PRIMARY KEY (intFutOptTransactionHeaderId)
)
