CREATE TABLE [dbo].[tblTMReadingSourceType]
(
    [intReadingSourceTypeId] INT IDENTITY(1,1) NOT NULL,
    [strReadingSourceType] NVARCHAR(70) COLLATE Latin1_General_CI_AS NULL,
    [intConcurrencyId] INT NOT NULL DEFAULT(0),
    [ysnDefault] BIT DEFAULT 0 NOT NULL,
    CONSTRAINT [PK_dbo.tblTMReadingSourceType_intReadingSourceTypeId] PRIMARY KEY CLUSTERED ([intReadingSourceTypeId] ASC)
)






