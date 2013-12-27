CREATE TABLE [dbo].[agitgmst] (
    [agitg_itm_no]      CHAR (13)   NOT NULL,
    [agitg_loc_no]      CHAR (3)    NOT NULL,
    [agitg_comment_1]   CHAR (60)   NULL,
    [agitg_comment_2]   CHAR (60)   NULL,
    [agitg_comment_3]   CHAR (60)   NULL,
    [agitg_comment_4]   CHAR (60)   NULL,
    [agitg_comment_5]   CHAR (60)   NULL,
    [agitg_comment_6]   CHAR (60)   NULL,
    [agitg_comment_7]   CHAR (60)   NULL,
    [agitg_comment_8]   CHAR (60)   NULL,
    [agitg_comment_9]   CHAR (60)   NULL,
    [agitg_comment_10]  CHAR (60)   NULL,
    [agitg_comment_11]  CHAR (60)   NULL,
    [agitg_comment_12]  CHAR (60)   NULL,
    [agitg_comment_13]  CHAR (60)   NULL,
    [agitg_comment_14]  CHAR (60)   NULL,
    [agitg_comment_15]  CHAR (60)   NULL,
    [agitg_user_id]     CHAR (16)   NULL,
    [agitg_user_rev_dt] INT         NULL,
    [A4GLIdentity]      NUMERIC (9) IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_agitgmst] PRIMARY KEY NONCLUSTERED ([agitg_itm_no] ASC, [agitg_loc_no] ASC)
);




GO
CREATE UNIQUE CLUSTERED INDEX [Iagitgmst0]
    ON [dbo].[agitgmst]([agitg_itm_no] ASC, [agitg_loc_no] ASC);


GO
GRANT UPDATE
    ON OBJECT::[dbo].[agitgmst] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[agitgmst] TO PUBLIC
    AS [dbo];


GO
GRANT REFERENCES
    ON OBJECT::[dbo].[agitgmst] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[agitgmst] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[agitgmst] TO PUBLIC
    AS [dbo];

