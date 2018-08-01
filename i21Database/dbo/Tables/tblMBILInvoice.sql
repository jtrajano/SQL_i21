CREATE TABLE [dbo].[tblMBILInvoice](
	[intInvoiceId] INT IDENTITY NOT NULL,
	[strInvoiceNo] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL,
	[intOrderId] INT NOT NULL,
	[intEntityCustomerId] INT NULL,
	[intLocationId] INT NULL,
	[strType] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[dtmDeliveryDate] DATETIME NULL,
	[dtmInvoiceDate] DATETIME NULL,
	[intDriverId] INT NULL,
	[intShiftId] INT NOT NULL,
	[strComments] NVARCHAR (400) COLLATE Latin1_General_CI_AS NULL,
	[dblTotal] NUMERIC (18, 6) NULL,
	[intTermId] INT NULL,
	[ysnPosted]	BIT DEFAULT ((0)) NULL,
	[intConcurrencyId] INT DEFAULT ((1)) NULL,
	CONSTRAINT [PK_tblMBILInvoice] PRIMARY KEY CLUSTERED ([intInvoiceId] ASC)
)