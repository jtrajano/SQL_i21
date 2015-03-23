CREATE TABLE [dbo].[tblTMFillMethod] (
    [intConcurrencyId] INT           DEFAULT 1 NOT NULL,
    [intFillMethodId]  INT           IDENTITY (1, 1) NOT NULL,
    [strFillMethod]    NVARCHAR (50) COLLATE Latin1_General_CI_AS DEFAULT ('') NOT NULL,
    [ysnDefault]       BIT           DEFAULT 0 NOT NULL,
    CONSTRAINT [PK_tblTMFillMethod] PRIMARY KEY CLUSTERED ([intFillMethodId] ASC),
	CONSTRAINT [UQ_tblTMFillMethod_strFillMethod] UNIQUE NONCLUSTERED ([strFillMethod] ASC)
);


GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Check',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMFillMethod',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMFillMethod',
    @level2type = N'COLUMN',
    @level2name = N'intFillMethodId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Fill Method',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMFillMethod',
    @level2type = N'COLUMN',
    @level2name = N'strFillMethod'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Indicates if default data',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMFillMethod',
    @level2type = N'COLUMN',
    @level2name = N'ysnDefault'