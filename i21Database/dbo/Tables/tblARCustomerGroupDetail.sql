﻿CREATE TABLE [dbo].[tblARCustomerGroupDetail] (
    [intCustomerGroupDetailId] INT IDENTITY (1, 1) NOT NULL,
    [intCustomerGroupId]       INT NOT NULL,
    [intEntityId]              INT NOT NULL,
    [ysnSpecialPricing]        BIT CONSTRAINT [DF_tblARCustomerGroupDetail_ysnSpecialPricing] DEFAULT ((0)) NOT NULL,
    [ysnContract]              BIT CONSTRAINT [DF_tblARCustomerGroupDetail_ysnContract] DEFAULT ((0)) NOT NULL,
    [ysnBuyback]               BIT CONSTRAINT [DF_tblARCustomerGroupDetail_ysnBuyback] DEFAULT ((0)) NOT NULL,
    [ysnQuote]                 BIT CONSTRAINT [DF_tblARCustomerGroupDetail_ysnQuote] DEFAULT ((0)) NOT NULL,
	[ysnVolumeDiscount]		   BIT CONSTRAINT [DF_tblARCustomerGroupDetail_ysnVolumeDiscount] DEFAULT ((0)) NOT NULL,
    [ysnAutomatedQuoting]      BIT CONSTRAINT [DF_tblARCustomerGroupDetail_ysnAutomatedQuoting] DEFAULT ((0)) NOT NULL,
	[intCompanyId]			   INT NULL,
    [intConcurrencyId]         INT NOT NULL,
    -- MON
    ysnAutomatedQuoting BIT null,
    CONSTRAINT [PK_tblARCustomerGroupDetail_1] PRIMARY KEY CLUSTERED ([intCustomerGroupDetailId] ASC),	
	CONSTRAINT [FK_tblARCustomerGroupDetail_tblARCustomerGroup] FOREIGN KEY ([intCustomerGroupId]) REFERENCES [dbo].[tblARCustomerGroup] ([intCustomerGroupId]) ON DELETE CASCADE,
);

