﻿CREATE TYPE [dbo].[ServiceChargeInvoiceParam] AS TABLE(
	[intInvoiceId] [INT] NOT NULL,
	[dtmForgiveDate] [DATETIME] NULL,
	[dtmToday] [datetime]  NOT NULL
)
GO