CREATE TABLE [dbo].[tblQMTest]
(
	[intTestId] INT NOT NULL IDENTITY, 
	[intAnalysisTypeId] INT NOT NULL, 
	[intConcurrencyId] INT NULL CONSTRAINT [DF_tblQMTest_intConcurrencyId] DEFAULT 0, 
	[strTestName] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL, 
	[strDescription] NVARCHAR(100) COLLATE Latin1_General_CI_AS NOT NULL, 
	[strTestMethod] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
	[strIndustryStandards] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
	[intReplications] INT NOT NULL CONSTRAINT [DF_tblQMTest_intReplications] DEFAULT 1, 
	[strSensComments] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL, 
	[ysnAutoCapture] BIT NOT NULL CONSTRAINT [DF_tblQMTest_ysnAutoCapture] DEFAULT 0, 
	[ysnIgnoreSubSample] BIT NOT NULL CONSTRAINT [DF_tblQMTest_ysnIgnoreSubSample] DEFAULT 0, 
	[ysnActive] BIT NOT NULL CONSTRAINT [DF_tblQMTest_ysnActive] DEFAULT 1, 
	
	[intCreatedUserId] [int] NULL,
	[dtmCreated] [datetime] NULL CONSTRAINT [DF_tblQMTest_dtmCreated] DEFAULT GetDate(),
	[intLastModifiedUserId] [int] NULL,
	[dtmLastModified] [datetime] NULL CONSTRAINT [DF_tblQMTest_dtmLastModified] DEFAULT GetDate(),
		
	CONSTRAINT [PK_tblQMTest] PRIMARY KEY ([intTestId]), 
	CONSTRAINT [AK_tblQMTest_strTestName] UNIQUE ([strTestName]), 
	CONSTRAINT [FK_tblQMTest_tblQMAnalysisType] FOREIGN KEY ([intAnalysisTypeId]) REFERENCES [tblQMAnalysisType]([intAnalysisTypeId]) 
)