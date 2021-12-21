

CREATE TABLE [dbo].[tblCMBorrowingFacilityLimit](
	intBorrowingFacilityLimitId        INT IDENTITY(1,1)   NOT NULL,
	intBorrowingFacilityId              INT                 NOT NULL,
    strBorrowingFacilityLimit           NVARCHAR(40)        NOT NULL,
    dblLimit                            DECIMAL(18,6)       NOT NULL,
    intConcurrencyId                    INT                 NOT NULL,
 CONSTRAINT [PK_BorrowingFacilityLimitId] PRIMARY KEY CLUSTERED 
(
	[intBorrowingFacilityLimitId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[tblCMBorrowingFacilityLimit]  WITH CHECK ADD  CONSTRAINT [FK_tblCMBorrowingFacilityLimit_tblCMBorrowingFacility] 
FOREIGN KEY([intBorrowingFacilityId])
REFERENCES [dbo].[tblCMBorrowingFacility] ([intBorrowingFacilityId])
GO

ALTER TABLE [dbo].[tblCMBorrowingFacilityLimit] CHECK CONSTRAINT [FK_tblCMBorrowingFacilityLimit_tblCMBorrowingFacility]
GO






