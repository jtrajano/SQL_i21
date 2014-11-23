CREATE TABLE [dbo].[tblCTDeferredPay](
	[intDeferredPayId] [int] IDENTITY(1,1) NOT NULL,
	[intConcurrencyId] [int] NOT NULL,
	[dtmLastCalcDate] [datetime] NULL,
	[ysnAdjSettle] [bit] NOT NULL CONSTRAINT [DF_tblCTDeferredPay_ysnAdjSettle]  DEFAULT ((1)),
 CONSTRAINT [PK_tblCTDeferredPay_intDeferredPayId] PRIMARY KEY CLUSTERED 
(
	[intDeferredPayId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

