﻿CREATE TABLE [dbo].[tblAPPaymentDetail] (
    [intPaymentDetailId] INT             IDENTITY (1, 1) NOT NULL,
    [intPaymentId]       INT             NOT NULL,
    [intBillId]          INT             NULL,
    [intAccountId]       INT             NOT NULL,
    [dblDiscount]        DECIMAL (18, 6) NOT NULL DEFAULT 0,
    [dblAmountDue]       DECIMAL (18, 6) NOT NULL DEFAULT 0,
    [dblPayment]         DECIMAL (18, 6) NOT NULL DEFAULT 0,
    [dblInterest]        DECIMAL (18, 6) NOT NULL DEFAULT 0,
    [dblTotal] DECIMAL(18, 6) NOT NULL DEFAULT 0, 
    [intConcurrencyId] INT NOT NULL DEFAULT 0, 
	[intPayScheduleId] INT NULL,
	-- [ysnPaySchedule] BIT NOT NULL DEFAULT(0),
	[ysnOffset] BIT NOT NULL DEFAULT(0),
    [dblWithheld] DECIMAL(18, 6) NOT NULL DEFAULT 0, 
    [intInvoiceId] INT NULL , 
	[intOrigBillId] INT NULL , 
	[intOrigInvoiceId] INT NULL,
    CONSTRAINT [PK_dbo.tblAPPaymentDetail] PRIMARY KEY CLUSTERED ([intPaymentDetailId] ASC),
    CONSTRAINT [FK_dbo.tblAPPaymentDetail_dbo.tblAPPayments_intPaymentId] FOREIGN KEY ([intPaymentId]) REFERENCES [dbo].[tblAPPayment] ([intPaymentId]) ON DELETE CASCADE,
	CONSTRAINT [FK_tblAPPaymentDetail_tblAPBill] FOREIGN KEY ([intBillId]) REFERENCES [tblAPBill]([intBillId]),
	CONSTRAINT [FK_tblAPPaymentDetail_tblARInvoice] FOREIGN KEY ([intInvoiceId]) REFERENCES [tblARInvoice]([intInvoiceId]),
	CONSTRAINT [FK_tblAPPaymentDetail_tblGLAccount] FOREIGN KEY ([intAccountId]) REFERENCES [tblGLAccount]([intAccountId])
);


GO


CREATE NONCLUSTERED INDEX [IX_tblAPPaymentDetail_intPaymentId_intBillId] ON [dbo].[tblAPPaymentDetail] 
(
	[intBillId] ASC,
	[intPaymentId] ASC
)
WITH (SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF) ON [PRIMARY]
GO


CREATE NONCLUSTERED INDEX [IX_tblAPPaymentDetail_intBillId] ON [dbo].[tblAPPaymentDetail] 
(
	[intBillId] ASC
)
WITH (SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_tblAPPaymentDetail_intOrigBillId] ON [dbo].[tblAPPaymentDetail] 
(
	[intOrigBillId] ASC
)
WITH (SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF) ON [PRIMARY]
GO

CREATE NONCLUSTERED INDEX [IX_rptAging_1] ON [dbo].[tblAPPaymentDetail]
(
	[intBillId] ASC,
	[intAccountId] ASC
)
INCLUDE ( 	[intPaymentId],
	[dblDiscount],
	[dblPayment],
	[dblInterest],
	[dblWithheld]) WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF) ON [PRIMARY]
GO


CREATE NONCLUSTERED INDEX [IX_tblAPPaymentDetail_intPaymentId_intInvoiceId]
ON [dbo].[tblAPPaymentDetail] ([intPaymentId],[intInvoiceId])
INCLUDE ([intBillId],[dblPayment],[dblWithheld])
GO

CREATE TRIGGER trg_tblAPPaymentDetail
ON dbo.tblAPPaymentDetail
AFTER DELETE AS
BEGIN
INSERT INTO tblAPPaymentDetailDeleted
(
	[intPaymentDetailId]	,
	[intPaymentId]			,
	[intBillId]         	,
	[intAccountId]      	,
	[dblDiscount]       	,
	[dblAmountDue]      	,
	[dblPayment]        	,
	[dblInterest]       	,
	[dblTotal] 				,
	[intConcurrencyId] 		,
	[dblWithheld] 			,
	[intInvoiceId]			,
	[intOrigBillId]			,
	[intOrigInvoiceId]
)
SELECT 
	[intPaymentDetailId]	,
	[intPaymentId]			,
	[intBillId]         	,
	[intAccountId]      	,
	[dblDiscount]       	,
	[dblAmountDue]      	,
	[dblPayment]        	,
	[dblInterest]       	,
	[dblTotal] 				,
	[intConcurrencyId] 		,
	[dblWithheld] 			,
	[intInvoiceId]			,
	[intOrigBillId]			,
	[intOrigInvoiceId]
FROM DELETED
END
GO