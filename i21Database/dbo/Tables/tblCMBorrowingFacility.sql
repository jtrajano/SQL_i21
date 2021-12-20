CREATE TABLE tblCMBorrowingFacility(
  intBorrowingFacilityId              INT             IDENTITY(1,1) NOT NULL,
  strBorrowingFacilityId              NVARCHAR(20)    COLLATE Latin1_General_CI_AS NOT NULL,
  intBankId                           INT             NOT NULL,
  strBankReferenceNo                  NVARCHAR(30)    COLLATE Latin1_General_CI_AS NOT NULL,
  intPositionCurrencyId               INT             NOT NULL,
  dblGlobalLineCredit                 DECIMAL (18, 2) NOT NULL,
  dtmExpiration                       DATETIME        NOT NULL,
  strComment                          NVARCHAR(1000)  COLLATE Latin1_General_CI_AS NULL,
  ysnActive                           BIT             NULL,
  intConcurrencyId                    INT             NOT NULL,
  CONSTRAINT [PK_BorrowingFacilityId] PRIMARY KEY CLUSTERED ([intBorrowingFacilityId] ASC)
  WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) 
  ON [PRIMARY]
) ON [PRIMARY]
GO


ALTER TABLE [dbo].[tblCMBorrowingFacility]  WITH CHECK ADD  CONSTRAINT [FK_tblCMBorrowingFacility_tblCMBank] FOREIGN KEY([intBankId])
REFERENCES [dbo].[tblCMBank] ([intBankId])
GO
