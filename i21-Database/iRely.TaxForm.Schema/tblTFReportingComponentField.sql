CREATE TABLE [dbo].[tblTFReportingComponentField](
	[intReportingComponentFieldId] [int] IDENTITY(1,1) NOT NULL,
	[intReportingComponentId] [int] NULL,
	[strColumn] [nvarchar](200) COLLATE Latin1_General_CI_AS NULL,
	[strCaption] [nvarchar](200) COLLATE Latin1_General_CI_AS NULL,
	[strFormat] [nvarchar](50) COLLATE Latin1_General_CI_AS NULL,
	[strFooter] [nvarchar](50) COLLATE Latin1_General_CI_AS NULL,
	[intWidth] [int] NULL,
	[intMasterId] INT NULL,
	[ysnFromConfiguration] BIT DEFAULT((0)) NULL,
	[intConcurrencyId] [int] DEFAULT ((1)) NULL,
	CONSTRAINT [PK_tblTFReportingComponentField] PRIMARY KEY ([intReportingComponentFieldId] ASC),
	CONSTRAINT [FK_tblTFReportingComponentField_tblTFReportingComponent] FOREIGN KEY([intReportingComponentId]) REFERENCES [dbo].[tblTFReportingComponent] ([intReportingComponentId]) ON DELETE CASCADE, 
    CONSTRAINT [UK_tblTFReportingComponentField_ComponentColumnCaption] UNIQUE ([intReportingComponentId],[strColumn],[strCaption]) 
)