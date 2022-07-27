

CREATE TABLE [dbo].[tblCMBorrowingFacilityLimitDetail](
	intBorrowingFacilityLimitDetailId        INT IDENTITY(1,1)   NOT NULL,
	intBorrowingFacilityLimitId              INT                 NOT NULL,
    strLimitDescription				         NVARCHAR(100)       COLLATE Latin1_General_CI_AS NOT NULL,
    dblLimit	                             DECIMAL(18,6)       NOT NULL,
	dblHaircut	                             DECIMAL(18,6)       NOT NULL,
	ysnDefault								 BIT				 NOT NULL,
	intDaysInSublimit						 INT				 NOT NULL,
	intBankValuationRuleId					 INT				 NOT NULL,
    intConcurrencyId                    INT                 NOT NULL,
 CONSTRAINT [PK_BorrowingFacilityLimitDetailId] PRIMARY KEY CLUSTERED 
(
	intBorrowingFacilityLimitDetailId ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[tblCMBorrowingFacilityLimitDetail] ADD  CONSTRAINT [FK_tblCMBorrowingFacilityLimitDetail_tblCMBorrowingFacilityLimit] 
FOREIGN KEY(intBorrowingFacilityLimitId)
REFERENCES [dbo].[tblCMBorrowingFacilityLimit] (intBorrowingFacilityLimitId)
ON DELETE CASCADE
GO

ALTER TABLE [dbo].[tblCMBorrowingFacilityLimitDetail] CHECK CONSTRAINT [FK_tblCMBorrowingFacilityLimitDetail_tblCMBorrowingFacilityLimit] 
GO







