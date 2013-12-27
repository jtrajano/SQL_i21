CREATE TABLE [dbo].[galdcmst] (
    [galdc_loc_no]      CHAR (3)    NOT NULL,
    [galdc_load_no]     CHAR (8)    NOT NULL,
    [galdc_pur_sls_frt] CHAR (1)    NOT NULL,
    [galdc_seq_no]      TINYINT     NOT NULL,
    [galdc_comment]     CHAR (60)   NULL,
    [galdc_user_id]     CHAR (16)   NULL,
    [galdc_user_rev_dt] INT         NULL,
    [A4GLIdentity]      NUMERIC (9) IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_galdcmst] PRIMARY KEY NONCLUSTERED ([galdc_loc_no] ASC, [galdc_load_no] ASC, [galdc_pur_sls_frt] ASC, [galdc_seq_no] ASC)
);




GO
CREATE UNIQUE CLUSTERED INDEX [Igaldcmst0]
    ON [dbo].[galdcmst]([galdc_loc_no] ASC, [galdc_load_no] ASC, [galdc_pur_sls_frt] ASC, [galdc_seq_no] ASC);


GO
GRANT UPDATE
    ON OBJECT::[dbo].[galdcmst] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[galdcmst] TO PUBLIC
    AS [dbo];


GO
GRANT REFERENCES
    ON OBJECT::[dbo].[galdcmst] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[galdcmst] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[galdcmst] TO PUBLIC
    AS [dbo];

