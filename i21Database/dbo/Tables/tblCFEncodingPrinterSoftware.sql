CREATE TABLE [dbo].[tblCFEncodingPrinterSoftware] (
    [intKeyId]      INT            IDENTITY (1, 1) NOT NULL,
    [AcctName]      NVARCHAR (100) COLLATE Latin1_General_CI_AS NOT NULL,
    [DispCardId]    NVARCHAR (100) COLLATE Latin1_General_CI_AS NOT NULL,
    [Notation]      NVARCHAR (100) COLLATE Latin1_General_CI_AS NOT NULL,
    [Exp]           NVARCHAR (100) COLLATE Latin1_General_CI_AS NOT NULL,
    --[CardType]      NVARCHAR (MAX) NOT NULL,
    [EncodeTrack2]  NVARCHAR (100) COLLATE Latin1_General_CI_AS NOT NULL,
    [EncodeTrack1]  NVARCHAR (100) COLLATE Latin1_General_CI_AS NOT NULL,
    --[CardNo]        NVARCHAR (MAX) NOT NULL,
    CONSTRAINT [PK_tblCFEncodingPrinterSoftware] PRIMARY KEY CLUSTERED (intKeyId ASC)
);

