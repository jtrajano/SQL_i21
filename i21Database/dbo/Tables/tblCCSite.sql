CREATE TABLE [dbo].[tblCCSite]
(
	[intSiteId] INT NOT NULL IDENTITY,	
	[strSite] nvarchar(50) COLLATE Latin1_General_CI_AS NOT NULL,
	[strSiteDescription] nvarchar(50) COLLATE Latin1_General_CI_AS NOT NULL,
	[intPaymentMethodId] INT NOT NULL,
	[intCustomerId] INT NULL,
	[intSort] [int] NULL,
	[intConcurrencyId] [int] NOT NULL,
	CONSTRAINT [PK_tblCCSite] PRIMARY KEY ([intSiteId]),
	CONSTRAINT [AK_tblCCSite] UNIQUE ([strSite]),
	CONSTRAINT [FK_tblCCSite_tblARCustomer_intCustomerId] FOREIGN KEY ([intCustomerId]) REFERENCES [dbo].[tblARCustomer] ([intEntityCustomerId]),	
	CONSTRAINT [FK_tblCCSite_tblSMPaymentMethod_intPaymentMethodId] FOREIGN KEY (intPaymentMethodId) REFERENCES [dbo].[tblSMPaymentMethod] ([intPaymentMethodID])
)
