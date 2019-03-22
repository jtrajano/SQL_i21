CREATE TABLE [dbo].[tblSMLetterUpload]
(
	[intLetterUploadId] INT NOT NULL IDENTITY , 
    [intLetterId] INT NOT NULL, 
    [strFileName] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL, 
    [strFileLocation] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NOT NULL, 
    [blbFile] VARBINARY(MAX) NULL, 
    [intConcurrencyId] INT NOT NULL, 
    CONSTRAINT [PK_tblSMLetterUpload] PRIMARY KEY ([intLetterUploadId]), 
    CONSTRAINT [FK_tblSMLetterUpload_tblSMLetter] FOREIGN KEY ([intLetterId]) REFERENCES [tblSMLetter]([intLetterId])
)
