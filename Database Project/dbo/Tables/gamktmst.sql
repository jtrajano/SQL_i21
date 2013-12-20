CREATE TABLE [dbo].[gamktmst] (
    [gamkt_key]         CHAR (3)    NOT NULL,
    [gamkt_desc]        CHAR (20)   NULL,
    [gamkt_user_id]     CHAR (16)   NULL,
    [gamkt_user_rev_dt] INT         NULL,
    [A4GLIdentity]      NUMERIC (9) IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_gamktmst] PRIMARY KEY NONCLUSTERED ([gamkt_key] ASC)
);


GO
CREATE UNIQUE CLUSTERED INDEX [Igamktmst0]
    ON [dbo].[gamktmst]([gamkt_key] ASC);

