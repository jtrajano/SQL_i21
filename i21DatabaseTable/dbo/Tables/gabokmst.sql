CREATE TABLE [dbo].[gabokmst] (
    [gabok_pur_sls_ind]   CHAR (1)        NOT NULL,
    [gabok_ag_ga_ind]     CHAR (1)        NOT NULL,
    [gabok_com_cd]        CHAR (3)        NOT NULL,
    [gabok_itm_no]        CHAR (13)       NOT NULL,
    [gabok_cus_no]        CHAR (10)       NOT NULL,
    [gabok_seq_no]        INT             NOT NULL,
    [gabok_ship_to]       CHAR (4)        NULL,
    [gabok_needed_un]     DECIMAL (11, 3) NULL,
    [gabok_needed_rev_dt] INT             NULL,
    [gabok_comment_1]     CHAR (30)       NULL,
    [gabok_comment_2]     CHAR (30)       NULL,
    [gabok_user_id]       CHAR (16)       NULL,
    [gabok_user_rev_dt]   INT             NULL,
    [A4GLIdentity]        NUMERIC (9)     IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_gabokmst] PRIMARY KEY NONCLUSTERED ([gabok_pur_sls_ind] ASC, [gabok_ag_ga_ind] ASC, [gabok_com_cd] ASC, [gabok_itm_no] ASC, [gabok_cus_no] ASC, [gabok_seq_no] ASC)
);


GO
CREATE UNIQUE CLUSTERED INDEX [Igabokmst0]
    ON [dbo].[gabokmst]([gabok_pur_sls_ind] ASC, [gabok_ag_ga_ind] ASC, [gabok_com_cd] ASC, [gabok_itm_no] ASC, [gabok_cus_no] ASC, [gabok_seq_no] ASC);


GO
CREATE NONCLUSTERED INDEX [Igabokmst1]
    ON [dbo].[gabokmst]([gabok_cus_no] ASC);

