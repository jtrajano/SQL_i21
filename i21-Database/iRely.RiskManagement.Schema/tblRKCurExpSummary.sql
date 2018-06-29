CREATE TABLE [dbo].[tblRKCurExpSummary]
(
	[intCurExpSummaryId] INT IDENTITY(1,1) NOT NULL,	
	[intConcurrencyId] INT NOT NULL, 
	[intCurrencyExposureId] INT NOT NULL, 	
	[strTotalSum] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL,
	[dblUSD]  NUMERIC(24, 6) NOT NULL,		

	CONSTRAINT [PK_tblRKCurExpSummary_intCurExpSummaryId] PRIMARY KEY (intCurExpSummaryId),   
	CONSTRAINT [FK_tblRKCurExpSummary_tblRKCurrencyExposure_intCurrencyExposureId] FOREIGN KEY([intCurrencyExposureId])REFERENCES [dbo].[tblRKCurrencyExposure] (intCurrencyExposureId) ON DELETE CASCADE
	
)