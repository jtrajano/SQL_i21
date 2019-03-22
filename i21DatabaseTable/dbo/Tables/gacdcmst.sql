CREATE TABLE [dbo].[gacdcmst] (
    [gacdc_com_cd]         CHAR (3)    NOT NULL,
    [gacdc_cd]             CHAR (2)    NOT NULL,
    [gacdc_desc]           CHAR (20)   NULL,
    [gacdc_qlty_yn]        CHAR (1)    NULL,
    [gacdc_pur_gl_acct_no] INT         NULL,
    [gacdc_sls_gl_acct_no] INT         NULL,
    [gacdc_drying_yn]      CHAR (1)    NULL,
    [gacdc_user_id]        CHAR (16)   NULL,
    [gacdc_user_rev_dt]    INT         NULL,
    [A4GLIdentity]         NUMERIC (9) IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_gacdcmst] PRIMARY KEY NONCLUSTERED ([gacdc_com_cd] ASC, [gacdc_cd] ASC)
);


GO
CREATE UNIQUE CLUSTERED INDEX [Igacdcmst0]
    ON [dbo].[gacdcmst]([gacdc_com_cd] ASC, [gacdc_cd] ASC);

