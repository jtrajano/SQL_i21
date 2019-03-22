CREATE TABLE dbo.[tblRKCurrencyContractSwapped]
(
	[intCurrencyContractSwapId] [int] IDENTITY(1,1) NOT NULL,
	[intConcurrencyId] [int] NOT NULL,
	[intCurrencyContractId] int NOT NULL, 
	[intSwapContractTypeId] INT NULL, 
    [dtmSwapMaturityDate] DATETIME NULL, 
    [dblSwapContractAmount] NUMERIC(18, 6) NULL, 
    [dblSwapExchangeRate] NUMERIC(18, 6) NULL, 
    [dblSwapMatchAmount] NUMERIC(18, 6) NULL, 
    [strSwapStatus] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [strSwapRemarks] NVARCHAR(250) COLLATE Latin1_General_CI_AS NULL, 
    [ysnSwapConfirm] BIT NULL,  

    CONSTRAINT [PK_tblRKCurrencyContractSwapped_intCurrencyContractSwapId] PRIMARY KEY CLUSTERED ([intCurrencyContractSwapId] ASC),
	CONSTRAINT [FK_tblRKCurrencyContractSwapped_tblRKCurrencyContract_intCurrencyContractId] FOREIGN KEY([intCurrencyContractId]) REFERENCES [dbo].[tblRKCurrencyContract] ([intCurrencyContractId]) ON DELETE CASCADE,
)    
