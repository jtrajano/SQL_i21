CREATE TABLE [dbo].[tblCFEncodingPrinterSoftware] (
    [intKeyId]      INT            IDENTITY (1, 1) NOT NULL,
    [AcctName]      NVARCHAR (MAX) NOT NULL,
    [DispCardId]    NVARCHAR (MAX) NOT NULL,
    [Notation]      NVARCHAR (MAX) NOT NULL,
    [Exp]           NVARCHAR (MAX) NOT NULL,
    --[CardType]      NVARCHAR (MAX) NOT NULL,
    [EncodeTrack2]  NVARCHAR (MAX) NOT NULL,
    [EncodeTrack1]  NVARCHAR (MAX) NOT NULL,
    --[CardNo]        NVARCHAR (MAX) NOT NULL,
    CONSTRAINT [PK_tblCFEncodingPrinterSoftware] PRIMARY KEY CLUSTERED (intKeyId ASC)
);

