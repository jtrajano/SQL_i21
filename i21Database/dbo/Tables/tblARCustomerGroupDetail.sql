CREATE TABLE [dbo].[tblARCustomerGroupDetail] (
    [intCustomerGroupDetailId] INT IDENTITY (1, 1) NOT NULL,
    [intCustomerGroupId]       INT NOT NULL,
    [intEntityId]              INT NOT NULL,
    [ysnSpecialPricing]        BIT CONSTRAINT [DF_tblARCustomerGroupDetail_ysnSpecialPricing] DEFAULT ((0)) NOT NULL,
    [ysnContract]              BIT CONSTRAINT [DF_tblARCustomerGroupDetail_ysnContract] DEFAULT ((0)) NOT NULL,
    [ysnBuyback]               BIT CONSTRAINT [DF_tblARCustomerGroupDetail_ysnBuyback] DEFAULT ((0)) NOT NULL,
    [ysnQuote]                 BIT CONSTRAINT [DF_tblARCustomerGroupDetail_ysnQuote] DEFAULT ((0)) NOT NULL,
    [intConcurrencyId]         INT NOT NULL,
    CONSTRAINT [PK_tblARCustomerGroupDetail_1] PRIMARY KEY CLUSTERED ([intCustomerGroupDetailId] ASC)
);

