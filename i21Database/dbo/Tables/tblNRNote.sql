CREATE TABLE [dbo].[tblNRNote]
(
		[intNoteId] [int] IDENTITY(1,1) NOT NULL,
	[strNoteNumber] [nvarchar](10) COLLATE Latin1_General_CI_AS NOT NULL,
	[intCustomerId] INT NOT NULL,
	[strNoteType] [nvarchar](50) COLLATE Latin1_General_CI_AS NOT NULL,
	[intDescriptionId] [int] NOT NULL,
	[dblCreditLimit] [numeric](18, 6) NOT NULL,
	[dtmMaturityDate] [datetime] NOT NULL,
	[dblInterestRate] [numeric](18, 6) NOT NULL,
	[dblNotePrincipal] [numeric](18, 6) NULL,
	[ysnWriteOff] [bit] NULL,
	[dtmWriteOffDate] [datetime] NULL,
	[strSchdDescription] NVARCHAR(255) COLLATE Latin1_General_CI_AS NULL, 
    [ysnSchdForcePayment] BIT NULL, 
    [dblSchdForcePaymentAmt] NUMERIC(18, 6) NULL, 
    [intSchdInterval] INT NULL, 
    [intSchdMonthFreq] INT NULL, 
    [intSchdYearFreq] INT NULL, 
    [dtmSchdStartDate] DATETIME NULL, 
    [dtmSchdEndDate] DATETIME NULL, 
    [dblSchdLateFee] NUMERIC(18, 6) NULL, 
    [strSchdLateFeeUnit] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [strSchdLateAppliedOn] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [intSchdGracePeriod] INT NULL, 
	[strUCCFileRefNo] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [dtmUCCFiledOn] DATETIME NULL, 
    [dtmUCCLastRenewalOn] DATETIME NULL, 
    [dtmUCCReleasedOn] DATETIME NULL, 
    [strUCCComment] NVARCHAR(255) COLLATE Latin1_General_CI_AS NULL, 
	[intCreatedUserId] [int] NULL,
	[dtmCreated] [datetime] NULL,
	[intLastModifiedUserId] [int] NULL,
	[dtmLastModified] [datetime] NULL,
	[intConcurrencyId] [int] NULL,

 CONSTRAINT [PK_tblNRNote_intNoteId] PRIMARY KEY CLUSTERED 
(
	[intNoteId] ASC
) ON [PRIMARY],
CONSTRAINT [FK_tblNRNote_tblNRNoteDescription_intDescriptionId] FOREIGN KEY([intDescriptionId])
REFERENCES [tblNRNoteDescription] ([intDescriptionId]), 
    CONSTRAINT [UK_tblNRNote_strNoteNumber] UNIQUE ([strNoteNumber]) 
) ON [PRIMARY]