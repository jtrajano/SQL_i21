CREATE TABLE [dbo].[tblSMReportLabelDetail]
(
	[intReportLabelDetailId] INT NOT NULL PRIMARY KEY IDENTITY, 
	[intReportLabelsId] INT NOT NULL, 
	[strLabelName] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL, 
    [strCustomLabel] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL, 
	[intConcurrencyId] INT NOT NULL DEFAULT 1, 
    CONSTRAINT [FK_tblSMReportLabelDetail_tblSMReportLabels] FOREIGN KEY ([intReportLabelsId]) REFERENCES [tblSMReportLabels]([intReportLabelsId]) ON DELETE CASCADE
)
