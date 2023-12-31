﻿CREATE TABLE [dbo].[tblCRMHoursWorked]
(
	[intHoursWorkedId] [int] IDENTITY(1,1) NOT NULL,
	[intTransactionId] [int] NOT NULL,
	[intEntityId] [int] NOT NULL,
	[dblHours] [numeric](18, 6) NOT NULL,
	[dtmDate] [datetime] not null,
	[intItemId] [int] null,
	[ysnBillable] [bit] not null default(0),
	[dblRate] [numeric](18, 6) NOT NULL DEFAULT 0.00,
	[intInvoiceId] [int] null,
	[strJiraKey] [nvarchar](max) COLLATE Latin1_General_CI_AS NULL,
	[strDescription] [nvarchar](max) COLLATE Latin1_General_CI_AS NULL,
	[intCreatedByEntityId] [int] NOT NULL,
	[dtmCreatedDate] [datetime] NOT NULL,
	[intConcurrencyId] [int] NOT NULL DEFAULT 1,
	CONSTRAINT [PK_tblCRMHoursWorked_intHoursWorkedId] PRIMARY KEY CLUSTERED ([intHoursWorkedId] ASC),
	CONSTRAINT [FK_tblCRMHoursWorked_tblSMTransaction_intTransactionId] FOREIGN KEY ([intTransactionId]) REFERENCES [dbo].[tblSMTransaction] ([intTransactionId]),
	CONSTRAINT [FK_tblCRMHoursWorked_tblEMEntity_intEntityId] FOREIGN KEY ([intEntityId]) REFERENCES [dbo].[tblEMEntity] ([intEntityId]),
	CONSTRAINT [FK_tblCRMHoursWorked_tblICItem_intItemId] FOREIGN KEY ([intItemId]) REFERENCES [dbo].[tblICItem] ([intItemId]),
	CONSTRAINT [FK_tblCRMHoursWorked_tblARInvoice_intInvoiceId] FOREIGN KEY ([intInvoiceId]) REFERENCES [dbo].[tblARInvoice] ([intInvoiceId]),
	CONSTRAINT [FK_tblCRMHoursWorked_tblEMEntity_intCreatedByEntityId] FOREIGN KEY ([intCreatedByEntityId]) REFERENCES [dbo].[tblEMEntity] ([intEntityId])
)
