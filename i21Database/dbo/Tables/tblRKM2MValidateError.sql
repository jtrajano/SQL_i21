CREATE TABLE [dbo].[tblRKM2MValidateError]
(
	[intM2MValidationErrorId] INT NOT NULL IDENTITY, 
    [intM2MHeaderId] INT NOT NULL, 
    [intContractDetailId] INT NULL, 
    [intContractHeaderId] INT NULL, 
    [intFutOptTransactionHeaderId] INT NULL, 
    [strLocationName] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [strCommodityCode] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [strContractType] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [strContractNumber] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [strEntityName] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [strItemNo] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [strPricingType] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [strFutureMonth] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [strFutMarketName] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [dtmLastTradingDate] DATETIME NULL, 
    [strPhysicalOrFuture] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [strErrorMsg] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [intConcurrencyId] INT NULL DEFAULT ((1)), 
    CONSTRAINT [PK_tblRKM2MValidateError] PRIMARY KEY ([intM2MValidationErrorId]), 
    CONSTRAINT [FK_tblRKM2MValidateError_tblRKM2MHeader] FOREIGN KEY ([intM2MHeaderId]) REFERENCES [tblRKM2MHeader]([intM2MHeaderId]) ON DELETE CASCADE
)
