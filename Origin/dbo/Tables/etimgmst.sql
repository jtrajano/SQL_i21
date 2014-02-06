CREATE TABLE [dbo].[etimgmst] (
    [etimg_mess_no]     INT         NOT NULL,
    [etimg_msg1]        CHAR (60)   NULL,
    [etimg_msg2]        CHAR (60)   NULL,
    [etimg_msg3]        CHAR (60)   NULL,
    [etimg_alt_mess_no] INT         NULL,
    [etimg_date_calc]   INT         NOT NULL,
    [etimg_time_calc]   INT         NOT NULL,
    [etimg_last_rev_dt] INT         NULL,
    [etimg_last_time]   INT         NULL,
    [A4GLIdentity]      NUMERIC (9) IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_etimgmst] PRIMARY KEY NONCLUSTERED ([etimg_mess_no] ASC)
);


GO
CREATE UNIQUE CLUSTERED INDEX [Ietimgmst0]
    ON [dbo].[etimgmst]([etimg_mess_no] ASC);


GO
CREATE NONCLUSTERED INDEX [Ietimgmst1]
    ON [dbo].[etimgmst]([etimg_date_calc] ASC, [etimg_time_calc] ASC);


GO
GRANT DELETE
    ON OBJECT::[dbo].[etimgmst] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[etimgmst] TO PUBLIC
    AS [dbo];


GO
GRANT REFERENCES
    ON OBJECT::[dbo].[etimgmst] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[etimgmst] TO PUBLIC
    AS [dbo];


GO
GRANT UPDATE
    ON OBJECT::[dbo].[etimgmst] TO PUBLIC
    AS [dbo];

