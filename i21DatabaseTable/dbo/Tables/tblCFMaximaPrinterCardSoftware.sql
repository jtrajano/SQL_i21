CREATE TABLE [dbo].[tblCFMaximaPrinterCardSoftware] (
    [Key]           INT            IDENTITY (1, 1) NOT NULL,
    [AcctName]      NVARCHAR (MAX) NOT NULL,
    [DispCardId]    NVARCHAR (MAX) NOT NULL,
    [Notation]      NVARCHAR (MAX) NOT NULL,
    [Exp]           NVARCHAR (MAX) NOT NULL,
    [CardType]      NVARCHAR (MAX) NOT NULL,
    [EncodeString]  NVARCHAR (MAX) NOT NULL,
    [EncodeString1] NVARCHAR (MAX) NOT NULL,
    [CardNo]        NVARCHAR (MAX) NOT NULL,
    CONSTRAINT [PK_tblCFMaximaPrinterCardSoftware] PRIMARY KEY CLUSTERED ([Key] ASC)
);

