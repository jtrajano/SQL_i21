CREATE TABLE [dbo].[tblQMSampleStatus]
(
	[intSampleStatusId] INT NOT NULL IDENTITY, 
	[strStatus] NVARCHAR(30) COLLATE Latin1_General_CI_AS NOT NULL, 
	[strDescription] NVARCHAR(100) COLLATE Latin1_General_CI_AS NOT NULL, 
	[strSecondaryStatus] NVARCHAR(32) COLLATE Latin1_General_CI_AS, 
	[intSequence] INT, 

	CONSTRAINT [PK_tblQMSampleStatus] PRIMARY KEY ([intSampleStatusId]), 
	CONSTRAINT [AK_tblQMSampleStatus_strStatus] UNIQUE ([strStatus]) 
)