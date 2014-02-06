CREATE TABLE [dbo].[agtagmst] (
    [agtag_tag_no]      CHAR (8)    NOT NULL,
    [agtag_seq_no]      SMALLINT    NOT NULL,
    [agtag_desc]        CHAR (30)   NULL,
    [agtag_comment]     CHAR (70)   NULL,
    [agtag_hazmat_yn]   CHAR (1)    NULL,
    [agtag_user_id]     CHAR (16)   NULL,
    [agtag_user_rev_dt] INT         NULL,
    [A4GLIdentity]      NUMERIC (9) IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_agtagmst] PRIMARY KEY NONCLUSTERED ([agtag_tag_no] ASC, [agtag_seq_no] ASC)
);


GO
CREATE UNIQUE CLUSTERED INDEX [Iagtagmst0]
    ON [dbo].[agtagmst]([agtag_tag_no] ASC, [agtag_seq_no] ASC);

