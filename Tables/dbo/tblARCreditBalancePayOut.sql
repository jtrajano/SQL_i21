CREATE TABLE [dbo].[tblARCreditBalancePayOut]
(
    [intCreditBalancePayOutId]      INT                 IDENTITY (1, 1) NOT NULL,
    [dtmAsOfDate]                   DATETIME            NULL,
    [ysnPayBalance]                 BIT                 CONSTRAINT [DF_tblARCreditBalancePayOut_ysnPayBalance] DEFAULT ((0)) NOT NULL,
    [ysnPreview]                    BIT                 CONSTRAINT [DF_tblARCreditBalancePayOut_ysnPreview] DEFAULT ((0)) NOT NULL,
    [dblOpenARBalance]              NUMERIC (18, 6)     NULL DEFAULT 0,
    [intEntityId]                   INT                 NOT NULL,
	[dtmDate]                       DATETIME            NOT NULL,
    [intConcurrencyId]              INT                 NOT NULL CONSTRAINT [DF_tblARCreditBalancePayOut_intConcurrencyId] DEFAULT ((0)),
	CONSTRAINT [PK_tblARCreditBalancePayOut_intCreditBalancePayOutId] PRIMARY KEY CLUSTERED ([intCreditBalancePayOutId] ASC),
	CONSTRAINT [FK_tblARCreditBalancePayOut_tblEMEntity_intEntityId] FOREIGN KEY (intEntityId) REFERENCES tblEMEntity(intEntityId)
)
