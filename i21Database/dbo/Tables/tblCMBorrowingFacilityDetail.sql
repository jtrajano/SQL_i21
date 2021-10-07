
CREATE TABLE [dbo].[tblCMBorrowingFacilityDetail](
	intBorrowingFacilityDetailId        INT IDENTITY(1,1)   NOT NULL,
	intBorrowingFacilityId              INT                 NOT NULL,
    intBankAccountId                    INT                 NOT NULL,
    dblLimit                            DECIMAL(18,2)       NOT NULL,
    dblRate                             DECIMAL(18,6)       NOT NULL,
    dblFacilityLimit                    DECIMAL(18,6)       NOT NULL,
    intTradeTypeLimitId                 TINYINT             NOT NULL,
    dblHairCut                          DECIMAL(5,2)        NOT NULL,
    intDaysInCycle                      SMALLINT            NOT NULL,
    intConcurrencyId                    INT                 NOT NULL,
 CONSTRAINT [PK_BorrowingFacilityDetailId] PRIMARY KEY CLUSTERED 
(
	[intBorrowingFacilityDetailId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[tblCMBorrowingFacilityDetail]  WITH CHECK ADD  CONSTRAINT [FK_tblCMBorrowingFacilityDetail_tblCMBorrowingFacility] 
FOREIGN KEY([intBorrowingFacilityId])
REFERENCES [dbo].[tblCMBorrowingFacility] ([intBorrowingFacilityId])
GO

ALTER TABLE [dbo].[tblCMBorrowingFacilityDetail] CHECK CONSTRAINT [FK_tblCMBorrowingFacilityDetail_tblCMBorrowingFacility]
GO


