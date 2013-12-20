CREATE TABLE [dbo].[slhscmst] (
    [slhsc_lead_id]       CHAR (10)   NOT NULL,
    [slhsc_loc_id]        CHAR (10)   NOT NULL,
    [slhsc_rev_dt]        INT         NOT NULL,
    [slhsc_hst_seq]       SMALLINT    NOT NULL,
    [slhsc_seq]           SMALLINT    NOT NULL,
    [slhsc_comment]       CHAR (70)   NULL,
    [slhsc_sec_access_yn] CHAR (1)    NULL,
    [slhsc_user_id]       CHAR (16)   NULL,
    [slhsc_user_rev_dt]   INT         NULL,
    [A4GLIdentity]        NUMERIC (9) IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_slhscmst] PRIMARY KEY NONCLUSTERED ([slhsc_lead_id] ASC, [slhsc_loc_id] ASC, [slhsc_rev_dt] ASC, [slhsc_hst_seq] ASC, [slhsc_seq] ASC)
);


GO
CREATE UNIQUE CLUSTERED INDEX [Islhscmst0]
    ON [dbo].[slhscmst]([slhsc_lead_id] ASC, [slhsc_loc_id] ASC, [slhsc_rev_dt] ASC, [slhsc_hst_seq] ASC, [slhsc_seq] ASC);

