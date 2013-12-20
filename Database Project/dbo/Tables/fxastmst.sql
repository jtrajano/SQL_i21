CREATE TABLE [dbo].[fxastmst] (
    [fxast_div]                CHAR (2)        NOT NULL,
    [fxast_dept]               CHAR (3)        NOT NULL,
    [fxast_class]              CHAR (2)        NOT NULL,
    [fxast_id_no]              CHAR (6)        NOT NULL,
    [fxast_desc]               CHAR (50)       NOT NULL,
    [fxast_ser_no]             CHAR (25)       NULL,
    [fxast_comment]            CHAR (30)       NULL,
    [fxast_new_used_ind]       CHAR (1)        NULL,
    [fxast_acq_ccyymmdd]       INT             NULL,
    [fxast_cost]               DECIMAL (9, 2)  NULL,
    [fxast_mkt_val]            DECIMAL (9, 2)  NULL,
    [fxast_ins_val]            DECIMAL (9, 2)  NULL,
    [fxast_slvg_val]           DECIMAL (9, 2)  NULL,
    [fxast_life_yrs]           DECIMAL (3, 1)  NULL,
    [fxast_basis]              DECIMAL (9, 2)  NULL,
    [fxast_basis_desc]         CHAR (10)       NULL,
    [fxast_rt_key]             CHAR (8)        NULL,
    [fxast_beg_depr_ccyymm]    INT             NULL,
    [fxast_depr_ptd]           DECIMAL (9, 2)  NULL,
    [fxast_depr_ytd]           DECIMAL (9, 2)  NULL,
    [fxast_depr_ltd]           DECIMAL (9, 2)  NULL,
    [fxast_depr_new]           DECIMAL (9, 2)  NULL,
    [fxast_ace_ptd]            DECIMAL (9, 2)  NULL,
    [fxast_ace_ytd]            DECIMAL (9, 2)  NULL,
    [fxast_ace_ltd]            DECIMAL (9, 2)  NULL,
    [fxast_ace_new]            DECIMAL (9, 2)  NULL,
    [fxast_gl_depr]            DECIMAL (16, 8) NULL,
    [fxast_gl_exp]             DECIMAL (16, 8) NULL,
    [fxast_tx_basis]           DECIMAL (9, 2)  NULL,
    [fxast_tx_basis_desc]      CHAR (10)       NULL,
    [fxast_tx_rt_key]          CHAR (8)        NULL,
    [fxast_tx_beg_depr_ccyymm] INT             NULL,
    [fxast_tx_depr_ptd]        DECIMAL (9, 2)  NULL,
    [fxast_tx_depr_ytd]        DECIMAL (9, 2)  NULL,
    [fxast_tx_depr_ltd]        DECIMAL (9, 2)  NULL,
    [fxast_tx_depr_new]        DECIMAL (9, 2)  NULL,
    [fxast_tx_ace_ptd]         DECIMAL (9, 2)  NULL,
    [fxast_tx_ace_ytd]         DECIMAL (9, 2)  NULL,
    [fxast_tx_ace_ltd]         DECIMAL (9, 2)  NULL,
    [fxast_tx_ace_new]         DECIMAL (9, 2)  NULL,
    [fxast_dsp_ccyymmdd]       INT             NULL,
    [fxast_dsp_ref_no]         CHAR (25)       NULL,
    [fxast_dsp_comment]        CHAR (30)       NULL,
    [fxast_dsp_amt]            DECIMAL (9, 2)  NULL,
    [fxast_pool]               CHAR (4)        NULL,
    [fxast_user_id]            CHAR (16)       NULL,
    [fxast_user_rev_dt]        INT             NULL,
    [A4GLIdentity]             NUMERIC (9)     IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_fxastmst] PRIMARY KEY NONCLUSTERED ([fxast_div] ASC, [fxast_dept] ASC, [fxast_class] ASC, [fxast_id_no] ASC)
);


GO
CREATE UNIQUE CLUSTERED INDEX [Ifxastmst0]
    ON [dbo].[fxastmst]([fxast_div] ASC, [fxast_dept] ASC, [fxast_class] ASC, [fxast_id_no] ASC);


GO
CREATE NONCLUSTERED INDEX [Ifxastmst1]
    ON [dbo].[fxastmst]([fxast_desc] ASC);

