CREATE TABLE [dbo].[glfsfmst] (
    [glfsf_no]                  SMALLINT    NOT NULL,
    [glfsf_line_no]             INT         NOT NULL,
    [glfsf_action_type]         CHAR (3)    NULL,
    [glfsf_action_crl]          CHAR (1)    NULL,
    [glfsf_stmt_type]           CHAR (1)    NULL,
    [glfsf_report_title]        CHAR (50)   NULL,
    [glfsf_dsc_description]     CHAR (50)   NULL,
    [glfsf_hdr_description]     CHAR (50)   NULL,
    [glfsf_ftr_description]     CHAR (50)   NULL,
    [glfsf_gra_desc]            CHAR (30)   NULL,
    [glfsf_gra_beg1_8]          INT         NULL,
    [glfsf_gra_end1_8]          INT         NULL,
    [glfsf_gra_sub9_16]         INT         NULL,
    [glfsf_grp_desc]            CHAR (30)   NULL,
    [glfsf_grp_accm_no]         TINYINT     NULL,
    [glfsf_grp_dc]              CHAR (1)    NULL,
    [glfsf_grp_dollarsign]      TINYINT     NULL,
    [glfsf_grp_beg1_8]          INT         NULL,
    [glfsf_grp_end1_8]          INT         NULL,
    [glfsf_grp_sub9_16]         INT         NULL,
    [glfsf_grp_printall_yn]     CHAR (1)    NULL,
    [glfsf_grp_loc_no]          TINYINT     NULL,
    [glfsf_grp_indent_desc]     TINYINT     NULL,
    [glfsf_grp_printallpc_yn]   CHAR (1)    NULL,
    [glfsf_grp_printallmain_yn] CHAR (1)    NULL,
    [glfsf_grp_var_dc]          CHAR (1)    NULL,
    [glfsf_aca_desc]            CHAR (30)   NULL,
    [glfsf_aca1_8]              INT         NULL,
    [glfsf_aca9_16]             INT         NULL,
    [glfsf_acp_desc]            CHAR (30)   NULL,
    [glfsf_acp_accm_no]         TINYINT     NULL,
    [glfsf_acp_dc]              CHAR (1)    NULL,
    [glfsf_acp_dollarsign]      TINYINT     NULL,
    [glfsf_acp1_8]              INT         NULL,
    [glfsf_acp9_16]             INT         NULL,
    [glfsf_acp_loc_no]          TINYINT     NULL,
    [glfsf_acp_var_dc]          CHAR (1)    NULL,
    [glfsf_prnt_desc]           CHAR (30)   NULL,
    [glfsf_prnt_accm_no]        TINYINT     NULL,
    [glfsf_prnt_dcr]            CHAR (1)    NULL,
    [glfsf_prnt_dollarsign]     TINYINT     NULL,
    [glfsf_prnt_loc_no]         TINYINT     NULL,
    [glfsf_prnt_var_dc]         CHAR (1)    NULL,
    [glfsf_accm_no]             TINYINT     NULL,
    [glfsf_accm_on_off]         TINYINT     NULL,
    [glfsf_accm_dc]             CHAR (1)    NULL,
    [glfsf_calc_loc_var_1]      TINYINT     NULL,
    [glfsf_calc_op]             CHAR (1)    NULL,
    [glfsf_calc_loc_var_2]      TINYINT     NULL,
    [glfsf_calc_pct]            TINYINT     NULL,
    [glfsf_tot_no]              TINYINT     NULL,
    [glfsf_tot_desc]            CHAR (30)   NULL,
    [glfsf_tot_prt_type]        CHAR (1)    NULL,
    [glfsf_tot_accm_no]         TINYINT     NULL,
    [glfsf_tot_dc]              CHAR (1)    NULL,
    [glfsf_tot_loc_no]          TINYINT     NULL,
    [glfsf_tot_dollarsign]      TINYINT     NULL,
    [glfsf_tot_force_units]     CHAR (1)    NULL,
    [glfsf_tot_var_dc]          CHAR (1)    NULL,
    [glfsf_clr_tot_no]          TINYINT     NULL,
    [glfsf_line_type]           CHAR (1)    NULL,
    [glfsf_dbl_type]            CHAR (1)    NULL,
    [glfsf_blnk_lines]          TINYINT     NULL,
    [glfsf_lgnd_filler]         CHAR (80)   NULL,
    [glfsf_net_sub9_16]         INT         NULL,
    [glfsf_savl_loc_no]         TINYINT     NULL,
    [glfsf_savl_clear]          TINYINT     NULL,
    [glfsf_user_id]             CHAR (16)   NULL,
    [glfsf_user_rev_dt]         INT         NULL,
    [A4GLIdentity]              NUMERIC (9) IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_glfsfmst] PRIMARY KEY NONCLUSTERED ([glfsf_no] ASC, [glfsf_line_no] ASC)
);




GO
CREATE UNIQUE CLUSTERED INDEX [Iglfsfmst0]
    ON [dbo].[glfsfmst]([glfsf_no] ASC, [glfsf_line_no] ASC);


GO
GRANT UPDATE
    ON OBJECT::[dbo].[glfsfmst] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[glfsfmst] TO PUBLIC
    AS [dbo];


GO
GRANT REFERENCES
    ON OBJECT::[dbo].[glfsfmst] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[glfsfmst] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[glfsfmst] TO PUBLIC
    AS [dbo];

