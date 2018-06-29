CREATE TABLE [dbo].[tblLGIntrCompWeightClaimsStg]
(
	[intId] INT IDENTITY(1,1) PRIMARY KEY, 
	[intWeightClaimId] INT,
	[intLoadId] INT,
	[strWeightClaimNo] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
	[strWeightClaim] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL,
	[strWeightClaimDetail] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL,
	[strReference] NVARCHAR(512) COLLATE Latin1_General_CI_AS NULL,
	[strRowState] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
	[strFeedStatus] NVARCHAR(1024) COLLATE Latin1_General_CI_AS NULL,
	[dtmFeedDate] DATETIME DEFAULT(GETDATE()),
	[strMessage] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL,
	[intMultiCompanyId] INT,
	[intToCompanyLocationId] INT,
	[intToBookId] INT,
	[intReferenceId] INT,
	[intEntityId] INT,
	[strTransactionType] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL
)
