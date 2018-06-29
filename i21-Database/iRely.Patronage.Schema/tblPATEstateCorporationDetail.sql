CREATE TABLE [dbo].[tblPATEstateCorporationDetail]
(
	[intEstateCorporationDetailId] INT NOT NULL IDENTITY, 
    [intEstateCorporationId] INT NOT NULL, 
	[intCustomerId] INT NULL, 
    [dblOwnerPercentage] NUMERIC(18, 6) NOT NULL DEFAULT 0, 
	[ysnPaid] BIT NULL DEFAULT(0),
    [dtmPaidDate] DATETIME NULL, 
    [dblPaidAmount] NUMERIC(18, 6) NOT NULL DEFAULT 0, 
    [strPaidCheckNo] CHAR(8) COLLATE Latin1_General_CI_AS  NULL, 
    [dtmBirthDate] DATETIME NULL, 
	[intConcurrencyId] INT NULL DEFAULT 0

    CONSTRAINT [PK_tblPATEstateCorporationDetail] PRIMARY KEY ([intEstateCorporationDetailId]), 
    CONSTRAINT [FK_tblPATEstateCorporationDetail_tblPATEstateCorporation] FOREIGN KEY ([intEstateCorporationId]) REFERENCES [tblPATEstateCorporation]([intEstateCorporationId]) ON DELETE CASCADE
)
