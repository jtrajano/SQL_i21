CREATE TABLE [dbo].[aeitxmst] (
    [aeitx_itm_no]      CHAR (13)   NOT NULL,
    [aeitx_ae_itm_no]   BIGINT      NOT NULL,
    [aeitx_comments]    CHAR (30)   NULL,
    [aeitx_user_id]     CHAR (16)   NULL,
    [aeitx_user_rev_dt] INT         NULL,
    [A4GLIdentity]      NUMERIC (9) IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_aeitxmst] PRIMARY KEY NONCLUSTERED ([aeitx_itm_no] ASC)
);


GO
CREATE UNIQUE CLUSTERED INDEX [Iaeitxmst0]
    ON [dbo].[aeitxmst]([aeitx_itm_no] ASC);


GO
CREATE NONCLUSTERED INDEX [Iaeitxmst1]
    ON [dbo].[aeitxmst]([aeitx_ae_itm_no] ASC);

