CREATE TABLE [dbo].[ftfrmmst] (
    [ftfrm_cus_no]        CHAR (10)      NOT NULL,
    [ftfrm_farm_no]       CHAR (10)      NOT NULL,
    [ftfrm_field_no]      CHAR (10)      NOT NULL,
    [ftfrm_workord_date]  INT            NOT NULL,
    [ftfrm_loc_no]        CHAR (3)       NULL,
    [ftfrm_work_ord_no]   INT            NULL,
    [ftfrm_prod_grp]      CHAR (10)      NULL,
    [ftfrm_farm_desc]     CHAR (30)      NULL,
    [ftfrm_field_desc]    CHAR (30)      NULL,
    [ftfrm_acres]         DECIMAL (9, 2) NULL,
    [ftfrm_crop]          CHAR (15)      NULL,
    [ftfrm_split]         CHAR (4)       NULL,
    [ftfrm_applicator_no] CHAR (10)      NULL,
    [ftfrm_un_per_acre]   DECIMAL (9, 2) NULL,
    [ftfrm_analysis]      CHAR (20)      NULL,
    [ftfrm_batch_size]    INT            NULL,
    [ftfrm_no_batches]    SMALLINT       NULL,
    [ftfrm_comments]      CHAR (30)      NULL,
    [ftfrm_pests]         CHAR (45)      NULL,
    [ftfrm_user_id]       CHAR (16)      NULL,
    [ftfrm_user_rev_dt]   INT            NULL,
    [A4GLIdentity]        NUMERIC (9)    IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_ftfrmmst] PRIMARY KEY NONCLUSTERED ([ftfrm_cus_no] ASC, [ftfrm_farm_no] ASC, [ftfrm_field_no] ASC, [ftfrm_workord_date] ASC)
);




GO
CREATE UNIQUE CLUSTERED INDEX [Iftfrmmst0]
    ON [dbo].[ftfrmmst]([ftfrm_cus_no] ASC, [ftfrm_farm_no] ASC, [ftfrm_field_no] ASC, [ftfrm_workord_date] ASC);


GO
GRANT UPDATE
    ON OBJECT::[dbo].[ftfrmmst] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[ftfrmmst] TO PUBLIC
    AS [dbo];


GO
GRANT REFERENCES
    ON OBJECT::[dbo].[ftfrmmst] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[ftfrmmst] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[ftfrmmst] TO PUBLIC
    AS [dbo];

