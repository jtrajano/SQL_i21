CREATE TABLE [dbo].[tblCTContractOptDetail](
	[intContractOptDetailId] [int] IDENTITY(1,1) NOT NULL,
	[intConcurrencyId] [int] NOT NULL,
	[intContractOptHeaderId] [int] NOT NULL,
	[intBuySell] [int] NOT NULL,
	[intPutCall] [int] NOT NULL,
 CONSTRAINT [PK_tblCTContractOptDetail_intContractOptDetailId] PRIMARY KEY CLUSTERED 
(
	[intContractOptDetailId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

ALTER TABLE [dbo].[tblCTContractOptDetail]  WITH CHECK ADD  CONSTRAINT [FK_tblCTContractOptDetail_tblCTContractOptHeader_intContractOptHeaderId] FOREIGN KEY([intContractOptHeaderId])
REFERENCES [dbo].[tblCTContractOptHeader] ([intContractOptHeaderId]) ON DELETE CASCADE
GO

ALTER TABLE [dbo].[tblCTContractOptDetail] CHECK CONSTRAINT [FK_tblCTContractOptDetail_tblCTContractOptHeader_intContractOptHeaderId]
GO

