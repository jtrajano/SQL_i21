CREATE TABLE [dbo].[tblCFFee] (
    [intFeeId]                INT             IDENTITY (1, 1) NOT NULL,
    [strFee]                  NVARCHAR (250)  COLLATE Latin1_General_CI_AS NULL,
    [strFeeDescription]       NVARCHAR (250)  COLLATE Latin1_General_CI_AS NULL,
    [strCalculationType]      NVARCHAR (250)  COLLATE Latin1_General_CI_AS NULL,
    [strCalculationCard]      NVARCHAR (250)  COLLATE Latin1_General_CI_AS NULL,
    [strCalculationFrequency] NVARCHAR (250)  COLLATE Latin1_General_CI_AS NULL,
    [ysnExtendedRemoteTrans]  BIT             NULL,
    [ysnRemotesTrans]         BIT             NULL,
    [ysnLocalTrans]           BIT             NULL,
    [ysnForeignTrans]         BIT             NULL,
    [intNetworkId]            INT             NULL,
    [intCardTypeId]           INT             NULL,
    [intMinimumThreshold]     INT             NULL,
    [intMaximumThreshold]     INT             NULL,
    [dblFeeRate]              NUMERIC (18, 6) NULL,
    [intGLAccountId]          INT             NULL,
	[intItemId]			      INT			  NULL,
    [intRestrictedByProduct]  INT             NULL,
    [intConcurrencyId]        INT             CONSTRAINT [DF_tblCFFee_intConcurrencyId] DEFAULT ((1)) NULL,
    CONSTRAINT [PK_tblCFFee] PRIMARY KEY CLUSTERED ([intFeeId] ASC),
    CONSTRAINT [FK_tblCFFee_tblCFCardType] FOREIGN KEY ([intCardTypeId]) REFERENCES [dbo].[tblCFCardType] ([intCardTypeId]),
    CONSTRAINT [FK_tblCFFee_tblGLAccount] FOREIGN KEY ([intGLAccountId]) REFERENCES [dbo].[tblGLAccount] ([intAccountId])
);

GO

CREATE UNIQUE NONCLUSTERED INDEX tblCFFee_UniqueFee
	ON tblCFFee (strFee);

