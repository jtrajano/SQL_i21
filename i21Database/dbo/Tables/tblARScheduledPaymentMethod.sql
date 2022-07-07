CREATE TABLE [dbo].[tblARScheduledPaymentMethod] (
    [intScheduledPaymentMethodId]		INT				IDENTITY (1, 1) NOT NULL,
    [intEntityId]				        INT				NOT NULL,
    [intEntityCardInfoId]				INT				NULL,
	[intBankAccountId]					INT				NULL,
    [strPaymentMethodType]				NVARCHAR (20)	COLLATE Latin1_General_CI_AS NULL,
    [ysnAutoPay]						BIT				NOT NULL DEFAULT (0),
    [intDayOfMonth]						INT				NULL,
    [intConcurrencyId]					INT             NOT NULL DEFAULT ((0)),
    CONSTRAINT [PK_tblARScheduledPaymentMethod_intScheduledPaymentMethodId] PRIMARY KEY CLUSTERED ([intScheduledPaymentMethodId] ASC),
	CONSTRAINT [FK_tblARScheduledPaymentMethod_tblEMEntityCardInformation] FOREIGN KEY ([intEntityCardInfoId]) REFERENCES tblEMEntityCardInformation ([intEntityCardInfoId]) ON DELETE CASCADE,
    CONSTRAINT [FK_tblARScheduledPaymentMethod_tblARCustomer] FOREIGN KEY ([intEntityId]) REFERENCES tblARCustomer ([intEntityId]) ON DELETE CASCADE,
	CONSTRAINT [FK_tblARScheduledPaymentMethod_tblCMBankAccount] FOREIGN KEY ([intBankAccountId]) REFERENCES tblCMBankAccount([intBankAccountId]) ON DELETE CASCADE
);
