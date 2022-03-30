CREATE TABLE [dbo].[tblQMSamplingCriteria]
(
	[intSamplingCriteriaId] INT IDENTITY (1, 1) NOT NULL,
	[intConcurrencyId] INT NULL DEFAULT ((1)),
	[strSamplingCriteria] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL,

	CONSTRAINT [PK_tblQMSamplingCriteria] PRIMARY KEY ([intSamplingCriteriaId]),
	CONSTRAINT [AK_tblQMSamplingCriteria_strSamplingCriteria] UNIQUE ([strSamplingCriteria])
)