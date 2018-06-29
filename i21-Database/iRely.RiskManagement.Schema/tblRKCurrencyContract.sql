CREATE TABLE [dbo].[tblRKCurrencyContract]
(
	[intCurrencyContractId] [int] IDENTITY(1,1) NOT NULL,
	[intConcurrencyId] [int] NOT NULL,
	[strCurrencyContractNumber] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL, 
    [dtmContractDate] DATETIME NOT NULL, 
    [intContractTypeId] INT NOT NULL, 
    [intBankId] INT NOT NULL, 
    [dtmMaturityDate] DATETIME NOT NULL, 
    [strBankRef] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL, 
    [intCurrencyExchangeRateTypeId] INT NOT NULL, 
    [strBaseCurrency] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL, 
    [strMatchCurrency] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL, 
    [dblContractAmount] NUMERIC(18, 6) NOT NULL, 
    [dblExchangeRate] NUMERIC(18, 6) NOT NULL, 
    [dblMatchAmount] NUMERIC(18, 6) NOT NULL, 
    [dblAllocatedAmount] NUMERIC(18, 6) NULL, 
    [dblUnAllocatedAmount] NUMERIC(18, 6) NULL, 
    [dblSpotRate] NUMERIC(18, 6) NOT NULL, 
    [strStatus] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL, 
    [ysnSwap] BIT NOT NULL,

    CONSTRAINT [PK_tblRKCurrencyContract_intCurrencyContractId] PRIMARY KEY CLUSTERED ([intCurrencyContractId] ASC),
	CONSTRAINT [FK_tblRKCurrencyContract_tblCTContractType_intContractTypeId] FOREIGN KEY([intContractTypeId]) REFERENCES [dbo].[tblCTContractType] ([intContractTypeId]),
	CONSTRAINT [FK_tblRKCurrencyContract_tblCMBank_intUnitMeasureId] FOREIGN KEY([intBankId]) REFERENCES [dbo].[tblCMBank] ([intBankId]), 
	CONSTRAINT [FK_tblRKCurrencyContract_tblSMCurrencyExchangeRateType_intCurrencyExchangeRateTypeId] FOREIGN KEY([intCurrencyExchangeRateTypeId]) REFERENCES [dbo].[tblSMCurrencyExchangeRateType] ([intCurrencyExchangeRateTypeId]), 
    CONSTRAINT [UK_tblRKCurrencyContract_strCurrencyContractNumber] UNIQUE ([strCurrencyContractNumber])
)