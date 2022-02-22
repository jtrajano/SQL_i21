CREATE TABLE [dbo].[tblCRMIndustrySegment]
(
	[intIndustrySegmentId] INT IDENTITY(1,1) NOT NULL,
	[strIndustrySegment] NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NOT NULL,
	[intConcurrencyId] [int] NOT NULL DEFAULT 1,
	CONSTRAINT [PK_tblCRMIndustrySegment] PRIMARY KEY CLUSTERED ([intIndustrySegmentId] ASC),
	CONSTRAINT [UQ_tblCRMIndustrySegment_strIndustrySegment] UNIQUE ([strIndustrySegment])
)
